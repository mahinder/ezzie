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

class FinanceFeeCollection < ActiveRecord::Base
  belongs_to :batch
  has_many :finance_fees, :foreign_key =>"fee_collection_id",:dependent=>:destroy
  has_many :students, :through => :finance_fees
  has_many :fee_collection_particulars ,:dependent=>:destroy
  has_many :fee_collection_discounts   ,:dependent=>:destroy
  belongs_to :fee_category,:class_name => "FinanceFeeCategory"

  validates :name,:start_date,:fee_category_id,:end_date,:due_date, presence: true

  after_create :create_associates

  def validate
    unless self.start_date.nil? or self.end_date.nil?
      errors.add_to_base("start date cant be after end date") if self.start_date > self.end_date
      errors.add_to_base("start date cant be after due date") if self.start_date > self.due_date
      errors.add_to_base("end date cant be after due date") if self.end_date > self.due_date
    else
    end
  end

  def full_name
    "#{name} - #{start_date.to_s}"
  end

  def fee_transactions(student_id)
    FinanceFee.find_by_fee_collection_id_and_student_id(self.id,student_id)
  end

  def check_transaction(transactions)
    transactions.finance_fees_id.nil? ? false : true
   
  end

  def self.shorten_string(string, count)
    if string.length >= count
      shortened = string[0, count]
      splitted = shortened.split(/\s/)
      words = splitted.length
      splitted[0, words-1].join(" ") + ' ...'
    else
      string
    end
  end

  def check_fee_category
    finance_fees = FinanceFee.find_all_by_fee_collection_id(self.id)
    flag = 1
    finance_fees.each do |f|
      flag = 0 unless f.transaction_id.nil?
    end
    flag == 1 ? true : false
  end

  def no_transaction_present
    f = FinanceFee.find_all_by_fee_collection_id(self.id)
    f.reject! {|x|x.transaction_id.nil?} unless f.nil?
    f.blank?
  end

  def create_associates
    
    batch_discounts = BatchFeeDiscount.find_all_by_finance_fee_category_id(self.fee_category_id)
    batch_discounts.each do |discount|
      discount_attributes = discount.attributes
      discount_attributes.delete "type"
      discount_attributes.delete "finance_fee_category_id"
      discount_attributes["finance_fee_collection_id"]= self.id
      BatchFeeCollectionDiscount.create(discount_attributes)
    end
    category_discount = StudentCategoryFeeDiscount.find_all_by_finance_fee_category_id(self.fee_category_id)
    category_discount.each do |discount|
      discount_attributes = discount.attributes
      discount_attributes.delete "type"
      discount_attributes.delete "finance_fee_category_id"
      discount_attributes["finance_fee_collection_id"]= self.id
      StudentCategoryFeeCollectionDiscount.create(discount_attributes)
  end
  student_discount = StudentFeeDiscount.find_all_by_finance_fee_category_id(self.fee_category_id)
    student_discount.each do |discount|
      discount_attributes = discount.attributes
      discount_attributes.delete "type"
      discount_attributes.delete "finance_fee_category_id"
      discount_attributes["finance_fee_collection_id"]= self.id
      StudentFeeCollectionDiscount.create(discount_attributes)
  end
  particlulars = FinanceFeeParticulars.find_all_by_finance_fee_category_id(self.fee_category_id,:conditions=>"is_deleted=0")
      particlulars.each do |p|
        particlulars_attributes = p.attributes
        particlulars_attributes.delete "finance_fee_category_id"
        particlulars_attributes["finance_fee_collection_id"]= self.id
        FeeCollectionParticular.create(particlulars_attributes)
      end
  end

  def fees_particulars(student)
    FeeCollectionParticular.find_all_by_finance_fee_collection_id(self.id,
      :conditions => ["((student_category_id IS NULL AND admission_no IS NULL )OR(student_category_id = '#{student.student_category_id}'AND admission_no IS NULL) OR (student_category_id IS NULL AND admission_no = '#{student.admission_no}')) and is_deleted=0"])
  end


end
