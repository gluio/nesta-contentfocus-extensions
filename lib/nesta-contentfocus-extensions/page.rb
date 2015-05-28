require 'redcarpet'
require 'nesta/models'

class HTMLWithTocRender < Redcarpet::Render::HTML
  def preprocess(document)
    @document = document
  end

  def paragraph(content)
    if ['[TOC]'].include?(content)
      toc_render = Redcarpet::Render::HTML_TOC.new(nesting_level: 2)
      parser     = Redcarpet::Markdown.new(toc_render)
      rendered = parser.render(@document)
      rendered.sub!(/\A<ul>/, '<ul class="toc">')
      return rendered
    else
      ["<p>",content,"</p>"].join
    end
  end
end

module Nesta
  class Page < FileModel
    def convert_to_html(format, scope, text)
      render_options = {
        prettify: true,
        safe_links_only: true,
        with_toc_data: true
      }
      markdown_options = {
        renderer: HTMLWithTocRender.new(render_options),
        autolink: true,
        disable_indented_code_blocks: true,
        fenced_code_blocks: true,
        footnotes: true,
        highlight: true,
        no_intra_emphasis: true,
        quote: true,
        strikethrough: true,
        superscript: true,
        tables: true
      }
      text = add_p_tags_to_haml(text) if @format == :haml
      template = Tilt[format].new(nil, 1, markdown_options) { text }
      template.render(scope)
    end

    def intro_image
      return metadata('Intro Image') if metadata('Intro Image')
    end
  end
end
