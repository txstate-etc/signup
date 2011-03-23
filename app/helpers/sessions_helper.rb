module SessionsHelper
  def attendance_sheet_entry(user)
    entry = user.name
    entry << " (" if user.email || user.department
    entry << user.email if user.email
    entry << ", " if user.email && user.department
    entry << user.department if user.department
    entry << ")" if user.email || user.department
    entry
  end
end
