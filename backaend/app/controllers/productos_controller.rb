# frozen_string_literal: true

require_relative '../models/producto'

class ProductosController
  def self.index
    Producto.all.map(&:to_h)
  end

  def self.show(id)
    producto = Producto.find(id)
    return { error: 'Producto no encontrado' } unless producto
    producto.to_h
  end

  def self.create(params)
    required_params = %w[nombre descripcion precio cantidad]
    missing = required_params.select { |p| params[p].nil? || params[p].empty? }
    return { error: "Faltan parámetros: #{missing.join(', ')}" } unless missing.empty?

    producto = Producto.create(params)
    producto.to_h
  end

  def self.update(id, params)
    producto = Producto.find(id)
    return { error: 'Producto no encontrado' } unless producto

    producto.update(params)
    producto.to_h
  end

  def self.destroy(id)
    producto = Producto.find(id)
    return { error: 'Producto no encontrado' } unless producto

    producto.destroy
    { message: 'Producto eliminado' }
  end
end