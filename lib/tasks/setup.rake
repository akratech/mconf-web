namespace :setup do
  desc "All production tasks"
  task :production_tasks => [ :git_submodules, :config_database, "db:migrate", "basic_data:all" ] do
  end

  desc "Set production environment and run all production tasks"
  task :production do
    RAILS_ENV = ENV['RAILS_ENV'] = 'production'
    Rake::Task["setup:production_tasks"].invoke
  end

  desc "Setup development environment"
  task :development => [ :production_taks, :populate ] do
  end

  desc "Copy database.yml if it doesn't exist"
  task :config_database do
    print "* Checking config/database.yml: "
    db_file = "#{ RAILS_ROOT }/config/database.yml"

    if File.exist?(db_file)
      puts "file exists."
    else
      `cp #{ db_file }.example #{ db_file }` 
      puts "copied."
    end
  end

  desc "Update Git Submodules"
  task :git_submodules do
    puts "* Updating Git submodules"

    git_version = `git --version`.chomp.split(" ").last
    if git_version > "1.6"
      system "git submodule sync"
    else
      system "git submodule init"
      system "git submodule update"
    end
  end
end
