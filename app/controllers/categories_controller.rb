class CategoriesController < ApplicationController
  def index
    #@categories = Category.page(params[:page])
    @filterrific = initialize_filterrific(
        Category,
        params[:filterrific],
        select_options: {
            sorted_by: Category.options_for_sorted_by
        },
        persistence_id: 'shared_key',
        default_filter_params: {},

    ) or return
    @categories = Category.filterrific_find(@filterrific).page(params[:page])
#@filterrific.find.page(params[:page])

    @categories =  @filterrific.find.page(params[:page])


    respond_to do |format|
      format.html
      format.js
    end

  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return
  end

end

