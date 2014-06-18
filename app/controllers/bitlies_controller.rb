class BitliesController < ApplicationController
  def redirect
    bitly = Bitly.where(token: params[:token]).first
    
    begin
      redirect_to bitly.href
    rescue
      render text: "This link could not be found."
    end
  end
end
