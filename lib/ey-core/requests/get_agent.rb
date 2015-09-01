class Ey::Core::Client::GetAgent < Cistern::Request
  include Ey::Core::Request

  service Ey::Core::Client

  def real
    params["url"] || (id = params.fetch("id"))

    request(
      :path => "/agents/#{id}",
      :url  => params["url"],
    )
  end

  def mock
    response(
      :body => {"agent" => self.find(:agents, resource_identity(params))},
    )
  end
end # Mock
