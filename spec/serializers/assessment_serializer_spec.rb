require 'rails_helper'

RSpec.describe AssessmentSerializer, type: :serializer do
  subject(:serialized) { described_class.new(assessment:).to_hash }

  context 'when it is an onboarding assessment' do
    let(:assessment) { create(:assessment_log, :onboarding) }

    it 'serializes assessment with incognia_signup_id as id' do
      expect(serialized).to eq(
        {
          'api_name' => assessment.api_name,
          'id' => assessment.incognia_signup_id,
          'timestamp' => assessment.created_at,
        }
      )
    end
  end

  AssessmentLog.api_names.except(:onboarding).values.each do |api_name|
    context "when it is an #{api_name} assessment" do
      let(:assessment) { create(:assessment_log, :login) }

      it 'serializes assessment with incognia_id as id' do
        expect(serialized).to eq(
          {
            'api_name' => assessment.api_name,
            'id' => assessment.incognia_id,
            'timestamp' => assessment.created_at,
          }
        )
      end
    end
  end
end
