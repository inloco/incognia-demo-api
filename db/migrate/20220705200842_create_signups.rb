class CreateSignups < ActiveRecord::Migration[7.0]
  def change
    create_table :signups do |t|
      t.json :address
      t.string :incognia_signup_id

      t.timestamps
    end
  end
end
