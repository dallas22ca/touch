class FolderMailer < ActionMailer::Base
  default from: "TouchBaseNow.com <no-reply@touchbasenow.com>"
  
  def invitation(foldership_id)
    @foldership = Foldership.find(foldership_id)
    @folder = @foldership.folder
    @inviter = @foldership.creator

    mail to: @foldership.name_and_email, subject: "You've been invited to a folder"
  end
end
