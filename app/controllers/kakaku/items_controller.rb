module Kakaku
  class ItemsController < ApiController
    def show
      @item = Kakaku::Item.new(params[:id])
    end
  end
end
