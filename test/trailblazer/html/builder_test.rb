require 'test_helper'
require 'trailblazer/html/builder'
require 'trailblazer/html/elements'

describe Trailblazer::Html::Builder do
  BuilderElement =
    {
      div: Trailblazer::Html::Element::Div,
      span: Trailblazer::Html::Element::Span,
      p: Trailblazer::Html::Element::P,
      br: Trailblazer::Html::Element::Br
   }.freeze

  let(:builder) {
    Trailblazer::Html::Builder.new(BuilderElement)
  }

  describe '#define_element_methods' do
    it 'should pass self to element' do
      builder.div(content: 'H').builder.must_equal builder
    end

    it 'should call correct element' do
      builder.div(content: 'H').to_s.must_equal %(<div>H</div>)
      builder.div(class: 'cool').to_s.must_equal %(<div class="cool"></div>)
    end

    it 'should raise NoMethodError if element not in set' do
      assert_raises(NoMethodError) { builder.not_an_element }
    end
  end

  describe 'returns html correctly' do
    it '#outputs with block' do
      div = builder.div(class: 'my_div') do |b|
        concat b.span(class: ['test'], content: 'a span')
        concat b.br
        concat b.p(content: 'paragraph')
      end
      div.to_s.must_equal %(<div class="my_div"><span class="test">a span</span><br><p>paragraph</p></div>)
	  end

    it '#outputs without string' do
      div = builder.div(content: "<h1>Fab Form</h1>")

      div.to_s.must_equal %(<div><h1>Fab Form</h1></div>)
    end
  end

  describe 'builder elements' do
    Password = Class.new(Trailblazer::Html::Element)
    Builder = Class.new(Trailblazer::Html::Builder) do
      element_set(BuilderElement)
    end
    InheritedBuilder = Class.new(Builder)
    PasswordInheritedBuilder = Class.new(InheritedBuilder) do
      element_set(password: Password)
    end

    it "stores elements" do
      Builder.elements.must_equal BuilderElement
    end

    it "inherits elements" do
      InheritedBuilder.elements.must_equal Builder.elements
    end

    it "extends inherited elements" do
      PasswordInheritedBuilder.elements[:password].must_equal Password
    end
  end
end
