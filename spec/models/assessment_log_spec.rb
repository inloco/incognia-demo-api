require 'rails_helper'

RSpec.describe AssessmentLog, type: :model do
  subject(:log) { build(:assessment_log) }

  it 'defines api_name enum correctly' do
    expected_enum = {
      onboarding: 'onboarding',
      login: 'login'
    }

    expect(log).to define_enum_for(:api_name)
      .with_values(expected_enum)
      .backed_by_column_of_type(:string)
  end
end
