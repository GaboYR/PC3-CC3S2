class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
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
  
  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end