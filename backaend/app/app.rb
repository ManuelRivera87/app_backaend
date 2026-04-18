# frozen_string_literal: true
require "time"

class App < Sinatra::Base
  TEST_USER = {
    id: 1,
    email: "test@backaend.local",
    password: "123456",
    name: "Usuario de Pruebas"
  }.freeze

  configure do
    set :show_exceptions, false
    set :quotes, []
    set :next_quote_id, 1
  end

  before do
    content_type :json
  end

  helpers do
    def parse_json_body
      body_content = request.body.read
      return {} if body_content.nil? || body_content.strip.empty?

      JSON.parse(body_content)
    rescue JSON::ParserError
      halt 400, { error: "El cuerpo JSON es inválido" }.to_json
    end

    def bearer_token
      auth_header = request.env["HTTP_AUTHORIZATION"]
      return nil unless auth_header

      scheme, token = auth_header.split(" ", 2)
      return nil unless scheme&.downcase == "bearer"

      token
    end

    def expected_token
      "token-demo-#{TEST_USER[:id]}"
    end

    def authorize!
      halt 401, { error: "No autorizado" }.to_json unless bearer_token == expected_token
    end

    def quote_params
      payload = parse_json_body
      required_fields = %w[cliente producto precio moneda]
      missing_fields = required_fields.select do |field|
        !payload.key?(field) || payload[field].to_s.strip.empty?
      end

      unless missing_fields.empty?
        halt 422,
             {
               error: "Faltan campos requeridos",
               fields: missing_fields
             }.to_json
      end

      {
        cliente: payload["cliente"],
        producto: payload["producto"],
        precio: payload["precio"],
        moneda: payload["moneda"],
        notas: payload["notas"]
      }
    end

    def find_quote(id)
      settings.quotes.find { |quote| quote[:id] == id }
    end
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

  # Inicio de sesión con usuario de pruebas en memoria
  post "/auth/login" do
    payload = parse_json_body

    if payload["email"] == TEST_USER[:email] && payload["password"] == TEST_USER[:password]
      {
        message: "Inicio de sesión exitoso",
        token: expected_token,
        user: {
          id: TEST_USER[:id],
          email: TEST_USER[:email],
          name: TEST_USER[:name]
        }
      }.to_json
    else
      status 401
      { error: "Credenciales inválidas" }.to_json
    end
  end

  # CRUD de cotizaciones
  get "/cotizaciones" do
    authorize!
    { data: settings.quotes }.to_json
  end

  get "/cotizaciones/:id" do
    authorize!
    quote = find_quote(params[:id].to_i)
    halt 404, { error: "Cotización no encontrada" }.to_json unless quote

    { data: quote }.to_json
  end

  post "/cotizaciones" do
    authorize!
    data = quote_params

    quote = {
      id: settings.next_quote_id,
      cliente: data[:cliente],
      producto: data[:producto],
      precio: data[:precio],
      moneda: data[:moneda],
      notas: data[:notas],
      created_at: Time.now.utc.iso8601,
      updated_at: Time.now.utc.iso8601
    }

    settings.quotes << quote
    settings.next_quote_id += 1

    status 201
    { message: "Cotización creada", data: quote }.to_json
  end

  put "/cotizaciones/:id" do
    authorize!
    quote = find_quote(params[:id].to_i)
    halt 404, { error: "Cotización no encontrada" }.to_json unless quote

    data = quote_params
    quote[:cliente] = data[:cliente]
    quote[:producto] = data[:producto]
    quote[:precio] = data[:precio]
    quote[:moneda] = data[:moneda]
    quote[:notas] = data[:notas]
    quote[:updated_at] = Time.now.utc.iso8601

    { message: "Cotización actualizada", data: quote }.to_json
  end

  delete "/cotizaciones/:id" do
    authorize!
    quote = find_quote(params[:id].to_i)
    halt 404, { error: "Cotización no encontrada" }.to_json unless quote

    settings.quotes.delete(quote)
    { message: "Cotización eliminada" }.to_json
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
