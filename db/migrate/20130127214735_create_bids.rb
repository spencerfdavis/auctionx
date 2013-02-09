class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.integer :bidder_id
      t.integer :auction_id
      t.float :price
      t.datetime :bid_time

      t.timestamps
    end
  end
end
