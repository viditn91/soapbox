#FIXME_AB: put required validations
#FIX: company name would be present and unique 
class Company < ActiveRecord::Base
  has_many :users
  has_many :groups
  validates :name, presence: true, uniqueness: true
end
