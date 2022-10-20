require 'rails_helper'

RSpec.describe Assessments::AssessForm, type: :model do
  subject(:form) { described_class.new(attrs) }
  let(:attrs) { {} }

  context 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:installation_id) }
  end

  describe '#submit' do
    subject(:submit) { form.submit }

    context 'when attributes are valid' do
      let(:attrs) { { user:, installation_id: } }
      let(:user) { build(:user) }
      let(:installation_id) { SecureRandom.uuid }
      let(:returned_assessments) { [signup_assessment, login_assessment] }

      before do
        allow(Assessments::AssessSignup).to receive(:call)
          .and_return(signup_assessment)
        allow(Assessments::AssessLogin).to receive(:call)
          .and_return(login_assessment)
      end
      let(:signup_assessment) { build(:assessments_assessment) }
      let(:login_assessment) { build(:assessments_assessment) }

      it 'invokes assess signup service' do
        expect(Assessments::AssessSignup).to receive(:call).with(user:)

        submit
      end

      it 'invokes assess login service' do
        expect(Assessments::AssessLogin).to receive(:call)
          .with(user:, installation_id:)

        submit
      end

      it "returns requested assessments" do
        assessments = submit

        expect(assessments).to match_array(returned_assessments)
      end
    end

    context 'when attributes are invalid' do
      let(:attrs) { {} }

      it 'does not request assessments' do
        expect(Assessments::AssessSignup).to_not receive(:call)
        expect(Assessments::AssessLogin).to_not receive(:call)

        submit
      end

      it 'returns falsy' do
        expect(submit).to be_falsy
      end
    end
  end
end
