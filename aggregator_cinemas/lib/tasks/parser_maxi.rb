class ParserMaxi
  require 'open-uri'
  require 'nokogiri'
  
  attr_reader :movies
  attr_accessor :movie_names
  attr_accessor :movie_urls
  attr_accessor :html
  attr_accessor :url
  
  # CINEMA_ID=8703 - кинотеатр: Кронверк Синема Макси / Сыктывкар
  def initialize(cinema_id: '8703')
    self.url = "http://www.formulakino.ru/bitrix/templates/formulakino/ajax/cinema_schedule.php?CINEMA_ID=#{cinema_id}"
    @movies = {}
    self.movie_names = []
    self.movie_urls = []
    self.html = Nokogiri::HTML(open(url), nil, 'utf-8')
  end
  
  def run
    fill_movie_names_urls(movie_names, movie_urls, url)
    add_data(movie_names, movie_urls, html)
  end
  
  def fill_movie_names_urls(movie_names, movie_urls, url)
    html = Nokogiri::HTML(open(url), nil, 'utf-8')
    html.css('div.cinemas>div.item>b.name>a').each do |a|
      movie_names << a.text
      movie_urls << 'http://formulakino.ru' + a['href']
    end
  end
  
  def add_data(movie_names, movie_urls, html)
    movie_urls.each_with_index do |url, i|
      html = Nokogiri::HTML(open(url), nil, 'utf-8')
      add_trailer_to_movies(html, movie_names[i])
      add_images_to_movies(html, movie_names[i])
      add_data_to_movies(html, movie_names[i])
      add_description_to_movies(html, movie_names[i])
    end
    add_sessions_to_movies(url)
  end
  
  def add_trailer_to_movies(html, name)
    @movies[name] = {}
    if html.css('div.pane0').size > 0
      @movies[name][:trailer] = 'http:' + html.css('div.pane0 a.fancybox').attr('href')
    else
      @movies[name][:trailer] = nil
    end
  end
  
  def add_images_to_movies(html, name)
    img_urls = []
    html.css('div.frames-list-gal img').each do |img|
      img_urls << 'http://formulakino.ru' + img['data-src']
    end
    @movies[name][:images] = img_urls
  end
  
  def add_data_to_movies(html, name)
    items = []
    html.css('aside>div.props').text.split("\n").each { |item| items << item.strip if item.size > 0 }
    items.each_with_index do |item, i|
      case item
      when /форматах|формате/
        @movies[name][:format] = items[i+1]
      when /Язык/
        @movies[name][:language] = items[i+1]
      when /Продолжительность$/
        @movies[name][:duration] = items[i+1]
      when /сеанса/
        @movies[name][:duration_session] = items[i+1]
      when /Жанр/
        @movies[name][:genre] = items[i+1]
      when /Возрастные/
        @movies[name][:age_rating] = items[i+1]
      when /Страна/
        @movies[name][:country] = items[i+1]
      when /Год/
        @movies[name][:year] = items[i+1]
      when /Режиссер|Режиссеры/
        @movies[name][:director] = items[i+1]
      when /Продюсер/
        @movies[name][:producer] = items[i+1]
      when /озвучивали|ролях/
        @movies[name][:actors] = items[i+1]
      when /мире/
        @movies[name][:date_world] = items[i+1]
      when /России/
        @movies[name][:date_russia] = items[i+1]
      end
    end
  end
  
  def add_description_to_movies(html, name)
    @movies[name][:description] = html.css('div.detailtext').text.strip
  end
  
  def add_sessions_to_movies(url)
    html = Nokogiri::HTML(open(url), nil, 'utf-8')
    html.css('div.item').each do |item|
      movie_name = item.css('b>a').text
      @movies[movie_name][:sessions] = []
      item.css('div.hall').each do |hall|
        hall_name = hall.css('span.hall-name-type').text.strip
        hall.css('div.times').each do |times|
          times.css('span.date').each do |span_date|
            session_date = span_date['data-date']
            span_date.css('span.hide320').each do |hide320|
              data_id = hide320['data-id']
              session_time = hide320.css('a.tr_chart').text.strip.split("\t")[0]
              format = hide320.css('span.marker').text
              @movies[movie_name][:sessions].push({
                hall_name: hall_name,
                session_date: session_date,
                session_time: session_time,
                format: format,
                session_price: get_movie_session_price(data_id)
              })
            end
          end
        end
      end
    end
  end
  
  def get_movie_session_price(id)
    require 'json'
    url = "http://www.formulakino.ru/ajax/movieSchedule/getPrice/?id=#{id}"
    json = JSON.parse(Nokogiri::HTML(open(url), nil, 'utf-8').css('p').text)
    if json['success']
      price = json['data'][0]['SUM_RUB']
    else
      price = nil
    end
    return price
  end
end