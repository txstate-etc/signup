Gem.loaded_specs["signup"].runtime_dependencies.each do |d|
  begin
    require d.name
  rescue LoadError => le
    # Put exceptions here.
    puts le
  end
end

require "signup/engine"

module Signup
end
