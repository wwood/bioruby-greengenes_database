#!/usr/bin/env ruby

require 'optparse'
require 'bio-logger'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'bio-greengenes_database'

SCRIPT_NAME = File.basename(__FILE__); LOG_NAME = Bio::GreenGenes::DBLogging::LOG_NAME

# Parse command line options into the options hash
options = {
  :logger => 'stderr',
  :log_level => 'info',
}
o = OptionParser.new do |opts|
  opts.banner = "
    Usage: #{SCRIPT_NAME} --db </path/to/database.sqlite3>

    Creates a new SQLite GreenGenes database\n\n"

  opts.on("-d", "--db PATH", "Path the the SRAmetadb.sqlite file/database [required]") do |f|
    options[:db_path] = f
  end

  # logger options
  opts.separator "\nVerbosity:\n\n"
  opts.on("-q", "--quiet", "Run quietly, set logging to ERROR level [default INFO]") {options[:log_level] = 'error'}
  opts.on("--logger filename",String,"Log to file [default #{options[:logger]}]") { |name| options[:logger] = name}
  opts.on("--trace options",String,"Set log level [default INFO]. e.g. '--trace debug' to set logging level to DEBUG"){|s| options[:log_level] = s}
end; o.parse!
if ARGV.length != 0 or options[:db_path].nil?
  $stderr.puts o
  exit 1
end
# Setup logging
Bio::Log::CLI.logger(options[:logger]); Bio::Log::CLI.trace(options[:log_level]); log = Bio::Log::LoggerPlus.new(LOG_NAME); Bio::Log::CLI.configure(LOG_NAME)

# Create the db
success = Bio::GreenGenes::DB::Connection.create_database(Bio::GreenGenes::DB::Connection.default_config options[:db_path])
if !success
  log.error "Error creating database, exiting."
  exit 1
end

# Load the table schema
success = Bio::GreenGenes::DB::Connection.load_schema
if !success
  log.error "Error loading database schema, exiting."
  exit 1
end
