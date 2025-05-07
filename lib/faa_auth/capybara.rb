require "capybara/cuprite"


Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :firefox do |app|
  Capybara::Selenium::Driver.new(app, browser: :firefox)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: {args: %w[headless disable-gpu]}
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

module FerrumOptions
  def ferrum_options(options: {}, browser_options: {})
    opts = {process_timeout: 120,
            timeout: 40,
            headless: false}.merge(options)
    b_options = {}
    b_options["no-sandbox"] = nil if options[:headless] == true
    b_options.merge(browser_options)
    opts["browser_options"] = b_options
    opts
  end
end


Capybara.register_driver(:cuprite) do |app|
  options = {
    window_size: [1200, 800],
    browser_options: {},
    process_timeout: 20,
    inspector: true,
    headless: ENV.fetch("HEADLESS", false)
  }
  browser_options = {}
  browser_options["no-sandbox"] = nil if options[:headless] == true
  options["browser_options"] = browser_options
  Capybara::Cuprite::Driver.new(app, options)
end


Capybara.default_driver = Capybara.javascript_driver = :cuprite
