require "trailblazer/html/attributes"
require 'uber/inheritable_attr'
require 'uber/options'

module Trailblazer::Html
  # The Element class is responsible for defining what the html should look like.
  # This includes default attributes, and the function to use to render the html
  # actual rendering is done via a HtmlBlock class
  class Element
    extend Uber::InheritableAttr

    inheritable_attr :default_hash
    inheritable_attr :processing_hash
    inheritable_attr :option_keys
    inheritable_attr :tag_name

    self.default_hash = {}
    self.processing_hash = {}
    self.option_keys = []

    # set the default value of an option or attribute
    # you can make this conditional by providing a condition
    # e.g. if: :some_method or unless: :some_method
    # to respect the order defaults are declared, rather than overriting existing defaults
    # we should delete the existing and create a new k/v pair
    def self.set_default(key, value, condition = {})
      self.default_hash.delete(key) # attempt to delete an existing key
      self.default_hash[key] = { value: value, condition: condition }
    end

    # process an option value (i.e. escape html)
    # This occurs after the value has been set (either by default or by user input)
    # you can make this conditional by providing a condition
    # e.g. if: :some_method or unless: :some_method
    def self.process_option(key, processor, condition = {})
      self.processing_hash[key] = { processor: processor, condition: condition }
    end

    # blacklist the keys that should NOT end up as html attributes
    def self.add_option_keys(*keys)
      self.option_keys += keys
    end

    # define the name of the html tag for the element
    # e.g.
    # tag :span
    # tag 'input'
    # Note that if you leave this out, the tag will be inferred
    # based on the name of your class
    # Also, this is not inherited
    def self.tag(name)
      self.tag_name = name
    end

    def initialize(builder: nil, **options)
      @builder = builder
      @options = options
      normalize_options
      process_options
      @tag = self.class.tag_name
    end
    attr_reader :tag, :builder, :options

    def attributes
      attrs = @options.select { |k, v| !option_key?(k) }
      Attributes[attrs]
    end

    # return the start/opening tag with the element
    # attributes hash converted into valid html attributes
    def start_tag
      if attributes.empty?
        "<#{tag}>"
      else
        "<#{tag}#{attributes.to_html}>"
      end
    end

    # return a closed start tag (e.g. <input name="body"/>)
    def closed_start_tag
      start_tag.insert(-2, '/')
    end

    # returns the end/ closing tag for an element
    def end_tag
      "</#{tag}>"
    end

    private

    # Options passed into our element instance (@options) take precident over class level defaults
    # Take each default value and merge it with options.
    # This way ordering is important and we can access values as they are evaluated
    def normalize_options
      self.class.default_hash.each do |key, hash|
        should_merge = key.to_s.include?('class') && !options[key].nil?

        next if options.has_key?(key) && !should_merge

        # if our default is conditional and the condition evaluates to false then skip
        next unless evaluate_option_condition?(hash[:condition])

        val = Uber::Options::Value.new(hash[:value]).evaluate(self)

        # if our default value is nil then skip
        next if val.nil?

        # otherwise perform the actual merge, classes get joined, otherwise we overwrite
        should_merge ? @options[key] += val : @options[key] = val
      end
    end

    # Options passed into our element instance (@options) take precident over class level defaults
    # Take each default value and merge it with options.
    # This way ordering is important and we can access values as they are evaluated
    def process_options
      self.class.processing_hash.each do |key, hash|
        # we can't process if our option is nil
        next if options[key].nil?
        # don't process if our condition is false
        next unless evaluate_option_condition?(hash[:condition])

        # get our value
        val = self.send(hash[:processor], options[key]) # TODO enable procs and blocks

        # set our value
        @options[key] = val
      end
    end

    def option_key?(k)
      self.class.option_keys.include?(k)
    end

    # this evaluates any conditons placed on our defaults returning true or false
    # e.g.
    # set_default :checked, "checked", if: :is_checked?
    # set_default :class, ["form-control"], unless: :file_input?
    def evaluate_option_condition?(condition = {})
      return true if condition.empty?
      operator = condition.keys[0]
      condition_result = Uber::Options::Value.new(condition.values[0]).evaluate(self)

      case operator.to_sym
      when :if     then condition_result
      when :unless then !condition_result
      end
    end
  end # class Element
end # module Trailblazer::Html
