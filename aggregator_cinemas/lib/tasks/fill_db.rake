namespace :fill_db do
  @count_create_items_movie = 0
  @count_update_items_movie = 0
  @count_create_items_genre = 0
  @count_update_items_genre = 0
  @all_genres = []
  @all_genres_movie = {}
  
  desc "Заполнение базы данных с помощью парсера кинотеатра Кронверк Синема"
  task :parser_maxi => :environment do
    require_relative 'parser_maxi'
    parser_maxi = ParserMaxi.new
    parser_maxi.run
    
    def fill_table_movies(name, parser_maxi)
      if Movie.where(title: name).size > 0
        m = Movie.find_by(title: name)
        m.update(
          age_rating: parser_maxi.movies[name][:age_rating], duration: parser_maxi.movies[name][:duration],
          country: parser_maxi.movies[name][:country], producer: parser_maxi.movies[name][:director],
          actors: parser_maxi.movies[name][:actors], description: parser_maxi.movies[name][:description],
          trailer: parser_maxi.movies[name][:trailer], images: parser_maxi.movies[name][:images].join(';'),
          premiere: parser_maxi.movies[name][:date_russia], image: parser_maxi.movies[name][:img_small])
        @count_update_items_movie += 1
      else
        m = Movie.create(title: name, image: parser_maxi.movies[name][:img_small],
          age_rating: parser_maxi.movies[name][:age_rating], duration: parser_maxi.movies[name][:duration],
          country: parser_maxi.movies[name][:country], producer: parser_maxi.movies[name][:director],
          actors: parser_maxi.movies[name][:actors], description: parser_maxi.movies[name][:description],
          trailer: parser_maxi.movies[name][:trailer], images: parser_maxi.movies[name][:images].join(';'),
          premiere: parser_maxi.movies[name][:date_russia])
        m.save
        @count_create_items_movie += 1
      end
    end
    
    def add_all_genres(name, parser_maxi)
      tmp_arr = []
      parser_maxi.movies[name][:genre].split(',').each do |g_name|
        g_name.strip!
        if (g_name =~ /(^\d)|(^[а-я])/) != 0
          @all_genres << g_name.downcase until @all_genres.include?(g_name.downcase)
          tmp_arr << g_name.downcase until tmp_arr.include?(g_name.downcase)
        end
      end
      @all_genres_movie[name] = tmp_arr
    end
      
    def fill_table_genres
      @all_genres.each do |name|
        if Genre.where(title: name).size > 0
          g = Genre.find_by(title: name)
          g.update(title: name)
          @count_update_items_genre += 1
        else
          g = Genre.create(title: name)
          g.save
          @count_create_items_genre += 1
        end
      end
    end
      
    def fill_table_genre_movies(parser_maxi)
      parser_maxi.movie_names.size.times do |i|
        name = parser_maxi.movie_names[i]
        movie_id = Movie.where(title: name).ids[0]
        @all_genres_movie[name].each do |g_name|
          genre_id = Genre.where(title: g_name).ids[0]
          gm = GenreMovie.create(genre_id: genre_id, movie_id: movie_id)
          gm.save
        end
      end
    end
    
    parser_maxi.movie_names.size.times do |i|
      name = parser_maxi.movie_names[i]
      fill_table_movies(name, parser_maxi)
      add_all_genres(name, parser_maxi)
    end
    fill_table_genres()
    fill_table_genre_movies(parser_maxi)
    
    puts "Количество добавленных фильмов:" + @count_create_items_movie.to_s
    puts "Количество обновлённых фильмов:" + @count_update_items_movie.to_s
    puts "Количество добавленных жанров:" + @count_create_items_genre.to_s
    puts "Количество обновлённых жанров:" + @count_update_items_genre.to_s
  end
end