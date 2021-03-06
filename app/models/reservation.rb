class Reservation < ActiveRecord::Base
  belongs_to :listing
  belongs_to :guest, :class_name => "User"
  has_one :review

  validates :checkin, presence: true
  validates :checkout, presence: true
  validate :checkin_before_checkout, :host_is_not_guest, :checkin_not_checkout
  before_validation :available?

  def duration
    checkout - checkin
  end

  def total_price
    listing.price * duration
  end

  def checkin_before_checkout
    if checkin && checkout && checkout < checkin
      errors.add(:reservation, "Please try date again.")
    end
  end

  def host_is_not_guest
    if self.listing.host_id == self.guest_id
      errors.add(:host_is_not_guest, "You cannot make a Reservation on your own listing")
    end
  end

  def checkin_not_checkout
    if checkin == checkout
      errors.add(:reservation, "Please try date again.")
    end
  end

  def available?
    if checkin && checkout
      listing.reservations.each do |res|
        if res.checkin <= checkout && res.checkout >= checkin
          errors.add(:reservation, "Please try date again.")
        end
      end
    end
  end
end
