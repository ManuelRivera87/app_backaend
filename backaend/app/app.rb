# frozen_string_literal: true

require_relative 'controllers/productos_controller'

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

  # CRUD para Productos
  get "/productos" do
    ProductosController.index.to_json
  end

  get "/productos/:id" do
    result = ProductosController.show(params[:id])
    status = result[:error] ? 404 : 200
    status status
    result.to_json
  end

  post "/productos" do
    request_body = JSON.parse(request.body.read)
    result = ProductosController.create(request_body)
    status = result[:error] ? 400 : 201
    status status
    result.to_json
  end

  put "/productos/:id" do
    request_body = JSON.parse(request.body.read)
    result = ProductosController.update(params[:id], request_body)
    status = result[:error] ? 404 : 200
    status status
    result.to_json
  end

  delete "/productos/:id" do
    result = ProductosController.destroy(params[:id])
    status = result[:error] ? 404 : 200
    status status
    result.to_json
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
