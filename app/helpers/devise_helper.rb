module DeviseHelper
  def devise_error_messages!
    html = ""
    
    if resource.errors.any?
      html += "<ul class=\"error\">"
      html += resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
      html += "</ul>"
    end
    
    html.html_safe
  end
end