module ReservationsHelper
  def link_to_edit_reservation(reservation)
    return unless reservation && reservation.session.in_future?
    content_tag :div, link_to("Request special accomodations", edit_reservation_path(reservation)), :class => "edit-reservation-link"
  end
end
