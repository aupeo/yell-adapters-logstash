module Yell
  module Adapters
    module Logstash
      # Filter class to be used with Rails ActionController
      # Use as a before_action to enable collection of more/custom data fields
      class ControllerFilters
        # Filter entry point (for before_action)
        # @param controller[ActionController::Base]
        def self.before(controller)
          if controller.respond_to?(:yell_adapter_logstash_fields)
            Thread.current[:yell_adapter_logstash_fields] = controller.send(:yell_adapter_logstash_fields, controller)
          else
            Thread.current[:yell_adapter_logstash_fields] = self.yell_adapter_logstash_fields(controller)
          end

          if controller.respond_to?(:yell_adapter_logstash_tags)
            Thread.current[:yell_adapter_logstash_tags] = controller.send(:yell_adapter_logstash_tags, controller)
          else
            Thread.current[:yell_adapter_logstash_tags] = self.yell_adapter_logstash_tags(controller)
          end
        end

        private
        # Default hash of fields to be collected
        # @param controller[ActionController::Base]
        # @return [Hash<String,String>]
        def self.yell_adapter_logstash_fields(controller)
          {
              'controller' => controller.class.name,
              'action' => controller.action_name,
              'params' => controller.request.filtered_parameters.inspect,
              'ip' => controller.request.ip,
              'remote_ip' => controller.request.remote_ip,
              'format' => controller.request.format.try(:ref),
              'method' => controller.request.method,
              'path' => (controller.request.fullpath rescue "unknown")
          }
        end
        # Default hash of tags to be collected
        # @param controller[ActionController::Base]
        # @return [Hash<String,String>]
        def self.yell_adapter_logstash_tags(controller)
          {
              'request_uuid' => controller.request.uuid
          }
        end

      end
    end
  end
end