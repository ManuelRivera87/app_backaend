# frozen_string_literal: true

class App < Sinatra::Base
  configure do
    set :show_exceptions, false
  end

  before do
    content_type :json
  end

  get "/" do
    {
      message: "Backend Ruby inicializado",
      status: "ok"
    }.to_json
  end

  get "/health" do
    {
      status: "ok",
      service: "backaend"
    }.to_json
  end

  not_found do
    status 404
    { error: "Ruta no encontrada" }.to_json
  end

  error do
    status 500
    { error: "Error interno del servidor" }.to_json
  end
end
