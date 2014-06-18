class BitliesController < ApplicationController
  def bitly
    begin
      redirect_to Bitly.where(token: params[:token]).first.href
    rescue
      render text: "This link could not be found."
    end
  end
end
