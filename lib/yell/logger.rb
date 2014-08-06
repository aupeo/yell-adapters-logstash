
unless (Yell::Logger.public_instance_method(:<<) rescue nil)

  module Yell
    class Logger
      def << (msg)
        unknown(msg)
      end
    end
  end

end
