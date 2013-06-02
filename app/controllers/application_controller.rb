class ApplicationController < ActionController::Base
  protect_from_forgery

  def get_tags_with_weight(record = nil)
    taglist = Site.tags_with_weight
    
    if record
      record_tags = record.tags.split(',')
      taglist = taglist.reject {|tag| !record_tags.include? tag[0] }
    end
    taglist
  end

private

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end

  helper_method :mobile_device?
end
