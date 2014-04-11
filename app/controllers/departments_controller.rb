class DepartmentsController < ApplicationController
  before_filter :authenticate, :except => [ :show, :index ]

  def index
    @departments = Department.active
    @page_title = "Departments Offering Training"
  end

  def show
    @department = Department.find( params[ :id ] )
    @topics = @department.upcoming
    @page_title = @department.name
    respond_to do |format|
      format.html
      format.atom
      if authorized?(@department) || (current_user && current_user.editor?(@department))
        format.csv { send_csv @department.to_csv, @department }
      end
    end
  end

  def manage
    @departments = Department.active
    if authorized? @departments
      @page_title = "Manage Departments"
    else
      redirect_to departments_path
    end
  end

  def new
    @department = Department.new
    if authorized? @department
      @department.permissions.build
      @page_title = "Create New Department"
    else
      redirect_to departments_path
    end
  end

  def edit
    begin
      @department = Department.find( params[:id] )
    rescue ActiveRecord::RecordNotFound
      render(:file => 'shared/404.erb', :status => 404, :layout => true) unless @department
      return
    end

    if authorized? @department
      @department.permissions.build if @department.permissions.blank?
      @page_title = "Update Department Details"
    else
      redirect_to @department
    end
  end
  
  def create
    @department = Department.new( params[ :department ] )
    if authorized? @department
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
    if authorized? @department
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
    department = Department.find( params[ :id ] )
    if authorized? department
      if department.deactivate!
        flash[ :notice ] = "The department \"#{department.name}\" has been deleted."
        redirect_to manage_departments_path
        return
      else
        errors = department.errors.full_messages.join(" ")
        flash[ :error ] = "Unable to delete department \"#{department.name}\". " + errors
      end
    end
    redirect_to department
  end

end
