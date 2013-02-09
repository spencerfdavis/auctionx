class CreateAuctions < ActiveRecord::Migration
  def change
    create_table :auctions do |t|
      t.string :url
      t.string :description
      t.integer :max_bids
      t.integer :user_id
      t.integer :process_id

      t.timestamps
    end
  end
end
