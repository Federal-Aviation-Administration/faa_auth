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
      @sign_in_selector = options.fetch(:sign_in_selector){ 'Sign In'}
      @options = default_options.merge(options)
      @driver = options.fetch(:driver, :cuprite)
      # Check credentials
      raise('FAA_USERNAME_CODE is required.') unless (options[:login] || ENV['FAA_USERNAME_CODE']).present?
      raise('FAA_ACCESS_PIN is required.') unless (options[:password] || ENV['FAA_ACCESS_PIN']).present?
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

    def get(url)
      session.visit(url)
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
