set :application, "global2"
set :repository,  "http://git-isabel.dit.upm.es/global2.git"
set :scm, "git"
set :git_enable_submodules, 1


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/isabel/#{ application }"
set :deploy_via, :export

after 'deploy:update_code', 'deploy:link_files'
after 'deploy:update_code', 'deploy:fix_file_permissions'

namespace(:deploy) do
  task :fix_file_permissions do
    # AttachmentFu dir is deleted in deployment
    run  "/bin/mkdir -p #{ release_path }/tmp/attachment_fu"
    run "/bin/chmod -R g+w #{ release_path }/tmp"
    sudo "/bin/chgrp -R www-data #{ release_path }/tmp"
  end

  task :link_files do
    run "ln -sf #{ shared_path }/config/database.yml #{ release_path }/config/"
  end

  desc "Restarting mod_rails with restart.txt"
    task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
end


role :app, "isabel@vcc.dit.upm.es"
role :web, "isabel@vcc.dit.upm.es"
role :db,  "isabel@vcc.dit.upm.es", :primary => true
