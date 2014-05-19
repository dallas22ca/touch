class FolderMailer < ActionMailer::Base
  default from: "no-reply@realtxn.com"
  
  def invitation(foldership_id)
    @foldership = Foldership.find(foldership_id)
    @folder = @foldership.folder
    @member = @foldership.member
    @inviter = @foldership.creator

    mail to: @member.name_and_email, subject: "You've been invited to a folder"
  end
end
