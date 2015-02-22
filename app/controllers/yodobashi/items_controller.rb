module Yodobashi
  class ItemsController < ApiController
    def show
      @item = Yodobashi::Item.new(params[:id])
    end
  end
end
