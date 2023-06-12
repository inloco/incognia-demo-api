require "capybara/cuprite"

# Then, we need to register our driver to be able to use it later
# with #driven_by method.#
# NOTE: The name :cuprite is already registered by Rails.
# See https://github.com/rubycdp/cuprite/issues/180
Capybara.register_driver(:better_cuprite) do |app|
  options = {
    window_size: [1200, 800],
    #browser_options: { 'no-sandbox': nil },
    # Increase Chrome startup wait time (required for stable CI builds)
    process_timeout: 20,
    # Enable debugging capabilities
    inspector: true,
    # Allow running Chrome in a headful mode by setting HEADLESS env
    # var to a falsey value
    headless: !ENV["HEADLESS"].in?(%w[n 0 no false])
  }

  Capybara::Cuprite::Driver.new(app, options)
end

# Configure Capybara to use :better_cuprite driver by default
Capybara.default_driver = :better_cuprite
Capybara.javascript_driver = :better_cuprite
Capybara.server_port = '8888'
