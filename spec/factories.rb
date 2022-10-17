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

  factory :assessments_assessment, class: Assessments::Assessment do
    api_name { Faker::Lorem.word }
    timestamp { Time.now }

    initialize_with { new(attributes) }
  end
end
