# encoding: utf-8
module Article::DocHelper
  
  def article_doc_list(item, options = {})
    title_tag = options[:title_tag] || 'p'
    thumbnail = item.thumbnail_uri
    uri       = item.public_uri
    attr      = options[:attr] || item.date_and_unit
    
    if options[:list_type].to_s == "blog"
      h = ""
      h << %Q(<#{title_tag} class="title"><a href="#{uri}">#{h(item.title)}</a></#{title_tag}>)
      h << %Q(<a href="#{uri}"><img src="#{thumbnail}" alt="" /></a>) if thumbnail
      h << %Q(<div class="body">#{truncate(item.summary_body, :length => 80)}</div>)
      h << %Q(#{attr})
      return h
    end
    
    %Q(#{link_to(item.title, item.public_uri)}#{item.date_and_unit})
  end
end
