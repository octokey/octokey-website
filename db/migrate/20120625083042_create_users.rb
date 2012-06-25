class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.text :email
      t.text :name
      t.text :public_keys
      t.boolean :verified
      t.timestamps
    end
  end

  def down
    drop_table :users
  end
end
