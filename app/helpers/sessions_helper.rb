module SessionsHelper
  def attendance_sheet_entry(user)
    entry = simple_format(user.name)
    line2 = ""
    line2 << user.email if user.email
    line2 << ", " if user.email && user.department
    line2 << user.department if user.department
    entry << simple_format(line2, :class => "line2") unless line2.blank?
    entry
  end
end
