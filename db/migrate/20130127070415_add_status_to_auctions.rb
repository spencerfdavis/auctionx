class AddStatusToAuctions < ActiveRecord::Migration
  def change
    add_column :auctions, :status, :integer, :default => Auction::SCHEDULED
  end
end
