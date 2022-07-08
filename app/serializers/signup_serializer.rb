class SignupSerializer < BaseSerializer

  def initialize(signup:)
    @signup = signup
  end

  def attributes
    { 'id' => nil }
  end

  def id
    signup.incognia_signup_id
  end

  private

  attr_reader :signup
end
