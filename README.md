# bio-greengenes_database

[![Build Status](https://secure.travis-ci.org/wwood/bioruby-greengenes_database.png)](http://travis-ci.org/wwood/bioruby-greengenes_database)

Software that interacts with an SQLite database that contains information from the (http://greengenes.secondgenome.com)[GreenGenes database],
for can be preferable to interacting with flat files, for performance reasons.

Note: this software is under active development!

## Installation

```sh
gem install bio-greengenes_database
```

## Usage

### Loading data into the database
First, the database itself needs to be created:
```sh
$ greengenes_database_create.rb --database /path/to/database.sqlite
```

Load sequence data, which is loaded into the 'sequence' database table
```sh
$ greengenes_database_load.rb --database /path/to/database.sqlite --type sequence --input /path/to/fasta.fa
```

### Using the loaded data in a Ruby script
```ruby
require 'bio-greengenes_database'

# Connect to the database
Bio::GreenGenes::DB.connect('/path/to/database.sqlite')

# Extract a sequence
otu_identifier = 1111886
Bio::GreenGenes::DB::Sequence.extract_sequence(otu_identifier) #=> 'AACGAACGCTGGCGGCATGCCTAACACAT...'
```

The API doc is online. For more code examples see the test files in
the source tree.

## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/wwood/bioruby-greengenes_database

The BioRuby community is on IRC server: irc.freenode.org, channel: #bioruby.

## Cite

If you use this software, please cite one of

* [BioRuby: bioinformatics software for the Ruby programming language](http://dx.doi.org/10.1093/bioinformatics/btq475)
* [Biogem: an effective tool-based approach for scaling up open source software development in bioinformatics](http://dx.doi.org/10.1093/bioinformatics/bts080)

## Biogems.info

This Biogem is published at (http://biogems.info/index.html#bio-greengenes_database)

## Copyright

Copyright (c) 2013 Ben J. Woodcroft. See LICENSE.txt for further details.

