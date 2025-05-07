module FaaAuth
  module CommonExtension
    def log(message)
      return unless @options[:debug] || @options[:verbose]
      puts "[#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}] #{message}" +
        ((@options[:debug] && @session) ? " -- #{session.current_url}" : "")
    end

    def debug(message)
      return unless @options[:debug]
      log(message)
    end
  end
end
