module ApplicationHelper
  def format_date(date)
    date.localtime.strftime("%m/%d/%Y %I:%M:%S %p")    
  end
  
  def format_time(time)
    time.localtime.strftime("%I:%M:%S %p")    
  end  
end
