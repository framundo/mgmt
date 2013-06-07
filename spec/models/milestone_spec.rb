require 'spec_helper'

describe Milestone do
  let(:project) {build(:project)}
  subject(:milestone) {build(:milestone)}
  Issue.status_list.each do |status|
    let!(status.downcase.to_sym) {create(:issue, project: project, status: status, milestone_number: milestone.number)}
  end

  describe '#issues' do
    let(:expected_issues) {[started,rejected,finished,accepted,delivered,not_started]}

    it "returns issues sorted by status" do
      (milestone.issues <=> expected_issues).should eq 0
    end
  end
end
