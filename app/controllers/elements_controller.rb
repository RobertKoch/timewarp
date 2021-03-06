class ElementsController < ApplicationController
  before_filter :authenticate_admin!, :only => [:index, :destroy]

  def index
    @elements = Element.all.order_by("label ASC").paginate(:page => params[:page], :per_page => 20)
  end

  def destroy
    el = Element.find(params[:id])
    el.destroy
    redirect_to admin_elements_path
  end

  def learn
    teached_me_count = 0
    elements = JSON.load params["elements"]

    elements.each do |el|
      label = el.keys[0]
      value = el.values[0]
      unless exists = Element.find_by(value: value)
        new_elem = Element.create(:label => label, :value => value)
        teached_me_count += 1
      end
    end

    respond_to do |format|
      format.json { render :json => teached_me_count }
    end
  end

  def teach
    respond_to do |format|
      format.json { render :json => Element.render_all.to_json }
    end
  end
end