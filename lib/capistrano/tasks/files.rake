namespace :files do
  desc "Symlink any files found in shared/config/initializers to release_path"
  task :link_initializers do
    base_path = 'config/initializers'
    on roles :app do
      source_path = shared_path.join(base_path)
      if test "[ -d #{source_path} ]"
        target_path = release_path.join(base_path)
        execute :mkdir, '-p', target_path
        files = capture(:ls, '-x', source_path).split
        files.each do |file|
          target = target_path.join(file)
          source = source_path.join(file)
          unless test "[ -L #{target} ]"
            if test "[ -f #{target} ]"
              execute :rm, target
            end
            execute :ln, '-s', source, target
          end
        end
      end
    end
  end
end
