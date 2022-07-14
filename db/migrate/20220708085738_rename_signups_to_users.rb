class RenameSignupsToUsers < ActiveRecord::Migration[7.0]
  def change
    rename_table :signups, :users
  end
end
