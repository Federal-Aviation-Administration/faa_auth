require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "ferrum"
  gem "mechanize"
  gem "debug"
  gem "nokogiri"
  gem "solargraph"
  gem "standard"
  gem "httpx"
  gem "json"
end


def which(cmd)
  exts = ENV["PATHEXT"] ? ENV["PATHEXT"].split(";") : [""]
  ENV["PATH"].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    end
  end
  nil
end

ENV["BROWSER_PATH"] ||= which("chrome") || which("chromium") || which("firefox")

require "ferrum"
require "nokogiri"
require "json"

module Ferrum
  class Browser
    # wait until the page is loaded
    def wait_until_loaded
      wait_until { loaded? }
    end

    def wait_until_xpath(selector)
      wait_until { at_xpath(selector).present? }
    end

    # implement text matcher selector

    # implement text matches xpath selector

    def text_matcher(text)
      xpath = "//*[contains(text(), '#{text}')]"
      at_xpath(xpath)
    end

    # find links that contain text
    def links_with_text(text)
      at_xpath("//a[contains(., '#{text}')]")
    end

    def link_with_text(text)
      links_with_text(text).first
    end

    # loaded?
    def loaded?
      !at_css("body.loading")
    end

    # wait until
    def wait_until(timeout: nil)
      timeout ||= self.timeout
      start_time = Time.now
      while Time.now - start_time < timeout
        return true if yield

        sleep 0.1
      end
      raise "Timeout waiting for condition"
    end

    def save_cookies_to_json_file(file = "cookies.json")
      cookies = browser.cookies.all
      File.write(file, JSON.pretty_generate(cookies))
    end
  end
end

module Faa
  class Auth
    attr_reader :browser

    def initialize(domain, options: {}, browser_options: {})
      @domain = domain
      opts = ferrum_options(options: options, browser_options: browser_options)
      @browser = Ferrum::Browser.new(opts)
    end

    def ferrum_options(options: {}, browser_options: {})
      opts = {process_timeout: 120,
              # host: 'localhost',
              # port: 9222,
              timeout: 40,
              headless: false}.merge(options)


      opts["no-sandbox"] = nil if options[:headless]
    end

    def go_home
      @browser.goto("https://#{@domain}")
    end

    def back_from_auth?
      @browser.url =~ %r{https://#{@domain}}
    end

    def login
      go_home
      browser.text_matcher("MyAccess Sign In").click
      loop do
        sleep 1
        break if browser.at_css("#contpiv")
      end
      browser.at_css("#contpiv").click
      browser.at_xpath("//button[@type='button' and contains(.,'OK')]").click
      loop do
        sleep 1
        break if back_from_auth?
      end
    end

    # save cookies to file uing ferrum as json
    def save_cookies_to_json_file(file = "cookies.json")
      cookies = browser.cookies.all
      File.write(file, JSON.pretty_generate(cookies))
    end

    def login_and_save_cookies(file = "cookies.json")
      login
      save_cookies_to_json_file(file)
    end
  end
end


if $0 == __FILE__
  # get the domain from command line
  domain = "my.faa.gov/"
  Faa::Auth.new(domain, options: {headless: false})
  client = Faa::Auth.new(domain, options: {headless: true})

  client.login_and_save_cookies("cookies.json")
end
