# Preview all emails at http://localhost:3000/rails/mailers/folder_mailer
class FolderMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/folder_mailer/invitation
  def invitation
    FolderMailer.invitation
  end

end
