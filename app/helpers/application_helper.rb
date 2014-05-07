module ApplicationHelper
  def title(&block)
    content_for(:title) { block.call }
  end
  
  def clearances
    %w[contacts permissions attendance]
  end
end
