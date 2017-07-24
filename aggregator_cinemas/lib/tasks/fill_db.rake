namespace :fill_db do
  @count_create_items = 0
  @count_update_items = 0
  
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
        @count_update_items += 1
      else
        m = Movie.create(title: name, image: parser_maxi.movies[name][:img_small],
          age_rating: parser_maxi.movies[name][:age_rating], duration: parser_maxi.movies[name][:duration],
          country: parser_maxi.movies[name][:country], producer: parser_maxi.movies[name][:director],
          actors: parser_maxi.movies[name][:actors], description: parser_maxi.movies[name][:description],
          trailer: parser_maxi.movies[name][:trailer], images: parser_maxi.movies[name][:images].join(';'),
          premiere: parser_maxi.movies[name][:date_russia])
        m.save
        @count_create_items += 1
      end
    end
    
    parser_maxi.movie_names.size.times do |i|
      name = parser_maxi.movie_names[i]
      fill_table_movies(name, parser_maxi)
    end
    puts "Количество добавленных фильмов:" + @count_create_items.to_s
    puts "Количество обновлённых фильмов:" + @count_update_items.to_s
  end
end