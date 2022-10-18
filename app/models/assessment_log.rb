class AssessmentLog < ApplicationRecord
  enum api_name: {
    onboarding: 'onboarding',
    login: 'login'
  }
end
