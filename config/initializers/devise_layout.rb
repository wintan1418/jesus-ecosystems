# Use the cinematic devise layout for all Devise sign-in / password screens.
Rails.application.config.to_prepare do
  Devise::SessionsController.layout   "devise"
  Devise::PasswordsController.layout  "devise"
  Devise::UnlocksController.layout    "devise" if defined?(Devise::UnlocksController)
  Devise::RegistrationsController.layout "devise" if defined?(Devise::RegistrationsController)
end
