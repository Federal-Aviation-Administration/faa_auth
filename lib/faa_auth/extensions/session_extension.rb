module FaaAuth

  module SessionExtension

    def doc
      Nokogiri.HTML(session.html)
    end

    def html_links
      wait_for_selector('a')
      doc.css('a').map{|e| Link.new(e.text, e['href'])}
    end


    def links_for(selector, options = {})
      wait_for_selector(selector, options)
      doc.css(selector).map{|e| e['href']}
    end

    def ensure_on(path)
      session.visit path unless session.current_url == path
    end

    def wait_for_selector(selector, options = {})
      3.times do
        found = session.find(selector) rescue nil
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
      %Q(img[alt="MyFAA"])
    end

    def sign_in(url = nil)
      url ||= initial_url
      session.visit url
      debug "Visiting #{url}\n"
      #restore_cookies if keep_cookie?
      link = find_sign_in_link
      if link
        debug "found sign in link: [#{link}]\n"
        session.click_link link
      end
      success = submit_signin_form
      if success
        success =submit_access_form
      end
      return success
    end

    def find_sign_in_link
      'MyAccess Sign In'
    end

    def restore_cookies
      log "Restoring cookies"
      wait_for_selector('body')
      session.restore_cookies
      session.visit session.current_url
      session.save_cookies
    end

    def keep_cookie?
      options[:keep_cookie]
    end

    def agree_button_selector
      '#cont'
    end

    def submit_signin_form
      debug "Begin submit_signin_form\n"
      unless session.has_selector? agree_button_selector
        log "Agree & Continue button not found in this page"
        return false
      end
      session.fill_in 'username', with: login if session.first('#username').value.blank?
      # session.fill_in 'ap_password', with: password
      session.first(agree_button_selector).click
      log "Clicked Agree&Continue"
      debug "End submit_signin_form\n"
      true
    end

    def submit_access_form
      fillin_access_form
      click_access_form
    end


    def fillin_access_form
      debug "Begin fillin_access_form\n"
      # raise('Failed on signin') if alert_displayed?
      # unless session.has_selector?('#PIN_INPUT')
      #   log 'MyAccess input not found in this page'
      #   return false
      # end
      wait_for_selector('#PIN_INPUT')
      security_answer = get_security_answer
      session.fill_in 'PIN_INPUT', with: password
      session.fill_in 'answer0', with: security_answer
      debug("Current path in fillin_access_form #{current_path}\n")
      debug "End fillin_access_form/n"
    end

    def get_security_answer
      if match_security_question? security_question
        security_answer = get_security_answer_from_env(security_question)
        security_answer = ask security_question unless security_answer
      else
        security_answer = ask security_question
      end
      security_answer
    end

    def click_access_form
      sleep(1)
      debug "Begin click_access_form\n"
      session.click_button 'LOGIN_BUTTON'
      debug("Current path after login button clicked #{current_path}\n")
      wait_for_selector(initial_url_selector)
      unless session.has_css?(initial_url_selector)
        wait_for_selector(initial_url_selector)
      end
      if session.has_css?('#LOGIN_BUTTON')
        session.click_button 'LOGIN_BUTTON'
      end
      # if session.has_css?('#LOGIN_BUTTON')
      #   click_access_form
      # end
      log "clicked Signin"
      debug "End click_access_form\n"
      session.save_cookies if keep_cookie?
      true

    end

    def security_question
      form_labels = doc.css('#INPUT_FORM').css('label')
      form_labels .find{|l| l['for'] =~ /answer/}.text
    end

    def retry_signin_form_with_image_recognition
      return true unless session.has_selector?('#signInSubmit')
      session.fill_in 'ap_password', with: password
      if image_recognition_displayed?
        input = ask "Got the prompt. Read characters from the image [blank to cancel]: "
        if input.blank?
          debug "Going back to #{initial_url}"
          session.visit initial_url
          return true
        end
        session.fill_in 'auth-captcha-guess', with: input
      end
      sleep 1
      session.click_on('signInSubmit')
      sleep 2
    end

    def alert_displayed?
      session.has_selector?('.a-alert-error')
    end

    def my_access_pin_displayed?
      session.has_selector?('#auth-captcha-image-container')
    end

    #private

    def login
      options.fetch(:login, Converter.decode(ENV['FAA_USERNAME_CODE']))
    end
    def password
      options.fetch(:password, Converter.decode(ENV['FAA_PASSWORD_CODE']))
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
      (1..3).each_with_object({}) do |i,h|
        env_key = "FAA_SECURITY_QUESTION#{i}"
        h[i] = Converter.decode(ENV.fetch(env_key,''))
      end
    end


    def security_question_hash
      @security_question_hash ||= security_question_number_to_hash.invert
    end

  end

end





#   def security_question
#   end

#   def security_answer
#     doc.css('#securit
#     #options.fetch(:security_answer, Converter.decode(ENV['FAA_SECURITY_ANSWER1']))
#     'Mia'
#   end

#   def security_answer2

#   end

#   def security_question2
#   end

#   def security_answers
#     security_question1: Converter.decode(ENV['FAA_SECURITY_QUESTION1']))
#     security_answer1: Converter.decode(ENV['FAA_SECURITY_ANSWER1']))

# end
