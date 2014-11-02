namespace :rvm_local do
  namespace :alias do
    desc "Create an alias for the given"
    task :create do
      on roles(fetch(:rvm1_roles, :all)) do
        within fetch(:release_path) do
          execute "#{fetch(:rvm1_auto_script_path)}/rvm-auto.sh",
            fetch(:rvm1_ruby_version), "rvm", "alias", "create",
            fetch(:rvm1_alias_name), fetch(:rvm1_ruby_version)
        end
      end
    end
    before :create, "deploy:updating"
    before :create, 'rvm1:hook'
  end
end
