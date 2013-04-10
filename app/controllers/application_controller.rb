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
end
