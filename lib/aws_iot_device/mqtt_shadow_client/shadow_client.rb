require 'aws_iot_device/mqtt_shadow_client/mqtt_manager'
require 'aws_iot_device/mqtt_shadow_client/shadow_topic_manager'
require 'aws_iot_device/mqtt_shadow_client/shadow_action_manager'

module AwsIotDevice
  module MqttShadowClient
    class ShadowClient
      attr_accessor :action_manager

      def initialize(*args)
        @mqtt_client = MqttManager.new(*args)
      end

      def connect(*args, &block)
        @mqtt_client.connect(*args)
        if block_given?
          begin
            yield(self)
          ensure
            @mqtt_client.disconnect
          end
        end
      end

      def topic_manager(shadow_name)
        @topic_manager = ShadowTopicManager.new(@mqtt_client, shadow_name)
      end

      def create_shadow_handler_with_name(shadow_name, is_persistent_subscribe=false)
        topic_manager(shadow_name)
        @action_manager = ShadowActionManager.new(shadow_name, @topic_manager, is_persistent_subscribe)
      end

      def get_shadow(timeout=5, callback=nil, &block)
        @action_manager.shadow_get(timeout, callback, &block)
      end

      def update_shadow(payload, timeout=5, callback=nil, &block)
        @action_manager.shadow_update(payload, timeout, callback, &block)
      end

      def delete_shadow(timeout=5, callback=nil, &block)
        @action_manager.shadow_delete(timeout, callback, &block)
      end

      def register_get_callback(callback, &block)
        @action_manager.register_get_callback(callback, &block)
      end

      def register_update_callback(callback, &block)
        @action_manager.register_update_callback(callback, &block)
      end

      def register_delete_callback(callback, &block)
        @action_manager.register_delete_callback(callback, &block)
      end

      def register_delta_callback(callback)
        @action_manager.register_shadow_delta_callback(callback)
      end

      def remove_delta_callback
        @action_manager.remove_shadow_delta_callback
      end

      def remove_get_callback
        @action_manager.remove_get_callback
      end

      def remove_update_callback
        @action_manager.remove_update_callback
      end

      def remove_delete_callback
        @action_manager.remove_delete_callback
      end

      def disconnect
        @mqtt_client.disconnect
      end

      def configure_endpoint(host, port)
        @mqtt_client.config_endpoint(host,port)
      end

      def configure_credentials(ca_file, key, cert)
        @mqtt_client.config_ssl_context(ca_file, key, cert)
      end
    end
  end
end
