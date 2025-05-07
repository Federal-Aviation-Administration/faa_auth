class FaaInfo
  def self.domain
    ENV.fetch("FAA_DOMAIN", "my.faa.gov")
  end
end
