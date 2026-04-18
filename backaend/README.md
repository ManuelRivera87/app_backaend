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
