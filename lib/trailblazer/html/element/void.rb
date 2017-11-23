module Trailblazer::Html
  class Element
    class Void < Element
      html do |element|
        start_tag
      end

      def content
        nil
      end

      def has_content?
        false
      end
    end
  end
end
