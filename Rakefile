require 'find'
require 'geo_combine'
require 'progress_bar'
require 'rainbow'

desc "Validate all geoblacklight.json records"
task :validate do
  dirs = Dir.glob('*').select { |f| File.directory? f }
  args = ARGV.drop(1).each { |a| task a.to_sym }
  if args.first == 'all'
    args = dirs
  else
    args.reject! { |a| !dirs.include? a }
  end

  raise Rainbow("No valid directories to validate").magenta if args.empty?

  args.each do |a|
    paths = Dir["#{Dir.pwd}/#{a}/**/geoblacklight.json"]
    records_invalid = 0
    records_valid = 0
    invalid_paths = []

    puts "Validating #{paths.count} Geoblacklight records:"

    bar = ProgressBar.new(paths.length)
    bar.write

    paths.each_with_index do |path, idx|
      rec = GeoCombine::Geoblacklight.new(File.read(path))
      rec.valid?
      records_valid += 1
      bar.increment!
      bar.write
    rescue
      records_invalid += 1
      invalid_paths << path
    end

    if records_invalid > 0
      puts Rainbow("Contains #{records_invalid} invalid records:").magenta
      puts invalid_paths
    else
      puts Rainbow("All records are valid!").green
    end
  end
end
