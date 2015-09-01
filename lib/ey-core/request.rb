module Ey::Core::Request
  def method_missing(method, *args, &block)
    if service.respond_to?(method)
      service.send(method, *args, &block)
    else
      super
    end
  end

  attr_reader :params

  def _real(params)
    @params = params.dup
    real
  end

  def _mock(params)
    @params = params.dup
    mock
  end
end
