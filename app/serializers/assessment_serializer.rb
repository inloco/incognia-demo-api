class AssessmentSerializer < BaseSerializer
  def initialize(assessment:)
    @assessment = assessment
  end

  def attributes
    { 'api_name' => nil, 'timestamp' => nil }
  end

  def api_name
    assessment.api_name
  end

  def timestamp
    assessment.timestamp
  end

  private

  attr_reader :assessment
end
