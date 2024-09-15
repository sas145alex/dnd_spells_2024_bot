class AdminUser < ApplicationRecord
  SYSTEM_USER_ID = 0

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, 
         :rememberable,
         :validatable,
         :trackable

  def self.system_user
    @system_user ||= find_by(id: SYSTEM_USER_ID)
  end
end
