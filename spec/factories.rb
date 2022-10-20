FactoryBot.define do
  factory :user do
    account_id { SecureRandom.uuid }
    email { Faker::Internet.email }
    address do
      {
        structured_address:{
          country_name: Faker::Address.country,
          country_code: Faker::Address.country_code,
          state: Faker::Address.state,
          city: Faker::Address.city,
          borough: Faker::Lorem.word,
          street: Faker::Address.street_name,
          number: Faker::Address.building_number,
          postal_code: Faker::Address.zip_code
        }
      }
    end
    incognia_signup_id { SecureRandom.uuid }
  end

  factory :signin_code do
    user
    code { SecureRandom.base64(20) }
    expires_at { 2.minutes.from_now }
  end

  factory :assessment_log do
    incognia_id { SecureRandom.uuid }

    trait :onboarding do
      api_name { :onboarding }
      incognia_signup_id { SecureRandom.uuid }
    end

    trait :non_onboarding do
      api_name do
        AssessmentLog.api_names.except(:onboarding).values.sample.to_sym
      end
      account_id { SecureRandom.uuid }
      installation_id { SecureRandom.hex }
    end
  end

  factory :incognia_assessment, class: OpenStruct do
    id { SecureRandom.uuid }
    risk_assessment { [:low_risk, :unknown_risk, :high_risk].sample }

    trait :signup do
      id { SecureRandom.uuid }
      request_id { SecureRandom.uuid }
    end
  end
end
