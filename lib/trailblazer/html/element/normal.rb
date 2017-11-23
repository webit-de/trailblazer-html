require "trailblazer/html/html_block"

module Trailblazer::Html
  class Element
    class Normal < Element
      inheritable_attr :html_context
      inheritable_attr :html_blocks

      self.html_blocks = {}
      self.html_context = :default

      # define what your html should look like
      # this block is executed in the context of an HtmlBlock instance
      def self.html(context = :default, &block)
        self.html_blocks[context] = block
      end

      # a convenient way of changing the key for a context
      # useful for inheritance if you want to replace a context
      # but still access the original function
      def self.rename_html_context(old_context, new_context)
        self.html_blocks[new_context] = self.html_blocks.delete(old_context)
      end

      def self.call(**options, &block)
        new(**options, &block)
      end

      def initialize(**options, &block)
        super(options)
        @block = block
        @html_blocks = define_html_blocks
      end
      attr_reader :html_blocks

      def to_html(context: nil)
        context ||= self.class.html_context
        html_blocks[context].call
      end
      alias_method :to_s, :to_html

      private

      def define_html_blocks
        self.class.html_blocks.each_with_object({}) do |(context, block), hash|
          hash[context] = HtmlBlock.new(self, block)
        end
      end

    end
  end
end
