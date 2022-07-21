# Load general RSpec Rails configuration
require "rails_helper.rb"

# Load configuration files and helpers
Dir[Rails.root.join('spec', 'system', 'support', '**', '*.rb')].sort.each { |f| require f }
