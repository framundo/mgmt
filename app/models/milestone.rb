class Milestone < ActiveRecord::Base

  # Validations

  validates_presence_of :number
  # validates_presence_of :start_date
  validates_presence_of :due_date
  # validates_presence_of :estimated_hours
  # validates_presence_of :client_estimated_hours
  # validate :start_must_be_before_due_date
  # validate :estimated_hours_must_be_lower_than_client_estimated_hours
  validate :does_not_overlap

  # Associations

  belongs_to :project

  # Instance Methods

  # def start_must_be_before_due_date
  #   errors.add(:start_date, "must be before due date") unless self.start_date < self.due_date
  # end

  # def estimated_hours_must_be_lower_than_client_estimated_hours
  #   errors.add(:estimated_hours, "must be lower than client estimated hours") unless self.estimated_hours <= self.client_estimated_hours
  # end 

  def issues
    Issue.where(milestone_number: number).sort do |a,b|
      Issue.status_list.index(a.status) <=> Issue.status_list.index(b.status)
    end
  end

  def does_not_overlap
    project.milestones.where("start_date IS NOT NULL AND due_date IS NOT NULL").each do |milestone|
      unless self.due_date < milestone.start_date || self.start_date > milestone.due_date
        errors.add(:start_date, 'models.milestone.overlap')
      end
    end
  end
  
end
