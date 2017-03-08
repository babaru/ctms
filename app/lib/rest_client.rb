class RestClient
  include HTTParty

  def initialize(base_uri)
    self.class.base_uri base_uri
  end

  def get(uri, options)
    self.class.get(uri, options)
  end
end
