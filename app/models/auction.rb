class Auction < ActiveRecord::Base
  belongs_to :user
  has_many :bids
  
  SCHEDULED = 0
  ACTIVE = 1
  CANCELLED = 2
  COMPLETED = 3
  
  LIMIT = 5
  
  scope :scheduled, lambda{ where(status: SCHEDULED).limit(LIMIT)}
  scope :active, lambda{ where(status: ACTIVE).limit(LIMIT)}  
  scope :cancelled, lambda{ where(status: CANCELLED).limit(LIMIT)}
  scope :completed, lambda{ where(status: COMPLETED).limit(LIMIT)}
  
  before_create :parse_auction_id, :set_description
  after_create :spawn_auction_process
  after_destroy :kill_watcher_process
  
  def current_price
    bids.last.nil? ? "N/A" : bids.last.price
  end
  
  def total_bids
    bids.count
  end

  def last_active_bidders
    bids.select("distinct(bidder_id), bidders.username, count(*) as total_bids, MAX(bid_time) as latest_bid").
         group("bidder_id").
         joins(:bidder).
         order("MAX(bid_time) desc").limit(LIMIT)
  end

  def most_active_bidders
    bids.select("DISTINCT(bidder_id), bidders.username, count(*) as total_bids, MAX(bid_time) as latest_bid").
         order("total_bids desc").
         group("bidder_id").
         joins(:bidder).limit(LIMIT)
  end
  
private
  def kill_watcher_process
    system "kill -9 #{process_id}"
  end

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
  end
end