class FreeCopyRequestsController < ApplicationController
  # Phase 3 will replace these stubs with the real multi-step Turbo Frame form,
  # validations, mailers, and rate limiting. For now we render a holding page.

  def new
    set_meta_tags title:       I18n.t("free_copy.new.heading_1") + " " + I18n.t("free_copy.new.heading_2"),
                  description: I18n.t("free_copy.new.subhead")
  end

  def create
    redirect_to free_copy_thank_you_path
  end

  def thank_you
  end
end
