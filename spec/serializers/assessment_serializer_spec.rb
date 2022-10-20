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

  shared_examples_for 'assessment with incognia_id as id' do |opts|
    context "when it is an #{opts[:api_name]} assessment" do
      let(:assessment) { create(:assessment_log, opts[:api_name]) }

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

  it_behaves_like 'assessment with incognia_id as id', api_name: :login
end
