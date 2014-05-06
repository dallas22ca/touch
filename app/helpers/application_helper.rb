module ApplicationHelper
  def title(&block)
    content_for(:title) { block.call }
  end
end
