if Rails.env.production?
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    port: 587,
    address: "smtp.mandrillapp.com",
    user_name: CONFIG["mandrill_username"],
    password: CONFIG["mandrill_password"],
    domain: "touchbasenow.com",
    authentication: :login,
    enable_starttls_auto: true
  }
end