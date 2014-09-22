namespace :db do
  desc "Migrate attachments from old PaperClip format to new."
  task :import_attachments => [:environment] do
    path_to_old_items="/home/rubyapps/registerme/shared/system/items"
    Document.all.each do |d|
      new_file = Pathname.new d.item.path
      old_file = Pathname.new "#{path_to_old_items}/#{d.id}/original/#{d.item_file_name}"

      if !old_file.exist?
        puts "Can't find old file: #{old_file}"
        next
      end

      puts "Copying #{old_file} to #{new_file}"
      FileUtils.mkdir_p new_file.dirname
      FileUtils.cp old_file.to_s, new_file.to_s
    end
  end
end
