desc 'Copy updated generator from tp2 to current site.
Use carefully, cos it could break stuff if the site is too old.'
task :update_tp => :environment do
  this_path = "#{Dir.pwd}"
  cmdline = "cd .. && cp -r tp2/lib/generators \"#{File.join(this_path, 'lib')}\""
  puts cmdline
  system cmdline
end
