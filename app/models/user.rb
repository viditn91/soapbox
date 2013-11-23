class User < ActiveRecord::Base

  #FIXME_AB: What I am getting is, following company is a company. If yes the we should name it as a company[Fixed]
  #FIX : Renamed to company
  belongs_to :company
  #FIXME_AB: Think about when a user is destroyed[Fixed]
  #Fixed: Don't destroy associated models
  has_many :followings
  has_many :followees, through: :followings
  has_many :inverse_followings, class_name: 'Following', foreign_key: 'followee_id'
  has_many :followers, through: :inverse_followings, source: :user
  has_and_belongs_to_many :groups
  #FIXME_AB: We need a better way to handle a user's destroy. Please think and share how should we handle destroy of various entities
  #[Fixed]
  has_many :groups_owned, foreign_key: 'admin_id', class_name: 'Group', dependent: :destroy
  #FIXME_AB: For ordering use scope[Fixed]
  #FIX: Scope added
  has_many :posts, -> { order("created_at DESC") }

  has_many :likes
  has_many :comments
  has_many :notifications


  #FIXME_AB: No need to use ActionController::Base.helpers.asset_path just pass 'missing.jpg' because in any way we will be using image_tag to display the image, which will take care of this
  #[Fixed]

  has_attached_file :avatar, :default_url => 'missing.png'

  validates :email, presence: true
  validates :email, uniqueness: true
 
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauth_providers => [:google_oauth2]
 
  before_create :provide_dummy_names
  after_create :send_welcome_email


  def self.from_omniauth(access_token, signed_in_resource = nil)
    data = access_token.info
    user = User.where(:email => data["email"]).first


    unless user
        user = User.create(email: data["email"],
             password: Devise.friendly_token[0,20],
             name: data["name"])
        #FIXME_AB: whay hardcoading username
        #To Discuss
        user.username = 'ViceLikePillow' + user.id.to_s
        #FIXME_AB: How would you handle if an exectpion is railsed by save!
        #To Discuss
        user.save!
    end
    user
  end

  #FIXME_AB: following mehtod should be named as display_name as I guess will be used for display purpose only.
  #To discuss
  def name
    (firstname.try(:capitalize) || '') + ' ' + (lastname.try(:capitalize) || '')
  end

  def to_param
    "#{id}-#{firstname}".parameterize
  end

  def privileged?(entity)
    user = self
    if(user.is_admin? || user.is_moderator? || entity.try(:user) == user )
      return true
    else
      return false
    end
  end
  
  private

  def provide_dummy_names
      self.firstname = 'soapBox User'
      self.lastname = (User.last.try(:id) || 0 + 1).to_s
  end

  def send_welcome_email
    SoapBoxMailer.welcome_email(self).deliver
  end

end