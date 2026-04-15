module AdminHelper
  def admin_nav_class(active)
    active ? "admin-nav-link admin-nav-link--active" : "admin-nav-link"
  end

  def admin_page_header(title, subtitle: nil, eyebrow: nil, &block)
    render partial: "admin/shared/page_header",
           locals: { title: title, subtitle: subtitle, eyebrow: eyebrow, action_block: block }
  end

  def status_badge(status)
    klass = {
      "pending"    => "admin-badge admin-badge--pending",
      "fulfilling" => "admin-badge admin-badge--fulfilling",
      "shipped"    => "admin-badge admin-badge--shipped",
      "cancelled"  => "admin-badge admin-badge--cancelled"
    }.fetch(status.to_s, "admin-badge")

    content_tag(:span, status.to_s.humanize, class: klass)
  end
end
