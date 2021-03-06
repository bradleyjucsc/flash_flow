require 'optparse'

module FlashFlow
  class Options
    def self.parse
      options = {}
      opt_parser = OptionParser.new do |opts|
        opts.banner = 'Usage: flash_flow [options]'
        opts.separator ''

        opts.on('--install', 'Copy flash_flow.yml.erb to your repo and exit') { |v| options[:install] = true }
        opts.on('-v', '--version', 'Print the current version of flash flow and exit') { |v| options[:version] = true }
        opts.on('--prod-deploy', 'Run IssueTracker#deploy_production and exit') { |v| options[:prod_deploy] = true }
        opts.on('--review-deploy', 'Run IssueTracker#deploy_review and exit') { |v| options[:review_deploy] = true }
        opts.on('--release-notes hours', 'Run IssueTracker#release_notes and exit') { |v| options[:release_notes] = v }
        opts.on('--release-email', 'Send an email with a latest build info and exit') { |v| options[:release_email] = v }
        opts.on('-n', '--no-merge', 'Run flash flow, but do not merge this branch') { |v| options[:do_not_merge] = true }
        opts.on('--rerere-forget', 'Delete the saved patch for this branch and let the merge fail if there is a conflict') { |v| options[:rerere_forget] = true }
        opts.on('--story id1', 'story id for this branch') { |v| options[:stories] = [v] }
        opts.on('--stories id1,id2', 'comma-delimited list of story ids for this branch') { |v| options[:stories] = v.split(',') }
        opts.on('-f', '--force-push', 'Force push your branch') { |v| options[:force] = v }
        opts.on('-c', '--config-file FILE_PATH', 'The path to your config file. Defaults to config/flash_flow.yml.erb') { |v| options[:config_file] = v }
        opts.on('--resolve', 'Launch a bash shell to save your conflict resolutions') { |v| options[:resolve] = true }
        opts.on('--resolve-manual', 'Print instructions to use git to resolve conflicts') { |v| options[:resolve_manual] = true }
        opts.on('--merge-status', 'Show status of all branches and their stories and exit') { |v| options[:merge_status] = true }
        opts.on('--merge-status-html', 'Show status of all branches and their stories in html format and exit') { |v| options[:merge_status_html] = true }
        opts.on('--make-release branch1,branch2', 'Comma-delimited list of branches to merge to the release branch. Run "--merge-release ready" to merge all ready to ship branches') { |v| options[:release_branches] = v.split(',') }
        opts.on('--gen-pdf-diffs output_file,build_id,threshold', 'Generate a pdf file with screenshot differences for the specified (latest) build. output_file is required. build_id defaults to the latest build. threshold defaults to 0') { |v| options[:gen_pdf_diffs] = v.split(',') }
        opts.on('--merge-release-email', 'Send an email if the release is ready to be merged to master') { |v| options[:merge_release_email] = true }
        opts.on('--merge-release', 'Merge the release branch into the master branch and push') { |v| options[:merge_release] = true }
        opts.on('--notify-compliance', 'Send the compliance notification email if everything is ready') { |v| options[:notify_compliance] = true }

        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end
      end

      opt_parser.parse!

      options[:stories] ||= []
      options[:config_file] ||= './config/flash_flow.yml.erb'

      options
    end
  end
end
