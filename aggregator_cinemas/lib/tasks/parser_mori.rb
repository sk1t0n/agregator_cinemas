class ParserMori
  require 'open-uri'
  require 'nokogiri'

  attr_reader :movies
  attr_accessor :movie_names
  attr_accessor :movie_urls
  attr_accessor :html
  attr_accessor :url_films

  # 4768 - Сыктывкар
  # https://mori-cinema.ru/tickets/4768/2599001/
  def initialize(id = '4768')
    self.url_films = 'https://mori-cinema.ru/films/'
    @movies = {}
    self.movie_names = []
    self.movie_urls = []
    self.html = Nokogiri::HTML(open(url_films).read.encode('utf-8'), nil , nil)
  end

  def run
    fill_movie_names_urls(movie_names,   movie_urls, url_films)
    add_sessions_to_movies
    movies.each_with_index do |movie, i|
      puts movie_names[i]
      puts movie
      puts '---------------------------------------------'
    end
  end

  def fill_movie_names_urls(movie_names, movie_urls, url)
    html = Nokogiri::HTML(open(url).read.encode('utf-8'), nil, nil)
    html.css('div[tab=THEATER]>ul.cat_films>li').each do |li|
      movie_names << li.css('div.films>span.title').text
      movie_urls.push << 'https://mori-cinema.ru' + li.css('div.films>a')[0]['href']
    end
  end

  def add_sessions_to_movies
    require 'date'
    movie_urls.each_with_index do |url, url_index|
      movies[url_index] = {}
      sessions = []
      url_ticket = 'https://mori-cinema.ru/tickets/4768/' + movie_urls[url_index].split('/')[-1].split('_')[0] + '/'
      html = Nokogiri::HTML(open(url_ticket).read.encode('utf-8'), nil, nil)
      session_date = nil
      day = {}
      html.css('table.tbl_timetable').each_with_index do |table, tbl_idx|
        if tbl_idx == 0
          session_date = Date.today.strftime("%d.%m.%Y")
        elsif tbl_idx == 1
          session_date = (Date.today + 1).strftime("%d.%m.%Y")
        elsif tbl_idx > 1
          session_date = table.at_css('tbody>tr:first>th').text.strip
        end
        day = { date: session_date, data: [] }
        if table.css('tr.color').count > 0
          table.css('tr.color').each_with_index do |tr, tr_idx|
            next if tr.text.strip.length == 0
            session_times = []
            session_prices = []
            nth_child_format_idx = tr_idx == 0 ? 2 : 1
            session_format = tr.at_css("td:nth-child(#{nth_child_format_idx})").text
            if tr.at_css("td:nth-child(#{nth_child_format_idx + 1})>a")
              tr.css("td:nth-child(#{nth_child_format_idx + 1})>a").each_with_index do |a|
                session_times << a.text
                url = 'https://mori-cinema.ru' + a.attr('href')
                session_prices << url #get_price(url)
              end
            end
            day[:data] << { format: session_format, times: session_times, prices: session_prices }
          end
        end
        sessions << day
      end
      movies[url_index][:sessions] = sessions
    end
  end

  def get_price(url)
    html = Nokogiri::HTML(open(url).read.encode('utf-8'), nil, nil)
    puts price = html.css('[id="Type1"]').text.strip
    price
  end
end
