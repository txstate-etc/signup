namespace :static do

  def urls_and_paths
    Dir.glob("#{Rails.root}/app/views/static/*.html.erb").map do |file|
      file = File.basename(file, '.html.erb')
      ["/static/#{file}", "#{file}.html"]
    end
  end

  desc "Generate static html files and put them in /public/" 
  task :generate => :environment do
    require "rails/console/app"
    require "rails/console/helpers"
    extend Rails::ConsoleMethods

    urls_and_paths.each do |url, path|
      $stderr.puts "About to generate static file #{path} from url #{url}"
      r = app.get(url)
      if 200 == r
        File.open(Rails.public_path + path, "w") do |f|
          f.write(app.response.body)
        end
      else
        $stderr.puts "Error generating static file #{path} #{r.inspect}"
      end
    end
  end
end
