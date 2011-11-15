class Subject < ActiveRecord::Base
  belongs_to :batch
  belongs_to :elective_group
  has_many :timetable_entries,:foreign_key=>'subject_id'
  has_many :employees_subjects
  has_many :employees ,:through => :employees_subjects
  validates :batch_id, :code, :name, :max_weekly_classes, presence: true
 # validates_presence_of :name, :max_weekly_classes, :code,:batch_id
  validates :max_weekly_classes, numericality: true
  #validates_numericality_of :max_weekly_classes
  validates_uniqueness_of :code, :scope=>:batch_id

  scope :for_batch, lambda { |b| { :conditions => { :batch_id => b.to_i, :is_deleted => false } } }
  scope :without_exams, :conditions => { :no_exams => false, :is_deleted => false }
  def inactivate
    update_attribute(:is_deleted, true)
  end
end
