# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe "Health endpoint" do
  it "returns a healthy response" do
    get "/health"

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)).to include(
      "status" => "ok",
      "service" => "backaend"
    )
  end
end
