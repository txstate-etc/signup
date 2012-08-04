class DepartmentsController < ApplicationController
  before_filter :authenticate, :except => [ :show, :index ]

  def index
    @departments = Department.all
    @page_title = "Departments Offering Training"
  end

  def show
    @department = Department.find( params[ :id ] )
    @page_title = "Topics Offered By: " + @department.name
  end

  def manage
    @departments = Department.all
    @page_title = "Manage Departments"
  end

  def new
    if current_user && current_user.admin?
      @department = Department.new
      @department.permissions.build
      @page_title = "Create New Department"
    else
      redirect_to departments_path
    end
  end

  def edit
    if current_user && current_user.admin?
      begin
        @department = Department.find( params[:id] )
      rescue ActiveRecord::RecordNotFound
        render(:file => 'shared/404.erb', :status => 404, :layout => true) unless @department
        return
      end
      @department.permissions.build if @department.permissions.blank?
      @page_title = "Update Department Details"
    else
      redirect_to departments_path
    end
  end
  
  def create
    if current_user && current_user.admin?
      @department = Department.new( params[ :department ] )
      if @department.save
        flash[ :notice ] = "Department \"" + @department.name + "\" added."
        redirect_to manage_departments_path
      else
        @department.permissions.build
        @page_title = "Create New Department"
        render :action => 'new'
      end
    else
      redirect_to departments_path
    end
  end
  
  def update
    @department = Department.find( params[ :id ] )
    if current_user && current_user.admin?
      success = @department.update_attributes( params[ :department ] )
      @page_title = @department.name
      if success
        flash[ :notice ] = "The department's data has been updated."
        redirect_to manage_departments_path
      else
        flash.now[ :error ] = "There were problems updating this department."
        @department.permissions.build if @department.permissions.blank?
        render :action => 'edit'
      end
    else
      redirect_to @department
    end
  end
  
  def destroy
    @department = Department.find( params[ :id ] )
    if current_user && current_user.admin?    
      if @department.topics.present?
        flash[ :error ] = "Cannot delete department! There are topics assigned to it."
        redirect_to @department
      else
        @department.destroy
        flash[ :notice ] = "The department #{@department.name} has been deleted."
        redirect_to manage_departments_path
      end    
    else
      redirect_to @department
    end
  end  
end
