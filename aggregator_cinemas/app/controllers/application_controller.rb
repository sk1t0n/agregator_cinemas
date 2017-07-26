class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true
  add_flash_types :success, :danger, :info, :warning
  
  before_action :add_cinema_ids, :add_cinema_titles
  
  KRONVERK = 'Кронверк Синема'
  MORI = 'Мори Синема'
  RUBLIK = 'Рублион Синема'
  PARMA = 'Рублион Парма'
  RADUGA = 'Радуга 3D'
  
  def add_cinema_ids
    @cinema_ids = []
    if Cinema.where(title: KRONVERK).size > 0
      kronverk_id = Cinema.where(title: KRONVERK).first.id
    end
    if Cinema.where(title: MORI).size > 0
      mori_id = Cinema.where(title: MORI).first.id
    end
    if Cinema.where(title: RUBLIK).size > 0
      rublik_id = Cinema.where(title: RUBLIK).first.id
    end
    if Cinema.where(title: PARMA).size > 0
      parma_id = Cinema.where(title: PARMA).first.id
    end
    if Cinema.where(title: RADUGA).size > 0
      raduga_id = Cinema.where(title: RADUGA).first.id
    end
    
    @cinema_ids.push(kronverk_id, mori_id, rublik_id, parma_id, raduga_id)
  end
  
  def add_cinema_titles
    @cinema_titles = [KRONVERK, MORI, RUBLIK, PARMA, RADUGA]
  end
end