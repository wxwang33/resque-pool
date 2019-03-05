require 'mono_logger'

module Resque
  class Pool
    class LoggerBuilder
      def initialize(opts = {})
        @quiet = !!opts[:quiet]
        @verbose = !!opts[:verbose]
        @log_dev = opts[:log_dev] || $stdout
        @format = opts[:format] || 'text'
      end
      
      def build
        logger = MonoLogger.new(@log_dev)
        logger.level = level
        logger.formatter = send(:"#{@format}_formatter")
        logger
      end

      private

      def level
        if @verbose && !@quiet
          MonoLogger::DEBUG
        elsif !@quiet
          MonoLogger::INFO
        else
          MonoLogger::FATAL
        end
      end

      def text_formatter
        proc do |severity, datetime, _progname, msg|
          "resque-pool: [#{severity}] #{datetime.strftime('%FT%T.%6N')}: #{msg}\n"
        end
      end

      def json_formatter
        proc do |severity, datetime, progname, msg|
          require 'json'
          JSON.dump(
            name: 'resque-pool',
            level: severity,
            timestamp: datetime.strftime('%FT%T.%6N'),
            pid: Process.pid,
            msg: msg
          ) + "\n"
        end
      end
    end
  end
end
