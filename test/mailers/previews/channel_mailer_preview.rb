# Preview all emails at http://localhost:3000/rails/mailers/channel_mailer
class ChannelMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/channel_mailer/invitation
  def invitation
    ChannelMailer.invitation
  end

end
