module GithubProvisioner

  class Repository < SimpleDelegator

    def initialize(github, project)
      super(project)
      @github = github
      @project = project
    end

    # Methods related to issues

    def provide_issues!
      self.issues_attributes = fetch_parsed_issues
      save!
    end

    def sync_issues!
      gh_issues = fetch_parsed_issues(:all)
      transaction do
        gh_issues.each { |issue| sync_issue(issue) }
      end
    end

    # Methods related to milestones

    def provide_milestones!
      self.milestones_attributes = fetch_parsed_milestones
      save!
    end

    def sync_milestones!
      gh_milestones = fetch_parsed_milestones
      transaction do
        gh_milestones.each { |milestone| sync_milestone(milestone) }
      end
    end

    private

      # Methods related to issues

      def fetch_issues(state)
        if state == :all
          fetch_issues(:closed).to_a + fetch_issues(:open).to_a
        else
          options = {
            user: organization, 
            repo: name, 
            state: state.to_s
          }
          result = []
          @github.issues.list(options).each_page { |page| result << page.to_a }
          result.flatten
        end
      end

      def fetch_parsed_issues(state = :open)
        fetch_issues(state).map do |issue|
          GithubProvisioner::Issue.extract_attributes(issue)
        end
      end

      def sync_issue(gh_issue)
        puts "syncing issue #{gh_issue}"
        issue = self.issues.where(number: gh_issue[:number]).first
        if issue.nil?
          ::Issue.create!(gh_issue.merge(project: @project))
        else
          gh_issue[:milestone_number] = nil if gh_issue[:milestone_number].nil?
          issue.update_attributes!(gh_issue)
        end
      end

      # Methods related to milestones

      def fetch_milestones
        options = {
          user: organization, 
          repo: name, 
        }
        result = []
        @github.issues.milestones.list(options).each_page { |page| result << page.to_a }
        result.flatten
      end

      def fetch_parsed_milestones
        fetch_milestones.map do |milestone|
          GithubProvisioner::Milestone.extract_attributes(milestone)
        end
      end

      def sync_milestone(gh_milestone)
        puts "syncing milestone #{gh_milestone}"
        milestone = self.milestones.where(number: gh_milestone[:number]).first
        if milestone.nil?
          ::Milestone.create!(gh_milestone.merge(project: @project))
        elsif milestone.due_date != gh_milestone[:due_date]
          milestone.update_attributes!(due_date: gh_milestone[:due_date])
        end
      end

  end

end