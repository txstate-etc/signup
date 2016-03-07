Dir.glob(File.expand_path("../../capistrano/tasks", __FILE__) + '/*.rake').each do |file|
  load file
end
