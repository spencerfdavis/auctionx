class Auction < ActiveRecord::Base
  belongs_to :user
  has_many :bids
  
  SCHEDULED = 0
  ACTIVE = 1
  CANCELLED = 2
  COMPLETED = 3
  
  LIMIT = 5
  
  scope :scheduled, lambda{ where(status: SCHEDULED)}
  scope :active, lambda{ where(status: ACTIVE)}  
  scope :cancelled, lambda{ where(status: CANCELLED)}
  scope :completed, lambda{ where(status: COMPLETED)}
  
  before_create :parse_auction_id, :set_description
  after_create :spawn_auction_process
  
  def current_price
    bids.last.nil? ? "N/A" : bids.last.price
  end
  
  def total_bids
    bids.count
  end
  
  def last_active_bidders
    bids.select("DISTINCT(bidder_id), bidders.username, count(*) as total_bids, bid_time").order("bids.id desc").group("bidder_id").joins(:bidder).limit(LIMIT)
  end
  
  def most_active_bidders
    bids.select("DISTINCT(bidder_id), bidders.username, count(*) as total_bids, bid_time").order("total_bids desc").group("bidder_id").joins(:bidder).limit(LIMIT)    
    #bids.order("count_all DESC").joins(:bidder).limit(LIMIT).count(:group=>"bidders.username")
  end
  
  private
  def parse_auction_id
    self.site_id = url.scan(/auction_id=(\d*)/).flatten.first
  end
  
  def set_description
    agent = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari'} 
    page = agent.get(url)
    self.description = page.title
  end
  
  def spawn_auction_process
    pid = Process.spawn("rails runner \"DealDash.run('#{id}')\" -e #{Rails.env}")
    Process.detach pid
    self.process_id = pid
    self.save
    puts "\n\n\n FETCH"
  end
  
end
