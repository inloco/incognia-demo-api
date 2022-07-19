require 'system_helper'

RSpec.describe "Mobile Supported Login", type: :system do
  context 'when user with informed email exists' do
    let(:user) { create(:user) }

    before do
      visit new_web_session_path

      fill_in 'Email', with: user.email
      click_button 'Sign in'
    end

    it 'renders the MFA info' do
      expect(page).to have_text('Two-Factor Authentication')
      expect(page).to have_selector('svg')
    end

    context 'and scans the presented QR code with their mobile' do
      let(:signin_code) { SigninCode.find_by(user: user) }

      it 'signs in the user at browser' do
        # Waits QR code to appear
        find 'svg'

        using_session 'mobile app' do
          post_api_request(
            'signin/validate_qrcode',
            account_id: user.account_id, code: signin_code.code
          )
        end

        expect(page).to have_selector('.dashboard')
        expect(page).to have_text(user.email)
      end
    end
  end

  context 'when user with informed email does not exist' do
    it 'renders the MFA info' do
      visit new_web_session_path

      fill_in 'Email', with: Faker::Internet.email
      click_button 'Sign in'

      expect(page).to have_text('is invalid')
    end
  end
end
