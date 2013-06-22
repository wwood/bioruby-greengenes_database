require 'active_record'

module Bio
  module GreenGenes
    class DB
      def self.connect(database_path)
        Connection.connect database_path
      end

      class Connection < ActiveRecord::Base
        self.abstract_class = true

        # Return a hash of a typical config to be used when connecting to the database
        def self.default_config(database_path)
          {
            'adapter' => 'sqlite3',
            'database' => database_path,
            'pool' => 5,
            'timeout' => 5000,
          }
        end

        def self.log
          Bio::Log::LoggerPlus[Bio::GreenGenes::DBLogging::LOG_NAME]
        end

        # Connect to a local GreenGenes SQLite database.
        def self.connect(database_path)
          log.info "Attempting to connect to database #{database_path}"

          options = default_config database_path
          options = {
            :adapter => 'sqlite3',
            :database => database_path,
            :pool => 5,
            :timeout => 5000,
          }

          establish_connection(options)
        end

        # Create the database, but don't migrate (don't create any tables).
        #
        # Returns true if create worked, else false.
        def self.create_database(config)
          # The code for this methods was modified from the Rakefile's method of the same name
          if config['adapter'] =~ /sqlite/
            if File.exist?(config['database'])
              log.error "#{config['database']} already exists"
              return false
            else
              begin
                # Create the SQLite database
                ActiveRecord::Base.establish_connection(config)
                ActiveRecord::Base.connection
              rescue Exception => e
                log.error e, *(e.backtrace)
                log.error "Couldn't create database for #{config.inspect}"
                return false
              end
            end
            return true
          else
            raise "Only SQLite is supported at this time by bio-greengenes_database"
          end
        end

        def self.load_schema
          schema_path = File.expand_path File.join(File.dirname(__FILE__),'../../../../db/schema.rb')
          load schema_path
        end
      end
    end
  end
end
