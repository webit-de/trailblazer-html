require 'set'

module Trailblazer::Html
  class Attributes < Hash
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
    def to_html
      return if empty?
      output = "".dup
      sep    = " "
      each_pair do |key, value|
        if TAG_PREFIXES.include?(key) && value.is_a?(Hash)
          value.each_pair do |k, v|
            next if v.nil?
            output << sep
            output << %(#{key_to_attr_name(key)}-#{attribute_html(k, v)})
          end
        elsif BOOLEAN_ATTRIBUTES.include?(key)
          if value
            output << sep
            output << key_to_attr_name(key)
          end
        elsif !value.nil?
          output << sep
          output << attribute_html(key, value)
        end
      end
      output
    end

    private
    def key_to_attr_name(key)
      key.to_s.gsub('_', '-')
    end

    def val_to_string(value)
      value.is_a?(Array) ? value.join(' ') : value
    end

    def attribute_html(key, value)
      %(#{key_to_attr_name(key)}="#{val_to_string(value)}")
    end
  end # class Attributes
end # module Trailblazer::Html
