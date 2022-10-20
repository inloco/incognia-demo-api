class AssessmentsController < ApplicationController
  def assess
    account_id = params.fetch(:user_id)
    user = User.find_by!(account_id:)

    form = Assessments::AssessForm.new(
      user:,
      installation_id: request.headers[INCOGNIA_INSTALLATION_ID_HEADER],
    )
    assessments = form.submit

    if assessments
      render json: serialize_assessments(assessments)
    else
      render json: { errors: form.errors.to_hash }, status: :unprocessable_entity
    end
  end

  def latest
    account_id = params.fetch(:user_id)
    user = User.find_by!(account_id:)
    installation_id = request.headers[INCOGNIA_INSTALLATION_ID_HEADER]

    assessments = Assessments::GetLatestAssessmentLogs.(user:, installation_id:)

    render json: serialize_assessments(assessments)
  end

  private

  def serialize_assessments(assessments)
    serialized_assessments = assessments.map do |assessment|
      AssessmentSerializer.new(assessment:).to_hash
    end
  end
end
