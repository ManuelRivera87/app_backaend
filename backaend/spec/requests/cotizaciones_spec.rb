# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe "Cotizaciones endpoints" do
  let(:headers) do
    {
      "CONTENT_TYPE" => "application/json",
      "HTTP_AUTHORIZATION" => "Bearer token-demo-1"
    }
  end

  before do
    App.set :quotes, []
    App.set :next_quote_id, 1
  end

  it "requires authorization" do
    get "/cotizaciones"

    expect(last_response.status).to eq(401)
  end

  it "creates, lists, gets, updates and deletes a quote" do
    create_payload = {
      cliente: "Acme",
      producto: "Licencia anual",
      precio: 1499,
      moneda: "USD",
      notas: "Entrega inmediata"
    }

    post "/cotizaciones", create_payload.to_json, headers
    expect(last_response.status).to eq(201)

    created = JSON.parse(last_response.body)
    id = created.dig("data", "id")
    expect(id).to eq(1)

    get "/cotizaciones", {}, headers
    expect(last_response.status).to eq(200)
    list = JSON.parse(last_response.body)
    expect(list.fetch("data").size).to eq(1)

    get "/cotizaciones/#{id}", {}, headers
    expect(last_response.status).to eq(200)

    update_payload = {
      cliente: "Acme Corp",
      producto: "Licencia enterprise",
      precio: 2500,
      moneda: "USD",
      notas: "Incluye soporte premium"
    }

    put "/cotizaciones/#{id}", update_payload.to_json, headers
    expect(last_response.status).to eq(200)
    updated = JSON.parse(last_response.body)
    expect(updated.dig("data", "cliente")).to eq("Acme Corp")

    delete "/cotizaciones/#{id}", {}, headers
    expect(last_response.status).to eq(200)

    get "/cotizaciones/#{id}", {}, headers
    expect(last_response.status).to eq(404)
  end
end
