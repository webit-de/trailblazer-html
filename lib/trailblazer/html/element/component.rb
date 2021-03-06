require "trailblazer/html/html_block"

module Trailblazer::Html
  class Element
    class Component < Element
      add_option_keys :content

      html do |element|
        concat start_tag
        concat element.content
        concat end_tag
      end

      html(:start) { start_tag }

      html(:end) { end_tag }

      def content
        @block ? HtmlBlock.new(self, @block).call : options[:content].to_s
      end

      def has_content?
        @block || options[:content]
      end

      def end
        to_html(context: :end)
      end

      def start
        to_html(context: :start)
      end

      # Delegate missing methods to the builder
      # TODO:: @apotonick is going to do something fancy here to delegate
      # the builder methods rather then using this method missing.
      def method_missing(method, *args, &block)
        return super unless builder

        builder.send(method, *args, &block)
      end
    end
  end
end
