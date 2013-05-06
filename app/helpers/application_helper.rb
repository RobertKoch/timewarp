module ApplicationHelper
  def error_helper(object, fields=nil)
    render 'partials/error_helper', { :object => object, :fields => fields }
  end

  def to_german_date(date)
    # todo: monat als namen in deutsch ausgeben, falls es eine einfache möglichkeit gibt
    date.strftime('%d. %m. %Y')
  end
end
