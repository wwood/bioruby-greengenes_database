class Bio::GreenGenes::DB::Sequence < Bio::GreenGenes::DB::Connection
  # Given an OTU identifier, return its sequence. If it is not
  # present in the database, return nil. Raise an Exception if it is
  # found more than once (this shouldn't happen).
  def self.extract_sequence(otu_identifier)
    seq_rows = self.find_all_by_otu_identifier(otu_identifier)
    if seq_rows.length == 1
      return seq_rows[0].sequence
    elsif seq_rows.length > 1
      raise "Unexpectedly found multiple sequences in the SQL table with the same OTU identifier"
    else
      return nil
    end
  end
end
