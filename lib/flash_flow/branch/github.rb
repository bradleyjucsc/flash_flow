require 'octokit'

module FlashFlow
  module Branch
    class Github

      attr_accessor :repo, :unmergeable_label

      def initialize(config={})
        initialize_connection!(config['token'])
        @repo = config['repo']
        @master_branch = config['master_branch'] || master
        @unmergeable_label = config['unmergeable_label'] || 'unmergeable'
        @do_not_merge_label = config['do_not_merge_label'] || 'do not merge'
      end

      def initialize_connection!(token)
        if token.nil?
          raise RuntimeError.new("Github token must be set in your flash_flow config file.")
        end
        octokit.configure do |c|
          c.access_token = token
        end
      end

      def remove_from_merge(branch)
        pr = pr_for(branch)
        if pr && @do_not_merge_label
          add_label(pr.number, @do_not_merge_label)
        end
      end

      def fetch
        pull_requests.map do |pr|
          {
              'remote_url' => pr.head.repo.ssh_url,
              'ref' => pr.head.ref,
              'status' => status_from_labels(pr),
              'metadata' => {
                  'pr_number' => pr.number,
                  'user_url' => pr.user.html_url,
                  'repo_url' => pr.head.repo.html_url
              }
          }
        end
      end

      def add_to_merge(branch)
        pr = pr_for(branch)

        pr ||= create_pr(branch.ref, branch.ref, branch.ref)

        if pr && @do_not_merge_label
          remove_label(pr.number, @do_not_merge_label)
        end
      end

      def mark_success(branch)
        remove_label(branch.metadata['pr_number'], @unmergeable_label)
      end

      def mark_failure(branch)
        add_label(branch.metadata['pr_number'], @unmergeable_label)
      end

      private

      def status_from_labels(pull_request)
        case
          when has_label?(pull_request.number, @do_not_merge_label)
            'removed'
          when has_label?(pull_request.number, @unmergeable_label)
            'fail'
          else
            nil
        end
      end

      def pr_for(branch)
        pull_requests.detect { |p| branch.remote_url == p.head.repo.ssh_url && branch.ref == p.head.ref }
      end

      def update_pr(pr_number)
        octokit.update_pull_request(repo, pr_number, {})
      end

      def create_pr(branch, title, body)
        pr = octokit.create_pull_request(repo, @master_branch, branch, title, body)
        pull_requests << pr
        pr
      end

      def pull_requests
        @pull_requests ||= octokit.pull_requests(repo).sort_by(&:updated_at)
      end

      def remove_label(pull_request_number, label)
        if has_label?(pull_request_number, label)
          octokit.remove_label(repo, pull_request_number, label)
        end
      end

      def add_label(pull_request_number, label)
        unless has_label?(pull_request_number, label)
          octokit.add_labels_to_an_issue(repo, pull_request_number, [label])
        end
      end

      def has_label?(pull_request_number, label_name)
        labels(pull_request_number).detect { |label| label.name == label_name }
      end

      def labels(pull_request_number)
        @labels ||= {}
        @labels[pull_request_number] ||= octokit.labels_for_issue(repo, pull_request_number)
      end

      def octokit
        Octokit
      end
    end
  end
end