module Trailblazer::Html
  class Element
    class Void < Element
      html do |element|
        start_tag
      end
    end
  end
end
