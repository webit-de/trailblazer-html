require 'trailblazer/html/elements'
require 'trailblazer/html/builder'

module Trailblazer::Html
  module Helper
    class BuilderWrapper < SimpleDelegator
      def method_missing(method, *args, &block)
        super.to_html
      end
    end

    def tag
      BuilderWrapper.new(builder)
    end

    private

    def builder
      @builder ||= Trailblazer::Html::Builder.new(Trailblazer::Html::Element::VALID_ELEMENT_SET)
    end
  end

  module RailsHelper
    include Helper

    def tag(name = nil, opts = nil, open = false, *args, **options)
      if name.nil?
        super()
      else
        if opts.is_a?(Hash)
          opts.each_pair { |k,v| options[k.to_sym] = v }
        end
        element = builder.public_send(name, options)
        open ? element.to_html(context: :start) : element.to_html
      end
    end

    def content_tag(name, content = nil, opts = nil, *args, **options, &block)
      if opts.is_a?(Hash)
        opts.each_pair { |k,v| options[k.to_sym] = v }
      end
      if content.is_a?(Hash)
        content.each_pair { |k,v| options[k.to_sym] = v }
      else
        options[:content] = content
      end
      builder.public_send(name, options, &block).to_html
    end
  end
end
