class RestClient
  include HTTParty

  def initialize(base_uri)
    self.class.base_uri base_uri
  end

  def get(uri, options)
    self.class.get(uri, options)
  end

  def post(uri, options)
    self.class.post(uri, options)
  end

  def put(uri, options)
    self.class.put(uri, options)
  end

  def delete(uri, options)
    self.class.delete(uri, options)
  end
end
