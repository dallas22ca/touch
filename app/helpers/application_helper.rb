module ApplicationHelper
  def title(&block)
    content_for(:title) { block.call }
  end
  
  def clearances
    %w[members permissions attendance]
  end
end
