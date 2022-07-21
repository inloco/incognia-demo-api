shared_examples_for 'form with sign in code validations' do
  it { should validate_presence_of(:code) }

  describe 'code existence' do
    before { attrs.merge!(code: Faker::Lorem.word) }

    it 'is expected to validate that :code is invalid' do
      expect(form).to be_invalid
      expect(form.errors).to have_key(:code)
      expect(form.errors[:code]).to include(I18n.t('errors.messages.invalid'))
    end
  end

  describe 'code usage' do
    before { signin_code.update(used_at: 5.hours.ago) }

    it 'is expected to validate that :code is already used' do
      expect(form).to be_invalid
      expect(form.errors).to have_key(:code)
      expect(form.errors[:code]).to include(
        I18nHelpers.model_attribute_error(
          klass: form.class,
          attribute: :code,
          error_key: :already_used
        )
      )
    end
  end

  describe 'code expiration' do
    before { signin_code.update(expires_at: 5.hours.ago) }

    it 'is expected to validate that :code is expired' do
      expect(form).to be_invalid
      expect(form.errors).to have_key(:code)
      expect(form.errors[:code]).to include(
        I18nHelpers.model_attribute_error(
          klass: form.class,
          attribute: :code,
          error_key: :expired
        )
      )
    end
  end
end
