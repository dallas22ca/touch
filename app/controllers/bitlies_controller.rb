class BitliesController < ApplicationController
  def redirect
    bitly = Bitly.where(token: params[:token]).first
    
    if bitly
      redirect_to bitly.href
    else
      render text: "This link could not be found."
    end
  end
end
