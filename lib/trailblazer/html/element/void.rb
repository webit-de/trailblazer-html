module Trailblazer::Html
  class Element
    class Void < Element
      def self.call(**options)
        new(**options)
      end

      def to_html
        start_tag
      end
      alias_method :to_s, :to_html

    end
  end
end
