class Guardian < ActiveRecord::Base
  
  belongs_to :country
  belongs_to :country_state
  belongs_to :ward, :class_name => 'Student'
  validates :first_name, :relation, presence: true
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def is_immediate_contact?
    ward.immediate_contact_id == id
  end
end
