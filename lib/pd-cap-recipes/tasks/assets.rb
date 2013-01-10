Capistrano::Configuration.instance(:must_exist).load do |config|
  after 'deploy:assets:precompile', 'deploy:assets:cdn_deploy'

  namespace :deploy do
    namespace :assets do
      desc <<-DESC
        Deploy the compiled assets to a CDN. RSync the shared directory to asset_cdn_host.
        This operation happens on a single host.
      DESC
      task :cdn_deploy, :roles => :web do
        unless fetch(:skip_cdn_deploy, false)
          # sync assets
          server = find_servers_for_task(current_task).first
          asset_dir = "#{shared_path}/assets"
          ssh_env = fetch(:ssh_env, "-e 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'")
          run "rsync -av #{ssh_env} #{asset_dir} #{asset_cdn_host}", :hosts => server
        end
      end

      # Override the capistrano default task
      task :precompile, :roles => :web, :except => { :no_release => true } do
        if force_asset_compilation? || assets_dirty?
          run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
          set :skip_cdn_deploy, false
        else
          set :skip_cdn_deploy, true
          logger.info "Skipping asset pre-compilation because there were no asset changes"
        end
      end

      def force_asset_compilation?
        fetch(:always_compile_assets, false) || ENV['COMPILE_ASSETS'] == 'true'
      end

      def cached_copy
        File.join(shared_path, fetch(:repository_cache, "cached-copy"))
      end

      def assets_dirty?
        r = safe_current_revision
        return true if r.nil?
        from = source.next_revision(r)
        asset_changing_files = ["vendor/assets/", "app/assets/", "lib/assets", "Gemfile", "Gemfile.lock"]
        asset_changing_files = asset_changing_files.select do |f|
          File.exists? f
        end
        capture("cd #{cached_copy} && #{source.local.log(current_revision, source.local.head)} #{asset_changing_files.join(" ")} | wc -l").to_i > 0
      end
    end
  end
end
