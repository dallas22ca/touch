module ApplicationHelper
  def title(&block)
    content_for(:title) { block.call }
  end
  
  def clearances
    %w[members permissions attendance]
  end
  
  def parse_default(url)
    url.gsub "default_org_logo", "/#{@website["domain"]}/imgs/top_logo.png"
  end
end
