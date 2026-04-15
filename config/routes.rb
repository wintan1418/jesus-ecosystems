Rails.application.routes.draw do
  # ─── Admin ─────────────────────────────────────────────────────────────────
  devise_for :admins, path: "admin", path_names: { sign_in: "sign_in", sign_out: "sign_out" }

  namespace :admin do
    root "dashboard#index", as: :root

    # Dedicated home-page content editor (grouped SiteSetting editor).
    get   "home",       to: "home_content#edit",   as: :home_content
    patch "home",       to: "home_content#update"

    resources :books do
      resources :book_translations, path: "translations", except: [:show]
      resources :chapters, only: [:new, :create]
      resources :audiobooks, only: [:new, :create]
    end

    resources :chapters,   only: [:index, :show, :edit, :update, :destroy]
    resources :audiobooks, only: [:index, :show, :edit, :update, :destroy]

    resources :free_copy_requests do
      member do
        patch :update_status
      end
      collection do
        post :bulk_ship
      end
    end

    resources :email_subscribers, only: [:index, :show, :destroy]
    resources :site_settings
    resources :posts
  end

  # Back-compat aliases so any bookmarks still resolve.
  get "/admins",          to: redirect("/admin/sign_in")
  get "/admins/sign_in",  to: redirect("/admin/sign_in")

  # ─── Health & ops ──────────────────────────────────────────────────────────
  get "up" => "rails/health#show", as: :rails_health_check

  # ─── Public newsletter subscribe (locale-agnostic) ────────────────────────
  resources :subscribes, only: [:create]

  # ─── Bare root → locale-aware redirect ─────────────────────────────────────
  root to: redirect { |_, req|
    locale = req.headers["Accept-Language"].to_s.scan(/^[a-z]{2}/).first
    locale = "en" unless %w[en es pt].include?(locale)
    "/#{locale}"
  }

  # ─── Public, locale-prefixed ───────────────────────────────────────────────
  scope ":locale", locale: /en|es|pt/ do
    get "/", to: "pages#home", as: :locale_root

    get "/about",   to: "pages#about",   as: :about
    get "/contact", to: "pages#contact", as: :contact

    resources :books, only: [:index, :show], param: :slug do
      member do
        get :read
      end
      resources :chapters, only: [:show], param: :slug
    end

    resources :audiobooks, only: [:index, :show]

    # Journal
    get  "/journal.rss",     to: "posts#index", defaults: { format: :rss }, as: :journal_rss
    get  "/journal",         to: "posts#index", as: :journal
    get  "/journal/:slug",   to: "posts#show",  as: :post

    get  "/request-free-copy",            to: "free_copy_requests#new",        as: :request_free_copy
    get  "/request-free-copy/thank-you",  to: "free_copy_requests#thank_you",  as: :free_copy_thank_you
    resources :free_copy_requests, only: [:new, :create]
  end
end
