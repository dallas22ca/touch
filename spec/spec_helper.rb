ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'sidekiq/testing'

DatabaseCleaner.strategy = :truncation
Capybara.javascript_driver = :webkit

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.include Capybara::DSL
  config.include FactoryGirl::Syntax::Methods
  
  config.before :each do
    ActionMailer::Base.deliveries = []
    Event.delete_all
    Message.delete_all
    Organization.delete_all
    Task.delete_all
    Home.delete_all
    Comment.delete_all
    User.delete_all
    Member.delete_all
    
    Sidekiq::Testing.inline!
    DatabaseCleaner.start
  end

  config.after :each do
    Capybara.reset_sessions!
    DatabaseCleaner.clean
  end
  
  def sign_in(user, org = false)
    visit org ? signin_path(org) : new_user_session_path
    page.should have_content "I'd rather sign in with my email address."
    click_link "I'd rather sign in with my email address."
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Sign In"
  end
end