$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "signup/version"

# Describe your   s.add_runtime_dependency and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "signup"
  s.version     = Signup::VERSION
  s.authors     = ["Charles Jones"]
  s.email       = ["cj32@txstate.edu"]
  s.homepage    = "http://www.its.txstate.edu/departments/etc/signup"
  s.summary     = "The Signup tool allows users to signup for a workshop, presentation, meeting, or any other event requiring a reservation."
  s.description = "The Signup tool allows users to signup for a workshop, presentation, meeting, or any other event requiring a reservation. Users will be sent automatic reminders about the event and allowed to cancel their reservation if needed."
  s.license     = "Apache-2.0"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE.txt", "Rakefile", "README.md"]
  s.test_files = `git ls-files -- test/*`.split("\n")

  s.add_runtime_dependency "rails", "~> 4.2"
  s.add_runtime_dependency 'sass-rails'
  s.add_runtime_dependency 'jquery-rails'
  s.add_runtime_dependency 'jbuilder'
  s.add_runtime_dependency 'simple_form', '~> 3.2.1'

  # add cache of association counts
  # more flexibly than the builtin version
  s.add_runtime_dependency 'counter_culture', '~> 0.1.25'

  # convert urls in descriptions into links
  # Won't need this after implementing wysiwyg editor.
  s.add_runtime_dependency 'rails_autolink', '~> 1.1.6'

  # Tags!
  s.add_runtime_dependency 'acts-as-taggable-on', '~> 3.4.2'

  # Attachments/Documents
  s.add_runtime_dependency 'paperclip', '~> 4.3.5'

  # Nested form helpers (for attachments, instructors, etc)
  s.add_runtime_dependency 'cocoon', '~> 1.2.6'

  # LDAP user lookups
  s.add_runtime_dependency 'net-ldap', '~> 0.9.0'

  # Autocomplete for instructors, etc.
  # despite the name, works fine on rails 4
  s.add_runtime_dependency 'rails-jquery-autocomplete', '~> 1.0.3'

  # used by HtmlToPlainText
  s.add_runtime_dependency 'htmlentities', '~> 4.3.2'

  # rical library for generating ics files
  s.add_runtime_dependency 'ri_cal'#, :github => 'txstate-etc/ri_cal', :ref => '5891733ef1'

  # render pdf documents from ruby code
  s.add_runtime_dependency 'prawn', '~> 1.3.0'

  # audit model changes
  s.add_runtime_dependency 'paper_trail', '~> 4.1.0'

  s.add_development_dependency 'spring'
  s.add_development_dependency "mysql2", '~> 0.3.16'
end
