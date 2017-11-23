require 'trailblazer/html/element/component'

module Trailblazer::Html
  class Element
    class Foreign < Component
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
