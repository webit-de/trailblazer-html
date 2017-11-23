module Trailblazer::Html
  module Cdata
    # Returns a CDATA section with the given +content+. CDATA sections
    # are used to escape blocks of text containing characters which would
    # otherwise be recognized as markup. CDATA sections begin with the string
    # <tt><![CDATA[</tt> and end with (and may not contain) the string <tt>]]></tt>.
    #
    #   cdata_section("<hello world>")
    #   # => <![CDATA[<hello world>]]>
    #
    #   cdata_section(File.read("hello_world.txt"))
    #   # => <![CDATA[<hello from a text file]]>
    #
    #   cdata_section("hello]]>world")
    #   # => <![CDATA[hello]]]]><![CDATA[>world]]>
    def cdata_section(content)
      splitted = content.to_s.gsub(/\]\]\>/, "]]]]><![CDATA[>")
      "<![CDATA[#{splitted}]]>"
    end

  end
end
