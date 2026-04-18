# frozen_string_literal: true

class Producto
  attr_accessor :id, :nombre, :descripcion, :precio, :cantidad

  @@productos = []
  @@next_id = 1

  def initialize(id:, nombre:, descripcion:, precio:, cantidad:)
    @id = id
    @nombre = nombre
    @descripcion = descripcion
    @precio = precio
    @cantidad = cantidad
  end

  def to_h
    {
      id: @id,
      nombre: @nombre,
      descripcion: @descripcion,
      precio: @precio,
      cantidad: @cantidad
    }
  end

  def self.all
    @@productos
  end

  def self.find(id)
    @@productos.find { |p| p.id == id.to_i }
  end

  def self.create(params)
    producto = new(
      id: @@next_id,
      nombre: params['nombre'],
      descripcion: params['descripcion'],
      precio: params['precio'].to_f,
      cantidad: params['cantidad'].to_i
    )
    @@next_id += 1
    @@productos << producto
    producto
  end

  def self.reset!
    @@productos = []
    @@next_id = 1
  end

  def update(params)
    @nombre = params['nombre'] if params['nombre']
    @descripcion = params['descripcion'] if params['descripcion']
    @precio = params['precio'].to_f if params['precio']
    @cantidad = params['cantidad'].to_i if params['cantidad']
    self
  end

  def destroy
    @@productos.delete(self)
  end
end
