class CreateSequenceTable < ActiveRecord::Migration
  def self.up
    create_table :sequence do |t|
      t.string :otu_identifier
      t.text :sequence
    end

    add_index :sequence, :otu_identifier
  end

  def self.down
    drop_table :sequence
  end
end
