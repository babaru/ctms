class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:gitlab]

  has_many :user_watching_projects
  has_many :projects, through: :user_watching_projects

  has_many :user_watching_plans
  has_many :plans, through: :user_watching_plans

  def self.from_omniauth(auth)
    user = User.where(provider: auth.provider, uid: auth.uid).first_or_create
    user.update({
      email: auth.info.email,
      password: Devise.friendly_token[0,20],
      name: auth.info.name,
      image: auth.info.image,
      access_token: auth.credentials.token
    })
    user
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.gitlab_data"] && session["devise.gitlab_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

end
