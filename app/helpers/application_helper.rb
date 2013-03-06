module ApplicationHelper
  def error_helper(object, fields=nil)
    render 'partials/error_helper', { :object => object, :fields => fields }
  end
end
