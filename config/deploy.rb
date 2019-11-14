# config valid for current version and patch releases of Capistrano
lock "~> 3.12"

set :application, "redmine"
set :repo_url, "git@github.com:sassafrastech/redmine.git"
set :deploy_to, "/home/deploy/redmine"
set :linked_files, %w[config/initializers/secret_token.rb config/database.yml config/configuration.yml config/additional_environment.rb]
set :linked_dirs, %w[tmp log plugins public/themes]
set :pty, true

if ENV["REV"]
  set :branch, ENV["REV"]
else
  ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
end

namespace :db do
  task :migrate_plugins do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute(:rake, "redmine:plugins:migrate")
        end
      end
    end
  end
end

after "deploy:migrate", "db:migrate_plugins"
