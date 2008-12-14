def set_constant(constant, value)
  if respond_to?(:silence_warnings)
    silence_warnings do
      Object.send(:remove_const, constant) if Object.const_defined?(constant)
      Object.const_set(constant, value)
    end
  else
    Object.send(:remove_const, constant) if Object.const_defined?(constant)
    Object.const_set(constant, value)
  end
end

include RequiredSoftware
def load_testing_libs(args = {})
  missing_gems = missing_libs(load_required_software, 'testing_gems', args)
  unless missing_gems.blank?
    puts "ERROR: Not all the nessesary gems are installed for these Tests to run."
    puts "Please run 'rake manage_gems:testing:install' to install them then try again."
    puts "Missing #{missing_gems.join(', ')}"
    exit
  end
end

def verify_zebra_changes_allowed
  return if ENV['ZEBRA_CHANGES_PERMITTED']
  puts "\n/!\\ IMPORTANT /!\\\n\n"
  puts "Testing currently uses the Zebra instance for this Kete codebase and will add, update and remove records from it.\n\n"
  puts "Do not run these tests unless you're sure that the Zebra search engine is not being used on a production host!\n\n"
  puts "Press any key to continue, or Ctrl+C to abort before any changes are made.."
  STDIN.gets
  ENV['ZEBRA_CHANGES_PERMITTED'] = 'true'
end

def ensure_zebra_running
  begin
    zoom_db = ZoomDb.find_by_database_name('public')
    Topic.process_query(:zoom_db => zoom_db, :query => "@attr 1=_ALLRECORDS @attr 2=103 ''")
  rescue
    start_zebra = system('rake zebra:start')
    unless start_zebra
      raise "Zebra unable to start. Please start it manually before rerunning the tests."
    end
  end
end
