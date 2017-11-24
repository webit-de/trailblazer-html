require 'set'
require 'json'
require 'bigdecimal'
require 'trailblazer/html/html_escape'

module Trailblazer::Html
  class Attributes < Hash
    include Trailblazer::Html::HtmlEscape

    BOOLEAN_ATTRIBUTES = %w(allowfullscreen async autofocus autoplay checked
                        compact controls declare default defaultchecked
                        defaultmuted defaultselected defer disabled
                        enabled formnovalidate hidden indeterminate inert
                        ismap itemscope loop multiple muted nohref
                        noresize noshade novalidate nowrap open
                        pauseonexit readonly required reversed scoped
                        seamless selected sortable truespeed typemustmatch
                        visible).to_set

    BOOLEAN_ATTRIBUTES.merge(BOOLEAN_ATTRIBUTES.map(&:to_sym))

    TAG_PREFIXES = ["aria", "data", :aria, :data].to_set

    def self.[](hash)
      hash ||= {}
      super
    end

    # converts the hash into a string k1=v1 k2=v2
    # replaces underscores with - so we can use regular keys
    # allows one layer of nested hashes so we can define data options as a hash.
    def to_html(escape: true)
      output = "".dup
      sep    = " "
      each_pair do |key, value|
        if TAG_PREFIXES.include?(key) && value.is_a?(Hash)
          value.each_pair do |k, v|
            next if v.nil?
            output << sep
            v = v.to_json if v.is_a?(Array)
            output << %(#{key_to_attr_name(key)}-#{attribute_html(k, v, escape: escape)})
          end
        elsif BOOLEAN_ATTRIBUTES.include?(key)
          if value
            output << sep
            output << key_to_attr_name(key)
          end
        elsif !value.nil?
          output << sep
          output << attribute_html(key, value, escape: escape)
        end
      end
      output
    end

    private
    def key_to_attr_name(key)
      key.to_s.gsub('_', '-')
    end

    def val_to_string(value)
      if value.is_a?(Array)
        value.join(' ')
      elsif value.is_a?(Hash)
        value.to_json
      elsif value.is_a?(BigDecimal)
        value.to_s('F')
      else
        value
      end
    end

    def attribute_html(key, value, escape: true)
      val = val_to_string(value)
      val = html_escape_once(val) if escape
      %(#{key_to_attr_name(key)}="#{val}")
    end
  end # class Attributes
end # module Trailblazer::Html
