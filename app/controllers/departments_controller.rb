class DepartmentsController < ApplicationController
  def index
    @departments = Department.all
    @page_title = "Departments Offering Training"
  end

  def show
    @department = Department.find( params[ :id ] )
    @page_title = "Topics Offered By: " + @department.name
  end

end
