module FaaAuth
  module SessionExtension
    def doc
      Nokogiri.HTML(session.html)
    end

    def html_links
      wait_for_selector("a")
      doc.css("a").map { |e| Link.new(e.text, e["href"]) }
    end

    def links_for(selector, options = {})
      wait_for_selector(selector, options)
      doc.css(selector).map { |e| e["href"] }
    end

    def ensure_on(path)
      session.visit path unless session.current_url == path
    end

    def wait_for_selector(selector, options = {})
      3.times do
        found = begin
          session.find(selector)
        rescue
          nil
        end
        if found
          break
        else
          sleep(1)
        end
      end
    end

    # Helpers for sign in
    def initial_url
      options.fetch(:url) { "https://#{FaaInfo.domain}/" }
    end

    def initial_url_selector
      %(img[alt="MyFAA"])
    end

    def access_sign_in_page?
      session.has_selector?("#accessid")
    end

    def goto_access_sign_in
      return true if access_sign_in_page?
      click_sign_in_selector
      access_sign_in_page?
    end

    def sign_in(url = nil)
      url ||= initial_url
      session.visit url
      at_access_page = goto_access_sign_in
      if at_access_page
        sign_in_to_access
      else
        raise "Need to override sign_in_selector to goto access sign in page"
      end
    end

    def sign_in_selector=(text)
      @sign_in_selector = text
    end

    def sign_in_selector
      @sign_in_selector
    end

    def click_sign_in_selector
      session.find(sign_in_selector).click
    rescue
      raise "you must set sign in selector in initialization :sign_in_selector or #sign_in_selector="
    end

    def sign_in_selector
      session.find_link(sign_in_selector)
    end

    def sign_in_to_access
      success = submit_use_email_address
      if success
        success = submit_access_form
      end
      success
    end

    def find_sign_in_link
      "MyAccess Sign In"
    end

    def restore_cookies
      log "Restoring cookies"
      wait_for_selector("body")
      session.restore_cookies
      session.visit session.current_url
      session.save_cookies
    end

    def keep_cookie?
      options[:keep_cookie]
    end

    def agree_button_selector
      "#cont"
    end

    def submit_use_email_address
      session.fill_in("userEmail", with: login)
      session.first(agree_button_selector).click
      log "Clicked Agree&Continue"
      debug "End submit_signin_form\n"
      true
    end

    def submit_signin_form
      debug "Begin submit_signin_form\n"
      unless session.has_selector? agree_button_selector
        log "Agree & Continue button not found in this page"
        return false
      end
      session.fill_in "username", with: login if session.first("#username").value.blank?
      # session.fill_in 'ap_password', with: password
      session.first(agree_button_selector).click
      log "Clicked Agree&Continue"
      debug "End submit_signin_form\n"
      true
    end

    def submit_access_form
      fillin_access_form
    end

    def login_button
      session.find_by_id("LOGIN_BUTTON")
    end

    def login_button_enabled?
      !login_button["class"].split.include? "disabled"
    end

    def fillin_access_form
      debug "Begin fillin_access_form\n"
      wait_for_selector("#PIN_INPUT")
      question = get_security_question
      security_answer = get_security_answer_for_question(question)
      pin = get_access_pin
      session.fill_in "PIN_INPUT", with: pin
      session.fill_in "answer0", with: security_answer
      sleep(2)
      # login_button = session.find_by_id('LOGIN_BUTTON')
      # loop do
      #  answer_field.send_keys [:control, "a"]
      # break if login_button_enabled?
      # end
      session.click_on("Sign In")
      fillin_access_form if session.has_selector?("#PIN_INPUT")
      log "Clicked Sign In"
      debug "End fillin_access_form/n"
      true
    end

    def get_security_answer_for_question(security_question)
      if match_security_question? security_question
        security_answer = get_security_answer_from_env(security_question)
        security_answer ||= ask security_question
      else
        security_answer = ask security_question
      end
      security_answer
    end

    def click_access_form
      debug "Begin click_access_form\n"
      session.document.synchronize(5) do
        btn = session.find("#LOGIN_BUTTON")
        btn.click if btn
        session.find(initial_url_selector)
      end
      log "clicked Signin"
      debug "End click_access_form\n"
      session.save_cookies if keep_cookie?
      true
    end

    def get_security_question
      form_labels = doc.css("#INPUT_FORM").css("label")
      form_labels.find { |l| l["for"] =~ /answer/ }.text
    end

    def retry_signin_form_with_image_recognition
      return true unless session.has_selector?("#signInSubmit")
      session.fill_in "ap_password", with: password
      if image_recognition_displayed?
        input = ask "Got the prompt. Read characters from the image [blank to cancel]: "
        if input.blank?
          debug "Going back to #{initial_url}"
          session.visit initial_url
          return true
        end
        session.fill_in "auth-captcha-guess", with: input
      end
      sleep 1
      session.click_on("signInSubmit")
      sleep 2
    end

    def alert_displayed?
      session.has_selector?(".a-alert-error")
    end

    def my_access_pin_displayed?
      session.has_selector?("#auth-captcha-image-container")
    end

    # private

    def login
      options.fetch(:login, Converter.decode(ENV["FAA_USERNAME_CODE"]))
    end

    def get_access_pin
      options.fetch(:password, Converter.decode(ENV["FAA_ACCESS_PIN"]))
    end

    def get_security_answer_from_env(question)
      number = security_question_hash[question]
      env_key = ENV["FAA_SECURITY_ANSWER#{number}"]
      return false unless env_key.present?
      Converter.decode(env_key)
    end

    def match_security_question?(question)
      security_question_hash[question].present?
    end

    def security_question_number_to_hash
      (1..3).each_with_object({}) do |i, h|
        env_key = "FAA_SECURITY_QUESTION#{i}"
        h[i] = Converter.decode(ENV.fetch(env_key, ""))
      end
    end

    def security_question_hash
      @security_question_hash ||= security_question_number_to_hash.invert
    end
  end
end
