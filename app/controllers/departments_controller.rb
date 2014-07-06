class DepartmentsController < ApplicationController
  before_action :set_department, only: [:show, :edit, :update, :destroy]

  # GET /departments/1
  # GET /departments/1.json
  def show
    @page_title = @department.name
    respond_to do |format|
      format.html
      format.atom
      if authorized?(@department) || (current_user && current_user.editor?(@department))
        format.csv do
          key = fragment_cache_key(['departments/csv', @department])
          data = Rails.cache.fetch(key) do 
            Cashier.store_fragment(key, @department.cache_key)
            @department.to_csv
          end
          send_csv data, @department 
        end
      end
    end
  end

  # GET /departments/new
  def new
    @department = Department.new
    @department.permissions.build
  end

  # GET /departments/1/edit
  def edit
    @department.permissions.build unless @department.permissions.present?
  end

  # POST /departments
  # POST /departments.json
  def create
    @department = Department.new(department_params)

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
      @department = Department.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def department_params
      params.require(:department).permit(:name, 
        permissions_attributes: [:id, :name_and_login, :_destroy]
      )
    end
end
