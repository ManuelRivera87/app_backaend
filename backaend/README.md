# Backaend

Base inicial para un backend en Ruby con Sinatra.

## Estructura

```text
backaend/
├── app/
│   ├── controllers/
│   ├── models/
│   ├── services/
│   └── app.rb
├── config/
│   ├── boot.rb
│   └── environment.rb
├── spec/
│   ├── requests/
│   └── spec_helper.rb
├── Gemfile
├── config.ru
└── .gitignore
```

## Primeros pasos

1. Instala dependencias con `bundle install`
2. Inicia el servidor con `bundle exec rackup`
3. Prueba el endpoint `GET /health`

---

## Autenticación (sin base de datos)

El proyecto incluye un usuario genérico en memoria para pruebas manuales o desde frontend.

- **Email**: `test@backaend.local`
- **Password**: `123456`

### `POST /auth/login`

Inicia sesión y devuelve un token tipo Bearer.

**Body**

```json
{
  "email": "test@backaend.local",
  "password": "123456"
}
```

**Respuesta exitosa (200)**

```json
{
  "message": "Inicio de sesión exitoso",
  "token": "token-demo-1",
  "user": {
    "id": 1,
    "email": "test@backaend.local",
    "name": "Usuario de Pruebas"
  }
}
```

> Usa el token en los endpoints protegidos con el header:
> `Authorization: Bearer token-demo-1`

---

## Módulo de cotizaciones (CRUD)

Todos los endpoints de cotizaciones requieren autenticación con Bearer token.

### Campos de una cotización

- `cliente` (requerido)
- `producto` (requerido)
- `precio` (requerido)
- `moneda` (requerido)
- `notas` (opcional)

### 1) `GET /cotizaciones`

**Funcionalidad:** lista todas las cotizaciones guardadas en memoria.

**Respuesta (200)**

```json
{
  "data": []
}
```

### 2) `GET /cotizaciones/:id`

**Funcionalidad:** obtiene una cotización específica por su ID.

**Respuesta (200)**

```json
{
  "data": {
    "id": 1,
    "cliente": "Acme",
    "producto": "Licencia anual",
    "precio": 1499,
    "moneda": "USD",
    "notas": "Entrega inmediata",
    "created_at": "2026-04-18T00:00:00Z",
    "updated_at": "2026-04-18T00:00:00Z"
  }
}
```

### 3) `POST /cotizaciones`

**Funcionalidad:** crea una nueva cotización.

**Body**

```json
{
  "cliente": "Acme",
  "producto": "Licencia anual",
  "precio": 1499,
  "moneda": "USD",
  "notas": "Entrega inmediata"
}
```

**Respuesta (201)**

```json
{
  "message": "Cotización creada",
  "data": {
    "id": 1,
    "cliente": "Acme",
    "producto": "Licencia anual",
    "precio": 1499,
    "moneda": "USD",
    "notas": "Entrega inmediata",
    "created_at": "2026-04-18T00:00:00Z",
    "updated_at": "2026-04-18T00:00:00Z"
  }
}
```

### 4) `PUT /cotizaciones/:id`

**Funcionalidad:** actualiza todos los campos de una cotización existente.

**Body**

```json
{
  "cliente": "Acme Corp",
  "producto": "Licencia enterprise",
  "precio": 2500,
  "moneda": "USD",
  "notas": "Incluye soporte premium"
}
```

**Respuesta (200)**

```json
{
  "message": "Cotización actualizada",
  "data": {
    "id": 1,
    "cliente": "Acme Corp",
    "producto": "Licencia enterprise",
    "precio": 2500,
    "moneda": "USD",
    "notas": "Incluye soporte premium",
    "created_at": "2026-04-18T00:00:00Z",
    "updated_at": "2026-04-18T00:05:00Z"
  }
}
```

### 5) `DELETE /cotizaciones/:id`

**Funcionalidad:** elimina una cotización por su ID.

**Respuesta (200)**

```json
{
  "message": "Cotización eliminada"
}
```

---

## Errores comunes

- **401 No autorizado**: falta header `Authorization` o token inválido.
- **404 Cotización no encontrada**: el ID solicitado no existe.
- **422 Faltan campos requeridos**: faltan `cliente`, `producto`, `precio` o `moneda`.
- **400 JSON inválido**: body mal formado.
