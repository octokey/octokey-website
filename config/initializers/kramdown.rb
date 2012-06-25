class KramdownTemplateHandler
  def self.call(template)
    Kramdown::Document.new(template.source).to_html.tap{|html| puts html }.inspect
  end
end

ActionView::Template.register_template_handler :md, KramdownTemplateHandler
