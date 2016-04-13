require "active_record"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define(version: 0) do
  create_table :users do |t|
    t.string :email, null: false
    t.string :password_digest, null: false
  end
end
