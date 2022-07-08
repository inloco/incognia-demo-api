class CreateSigninCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :signin_codes do |t|
      t.string :code
      t.timestamp :expires_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
