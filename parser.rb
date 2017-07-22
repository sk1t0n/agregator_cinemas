require 'open-uri'
require 'nokogiri'

url = 'http://www.kino11.ru/pars.php?day='
day = 0.to_s
#day=0 вчера
#day=1 сегодня
#day=2 завтра
#day=3 после завтра
#day=4 после после завтра

html = Nokogiri::HTML(open(url + day), nil, 'utf-8')
movies = Hash.new

movie_names = []
html.css('#fast_s_data>p').each { |p| movie_names << p.text }
movie_names.delete_at(-1)

html.css('.kp3>div').each_with_index do |div, i| 
  movies[movie_names[i]] = { :age_rating => div.text }
end

html.css('.kp>img').each_with_index do |img, i| 
  movies[movie_names[i]][:image] = 'http://kino11.ru/' + img['src']
end

html.css('.slotFilm article.artH div.articleBody3 span.inf2').each_with_index do |span, i|
  if i % 6 == 0
    movies[movie_names[i / 6]][:country] = span.text
  elsif i % 6 == 1
    movies[movie_names[i / 6]][:producer] = span.text
  elsif i % 6 == 2
    movies[movie_names[i / 6]][:genre] = span.text
  elsif i % 6 == 3
    movies[movie_names[i / 6]][:budget] = span.text
  elsif i % 6 == 4
    movies[movie_names[i / 6]][:duration] = span.text
  elsif i % 6 == 5
    movies[movie_names[i / 6]][:actors] = span.text
  end 
end

html.css('.slotFilm div.inf3>p').each_with_index do |p, i|
  movies[movie_names[i]][:description] = p.text
end

def add_cinema_to_movies(div, str, movie_names, movies, i, cinema_name)
  cinema = div.css(str)
  str1 = cinema.css('.str1')
  str1_times = []
  str1.css('div').each { |div| str1_times << div.text }
  str2 = cinema.css('span.str2')
  str2_formats = []
  str2.size.times do |i|
    if str2[i].text.size == 0
      str2_formats << ''
    else
      str2_formats << str2[i].text
    end
  end
  str3 = cinema.css('span.str3')
  str3_prices = []
  str3.each { |span| str3_prices << span.text.split('р')[0] }
  movies[movie_names[i]][cinema_name] = { :session_times => str1_times }
  movies[movie_names[i]][cinema_name][:session_formats] = str2_formats
  movies[movie_names[i]][cinema_name][:session_prices] = str3_prices
end

html.css('div.slotFilm div.inf div.namef ~ div.articleBody2').each_with_index do |div, i|
  add_cinema_to_movies(div, 'div.maxi_k div.str', movie_names, movies, i, 'maxi')
  add_cinema_to_movies(div, 'div.rublik_k div.str', movie_names, movies, i, 'rublik')
  add_cinema_to_movies(div, 'div.mori_k div.str', movie_names, movies, i, 'mori')
  add_cinema_to_movies(div, 'div.parma_k div.str', movie_names, movies, i, 'parma')
  add_cinema_to_movies(div, 'div.raduga_k div.str', movie_names, movies, i, 'raduga')
end

rating_kp_img = html.css('.kp>img')
kinopoisk_ids = rating_kp_img.map { |img| img['src'].split('/')[1].split('.')[0] }
kinopoisk_movie_names = rating_kp_img.map { |img| img['alt'].split(' -')[1] }

kinopoisk_ids.size.times { |i| puts 'https://rating.kinopoisk.ru/' + kinopoisk_ids[i] + '.xml' }

kinopoisk_movie_names.each_with_index do |name, i|
  url = 'https://rating.kinopoisk.ru/' + kinopoisk_ids[i] + '.xml'
  xml  = Nokogiri::XML(open(url))
  movies[name][:ratings] = { 
#    :kinopoisk => { :rating => xml.css('kp_rating').text, :num_vote => xml.css('kp_rating')[i]['num_vote'] }, 
#    :imdb => { :rating => xml.css('imdb_rating').text, :num_vote => xml.css('imdb_rating')[i]['num_vote'] }
  }
end

#puts 'url: ' + url + day
#puts "\n"
#movies.size.times do |i|
#  puts movies.keys[i]
#  puts movies[movies.keys[i]]
#  puts "\n"
#end