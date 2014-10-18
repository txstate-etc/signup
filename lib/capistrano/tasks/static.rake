namespace :static do

  desc "Generate static html files and put them in /public/" 
  task :generate do
    on roles :web do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "static:generate"
        end
      end
    end
  end
end
