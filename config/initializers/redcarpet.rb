module Redcarpet
  def self.call(template)
    markdown = ::Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    markdown.render(template.source).inspect
  end
end


ActionView::Template.register_template_handler :md, Redcarpet
