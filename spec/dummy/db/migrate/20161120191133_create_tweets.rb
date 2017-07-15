class CreateTweets < ActiveRecord::Migration[5.0]
  def change
    create_table :tweets do |t|
      t.references :parent, foreign_key: true, null: true
      t.references :author, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
