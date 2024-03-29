module EnvHelpers
  def with_env_vars(vars)
    original = ENV.to_hash
    vars.each { |k, v| ENV[k] = v }

    begin
      yield
    ensure
      ENV.replace(original)
    end
  end

  def valid_vars
    {

    }
  end

  def valid_vars
    {
      'FAA_USERNAME_CODE' => '',
      'FAA_ACCESS_PIN' => '',
      'FAA_CODE_SALT' => '',
    }

  end

end
