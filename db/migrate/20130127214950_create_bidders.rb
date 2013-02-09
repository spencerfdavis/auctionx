class CreateBidders < ActiveRecord::Migration
  def change
    create_table :bidders do |t|
      t.string :username

      t.timestamps
    end
  end
end
