require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

TEST_DATA_DIR = File.join(File.dirname(__FILE__),'data')

describe "BioGreengenesDatabase library" do
  it "should be able to extract sequences" do
    # Connect to the database
    Bio::GreenGenes::DB.connect(File.join TEST_DATA_DIR, 'gg-db-2-seqs.sqlite3')

    # Extract a sequence
    otu_identifier = 12
    Bio::GreenGenes::DB::Sequence.extract_sequence(otu_identifier).should == 'ATGC'
    otu_identifier = 122
    Bio::GreenGenes::DB::Sequence.extract_sequence(otu_identifier).should be_nil
  end
end
