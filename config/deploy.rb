# config valid for current version and patch releases of Capistrano
lock "~> 3.11.2"

set :application, "redmine"
set :repo_url, "git@github.com:sassafrastech/redmine.git"
set :deploy_to, "/home/deploy/redmine"
# Default flags, plus rmagick
set :bundle_flags, "--deployment --quiet --without rmagick"
set :linked_files, %w[config/initializers/secret_token.rb config/database.yml config/configuration.yml config/additional_environment.rb]
set :linked_dirs, %w[tmp log plugins]
set :pty, true

if ENV["REV"]
  set :branch, ENV["REV"]
else
  ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
end
