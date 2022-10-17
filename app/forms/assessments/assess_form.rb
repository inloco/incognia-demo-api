module Assessments
  class AssessForm
    include ActiveModel::Model

    attr_accessor :user, :installation_id

    validates :user, presence: true
    validates :installation_id, presence: true

    def submit
      return unless valid?

      [
        Assessments::AssessSignup.(user:),
        Assessments::AssessLogin.(user:, installation_id:),
      ]
    end
  end
end
