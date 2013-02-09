class AddSiteIdToAuction < ActiveRecord::Migration
  def change
    add_column :auctions, :site_id, :integer
  end
end
