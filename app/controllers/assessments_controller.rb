class AssessmentsController < ApplicationController
  def assess
    account_id = params.fetch(:account_id)
    user = User.find_by!(account_id:)

    form = Assessments::AssessForm.new(
      user:,
      installation_id: request.headers[INCOGNIA_INSTALLATION_ID_HEADER],
    )
    assessments = form.submit

    if assessments
      serialized_assessments = assessments.map do |assessment|
        AssessmentSerializer.new(assessment:).to_hash
      end

      render json: serialized_assessments
    else
      render json: { errors: form.errors.to_hash }, status: :unprocessable_entity
    end
  end
end
