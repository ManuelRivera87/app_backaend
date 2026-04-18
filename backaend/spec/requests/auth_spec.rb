# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe "Auth endpoints" do
  it "allows login with generic user" do
    post "/auth/login", { email: "test@backaend.local", password: "123456" }.to_json

    expect(last_response.status).to eq(200)

    body = JSON.parse(last_response.body)
    expect(body["token"]).to eq("token-demo-1")
    expect(body.dig("user", "email")).to eq("test@backaend.local")
  end

  it "rejects invalid credentials" do
    post "/auth/login", { email: "test@backaend.local", password: "bad" }.to_json

    expect(last_response.status).to eq(401)
    expect(JSON.parse(last_response.body)).to include("error" => "Credenciales inválidas")
  end
end
