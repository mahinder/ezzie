class User < ActiveRecord::Base

  attr_accessor :password, :role, :old_password, :confirm_password, :new_password
  validates :username, presence: true, uniqueness: true, length: {within: 1..20}, format: {with: /^[A-Z0-9_-]*$/i, message: "must contain only letters, numbers, and underscores" }
  validates :email, uniqueness: true, format: {with: /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i, message: "must be a valid email address"}
  validates :role, presence: true
  has_and_belongs_to_many :privileges

  has_one :student_record,:class_name=>"Student",:foreign_key=>"user_id"
  has_one :employee_record,:class_name=>"Employee",:foreign_key=>"user_id"

  before_save :create_user
  def create_user
    puts "I am called on before save"
    self.salt = random_string(8) if self.salt == nil
    self.hashed_password = Digest::SHA1.hexdigest(self.salt + self.password) unless self.password.nil?
    self.admin, self.employee, self.student = false, false, false
    self.admin = true if self.role == "Admin"
    self.employee = true if self.role == "Employee"
    self.student = true if self.role == "Student"
  end

  def random_string(len)
    randstr = ""
    chars = ("0".."9").to_a + ("a".."z").to_a + ("A".."Z").to_a
    len.times { randstr << chars[rand(chars.size - 1)] }
    randstr
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def role_name
    return "Admin" if self.admin?
    return "Student" if self.student?
    return "Employee" if self.employee?
    return nil
  end

  def check_reminders
    reminders =[]
    reminders = Reminder.find(:all , :conditions => ["recipient = '#{self.id}'"])
    count = 0
    reminders.each do |r|
      unless r.is_read
      count += 1
      end
    end
    return count
  end

  def self.authenticate?(username, password)
    puts "iam in autho"
    u = User.find_by_username username
    u.hashed_password == Digest::SHA1.hexdigest(u.salt + password)
  end

  def role_symbols
    prv = []
    @privilge_symbols ||= privileges.map { |privilege| prv << privilege.name.underscore.to_sym }

    if admin?
      return [:admin] + prv
    elsif student?
      return [:student] + prv
    elsif employee?
      return [:employee] + prv
    else
    return prv
    end
  end

end
