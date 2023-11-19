# PC3-CC3S2
## Parte 1:
Clonamos el repositorio en una carpeta y creamos una rama, en este caso la rama se llamara gabriel.
Posteriormente ejecutamos **bundle install --without production** y **rake db:migrate**.

#### Pregunta: ¿Cómo decide Rails dónde y cómo crear la base de datos de desarrollo? (Sugerencia: verifica los subdirectorios db y config)
En ruby-on-rails se crea la base de datos en desarrollo segun el archivo **config/database.yml**, dentro de este file podemos ver 
```yml
# SQLite version 3.x
#   gem install sqlite3
#
#   Ensure the SQLite 3 gem is defined in your Gemfile
#   gem 'sqlite3'
#
default: &default
  adapter: sqlite3
  pool: 5
  timeout: 5000

development:
  <<: *default
  database: db/development.sqlite3

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: db/test.sqlite3

production:
  <<: *default
  database: db/production.sqlite3

```
entonces, la creacion y ubicacion dependen de este archivo.
#### Pregunta: ¿Qué tablas se crearon mediante las migraciones?
Primero se crea un archivo rb dentro de **db/migrate/** llamada **..._create_movies.rb**, ahora, segun el codigo anterior, podemos ver que se crearon 3 bases de datos, **development.sqlite3, test.sqlite3** y **production.sqlite3**.


