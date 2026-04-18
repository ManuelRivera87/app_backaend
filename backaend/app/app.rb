# frozen_string_literal: true

require "json"
require "time"
require "sinatra/base"

require_relative "controllers/productos_controller"

class App < Sinatra::Base
  configure do
    set :show_exceptions, false
    set :products, []
    set :next_product_id, 1
    set :quotes, []
    set :next_quote_id, 1
    set :demo_user, {
      "id" => 1,
      "email" => "test@backaend.local",
      "password" => "123456",
      "name" => "Usuario de Pruebas",
      "token" => "token-demo-1"
    }
  end

  before do
    content_type :json
    headers[
      "Access-Control-Allow-Origin" => "*",
      "Access-Control-Allow-Methods" => "GET,POST,PUT,PATCH,DELETE,OPTIONS",
      "Access-Control-Allow-Headers" => "Authorization,Content-Type,Accept"
    ]
  end

  options "*" do
    204
  end

  get "/health" do
    json_response(
      {
        status: "ok",
        service: "backaend",
        timestamp: Time.now.utc.iso8601
      }
    )
  end

  post "/auth/login" do
    payload = parsed_body
    user = settings.demo_user

    unless payload["email"] == user["email"] && payload["password"] == user["password"]
      halt json_response({ error: "Credenciales inválidas" }, 401)
    end

    json_response(
      {
        message: "Inicio de sesión exitoso",
        token: user["token"],
        user: {
          id: user["id"],
          email: user["email"],
          name: user["name"]
        }
      }
    )
  end

  get "/productos" do
    json_response(ProductosController.index)
  end

  get "/productos/:id" do
    result = ProductosController.show(params["id"])
    status_code = result[:error] ? 404 : 200
    json_response(result, status_code)
  end

  post "/productos" do
    result = ProductosController.create(parsed_body)
    status_code = result[:error] ? 400 : 201
    json_response(result, status_code)
  end

  put "/productos/:id" do
    result = ProductosController.update(params["id"], parsed_body)
    status_code = result[:error] ? 404 : 200
    json_response(result, status_code)
  end

  patch "/productos/:id" do
    result = ProductosController.update(params["id"], parsed_body)
    status_code = result[:error] ? 404 : 200
    json_response(result, status_code)
  end

  delete "/productos/:id" do
    result = ProductosController.destroy(params["id"])
    status_code = result[:error] ? 404 : 200
    json_response(result, status_code)
  end

  get "/cotizaciones" do
    authorize!
    json_response(data: settings.quotes)
  end

  get "/cotizaciones/:id" do
    authorize!
    quote = find_quote(params["id"])
    halt json_response({ error: "Cotización no encontrada" }, 404) unless quote

    json_response(data: quote)
  end

  post "/cotizaciones" do
    authorize!
    payload = parsed_body
    validate_quote_payload!(payload)

    timestamp = Time.now.utc.iso8601
    quote = {
      "id" => settings.next_quote_id,
      "cliente" => payload["cliente"],
      "producto" => payload["producto"],
      "precio" => payload["precio"],
      "moneda" => payload["moneda"],
      "notas" => payload["notas"],
      "created_at" => timestamp,
      "updated_at" => timestamp
    }

    settings.quotes << quote
    settings.next_quote_id += 1

    json_response({ message: "Cotización creada", data: quote }, 201)
  end

  put "/cotizaciones/:id" do
    authorize!
    payload = parsed_body
    validate_quote_payload!(payload)
    quote = find_quote(params["id"])
    halt json_response({ error: "Cotización no encontrada" }, 404) unless quote

    quote["cliente"] = payload["cliente"]
    quote["producto"] = payload["producto"]
    quote["precio"] = payload["precio"]
    quote["moneda"] = payload["moneda"]
    quote["notas"] = payload["notas"]
    quote["updated_at"] = Time.now.utc.iso8601

    json_response({ message: "Cotización actualizada", data: quote })
  end

  patch "/cotizaciones/:id" do
    authorize!
    payload = parsed_body
    quote = find_quote(params["id"])
    halt json_response({ error: "Cotización no encontrada" }, 404) unless quote

    updatable_keys = %w[cliente producto precio moneda notas]
    present_keys = updatable_keys.select { |key| payload.key?(key) }
    halt json_response({ error: "Sin cambios para actualizar" }, 400) if present_keys.empty?

    present_keys.each { |key| quote[key] = payload[key] }
    quote["updated_at"] = Time.now.utc.iso8601

    json_response({ message: "Cotización actualizada", data: quote })
  end

  delete "/cotizaciones/:id" do
    authorize!
    quote = find_quote(params["id"])
    halt json_response({ error: "Cotización no encontrada" }, 404) unless quote

    settings.quotes.delete(quote)
    json_response(message: "Cotización eliminada")
  end

  error JSON::ParserError do
    json_response({ error: "JSON inválido" }, 400)
  end

  error Sinatra::NotFound do
    json_response({ error: "Ruta no encontrada" }, 404)
  end

  error do
    env["sinatra.error"]
    json_response({ error: "Error interno del servidor" }, 500)
  end

  helpers do
    def json_response(payload, status_code = 200)
      status status_code
      JSON.generate(payload)
    end

    def parsed_body
      request.body.rewind
      raw_body = request.body.read
      return {} if raw_body.nil? || raw_body.strip.empty?

      JSON.parse(raw_body)
    end

    def authorize!
      header = request.env["HTTP_AUTHORIZATION"].to_s
      expected = "Bearer #{settings.demo_user["token"]}"
      halt json_response({ error: "No autorizado" }, 401) unless header == expected
    end

    def validate_quote_payload!(payload)
      required_fields = %w[cliente producto precio moneda]
      missing = required_fields.select do |field|
        !payload.key?(field) || payload[field].nil? || payload[field].to_s.strip.empty?
      end
      halt json_response({ error: "Faltan campos requeridos: #{missing.join(', ')}" }, 422) unless missing.empty?
    end

    def find_quote(id)
      settings.quotes.find { |quote| quote["id"] == id.to_i }
    end
  end
end
