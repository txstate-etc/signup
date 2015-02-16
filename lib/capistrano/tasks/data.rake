namespace :data do
  
  def sql_dump_file
    fetch(:sql_dump_file, "dump.#{fetch(:application)}.sql")
  end

  def documents_dump_file
    fetch(:documents_dump_file, "documents.#{fetch(:application)}.tar.gz")
  end

  desc "Export data from the target environment and copy it to the local environment"
  task :import do
    invoke 'data:create_dump'
    invoke 'data:xfer_dump'
    invoke 'data:load_dump'
  end
  
  task :importlast do
    invoke 'data:xfer_dump'
    invoke 'data:load_dump'
  end
  
  task :grab_dump do
    invoke 'data:create_dump'
    invoke 'data:xfer_dump'
  end
  
  desc "Create sql file on remote server via rake task"
  task :create_dump do
    #FIXME: on_rollback { run "rm #{current_path}/tmp/#{sql_dump_file}" }
    
    on roles :db do
      within current_path do
        with rails_env: fetch(:rails_env) do    
          debug "executing remote mysqldump"
          execute :rake, 'db:dump'
        end
      end
    end
  end
  
  desc "Move sql file from remote to local"
  task :xfer_dump do
    on roles :db do
      within current_path do
        with rails_env: fetch(:rails_env) do    
          debug "initiating transfer"
          download! "#{current_path}/tmp/#{sql_dump_file}", "tmp/#{sql_dump_file}"
          download! "#{current_path}/tmp/#{documents_dump_file}", "tmp/#{documents_dump_file}"
          execute :rm, "#{current_path}/tmp/#{sql_dump_file}"
        end
      end
    end
  end

  desc "Load local sql file into local database"
  task :load_dump do
    if File.exist?("tmp/#{sql_dump_file}") && File.exist?("tmp/#{documents_dump_file}")
      puts "importing into local database"
      `rake db:fromdump`
      `rake db:migrate`
      
      keep_dump = ENV.key? 'KEEPDUMP'

      if keep_dump
        delete = false
      else
        set :agree, ask('Delete local dump file?', 'y')
        delete = (fetch(:agree).downcase =~ /y/) == 0
      end

      if delete
        FileUtils.rm_rf("tmp/#{sql_dump_file}")
        FileUtils.rm_rf("tmp/#{documents_dump_file}")
      elsif !keep_dump
        FileUtils.mv("tmp/#{sql_dump_file}", "tmp/"+Time.now.strftime("%Y%m%d%H%M%S")+".#{sql_dump_file}")
        FileUtils.mv("tmp/#{documents_dump_file}", "tmp/"+Time.now.strftime("%Y%m%d%H%M%S")+".#{documents_dump_file}")
      end
    else
      abort "No dump file exists, try data:import or data:importlast instead"
    end
  end
  
  desc "Assume we have a local dump file and send it to staging"
  task :send_dump do
    on roles :db do
      within current_path do
        with rails_env: fetch(:rails_env) do    
          debug "uploading dump file to remote server"
          upload! "tmp/#{sql_dump_file}", "#{current_path}/tmp/#{sql_dump_file}"
          upload! "tmp/#{documents_dump_file}", "#{current_path}/tmp/#{documents_dump_file}"
          debug "importing into remote database"
          execute :rake, 'db:fromdump'
          execute :rm, "#{current_path}/tmp/#{sql_dump_file}"
          execute :rake, 'db:migrate'
        end
      end
    end
  end
  
end
