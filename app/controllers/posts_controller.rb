class PostsController < ApplicationController
  def index
    @posts = Post.published.for_locale(I18n.locale)
                 .recent
                 .with_attached_featured_image
                 .limit(50)

    set_meta_tags title:       t("journal.index.title", default: "Journal · #{t('site.name')}"),
                  description: t("journal.index.subhead",
                                 default: "Fragments, discoveries, and corrections between volumes.")

    respond_to do |format|
      format.html
      format.rss { render layout: false }
    end
  end

  def show
    @post = Post.published.for_locale(I18n.locale)
                .with_attached_featured_image
                .friendly.find(params[:slug])

    set_meta_tags title:       "#{@post.title} · #{t('site.name')}",
                  description: @post.excerpt
  rescue ActiveRecord::RecordNotFound
    redirect_to journal_path, alert: t("journal.not_found", default: "Post not found.")
  end
end
