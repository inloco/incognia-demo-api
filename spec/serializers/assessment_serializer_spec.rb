require 'rails_helper'

RSpec.describe AssessmentSerializer, type: :serializer do
  subject(:serialized) { described_class.new(assessment:).to_hash }
  let(:assessment) { build(:assessments_assessment) }

  it 'serializes assessment' do
    expect(serialized).to eq(
      {
        'api_name' => assessment.api_name,
        'timestamp' => assessment.timestamp,
      }
    )
  end
end
