class PayrollsController < ApplicationController
    before_filter :login_required
    #filter_access_to :all
    def add_category
      @categories = PayrollCategory.find_all_by_is_deduction(false, :order=> "name ASC")
      @deductionable_categories = PayrollCategory.find_all_by_is_deduction(true, :order=> "name ASC")
      @category = PayrollCategory.new(params[:category])
      if request.post? and @category.save
        flash[:notice]="payroll category saved"
        redirect_to :action => "add_category"
      end

    end

    def edit_category
      @categories = PayrollCategory.find(:all, :order=> "name ASC")
      @category = PayrollCategory.find(params[:id])
      if request.post? and @category.update_attributes(params[:category])
        flash[:notice] = "Payroll category updated"
        redirect_to :action => "add_category"
      end
    end

    def activate_category
      category = PayrollCategory.update(params[:id], :status => true)
      @categories = PayrollCategory.find_all_by_is_deduction(false, :order=> "name ASC")
      @deductionable_categories = PayrollCategory.find_all_by_is_deduction(true, :order=> "name ASC")
      render :partial => "category"
    end

    def inactivate_category
      category = PayrollCategory.update(params[:id], :status => false)
      @categories = PayrollCategory.find_all_by_is_deduction(false, :order=> "name ASC")
      @deductionable_categories = PayrollCategory.find_all_by_is_deduction(true, :order=> "name ASC")
      render :partial => "category"
    end

    def delete_category
      employees = EmployeeSalaryStructure.find(:all ,:conditions=>"payroll_category_id = #{params[:id]}")
      if employees.empty?
        PayrollCategory.find(params[:id]).destroy
        @departments = PayrollCategory.find :all
        flash[:notice]="Successfully deleted!"
        redirect_to :action => "add_category"
      else
        flash[:notice]="Unable to delete!"
        redirect_to :action => "add_category"
      end
    end

    def manage_payroll
      puts "hey i am in payroll"
    # @employee = Employee.find(params[:id])
    # @independent_categories = PayrollCategory.find_all_by_payroll_category_id_and_status(nil, true)
    # @dependent_categories = PayrollCategory.find_all_by_status(true, :conditions=>"payroll_category_id != \'\'")
    # payroll_created = EmployeeSalaryStructure.find_all_by_employee_id(@employee.id)
    # unless @independent_categories.empty? and @dependent_categories.empty?
    # if payroll_created.empty?
    # if request.post?
    #
    # params[:manage_payroll].each_pair do |k, v|
    # EmployeeSalaryStructure.create(:employee_id => params[:id], :payroll_category_id => k, :amount => v['amount'])
    # end
    # flash[:notice] = "Data saved for #{@employee.first_name}"
    # redirect_to :controller => "employee", :action => "profile", :id=> @employee.id
    # end
    # else
    # redirect_to :controller=>"employee", :action=>"profile", :id=>@employee.id
    # end
    # else
    # redirect_to :controller=>"employee", :action=>"profile", :id=>@employee.id
    # end
    end

    def update_dependent_fields
      cat_id = params[:cat_id]
      amount = params[:amount]
      @dependent_categories = PayrollCategory.find_all_by_payroll_category_id(cat_id,:conditions=>"status = true")
      render :update do |page|
        @dependent_categories.each do |c|
          unless c.percentage.nil?
            percentage_value = c.percentage
            calculated_amount =(amount.to_i*percentage_value/100)
            page["manage_payroll_#{c.id}_amount"].value = calculated_amount
            page << remote_function(:url  => {:action => "update_dependent_fields"}, :with => "'amount='+ #{calculated_amount} + '&cat_id=' + #{c.id}")
          end
        end
      end
    end

    def edit_payroll_details
      @employee = Employee.find(params[:id])
      @independent_categories = PayrollCategory.find_all_by_payroll_category_id_and_status(nil, true)
      @dependent_categories = PayrollCategory.find_all_by_status(true, :conditions=>"payroll_category_id != \'\'")
      if request.post?
        params[:manage_payroll].each_pair do |k, v|
          row_id = EmployeeSalaryStructure.find_by_employee_id_and_payroll_category_id(@employee, k)
          unless row_id.nil?
            EmployeeSalaryStructure.update(row_id, :employee_id => params[:id], :payroll_category_id => k,
            :amount => v['amount'])
          else
            EmployeeSalaryStructure.create(:employee_id => params[:id], :payroll_category_id => k, :amount => v['amount'])
          end

        end
        flash[:notice] = "Data saved for #{@employee.first_name}"
        redirect_to :controller => "employees", :action => "profile", :id=> @employee.id
      end
    end
  end


