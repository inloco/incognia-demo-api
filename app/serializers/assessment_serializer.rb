class AssessmentSerializer < BaseSerializer
  def initialize(assessment:)
    @assessment = assessment
  end

  def attributes
    { 'api_name' => nil, 'id' => nil, 'timestamp' => nil }
  end

  def api_name
    assessment.api_name
  end

  def id
    return assessment.incognia_signup_id if assessment.onboarding?

    assessment.incognia_id
  end

  def timestamp
    assessment.created_at.to_i
  end

  private

  attr_reader :assessment
end
