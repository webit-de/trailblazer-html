require 'trailblazer/html/element/normal'
require 'trailblazer/html/element/modules/container'

module Trailblazer::Html
  class Element
    class Foreign < Normal
      include Trailblazer::Html::Element::Modules::Container
      html do |element|
        if has_content?
          concat start_tag
          concat element.content
          concat end_tag
        else
          closed_start_tag
        end
      end
    end
  end
end
