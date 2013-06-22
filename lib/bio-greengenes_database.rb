
require 'bio-logger'
module Bio
  module GreenGenes
    module DBLogging #Can't be Bio::GreenGenes::DB::Logging because DB is a class, not a module
      LOG_NAME = 'bio-gg-db'
      def log
        Bio::Log::LoggerPlus[LOG_NAME]
      end
    end
  end
end
Bio::Log::LoggerPlus.new(Bio::GreenGenes::DBLogging::LOG_NAME)

#require 'bio-greengenes_database/connect'
#require 'bio-greengenes_database/tables'

require 'bio/green_genes/db/connect.rb'
require 'bio/green_genes/db/sequence.rb'




