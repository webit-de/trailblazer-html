require 'trailblazer/html/element'
require 'trailblazer/html/element/void'
require 'trailblazer/html/element/component'
require 'trailblazer/html/element/foreign'
require 'trailblazer/html/html_escape'
require 'trailblazer/html/cdata'

module Trailblazer::Html
  class Element

    VALID_ELEMENT_SET = {}

    # get the tag_name from the element class and
    # assign to a constant with the same name
    def self.define_class_constant(klass)
      tag_name = klass.tag_name
      klass_name = tag_name.to_s
      klass_name[0] = klass_name[0].capitalize
      const_set(klass_name, klass)
      VALID_ELEMENT_SET[tag_name] = const_get(klass_name)
    end

    # HTML void elements
    %i(area base br col embed hr img input keygen link meta param source track wbr).each do |tag_name|
      define_class_constant Class.new(Trailblazer::Html::Element::Void) {
        tag tag_name
      }
    end

    # HTML foreign elements
    %i(mathml svg).each do |tag_name|
      define_class_constant Class.new(Trailblazer::Html::Element::Foreign) {
        tag tag_name
      }
    end

    # HTML normal elements
    %i(a abbr address article aside audio b bdi bdo blockquote body button canvas caption cite code
       colgroup data datalist dd del details dfn dialog div dl dt em fieldset figcaption figure footer
       form h1 head header hgroup html i iframe ins kbd label legend li main map mark menu meter
       nav noscript object ol optgroup option output p picture pre progress q rp rt ruby s samp
       section select slot small span strong sub summary sup table tbody td template
       tfoot th thead time title tr u ul var video).each do |tag_name|
      define_class_constant Class.new(Trailblazer::Html::Element::Component) {
        tag tag_name
      }
    end

    # HTML raw text element script
    define_class_constant Class.new(Trailblazer::Html::Element::Component) {
      include Trailblazer::Html::Cdata
      tag :script

      def content
        "\n//#{cdata_section("\n#{super}\n//")}\n" if has_content?
      end
    }

    # HTML raw text element style
    define_class_constant Class.new(Trailblazer::Html::Element::Component) {
      include Trailblazer::Html::Cdata
      tag :style

      def content
        "\n/*#{cdata_section("*/\n#{super}\n/*")}*/\n" if has_content?
      end
    }

    define_class_constant Class.new(Trailblazer::Html::Element::Component) {
      include Trailblazer::Html::HtmlEscape
      tag :textarea
      add_option_keys :value

      # add newline to preserve first newline in content
      # html escape the content
      def content
        "\n#{html_escape_once(options[:value] || super)}"
      end
    }


  end # class Element
end # module Trailblazer::Html
