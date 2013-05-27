set :application, "timewarp.mediacube.at"
set :repository,  "git@github.com:RobertKoch/timewarp.git"

set :deploy_to, "/var/www/timewarp.mediacube.at"
set :user, "robi"
set :use_sudo, true

set :scm, :git
set :branch, "master"
set :port, 5412

set :shared_children, shared_children + %w{public/saved_sites}

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

role :web, "timewarp.mediacube.at"
role :app, "timewarp.mediacube.at"
role :db,  "timewarp.mediacube.at", :primary => true

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :copy_config do
    run "ln -nfs #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"
  end
end

require "bundler/capistrano"
require "rvm/capistrano"

set :rvm_ruby_string, "ruby-1.9.3-p392" # use the same ruby as used locally for deployment
set :rvm_autolibs_flag, "read-only" 
before 'deploy:setup', 'rvm:create_gemset'

after "deploy:update_code", "deploy:copy_config"
