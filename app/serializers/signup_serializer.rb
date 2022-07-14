class SignupSerializer < BaseSerializer

  def initialize(user:)
    @user = user
  end

  def attributes
    { 'id' => nil }
  end

  def id
    user.incognia_signup_id
  end

  private

  attr_reader :user
end
