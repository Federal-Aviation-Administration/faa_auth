class Object

  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end

  def present?
    !blank?
  end


  def presence
    self if present?
  end
end

module FaaAuth

  class Client

    include FaaAuth::CommonExtension
    include FaaAuth::SessionExtension


    attr_accessor :options


    def initialize(options = {})
      @options = default_options.merge(options)
      @driver = options.fetch(:driver, :selenium)
      # Check credentials
      raise('FAA_USERNAME_CODE is required.') unless (options[:login] || ENV['FAA_USERNAME_CODE']).present?
      raise('FAA_PASSWORD_CODE is required.') unless (options[:password] || ENV['FAA_PASSWORD_CODE']).present?
      Converter.salt if options[:login].blank? || options[:password].blank?

      Capybara.save_path = options.fetch(:save_path, 'tmp') if Capybara.save_path.nil?
      Capybara.app_host = initial_url if Capybara.app_host.nil?
    rescue => e
      puts "Please setup credentials of faa_auth gem by following its instruction."
      raise e
    end

    def default_options
      {keep_cookie: true, debug: true}
    end

    def session
      @session ||= Capybara::Session.new(@driver)
    end

    # Hide instance variables of credentials on console
    def inspect
      to_s
    end

    def current_path
      session.current_path
    end

  end
end
