class SessionSerializer < BaseSerializer
  def initialize(user:)
    @user = user
  end

  def attributes
    { 'signup_id' => nil, 'signup_timestamp' => nil, 'structured_address' => nil }
  end

  def signup_id
    user.incognia_signup_id
  end

  def signup_timestamp
    user.created_at.to_i
  end

  def structured_address
    return if user.address.blank?

    user.address.fetch('structured_address')
  end

  private

  attr_reader :user
end
