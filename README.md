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

Despues de ello, agregamos en la consola la instruccion **rake db:seed**.
##### Pregunta: ¿Qué datos de semilla se insertaron y dónde se especificaron? (Pista: rake -T db:seed explica la tarea de semilla, rake -T explica otras tareas de Rake disponibles) 
Si ejecutamos **rake -T db:seed** aparece lo siguiente: 
```yml
# Load the seed data from db/seeds.rb**
```
Nods dice que los datos se especificaron en la ruta **db/seeds.rb**, y dentro de este .rb podemos ver la data que se agrego a la bd.
```ruby
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

movies = [{:title => 'Aladdin', :rating => 'G', :release_date => '25-Nov-1992'},
    	  {:title => 'The Terminator', :rating => 'R', :release_date => '26-Oct-1984'},
    	  {:title => 'When Harry Met Sally', :rating => 'R', :release_date => '21-Jul-1989'},
      	  {:title => 'The Help', :rating => 'PG-13', :release_date => '10-Aug-2011'},
      	  {:title => 'Chocolat', :rating => 'PG-13', :release_date => '5-Jan-2001'},
      	  {:title => 'Amelie', :rating => 'R', :release_date => '25-Apr-2001'},
      	  {:title => '2001: A Space Odyssey', :rating => 'G', :release_date => '6-Apr-1968'},
      	  {:title => 'The Incredibles', :rating => 'PG', :release_date => '5-Nov-2004'},
      	  {:title => 'Raiders of the Lost Ark', :rating => 'PG', :release_date => '12-Jun-1981'},
      	  {:title => 'Chicken Run', :rating => 'G', :release_date => '21-Jun-2000'},
  	 ]

movies.each do |movie|
  Movie.create!(movie)
end
```
Ahora una vista previa del rails en localhost:

### Parte 1: filtrar la lista de películas por clasificación:
Primero modificamos el archivo index.html.erb :
```erb
<!--  This file is app/views/movies/index.html.erb -->
<h2>All Movies</h2>

<%= form_tag movies_path, method: :get, id: 'ratings_form' do %>

  Include:

  <% @all_ratings.each do |rating| %>

  <div class="form-check form-check-inline">

  <%= label_tag "ratings[#{rating}]", rating, class: 'form-check-label' %>

  <%= check_box_tag "ratings[#{rating}]", "1", @ratings_to_show.include?(rating), class: 'form-check-input' %>

  </div> <% end %> <%= submit_tag 'Refresh', id: 'ratings_submit', class: 'btn btn-primary' %>

<%end%>
<table class="table table-striped col-md-12" id="movies">
  <thead>
    <tr>
      <th><%= link_to "Movie Title", { :sort => "name", :ratings => params[:ratings] }, { :class => @sort_column_class_title } %></th>
      <th>Rating</th>
      <th><%= link_to "Release Date", { :sort => "date", :ratings => params[:ratings] }, { :class => @sort_column_class_date } %></th>
      <th>More Info</th>
    </tr>
  </thead>
  <tbody>
    <% @movies.each do |movie| %>
      <tr>
        <td>
          <%= movie.title %>
        </td>
        <td>
          <%= movie.rating %>
        </td>
        <td>
          <%= movie.release_date %>
        </td>
        <td>
          <%= link_to "More about #{movie.title}", movie_path(movie) %>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>
<%= link_to 'Add new movie', new_movie_path, :class => 'btn btn-primary' %>

```
Despues agregamos un metodo a la clase movie:
```ruby
class Movie < ActiveRecord::Base
    def self.all_ratings
        ['G','PG','PG-13','R']
    end
    def self.with_ratings(ratings)
        if ratings.length == 0
          Movie.all
        else
          Movie.where(rating: ratings)
        end
    end
end
```
Finalmente, un cambio final en el controlador movies_controller.rb
```ruby
class MoviesController < ApplicationController
  def index
    @all_ratings = Movie.all_ratings
  
    # Limpiar la sesión si la URL no contiene "movies"
    session.clear unless request.original_url.include?('movies')
  
    # Restaurar parámetros de sesión si no se proporcionan nuevos
    params[:ratings] ||= session[:ratings]
    params[:sort] ||= session[:sort]
  
    # Inicializar variables de instancia para las clases de columnas
    @sort_column_class_title = nil
    @sort_column_class_date = nil
  
    # Obtener las clasificaciones seleccionadas del formulario
    @ratings_to_show = params[:ratings]&.keys || []
  
    # Ordenar las películas
    @movies = Movie.with_ratings(@ratings_to_show)
    sort_column = params[:sort]
  
    case sort_column
    when 'name'
      @movies = @movies.order(:title)
      @sort_column_class_title = 'hilite p-3 mb-2 bg-warning text-dark'
    when 'date'
      @movies = @movies.order(:release_date)
      @sort_column_class_date = 'hilite p-3 mb-2 bg-warning text-dark'
    end
  
    # Actualizar parámetros de sesión
    session[:ratings] = params[:ratings]
    session[:sort] = sort_column
  end
  
end
```
### Pull request
