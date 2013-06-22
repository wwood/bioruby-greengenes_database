require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'systemu'
require 'tempfile'

def create_database
  path_to_script = File.join(File.dirname(__FILE__),'../bin/greengenes_database_create.rb')


  Tempfile.open('gg-db') do |sqlite_file|
  #File.open('gg-db','w') do |sqlite_file|
    sqlite_file.close

    FileUtils.rm(sqlite_file.path)

    status, stdout, stderr = systemu "#{path_to_script} --trace error -d #{sqlite_file.path}"

    yield sqlite_file.path, status, stdout, stderr
  end
end

describe "BioGreengenesDatabase scripts" do
  it "should create a new database" do
    path_to_script = File.join(File.dirname(__FILE__),'../bin/greengenes_database_create.rb')
    create_database do |sqlite_path, status, stdout, stderr|
      stderr.should eq('')
      status.exitstatus.should eq(0)

      File.exist?(sqlite_path).should == true
    end
  end

  it 'should load sequence data do' do
    seqs = %w(>10 AANNTGTG >12 ATGC)
    path_to_script = File.join(File.dirname(__FILE__),'../bin/greengenes_database_load.rb')

    Tempfile.open('gg-db-seq') do |fasta_file|
      fasta_file.puts seqs.join("\n")
      fasta_file.close

      create_database do |sqlite_path|
        status, stdout, stderr = systemu "#{path_to_script} --trace error -d #{sqlite_path} -t sequence -i #{fasta_file.path}"
        stderr.should eq('')
        status.exitstatus.should eq(0)
        stdout.should eq('')

        cmd = "sqlite3 #{sqlite_path} \'select * from sequences;\'"
        status, sqlite_contents, stderr = systemu cmd
        stderr.should eq('')
        status.exitstatus.should eq(0)

        expected = %w(1|10|AANNTGTG 2|12|ATGC).join("\n") + "\n"
        sqlite_contents.should == expected
      end
    end
  end
end
