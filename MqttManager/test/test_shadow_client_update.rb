$LOAD_PATH << '~/Iot_raspberry_pi/MqttManager/'

require "shadow_client"

rootCAPath = "/Users/Pierre/certs/root-CA.crt"
privateKeyPath = "/Users/Pierre/certs/private.pem.key"
certificatePath = "/Users/Pierre/certs/certificate.pem.crt"

host = "a2perapdhhaey0.iot.ap-northeast-1.amazonaws.com"
port = 8883

myShadowClient = ShadowClient.new
myShadowClient.configureEndpoint(host, port)
myShadowClient.configureCredentials(rootCAPath, privateKeyPath, certificatePath)

myShadowClient.connect

cli = myShadowClient.createShadowHandlerWithName("TestThing",false)

filter_callback = Proc.new do |message|
  puts "Executing the specific callback for topic: #{message.topic}\n##########################################\n"
end

n = 1
3.times do
  puts "This is turn #{n} shadow_update\n"
  json_payload = "{\"state\":{\"desired\":{\"property\":\"RubySDK\",\"count\":#{n}}}}"
  cli.shadow_update(json_payload, filter_callback, 5)
  n += 1
end

sleep 2
myShadowClient.disconnect
