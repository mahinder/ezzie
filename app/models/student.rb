class Student < ActiveRecord::Base
  
  validates :admission_no, :admission_date, :first_name, :batch_id, :date_of_birth, presence: true
  validates :admission_no, uniqueness: true
  validates_format_of  :email, :with => /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i,   :allow_blank=>true, :message => "must be a valid email address"
  validates_format_of  :admission_no, :with => /^[A-Z0-9_-]*$/i,  :message => "must contain only letters, numbers, hyphen, and  underscores"
  belongs_to :country
  belongs_to :country_state
  belongs_to :batch
  belongs_to :student_category
  belongs_to :user,:dependent=>:destroy,:autosave=>true
  has_many   :guardians, :foreign_key => 'ward_id', :dependent => :destroy
  has_many   :finance_fees
  belongs_to :nationality, :class_name => 'Country'
  has_one    :immediate_contact 
  has_one    :student_previous_data

  before_validation :create_user_and_validate
  has_attached_file :photo,
    :styles => {
    :thumb=> "100x100#",
    :small  => "150x150>",
    :medium => "300x300>",
    :large =>   "400x400>" },
    :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
    :path => ":rails_root/public/system/:class/:attachment/:id/:style/:basename.:extension"

  attr_accessor :photo_file_name

  
  
  VALID_IMAGE_TYPES = ['image/gif', 'image/png','image/jpeg', 'image/jpg']
  validates_attachment_content_type :photo, :content_type =>VALID_IMAGE_TYPES,
    :message=>'Image can only be GIF, PNG, JPG',:if=> Proc.new { |p| !p.photo_file_name.blank? }

  def image_file=(input_data)
    return if input_data.blank?
    self.photo_filename     = input_data.original_filename
    self.photo_content_type = input_data.content_type.chomp
    self.photo_data         = input_data.read
  end
  
  def first_and_last_name
    "#{first_name} #{last_name}"
  end

  def full_name
    "#{first_name} #{middle_name} #{last_name}"
  end

  def gender_as_text
    return 'Male' if gender.downcase == 'm'
    return 'Female' if gender.downcase == 'f'
    nil
  end
  def immediate_contact
    Guardian.find(self.immediate_contact_id) unless self.immediate_contact_id.nil?
  end
  def create_user_and_validate
    self.email ||="noreply" + self.admission_no.to_s + "@fedena.com"
    if self.new_record?
      user_record = self.build_user
      user_record.first_name = self.first_name
      user_record.last_name = self.last_name
      user_record.username = self.admission_no.to_s
      user_record.password = self.admission_no.to_s + "123"
      user_record.role = 'Student'
      user_record.email = self.email.blank? ? "noreply#{self.admission_no.to_s}@fedena.com" : self.email.to_s
      check_user_errors(user_record)
      return false unless errors.blank?
    else
      self.user.role = "Student"
      changes_to_be_checked = ['admission_no','first_name','last_name','email']
      check_changes = self.changed & changes_to_be_checked
      unless check_changes.blank?
        self.user.username = self.admission_no if check_changes.include?('admission_no')
        self.user.first_name = self.first_name if check_changes.include?('first_name')
        self.user.last_name = self.last_name if check_changes.include?('last_name')
        self.user.email = self.email if check_changes.include?('email')
        check_user_errors(self.user)
      end
    end
    self.email = "noreply#{self.admission_no}@fedena.com" if self.email.blank?
    return false unless errors.blank?
  end
   def check_user_errors(user)
    unless user.valid?
      user.errors.each{|attr,msg| errors.add(attr.to_sym,"#{msg}")}
    end
    return false unless user.errors.blank?
  end

  def previous_fee_student(date)
    fee = FinanceFee.first(:conditions => "student_id < #{self.id} and fee_collection_id = #{date}", :joins=>'INNER JOIN students ON finance_fees.student_id = students.id',:order => "student_id DESC")
    prev_st = fee.student unless fee.blank?
    fee ||= FinanceFee.first(:conditions=>"fee_collection_id = #{date}", :joins=>'INNER JOIN students ON finance_fees.student_id = students.id',:order => "student_id DESC")
    prev_st ||= fee.student unless fee.blank?
    #    prev_st ||= self.batch.students.first(:order => "id DESC")
  end

  def next_fee_student(date)

    fee = FinanceFee.first(:conditions => "student_id > #{self.id} and fee_collection_id = #{date}", :joins=>'INNER JOIN students ON finance_fees.student_id = students.id', :order => "student_id ASC")
    next_st = fee.student unless fee.nil?
    fee ||= FinanceFee.first(:conditions=>"fee_collection_id = #{date}", :joins=>'INNER JOIN students ON finance_fees.student_id = students.id',:order => "student_id ASC")
    next_st ||= fee.student unless fee.nil?
    #    prev_st ||= self.batch.students.first(:order => "id DESC")
  end

  def finance_fee_by_date(date)
    FinanceFee.find_by_fee_collection_id_and_student_id(date.id,self.id)
  end

  def check_fees_paid(date)
    category = FinanceFeeCategory.find(date.fee_category_id)
    particulars = category.fees(self)
    total_fees=0
    financefee = date.fee_transactions(self.id)
    particulars.map { |s|  total_fees += s.amount.to_f}
    paid_fees_transactions = FinanceTransaction.find(:all,:select=>'amount,fine_amount',:conditions=>"FIND_IN_SET(id,\"#{financefee.transaction_id}\")") unless financefee.nil?
    paid_fees = 0
    paid_fees_transactions.map { |m| paid_fees += m.amount.to_f - m.fine_amount.to_f } unless paid_fees_transactions.nil?
    amount_pending = total_fees.to_f - paid_fees.to_f
    if amount_pending == 0
      return true
    else
      return false
    end

    #    unless particulars.nil?
    #      return financefee.check_transaction_done unless financefee.nil?
    #
    #    else
    #      return false
    #    end
  end
 def archive_student(status)
    self.update_attributes(:is_active => false, :status_description => status)
    student_attributes = self.attributes
    student_attributes["former_id"]= self.id
    student_attributes.delete "id"
    student_attributes.delete "has_paid_fees"
    student_attributes.delete "photo_file_size"
    student_attributes.delete "photo_file_name"
    student_attributes.delete "photo_content_type"
    student_attributes.delete "user_id"
    archived_student = ArchivedStudent.new(student_attributes)
    archived_student.photo = self.photo
    if archived_student.save
      guardian = self.guardians
      self.user.delete unless self.user.blank?
      self.delete
      guardian.each do |g|
        g.archive_guardian(archived_student.id)
      end
      #
      #student_exam_scores = ExamScore.find_all_by_student_id(self.id)
      #student_exam_scores.each do |s|
       # exam_score_attributes = s.attributes
        #exam_score_attributes.delete "id"
        #exam_score_attributes.delete "student_id"
        #exam_score_attributes["student_id"]= archived_student.id
        #ArchivedExamScore.create(exam_score_attributes)
        s.delete
      end
      
    end
 
  
end
