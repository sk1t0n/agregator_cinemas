class ParserKino11Ru
  require 'open-uri'
  require 'nokogiri'
  
  URL = 'http://www.kino11.ru/pars.php?day='

  attr_reader :movies
  attr_accessor :movie_names
  attr_accessor :html
  attr_accessor :day
  
  # * *Args*    :
  #   - +day+ -> день - может принимать значения 0,..,4
  #   day = 0 - вчера
  #   day = 1 - сегодня
  #   day = 2 - завтра
  #   day = 3 - после завтра
  #   day = 4 - после после завтра
  def initialize(day = '0')
    @movies = {}
    self.day = (day != nil && day.to_i >= 0 && day.to_i <= 4) ? day.to_s : '0'
    self.movie_names = []
    self.html = Nokogiri::HTML(open(URL + self.day), nil, 'utf-8')
    fill_movies
  end
  
  def fill_movies
    fill_movie_names
    add_movies_age_rating
    add_movies_image
    add_movies_data
    add_movies_cinemas
    add_movies_ratings
  end
  
  private

  def fill_movie_names
    html.css('#fast_s_data>p').each { |p| movie_names.push(p.text) }
    movie_names.delete_at(-1)
  end

  def add_movies_age_rating
    html.css('.kp3>div').each_with_index do |div, i|
      @movies[movie_names[i]] = { age_rating: div.text }
    end
  end

  def add_movies_image
    html.css('.kp>img').each_with_index do |img, i| 
      @movies[movie_names[i]][:image] = 'http://kino11.ru/' + img['src']
    end
  end

  def add_movies_data
    html.css('.slotFilm article.artH div.articleBody3 span.inf2').each_with_index do |span, i|
      if i % 6 == 0
        @movies[movie_names[i / 6]][:country] = span.text
      elsif i % 6 == 1
        @movies[movie_names[i / 6]][:director] = span.text
      elsif i % 6 == 2
        @movies[movie_names[i / 6]][:genre] = span.text
      elsif i % 6 == 3
        @movies[movie_names[i / 6]][:budget] = span.text
      elsif i % 6 == 4
        @movies[movie_names[i / 6]][:duration] = span.text
      elsif i % 6 == 5
        @movies[movie_names[i / 6]][:actors] = span.text
      end 
    end
    html.css('.slotFilm div.inf3>p').each_with_index do |p, i|
      @movies[movie_names[i]][:description] = p.text
    end
  end

  def add_cinema_to_movies(div, str, movie_names, i, cinema_name)
    cinema = div.css(str)
    str1 = cinema.css('.str1')
    str1_times = []
    str1.css('div').each { |div| str1_times.push(div.text) }
    str2 = cinema.css('span.str2')
    str2_formats = []
    str2.size.times do |i|
      if str2[i].text.size == 0
        str2_formats.push('')
      else
        str2_formats.push(str2[i].text)
      end
    end
    str3 = cinema.css('span.str3')
    str3_prices = []
    str3.each { |span| str3_prices.push(span.text.split('р')[0]) }
    @movies[movie_names[i]][cinema_name] = { session_times: str1_times }
    @movies[movie_names[i]][cinema_name][:session_formats] = str2_formats
    @movies[movie_names[i]][cinema_name][:session_prices] = str3_prices
  end
  
  def add_movies_cinemas
    html.css('div.slotFilm div.inf div.namef ~ div.articleBody2').each_with_index do |div, i|
      add_cinema_to_movies(div, 'div.maxi_k div.str', movie_names, i, 'maxi')
      add_cinema_to_movies(div, 'div.rublik_k div.str', movie_names, i, 'rublik')
      add_cinema_to_movies(div, 'div.mori_k div.str', movie_names, i, 'mori')
      add_cinema_to_movies(div, 'div.parma_k div.str', movie_names, i, 'parma')
      add_cinema_to_movies(div, 'div.raduga_k div.str', movie_names, i, 'raduga')
    end
  end

  def add_movies_ratings
    rating_kp_img = html.css('.kp>img')
    kinopoisk_ids = rating_kp_img.map { |img| img['src'].split('/')[1].split('.')[0] }
    kinopoisk_movie_names = rating_kp_img.map { |img| img['alt'].split(' -')[1] }

    kinopoisk_movie_names.each_with_index do |name, i|
      url = 'https://rating.kinopoisk.ru/' + kinopoisk_ids[i] + '.xml'
      xml  = Nokogiri::XML(open(url))
      puts name
      puts @movies[name]
      puts @movies[name].class
      @movies[name][:kinopoisk] = {}
      @movies[name][:imdb] = {}
      if xml.css('rating imdb_rating').size == 0
        # parse imdb.com
      else
        @movies[name][:imdb] = {
          rating: xml.css('imdb_rating').text,
          num_vote: xml.xpath('//rating//imdb_rating').attr('num_vote').content
        }
      end
      if xml.css('rating kp_rating').size > 0
        @movies[name][:kinopoisk] = { 
          rating: xml.css('kp_rating').text,
          num_vote: xml.xpath('//rating//kp_rating').attr('num_vote').content
        }
      end
    end
  end
end