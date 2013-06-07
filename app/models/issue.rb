class Issue < ActiveRecord::Base
  
  STATUS = %w(
    started
    rejected
    finished
    accepted
    delivered
    not_started
  )
  ACTIONS = {
    "start" => "started",
    "finish" => "finished",
    "accept" => "accepted",
    "reject" => "rejected",
    "deliver" => "delivered" 
  }
  TYPE = %w(
    chore
    feature
    bug
  )

  TRANSITIONS = {
    "not_started" => ["start"],
    "started" => ["finish"],
    "finished" => ["accept", "reject"],
    "accepted" => ["deliver"],
    "rejected" => ["start"],
    "delivered" => []
  }

  # Validations

  validates_presence_of :number
  validates_presence_of :project
  validates :status, inclusion: { in: STATUS }
  validates :issue_type, inclusion: { in: TYPE }

  # Associations

  belongs_to :project
  has_many :worked_hours_entries

  # Class Methods

  def self.status_list
    STATUS
  end

  # Instance Methods

  def worked_hours
    worked_hours_entries.reduce(0) { |sum, entry|  sum + entry.amount }
  end

end
