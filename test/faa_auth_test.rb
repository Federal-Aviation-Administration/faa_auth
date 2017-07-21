require_relative "test_helper"

require 'minitest/spec'
require 'minitest/autorun'

describe FaaAuth::Client do
  include EnvHelpers

  it "fails to initialize when login isn't given" do

    lambda{ FaaAuth::Client.new(password: 'secret')}.must_raise
  end

  it %q(fails to initialize when password isn't given) do
    lambda{ FaaAuth::Client.new(login: 'foo')}.must_raise
  end

  it %q(succeeds in initializing when login and password ar given) do
    FaaAuth::Client.new(login: 'foo', password: 'secret')
  end

  it "succeeds in initializing when login and passwrod codes are given with envvar" do
    with_env_vars valid_vars do
      FaaAuth::Client.new
    end
  end

  it "fails to initialize when salt isn't set" do
    with_env_vars valid_vars.merge('FAA_CODE_SALT' => nil) do
      lambda{FaaAuth::Client.new}.must_raise
    end
  end

  describe '#initial_url' do
    it 'has my.faa.gov domain' do
      with_env_vars valid_vars do
        client = FaaAuth::Client.new
        client.initial_url.must_match /my.faa.gov/
      end
    end

      it 'switches domain with envvar' do
      with_env_vars valid_vars.merge('FAA_DOMAIN' => 'faa.co.jp') do
        client = FaaAuth::Client.new
        client.initial_url.must_match /www\.faa\.co\.jp/
      end
    end

    it 'changes url with argument' do
      with_env_vars valid_vars do
        client = FaaAuth::Client.new(url: 'https://www.faa.co.uk')
        client.initial_url.must_match /www\.faa\.co\.uk/
      end
    end
  end



end
