namespace :fill_db do
  @count_create_items_movie = 0
  @count_update_items_movie = 0
  @count_create_items_genre = 0
  @count_update_items_genre = 0
  @count_create_items_movie_session = 0
  @count_delete_items_movie_session = 0
  @all_genres = []
  @all_genres_movie = {}
  
  desc "Заполнение базы данных с помощью парсера кинотеатра Мори Синема"
  task parser_mori: :environment do
    require_relative 'parser_mori'
    
    MORI = 'Мори Синема'
    
    parser_mori = ParserMori.new
    parser_mori.run
  end
  
  desc "Заполнение базы данных с помощью парсера кинотеатра Кронверк Синема"
  task parser_maxi: :environment do
    require_relative 'parser_maxi'
    
    KRONVERK = 'Кронверк Синема'
    
    def fill_table_movies(name, parser_maxi)
      if Movie.where(title: name).size > 0
        m = Movie.find_by(title: name)
        result = m.update(age_rating: parser_maxi.movies[name][:age_rating], duration: parser_maxi.movies[name][:duration],
          country: parser_maxi.movies[name][:country], director: parser_maxi.movies[name][:director],
          actors: parser_maxi.movies[name][:actors], description: parser_maxi.movies[name][:description],
          trailer: parser_maxi.movies[name][:trailer], images: parser_maxi.movies[name][:images].join(';'),
          premiere: parser_maxi.movies[name][:date_russia])
        @count_update_items_movie += 1 if result != nil
      else
        m = Movie.create(title: name, age_rating: parser_maxi.movies[name][:age_rating], 
          duration: parser_maxi.movies[name][:duration], country: parser_maxi.movies[name][:country], 
          director: parser_maxi.movies[name][:director], actors: parser_maxi.movies[name][:actors], 
          description: parser_maxi.movies[name][:description], trailer: parser_maxi.movies[name][:trailer], 
          images: parser_maxi.movies[name][:images].join(';'), premiere: parser_maxi.movies[name][:date_russia])
        @count_create_items_movie += 1 if m.save
      end
    end
    
    def add_all_genres(name, parser_maxi)
      tmp_arr = []
      parser_maxi.movies[name][:genre].split(',').each do |g_name|
        g_name.strip!
        if (g_name =~ /(^\d)|(^[а-я])/) != 0
          @all_genres.push(g_name.capitalize) until @all_genres.include?(g_name.capitalize)
          tmp_arr.push(g_name.capitalize) until tmp_arr.include?(g_name.capitalize) 
        end
      end
      @all_genres_movie[name] = tmp_arr
    end
      
    def fill_table_genres
      @all_genres.each do |name|
        if Genre.where(title: name).size > 0
          g = Genre.find_by(title: name)
          result = g.update(title: name)
          @count_update_items_genre += 1 if result != nil
        else
          g = Genre.create(title: name)
          @count_create_items_genre += 1 if g.save
        end
      end
    end
      
    def fill_table_genre_movies(parser_maxi)
      parser_maxi.movie_names.size.times do |i|
        name = parser_maxi.movie_names[i]
        movie_id = Movie.where(title: name).first.id
        @all_genres_movie[name].each do |g_name|
          genre_id = Genre.where(title: g_name).first.id
          if GenreMovie.where(genre_id: genre_id, movie_id: movie_id).size == 0
            GenreMovie.create(genre_id: genre_id, movie_id: movie_id).save
          end
        end
      end
    end
        
    def fill_table_movie_sessions(name, parser_maxi)
      cinema = Cinema.where(title: KRONVERK)
      cinema_id = cinema.first.id if cinema.size > 0
      movie = Movie.where(title: name)
      movie_id = movie.first.id if movie.size > 0
      if cinema_id != nil && movie_id != nil
        if MovieSession.where(cinema_id: cinema_id, movie_id: movie_id).size == 0
          parser_maxi.movies[name][:sessions].each do |session|
            session_date = session[:session_date]
            session_time = session[:session_time]
            if session[:format].size > 2
              format = session[:format].split('D').join('D ')
            else
              format = session[:format]
            end
            session_price = session[:session_price]
            ms = MovieSession.create(date: session_date, time: session_time, format: format, 
              price: session_price, cinema_id: cinema_id, movie_id: movie_id)
            @count_create_items_movie_session += 1 if ms.save
          end
        end
      end
    end
        
    def add_Kronverk_to_table_cinemas
      if Cinema.where(title: KRONVERK).size == 0
        Cinema.create(title: KRONVERK).save
      end
    end
        
    def delete_past_sessions
      if Cinema.where(title: KRONVERK).size > 0
        cinema_id = Cinema.where(title: KRONVERK).first.id
        d = Time.now.strftime("%Y-%m-%d")
        t = Time.now.strftime("%H:%M:%S")
        MovieSession.where(cinema_id: cinema_id).where("`date` < ? OR (`date` = ? AND `time` < ?)" , d, d, t)
          .each do |session|
          @count_delete_items_movie_session += MovieSession.delete(session.id)
        end
      end
    end

    parser_maxi = ParserMaxi.new
    parser_maxi.run

    add_Kronverk_to_table_cinemas
    parser_maxi.movie_names.size.times do |i|
      name = parser_maxi.movie_names[i]
      puts "Обрабатываются данные по фильму #{name}"
      fill_table_movies(name, parser_maxi)
      fill_table_movie_sessions(name, parser_maxi)
      add_all_genres(name, parser_maxi)
    end
    fill_table_genres
    fill_table_genre_movies(parser_maxi)
    delete_past_sessions

    puts 'Количество добавленных фильмов: ' + @count_create_items_movie.to_s
    puts 'Количество обновлённых фильмов: ' + @count_update_items_movie.to_s
    puts 'Количество добавленных жанров: ' + @count_create_items_genre.to_s
    puts 'Количество обновлённых жанров: ' + @count_update_items_genre.to_s
    puts 'Количество добавленных сеансов: ' + @count_create_items_movie_session.to_s
    puts 'Количество удалённых сеансов: ' + @count_delete_items_movie_session.to_s
  end
end