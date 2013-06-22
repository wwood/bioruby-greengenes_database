#!/usr/bin/env ruby

require 'optparse'
require 'bio-logger'
require 'bio'
require 'tempfile'
require 'systemu'

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
    Usage: #{SCRIPT_NAME} --db </path/to/database.sqlite3> --type <upload_type> --input-data <greengenes.fasta>

    Loads data into an GreenGenes database file\n\n"

  opts.on("-d", "--db PATH", "Path the the SRAmetadb.sqlite file/database [required]") do |f|
    options[:db_path] = f
  end
  opts.on("-t", "--type sequence", "Type of data to load (currently only sequence is supported) [required]") do |f|
    raise unless f=='sequence'
    options[:data_type] = f
  end
  opts.on("-i", "--input-data DATA_PATH", "The actual data to load e.g. path to fasta file for the sequence [required]") do |f|
    options[:input] = f
  end

  # logger options
  opts.separator "\nVerbosity:\n\n"
  opts.on("-q", "--quiet", "Run quietly, set logging to ERROR level [default INFO]") {options[:log_level] = 'error'}
  opts.on("--logger filename",String,"Log to file [default #{options[:logger]}]") { |name| options[:logger] = name}
  opts.on("--trace options",String,"Set log level [default INFO]. e.g. '--trace debug' to set logging level to DEBUG"){|s| options[:log_level] = s}
end; o.parse!
if ARGV.length != 0 or options[:db_path].nil? or options[:data_type].nil? or options[:input].nil?
  $stderr.puts "Found options: #{options.inspect}"
  $stderr.puts o
  exit 1
end
# Setup logging
Bio::Log::CLI.logger(options[:logger]); Bio::Log::CLI.trace(options[:log_level]); log = Bio::Log::LoggerPlus.new(LOG_NAME); Bio::Log::CLI.configure(LOG_NAME)


# Connect to the DB
Bio::GreenGenes::DB.connect(options[:db_path])

# Create a CSV file of the fasta sequences - this is faster than loading the rails way
primary_key = 1
Tempfile.open('gg_seq_data') do |tempfile|
  log.info "Creating CSV file for upload.."
  Bio::FlatFile.foreach(Bio::FastaFormat, options[:input]) do |seq|
    tempfile.puts [
      primary_key,
      seq.definition.split(/\s+/)[0],
      seq.seq
    ].join("\t")
    primary_key += 1
  end
  tempfile.close
  num_imported = primary_key-1
  log.info "Prepared #{num_imported} sequences for import"

  log.info "Importing the temporary CSV file into the database"
  command = "sqlite3 #{options[:db_path]}"
  stdin = ".mode tabs\n.import #{tempfile.path} #{Bio::GreenGenes::DB::Sequence.table_name}\n"
  status, stdout, stderr = systemu command, 0=>stdin
  unless status.exitstatus == 0
    raise Exception, "Some kind of error running sqlite3 import. STDERR was #{stderr}"
  end
  log.info "Finished importing #{num_imported} sequences into the database"
end
