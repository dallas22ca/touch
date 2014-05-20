ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'sidekiq/testing'

DatabaseCleaner.strategy = :truncation
Capybara.javascript_driver = :selenium

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.include Capybara::DSL
  config.include FactoryGirl::Syntax::Methods
  
  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
  
  def sign_in(user, org = false)
    visit org ? signin_path(org) : new_user_session_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Sign In"
    page.should have_content "Signed in"
  end
end