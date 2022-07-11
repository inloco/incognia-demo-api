class AddAccountFieldsToSignups < ActiveRecord::Migration[7.0]
  def change
    add_column :signups, :account_id, :string
    add_column :signups, :email, :string
    add_index :signups, :email, unique: true
  end
end
