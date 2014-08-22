module Yell
  module Adapters
    module Logstash
      # Filter class to be used with Rails ActionController
      # Use as a before_action to enable collection of more/custom data fields
      class ControllerFilters

        # reset all custom data
        def self.reset
          # Make sure we re-initialize to empty hashes, as some app servers 'reuse' threads
          logstash_fields.clear
          logstash_tags.clear
        end

        def self.logstash_fields
          Thread.current[:yell_adapter_logstash_fields] ||= {}
        end

        def self.logstash_tags
          Thread.current[:yell_adapter_logstash_tags] ||= {}
        end

        def self.merge_fields(fields)
          logstash_fields.merge!( fields )
        end

        def self.merge_tags(tags)
          logstash_tags.merge!( tags )
        end

        # Filter entry point (for before_action)
        # @param controller[ActionController::Base]
        def self.before(controller)
          # Make sure we re-initialize to empty hashes, as some app servers 'reuse' threads
          #reset
          fields = controller.respond_to?(:yell_adapter_logstash_fields_before) ?
            controller.send(:yell_adapter_logstash_fields_before, controller) :
            self.yell_adapter_logstash_fields_before(controller)
          merge_fields(fields)

          merge_tags(
              controller.respond_to?(:yell_adapter_logstash_tags_before) ?
                  controller.send(:yell_adapter_logstash_tags_before, controller) :
                  self.yell_adapter_logstash_tags_before(controller)
          )
        end
        # Filter entry point (for after_action)
        # @param controller[ActionController::Base]
        def self.after(controller)
          merge_fields(
              controller.respond_to?(:yell_adapter_logstash_fields_after) ?
                  controller.send(:yell_adapter_logstash_fields_after, controller) :
                  self.yell_adapter_logstash_fields_after(controller)
          )

          merge_tags(
              controller.respond_to?(:yell_adapter_logstash_tags_after) ?
                  controller.send(:yell_adapter_logstash_tags_after, controller) :
                  self.yell_adapter_logstash_tags_after(controller)
          )
        end
        private
        # Default hash of fields to be collected
        # @param controller[ActionController::Base]
        # @return [Hash<String,String>]
        def self.yell_adapter_logstash_fields_before(controller)
          {
              'controller' => controller.class.name,
              'action' => controller.action_name,
              'params' => controller.request.filtered_parameters.inspect,
              'ip' => controller.request.ip,
              'remote_ip' => controller.request.remote_ip,
              'format' => controller.request.format.try(:ref),
              'method' => controller.request.method,
              'path' => (controller.request.path rescue "unknown")
          }
        end
        # Default hash of tags to be collected
        # @param controller[ActionController::Base]
        # @return [Hash<String,String>]
        def self.yell_adapter_logstash_tags_before(controller)
          {
              'request_uuid' => controller.request.uuid
          }
        end
        # Default hash of fields to be collected
        # @param controller[ActionController::Base]
        # @return [Hash<String,String>]
        def self.yell_adapter_logstash_fields_after(controller)
          {
              'redirect_to' => controller.response.location
          }
        end
        # Default hash of tags to be collected
        # @param controller[ActionController::Base]
        # @return [Hash<String,String>]
        def self.yell_adapter_logstash_tags_after(controller)
          {
              'status' => controller.response.status
          }
        end

      end
    end
  end
end