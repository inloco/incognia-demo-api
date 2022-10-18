class CreateAssessmentLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :assessment_logs do |t|
      t.string :api_name
      t.string :incognia_id
      t.string :incognia_signup_id
      t.string :account_id
      t.string :installation_id

      t.timestamps
    end
  end
end
