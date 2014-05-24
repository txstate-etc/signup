class Session < ActiveRecord::Base
  belongs_to :topic
  belongs_to :site
end
