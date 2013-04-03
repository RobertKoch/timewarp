module ApplicationHelper
  def error_helper(object, fields=nil)
    render 'partials/error_helper', { :object => object, :fields => fields }
  end

  def to_german_date(date)
    date.strftime('%d. %b. %Y')
  end
end
