class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true
  add_flash_types :success, :danger, :info, :warning
  
  before_action :add_cinema_ids
  
  def add_cinema_ids
    @cinema_ids = []
    if Cinema.where(title: 'Кронверк Синема').size > 0
      kronverk_id = Cinema.where(title: 'Кронверк Синема').first.id
    elsif Cinema.where(title: 'Мори Синема').size > 0
      mori_id = Cinema.where(title: 'Мори Синема').first.id
    elsif Cinema.where(title: 'Рублион Синема').size > 0
      rublik_id = Cinema.where(title: 'Рублион Синема').first.id
    elsif Cinema.where(title: 'Рублион Парма').size > 0
      parma_id = Cinema.where(title: 'Рублион Парма').first.id
    elsif Cinema.where(title: 'Радуга 3D').size > 0
      raduga_id = Cinema.where(title: 'Радуга 3D').first.id
    end
    
    @cinema_ids.push(kronverk_id, mori_id, rublik_id, parma_id, raduga_id)
end
