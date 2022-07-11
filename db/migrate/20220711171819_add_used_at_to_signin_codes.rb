class AddUsedAtToSigninCodes < ActiveRecord::Migration[7.0]
  def change
    add_column :signin_codes, :used_at, :timestamp
  end
end
