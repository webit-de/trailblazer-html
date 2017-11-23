require 'trailblazer/html/element/component'

module Trailblazer::Html
  class Element
    class Foreign < Component
      html do |element|
        if element.has_content?
          concat start_tag
          concat content
          concat end_tag
        else
          self_closing_start_tag
        end
      end
    end
  end
end
