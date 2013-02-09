module AuctionsHelper
  def status(status)
    case status
      when Auction::SCHEDULED then "Scheduled"
      when Auction::ACTIVE then "Active"      
    end
  end
end
