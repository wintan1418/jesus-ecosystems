class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # Admin-only auth — public registration is intentionally disabled.
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
end
