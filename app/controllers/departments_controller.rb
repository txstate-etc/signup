class DepartmentsController < ApplicationController
  before_filter :authenticate, :except => [ :show, :index ]
  before_action :set_department, only: [:new, :show, :create, :edit, :update, :destroy]
  before_filter :ensure_authorized, except: [:index, :show, :manage]

  # GET /departments/1
  # GET /departments/1.json
  def show
    @page_title = @department.name
    respond_to do |format|
      format.html
      format.atom
      if authorized?(@department) || (current_user && current_user.editor?(@department))
        format.csv do
          data = cache(['departments/csv', @department]) do
            logger.debug { "Generating csv for department #{@department.name}" }
            @department.to_csv
          end
          send_csv data, @department 
        end
      end
    end
  end

  # POST /departments
  # POST /departments.json
  def create
    respond_to do |format|
      if @department.save
        format.html { redirect_to manage_departments_path, notice: 'Department was successfully created.' }
        format.json { render :show, status: :created, location: @department }
      else
        format.html { render :new }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /departments/1
  # PATCH/PUT /departments/1.json
  def update
    respond_to do |format|
      if @department.update(department_params)
        format.html { redirect_to manage_departments_path, notice: 'Department was successfully updated.' }
        format.json { render :show, status: :ok, location: @department }
      else
        flash.now[:alert] = 'There were problems updating this department.' 
        format.html { render :edit }
        format.json { render json: @department.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /departments/1
  # DELETE /departments/1.json
  def destroy
    @department.deactivate!
    respond_to do |format|
      format.html { redirect_to manage_departments_path, notice: "The department \"#{@department.name}\" has been deleted." }
      format.json { head :no_content }
    end
  end

  def manage
    @departments = Department.active.by_name    
    redirect_to departments_path unless authorized? @departments
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_department
      if action_name == 'new'
        @department = Department.new
      elsif action_name == 'create'
        @department = Department.new(department_params)
      else
        @department = Department.find(params[:id])
      end
      @department.permissions.build unless @department.permissions.present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def department_params
      params.require(:department).permit(:name, 
        permissions_attributes: [:id, :name_and_login, :_destroy]
      )
    end

    def ensure_authorized
      redirect_to departments_path unless authorized? @department
    end
end
