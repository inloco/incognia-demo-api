require 'rails_helper'

RSpec.describe Assessments::Assessment, type: :service do
  subject(:assessment) do
    build(:assessments_assessment, api_name: api_name, timestamp: timestamp)
  end
  let(:api_name) { Faker::Lorem.word }
  let(:timestamp) { Time.now }

  it 'responds to api_name' do
    expect(assessment.api_name).to eq(api_name)
  end

  it 'responds to timestamp' do
    expect(assessment.timestamp).to eq(timestamp)
  end
end
