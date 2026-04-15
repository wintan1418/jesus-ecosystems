class PagesController < ApplicationController
  def home
  end

  def about
    @recent_posts = Post.published.for_locale(I18n.locale).recent.limit(3)
    set_meta_tags title:       "#{SiteSetting['author_name'] || 'About'} · #{t('site.name')}",
                  description: SiteSetting["author_bio"].to_s.truncate(180)
  end

  def contact
  end
end
