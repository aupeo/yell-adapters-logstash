# encoding: utf-8
require 'logstash-event'
require 'yell'

module Yell
  module Adapters

    module Logstash

      class FileLogger < Yell::Adapters::Base

        MAX_EVENTS = 1000 # truncate file after so many

        attr_accessor :sync

        private

        setup do |options|
          @stream = nil

          self.sync = Yell.__fetch__(options, :sync, :default => true)
          @filename = ::File.expand_path(Yell.__fetch__(options, :filename, :default => default_filename))
          @event_count = 0
        end

        open do
          @stream = ::File.open(@filename, ::File::WRONLY|::File::APPEND|::File::CREAT)

          @stream.sync = self.sync if @stream.respond_to?(:sync)
          @stream.flush if @stream.respond_to?(:flush)

        end

        close do
          @stream.close if @stream.respond_to?(:close)
          @stream = nil

        end

        write do |event|

          if @event_count > MAX_EVENTS
            @stream.truncate(0)
            @event_count = 0
          end


          fields = format({
              'severity' => case event.level
                          when Integer then Yell::Severities[event.level] || 'ANY'
                          else event.level
                        end,
              'hostname' => event.hostname,
              'progname' => event.progname,
              'pid' => event.pid,
              'thread_id' => event.thread_id,
              '_file' => event.file,
              '_filename' => ::File.basename(event.file),
              '_line' => event.line,
              '_method' => event.method,
              'logger' => event.name,
              'timestamp' => event.time
          }, *event.messages)

          tags = {
              'environment' => Yell.env,
              'severity' => fields['severity']
          }

          scope_fields = Thread.current[:yell_adapter_logstash_fields]
          if  scope_fields && scope_fields.is_a?(Hash)
            fields.merge!(scope_fields)
          end

          scope_tags = Thread.current[:yell_adapter_logstash_tags]
          if  scope_tags && scope_tags.is_a?(Hash)
            tags.merge!(scope_tags)
          end

          le = ::LogStash::Event.new(
              '@version' => 1,
              '@timestamp' => fields['timestamp'],
              'fields' => fields,
              'tags' => tags
          )
          stream.syswrite(%Q(#{le.to_json}\n))
          @event_count  += 1
        end

        def format(*messages)
          messages.inject(Hash.new) do |result, m|
            result.merge to_message(m)
          end
        end

        def to_message(message)
          case message
            when Hash then message
            when Array then { 'message' => message.join("\n") }
            when Exception then { 'message' => %Q(#{message.class}: #{message.message}) }.tap do |m|
                m.merge!({ 'backtrace' => message.backtrace.join("\n") }) if message.backtrace
              end
            else { 'message' => message.to_s }
          end
        end

        def default_filename
          logdir = ::File.expand_path("log")

          ::File.expand_path(::File.directory?(logdir) ? "#{logdir}/logstash_#{Yell.env}.log" : "logstash_#{Yell.env}.log")
        end

        def stream
          synchronize { open! if @stream.nil?; @stream }
        end

      end

    end

    register( :logstash_file, Yell::Adapters::Logstash::FileLogger )

  end
end