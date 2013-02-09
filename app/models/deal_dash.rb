class DealDash
  attr_accessor :auction_id, :agent, :auction
  
  def self.run(auction_id)
    dd = DealDash.new({:auction_id => auction_id})
    puts "Watching Auction:#{auction_id}"
    dd.process
  end

  def initialize(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
    @auction = Auction.find(@auction_id)
    @auction.update_attribute(:status, Auction::ACTIVE)
    @agent = setup_agent
  end
  
  def process
    auction_page = agent.get(auction.url)
    
    loop do
      raw_data = agent.get(details_url)  
      data = JSON.parse(raw_data.body)
      puts data.inspect
      
      #Check if auction is over
      logout if is_ended?(data)
      collect_history(data)
      sleep 5
    end
  end
  
  private
  def collect_history(data)
    data["auctionsDetails"].first["history"].reverse.each do |history|
      price, time, username, action = history[0].to_f, Time.parse(history[1]), history[2], history[3]
      bidder = Bidder.find_or_create_by_username(username)
      last_entry = Bid.where(:auction_id => auction_id).last
      
      if last_entry.nil?
        puts "Last Entry Nil boy"
        bid = Bid.create({:auction_id => auction_id, 
                          :bidder_id => bidder.id, 
                          :price => price, 
                          :bid_time => time})
      else
        bid = Bid.create({:auction_id => auction_id, 
                          :bidder_id => bidder.id, 
                          :price => price, 
                          :bid_time => time}) if (price > last_entry.price)    
      end    
      
    end
  end
  
  def logout
    puts "Logging Out"
    @auction.update_attribute(:status, Auction::COMPLETED)
    exit
  end
  
  def is_ended?(data)
    result = data["auctionsDetails"].first["data"].include?("SOLD")
    if result 
      puts "Auction ID:#{auction_id} is sold!  Logging out and exiting!"
    end
    result
  end
  
  def details_url
    "http://www.dealdash.com/gonzales.php?auctionDetailsIds=#{auction.site_id}"
  end
  
  def setup_agent
    Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari'}    
  end
  # def process
  #    auction = Auction.find(auction_id)
  #    puts "Collecting Data for Auction:#{auction.description} with ID:#{auction.id}"
  #    #puts "Inside new thread doing my thing"
  #    Encoding.default_internal = nil    
  #    a = Mechanize.new { |agent|
  #      agent.user_agent_alias = 'Mac Safari'
  #    }
  # 
  #    page = a.get("http://www.dealdash.com/battle.php?auction_id=#{auction.site_id}")
  #    loop do
  #      raw_data = a.get("http://dealdash.com/auction_product.php?productpage=1&auctionid=#{auction.site_id}")  
  #      data = JSON.parse(raw_data.body)
  # 
  #      #Sold
  #      if data["data"].include?("SOLD")
  #        auction.status = Auction::COMPLETED
  #        auction.save
  #        break
  #      end
  # 
  #      data["history"].reverse.each do |history|
  #        price, time, username, action = history[0].to_f, Time.parse(history[1]), history[2], history[3]
  #        bidder = Bidder.find_or_create_by_username(username)
  #        last_entry = AuctionHistory.where(:auction_id => auction.id).last
  # 
  #        #puts "Creating Auction History for auction_id:#{auction.id}"
  #        if last_entry.nil?
  #          AuctionHistory.create({:auction_id => auction.id, 
  #                                 :bidder_id => bidder.id, 
  #                                 :price => price, 
  #                                 :bid_time => time})
  #        else
  #          #puts "Creating AuctionHistory for Auction ID:#{auction.id}"
  #          AuctionHistory.create({:auction_id => auction.id, 
  #                                 :bidder_id => bidder.id, 
  #                                 :price => price, 
  #                                 :bid_time => time}) if (price > last_entry.price)
  #        end
  #      end
  #      sleep 5
  #    end  
end