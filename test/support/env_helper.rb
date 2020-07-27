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
      'FAA_USERNAME_CODE' => 'T3V0b3V0YnJpZWZjYW5kbGVkb21pbmljLmUuc2lzbmVyb3NAZmFhLmdvdg==',
      'FAA_ACCESS_PIN' => 'T3V0b3V0YnJpZWZjYW5kbGUyOTU3MDYwNA==',
      'FAA_CODE_SALT' => 'Outoutbriefcandle',
    }

  end

end
