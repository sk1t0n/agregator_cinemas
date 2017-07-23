class ParserMaxi
  require 'open-uri'
  require 'nokogiri'
  
  attr_reader :movies
  attr_accessor :movie_names
  attr_accessor :movie_urls
  attr_accessor :html
  attr_accessor :url
  
  # -- параметры GET-запроса --
  # cinema=461 - кинотеатр: Кронверк Синема Макси / Сыктывкар
  # age - возрастные ограничения: '', '0', '6', '12', '16', '18'
  # when - когда: '', 'today' - сегодня на экранах, 'soon' - скоро на экранах
  # format - формат просмотра: 'any' - любой, '2d', '3d', 'imax', 'kinosale' - акции
  # subtitles - субтитры: '', 'Y'  
  def initialize(cinema: '461', age: '', day: 'today', format: 'any', subtitles: '')
    url = "https://www.formulakino.ru/bitrix/templates/formulakino/ajax/list_main.php?"
    params = "cinema=#{cinema}&age=#{age}&when=#{day}&format=#{format}&subtitles=#{subtitles}&list_template=page"
    self.url = url + params
    @movies = {}
    self.movie_names = []
    self.movie_urls = []
    self.html = Nokogiri::HTML(open(self.url), nil, 'utf-8')
  end
  
  def run
    fill_movie_names_urls(movie_names, movie_urls, html)
    add_data(movie_names, movie_urls, html)
#    movie_names.each do |name|
#      puts name
#      puts @movies[name]
#      puts "\n"
#    end
  end
  
  def fill_movie_names_urls(movie_names, movie_urls, html)
    html.css('div.info>h2>a').each do |a|
      movie_names << a.text
      movie_urls << 'http://formulakino.ru' + a['href']
    end
  end
  
  def add_data(movie_names, movie_urls, html)
    add_image_small_to_movies(movie_names, html)
    movie_urls.each_with_index do |url, i|
      html = Nokogiri::HTML(open(url), nil, 'utf-8')
      add_trailer_to_movies(html, movie_names[i])
      add_images_to_movies(html, movie_names[i])
      add_data_to_movies(html, movie_names[i])
      add_description_to_movies(html, movie_names[i])
#      add_sessions_to_movies(html, movie_names[i])
    end
  end
  
  def add_image_small_to_movies(movie_names, html)
    html.css('article img').each_with_index do |img, i| 
      movies[movie_names[i]] = { img_small: 'http://formulakino.ru' + img['src'] }
    end
  end
  
  def add_trailer_to_movies(html, name)
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
  
#  def add_sessions_to_movies(html, name)
#    
#  end
end