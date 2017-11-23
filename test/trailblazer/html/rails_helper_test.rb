require 'test_helper'
require 'trailblazer/html/helper'
require 'erbse'
require 'bigdecimal'

class RailsHelperTest < Minitest::Test

  include Trailblazer::Html::RailsHelper
  include Trailblazer::Html::Cdata

  def test_it_builds_standalone_tags
    assert_equal '<br>', tag.br
    assert_equal '<br>', tag(:br)
    assert_equal '<br>', tag('br')
  end

  def test_it_builds_standalone_tags_with_options
    assert_equal '<br clear="left">', tag.br(clear: "left")
    assert_equal '<br clear="left">', tag(:br, clear: "left")
  end

  def test_it_builds_nested_tags
    html =
      tag.div do |b|
        concat 'foo'
        concat b.br
        concat content_tag(:span, 'baz')
        concat 'bar'
      end
    assert_equal '<div>foo<br><span>baz</span>bar</div>', html
  end

  def test_tag_builder_with_string_options
    assert_equal '<p id="1" class="bar">foo</p>', content_tag(:p, 'foo', 'class' => 'bar', id: 1)
  end

  def test_tag_builder
    assert_equal "<span></span>", tag.span
    assert_equal "<span class=\"bookmark\"></span>", tag.span(class: "bookmark")
  end

  def test_tag_builder_void_tag
    assert_equal "<br>", tag.br
    assert_equal "<br class=\"some_class\">", tag.br(class: "some_class")
  end

  def test_tag_builder_options_rejects_nil_option
    assert_equal "<p></p>", tag('p', ignored: nil)
    assert_equal "<p></p>", tag.p(ignored: nil)
  end

  def test_tag_builder_options_accepts_false_option
    assert_equal "<p value=\"false\"></p>", tag.p(value: false)
  end

  def test_tag_builder_options_accepts_blank_option
    assert_equal "<p included=\"\"></p>", tag.p(included: "")
  end

  def test_tag_options_accepts_symbol_option
    assert_equal "<p value=\"symbol\"></p>", tag("p", value: :symbol)
  end

  def test_tag_options_accepts_integer_option_when_not_escaping
    assert_equal "<p value=\"42\"></p>", tag("p", value: 42)
  end

  def test_tag_builder_options_converts_boolean_option
    assert_equal '<p disabled itemscope multiple readonly allowfullscreen seamless typemustmatch sortable default inert truespeed></p>',
      tag.p(disabled: true, itemscope: true, multiple: true, readonly: true, allowfullscreen: true, seamless: true, typemustmatch: true, sortable: true, default: true, inert: true, truespeed: true)
  end

  def test_tag_builder_with_content
    assert_equal "<div id=\"post_1\">Content</div>", tag.div("Content", id: "post_1")
    assert_equal tag.div("Content", id: "post_1"),
                 tag.div("Content", "id": "post_1")
  end

  def test_tag_builder_nested
    assert_equal "<div>content</div>",
                 tag.div { "content" }
    assert_equal "<div id=\"header\"><span>hello</span></div>",
                 tag.div(id: "header") { |b| b.span "hello" }
    assert_equal "<div id=\"header\"><div class=\"world\"><span>hello</span></div></div>",
                 tag.div(id: "header") { |b| b.div(class: "world") { tag.span "hello" } }
  end

  def test_content_tag_with_block_in_erb
    buffer = render_erb("<%= content_tag(:div) do %>Hello world!<% end %>")
    assert_equal "<div>Hello world!</div>", buffer
  end

  def test_tag_builder_with_block_in_erb
    buffer = render_erb("<%= tag.div do %>Hello world!<% end %>")
    assert_equal "<div>Hello world!</div>", buffer
  end

  def test_content_tag_with_block_in_erb_containing_non_displayed_erb
    buffer = render_erb("<%= content_tag(:p) do %><% 1 %><% end %>")
    assert_equal "<p></p>", buffer
  end

  def test_tag_builder_with_block_in_erb_containing_non_displayed_erb
    buffer = render_erb("<%= tag.p do %><% 1 %><% end %>")
    assert_equal "<p></p>", buffer
  end

  def test_tag_builder_with_block_in_erb_containing_nested_tags
    buffer = render_erb("<%= tag.p do |b| %><% 1 %><%= b.br %>blah<% end %>")
    assert_equal "<p><br>blah</p>", buffer
  end

  def test_content_tag_with_block_and_options_in_erb
    buffer = render_erb("<%= content_tag(:div, :class => 'green') do %>Hello world!<% end %>")
    assert_equal %(<div class="green">Hello world!</div>), buffer
  end

  def test_tag_builder_with_block_and_options_in_erb
    buffer = render_erb("<%= tag.div(class: 'green') do %>Hello world!<% end %>")
    assert_equal %(<div class="green">Hello world!</div>), buffer
  end

  def test_content_tag_with_block_and_options_out_of_erb
    assert_equal %(<div class="green">Hello world!</div>), content_tag(:div, class: "green") { "Hello world!" }
  end

  def test_tag_builder_with_block_and_options_out_of_erb
    assert_equal %(<div class="green">Hello world!</div>), tag.div(class: "green") { "Hello world!" }
  end

  def test_content_tag_with_block_and_options_outside_out_of_erb
    assert_equal content_tag("a", "Create", href: "create"),
                 content_tag("a", "href" => "create") { "Create" }
  end

  def test_tag_builder_with_block_and_options_outside_out_of_erb
    assert_equal tag.a("Create", href: "create"),
                 tag.a("href": "create") { "Create" }
  end

  def test_content_tag_nested_in_content_tag_out_of_erb
    #assert_equal content_tag("p", content_tag("b", "Hello")),
    #             content_tag("p") { content_tag("b", "Hello") }
    assert_equal tag.p(tag.b("Hello")),
                 tag.p { tag.b("Hello") }
  end

  def test_content_tag_with_escaped_array_class
    str = content_tag("p", "limelight", class: ["song", "play>"])
    assert_equal "<p class=\"song play&gt;\">limelight</p>", str

    str = content_tag("p", "limelight", class: ["song", "play"])
    assert_equal "<p class=\"song play\">limelight</p>", str
  end

  def test_tag_builder_with_escaped_array_class
    str = tag.p "limelight", class: ["song", "play>"]
    assert_equal "<p class=\"song play&gt;\">limelight</p>", str

    str = tag.p "limelight", class: ["song", "play"]
    assert_equal "<p class=\"song play\">limelight</p>", str
  end

  def test_content_tag_with_unescaped_array_class
    str = content_tag("p", "limelight", class: ["song", "play>"], escape_attributes: false)
    assert_equal "<p class=\"song play>\">limelight</p>", str

    str = content_tag("p", "limelight", class: ["song", ["play>"]], escape_attributes: false)
    assert_equal "<p class=\"song play>\">limelight</p>", str
  end

  def test_tag_builder_with_unescaped_array_class
    str = tag.p "limelight", class: ["song", "play>"], escape_attributes: false
    assert_equal "<p class=\"song play>\">limelight</p>", str

    str = tag.p "limelight", class: ["song", ["play>"]], escape_attributes: false
    assert_equal "<p class=\"song play>\">limelight</p>", str
  end

  def test_content_tag_with_empty_array_class
    str = content_tag("p", "limelight", class: [])
    assert_equal '<p class="">limelight</p>', str
  end

  def test_tag_builder_with_empty_array_class
    assert_equal '<p class="">limelight</p>', tag.p("limelight", class: [])
  end

  def test_content_tag_with_unescaped_empty_array_class
    str = content_tag("p", "limelight", class: [])
    assert_equal '<p class="">limelight</p>', str
  end

  def test_tag_builder_with_unescaped_empty_array_class
    str = tag.p "limelight", class: [], escape_attributes: false
    assert_equal '<p class="">limelight</p>', str
  end

  def test_content_tag_with_data_attributes
    assert_equal '<p data-number="1" data-string="hello" data-string-with-quotes="double&quot;quote&quot;party&quot;">limelight</p>',
      content_tag("p", "limelight", data: { number: 1, string: "hello", string_with_quotes: 'double"quote"party"' })
  end

  def test_tag_builder_with_data_attributes
    assert_equal '<p data-number="1" data-string="hello" data-string-with-quotes="double&quot;quote&quot;party&quot;">limelight</p>',
      tag.p("limelight", data: { number: 1, string: "hello", string_with_quotes: 'double"quote"party"' })
  end

  def test_cdata_section
    assert_equal "<![CDATA[<hello world>]]>", cdata_section("<hello world>")
  end

  def test_cdata_section_with_string_conversion
    assert_equal "<![CDATA[]]>", cdata_section(nil)
  end

  def test_cdata_section_splitted
    assert_equal "<![CDATA[hello]]]]><![CDATA[>world]]>", cdata_section("hello]]>world")
    assert_equal "<![CDATA[hello]]]]><![CDATA[>world]]]]><![CDATA[>again]]>", cdata_section("hello]]>world]]>again")
  end

  def test_tag_honors_html_safe_for_param_values
    ["1&amp;2", "1 &lt; 2", "&#8220;test&#8220;"].each do |escaped|
      assert_equal %(<a href="#{escaped}"></a>), tag.a(href: escaped, escape_attributes: false)
    end
  end

  def test_tag_does_not_honor_html_safe_double_quotes_as_attributes
    assert_equal '<p title="&quot;">content</p>',
      content_tag("p", "content", title: '"')
  end

  def test_data_tag_does_not_honor_html_safe_double_quotes_as_attributes
    assert_equal '<p data-title="&quot;">content</p>',
      content_tag("p", "content", data: { title: '"' })
  end

  def test_skip_invalid_escaped_attributes
    ["&1;", "&#1dfa3;", "& #123;"].each do |escaped|
      assert_equal %(<a href="#{escaped.gsub(/&/, '&amp;')}"></a>), tag.a(href: escaped)
    end
  end

  def test_disable_escaping
    assert_equal '<a href="&amp;"></a>', tag("a", href: "&amp;", escape_attributes: false)
  end

  def test_tag_builder_disable_escaping
    assert_equal '<a href="&amp;"></a>', tag.a(href: "&amp;", escape_attributes: false)
    assert_equal '<a href="&amp;">cnt</a>', tag.a(href: "&amp;" , escape_attributes: false) { "cnt" }
    assert_equal '<br data-hidden="&amp;">', tag.br("data-hidden": "&amp;" , escape_attributes: false)
    assert_equal '<a href="&amp;">content</a>', tag.a("content", href: "&amp;", escape_attributes: false)
    assert_equal '<a href="&amp;">content</a>', tag.a(href: "&amp;", escape_attributes: false) { "content" }
  end

  #def test_data_attributes
  #  ["data", :data].each { |data|
  #    assert_equal '<a data-a-float="3.14" data-a-big-decimal="-123.456" data-a-number="1" data-array="[1,2,3]" data-hash="{&quot;key&quot;:&quot;value&quot;}" data-string-with-quotes="double&quot;quote&quot;party&quot;" data-string="hello" data-symbol="foo" />',
  #      tag("a", data => { a_float: 3.14, a_big_decimal: BigDecimal.new("-123.456"), a_number: 1, string: "hello", symbol: :foo, array: [1, 2, 3], hash: { key: "value" }, string_with_quotes: 'double"quote"party"' })
  #    assert_equal '<a data-a-float="3.14" data-a-big-decimal="-123.456" data-a-number="1" data-array="[1,2,3]" data-hash="{&quot;key&quot;:&quot;value&quot;}" data-string-with-quotes="double&quot;quote&quot;party&quot;" data-string="hello" data-symbol="foo" />',
  #      tag.a(data: { a_float: 3.14, a_big_decimal: BigDecimal.new("-123.456"), a_number: 1, string: "hello", symbol: :foo, array: [1, 2, 3], hash: { key: "value" }, string_with_quotes: 'double"quote"party"' })
  #  }
  #end

  #def test_aria_attributes
  #  ["aria", :aria].each { |aria|
  #    assert_equal '<a aria-a-float="3.14" aria-a-big-decimal="-123.456" aria-a-number="1" aria-array="[1,2,3]" aria-hash="{&quot;key&quot;:&quot;value&quot;}" aria-string-with-quotes="double&quot;quote&quot;party&quot;" aria-string="hello" aria-symbol="foo" />',
  #      tag("a", aria => { a_float: 3.14, a_big_decimal: BigDecimal.new("-123.456"), a_number: 1, string: "hello", symbol: :foo, array: [1, 2, 3], hash: { key: "value" }, string_with_quotes: 'double"quote"party"' })
  #    assert_equal '<a aria-a-float="3.14" aria-a-big-decimal="-123.456" aria-a-number="1" aria-array="[1,2,3]" aria-hash="{&quot;key&quot;:&quot;value&quot;}" aria-string-with-quotes="double&quot;quote&quot;party&quot;" aria-string="hello" aria-symbol="foo" />',
  #      tag.a(aria: { a_float: 3.14, a_big_decimal: BigDecimal.new("-123.456"), a_number: 1, string: "hello", symbol: :foo, array: [1, 2, 3], hash: { key: "value" }, string_with_quotes: 'double"quote"party"' })
  #  }
  #end

  def test_tag_builder_link_to_data_nil_equal
    div_type1 = tag.div "test", 'data-tooltip': nil
    div_type2 = tag.div "test", data: { tooltip: nil }
    assert_equal div_type1, div_type2
  end

  private

  def render_erb(string)
    eval(Erbse::Engine.new.call(string))
  end
end
