class CreateUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base
    has_secure_password
  end

  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    User.create!(email: 'john@example.com', password: 'test')
  end
end
