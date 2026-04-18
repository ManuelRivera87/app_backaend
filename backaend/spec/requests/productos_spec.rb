# frozen_string_literal: true

require "spec_helper"

describe "Productos API" do
  describe "GET /productos" do
    it "returns an empty array when no products exist" do
      get "/productos"
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)).to eq([])
    end
  end

  describe "POST /productos" do
    it "creates a new product" do
      product_data = {
        nombre: "Producto de prueba",
        descripcion: "Descripción de prueba",
        precio: 10.99,
        cantidad: 5
      }

      post "/productos", product_data.to_json, { "CONTENT_TYPE" => "application/json" }

      expect(last_response.status).to eq(201)
      response_body = JSON.parse(last_response.body)
      expect(response_body["nombre"]).to eq("Producto de prueba")
      expect(response_body["descripcion"]).to eq("Descripción de prueba")
      expect(response_body["precio"]).to eq(10.99)
      expect(response_body["cantidad"]).to eq(5)
      expect(response_body["id"]).to be_a(Integer)
    end

    it "returns error for missing parameters" do
      post "/productos", {}.to_json, { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(400)
      response_body = JSON.parse(last_response.body)
      expect(response_body["error"]).to include("Faltan parámetros")
    end
  end

  describe "GET /productos/:id" do
    it "returns a product by id" do
      product_data = {
        nombre: "Producto existente",
        descripcion: "Descripción",
        precio: 20.0,
        cantidad: 10
      }
      post "/productos", product_data.to_json, { "CONTENT_TYPE" => "application/json" }
      created_product = JSON.parse(last_response.body)

      get "/productos/#{created_product['id']}"
      expect(last_response).to be_ok
      response_body = JSON.parse(last_response.body)
      expect(response_body["nombre"]).to eq("Producto existente")
    end

    it "returns 404 for non-existent product" do
      get "/productos/999"
      expect(last_response.status).to eq(404)
      response_body = JSON.parse(last_response.body)
      expect(response_body["error"]).to eq("Producto no encontrado")
    end
  end

  describe "PUT /productos/:id" do
    it "updates a product" do
      product_data = {
        nombre: "Producto original",
        descripcion: "Descripción original",
        precio: 15.0,
        cantidad: 3
      }
      post "/productos", product_data.to_json, { "CONTENT_TYPE" => "application/json" }
      created_product = JSON.parse(last_response.body)

      update_data = {
        nombre: "Producto actualizado",
        precio: 25.0
      }
      put "/productos/#{created_product['id']}", update_data.to_json, { "CONTENT_TYPE" => "application/json" }

      expect(last_response).to be_ok
      response_body = JSON.parse(last_response.body)
      expect(response_body["nombre"]).to eq("Producto actualizado")
      expect(response_body["precio"]).to eq(25.0)
      expect(response_body["descripcion"]).to eq("Descripción original") # unchanged
    end

    it "returns 404 for non-existent product" do
      put "/productos/999", { nombre: "Test" }.to_json, { "CONTENT_TYPE" => "application/json" }
      expect(last_response.status).to eq(404)
    end
  end

  describe "DELETE /productos/:id" do
    it "deletes a product" do
      product_data = {
        nombre: "Producto a eliminar",
        descripcion: "Descripción",
        precio: 5.0,
        cantidad: 1
      }
      post "/productos", product_data.to_json, { "CONTENT_TYPE" => "application/json" }
      created_product = JSON.parse(last_response.body)

      delete "/productos/#{created_product['id']}"
      expect(last_response).to be_ok
      response_body = JSON.parse(last_response.body)
      expect(response_body["message"]).to eq("Producto eliminado")

      # Verify it's gone
      get "/productos/#{created_product['id']}"
      expect(last_response.status).to eq(404)
    end

    it "returns 404 for non-existent product" do
      delete "/productos/999"
      expect(last_response.status).to eq(404)
    end
  end
end