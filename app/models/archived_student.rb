#Fedena
#Copyright 2011 Foradian Technologies Private Limited
#
#This product includes software developed at
#Project Fedena - http://www.projectfedena.org/
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

class ArchivedStudent < ActiveRecord::Base
  belongs_to :country
  belongs_to :batch
  belongs_to :student_category
  belongs_to :nationality, :class_name => 'Country'
  has_many :archived_guardians, :foreign_key => 'ward_id', :dependent => :destroy
  has_one :immediate_contact

  #has_and_belongs_to_many :graduated_batches, :class_name => 'Batch', :join_table => 'batch_students',:foreign_key => 'student_id' ,:finder_sql =>'SELECT * FROM `batches`,`archived_students`  INNER JOIN `batch_students` ON `batches`.id = `batch_students`.batch_id WHERE (`batch_students`.student_id = `archived_students`.former_id )'

  has_attached_file :photo,
    :styles => {
    :thumb=> "100x100#",
    :small  => "150x150>"},
    :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/system/:class/:attachment/:id/:style/:basename.:extension"
attr_accessor :photo_file_name
  attr_accessor :photo_content_type
  attr_accessor :photo_file_size
  attr_accessor :photo_updated_at
  def gender_as_text
    self.gender == 'm' ? 'Male' : 'Female'
  end

  def first_and_last_name
    "#{first_name} #{last_name}"
  end

  def full_name
    "#{first_name} #{middle_name} #{last_name}"
  end

  def immediate_contact
    ArchivedGuardian.find(self.immediate_contact_id) unless self.immediate_contact_id.nil?
  end

  def all_batches
    self.graduated_batches + self.batch.to_a
  end

  def graduated_batches
   # SELECT * FROM `batches` INNER JOIN `batch_students` ON `batches`.id = `batch_students`.batch_id
    Batch.find(:all,:conditions=> 'batch_students.student_id = ' + self.former_id, :joins =>'INNER JOIN `batch_students` ON `batches`.id = `batch_students`.batch_id' )
  end
end