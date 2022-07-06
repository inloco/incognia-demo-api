FactoryBot.define do
  factory :signup do
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
end
