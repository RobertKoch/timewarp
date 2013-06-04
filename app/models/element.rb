# -*- encoding : utf-8 -*-
class Element
  include Mongoid::Document
  include Mongoid::Timestamps

  LABELS = %w/Header Logo Unternavigation Content Sidebar Bildergalerie Footer/

  field :label, type: String
  field :value, type: String

  validates :label, :inclusion => { :in => LABELS }, :allow_nil => false
  validates_presence_of :value

  def self.types
    LABELS
  end

  def self.render_all
    elements = {}
    Element.types.each do |type|
      ids = Element.where(label: type).to_a.collect{|e| e.value}
      elements[type] = ids
    end
    elements
  end
end
