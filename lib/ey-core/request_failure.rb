class Ey::Core::RequestFailure < StandardError
  attr_reader :request

  def initialize(request)
    @request = request

    message = "#{request.message} (#{request.type}) [#{request.id}]"
    message = "#{message} #{request.resource.attributes.inspect}" if request.resource
    super(message)
  end
end
