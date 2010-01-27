  #
  # = bio/io/sql.rb - BioSQL database classes
  #
  # Copyright::  Copyright (C) 2001 Toshiaki Katayama <k@bioruby.org>,
  # Copyright::  Copyright (C) 2007-2009 Raoul Jean Pierre Bonnal <bonnal@ingm.it>
  #
  # License::    The Ruby License
  #
  # == Description
  #
  # This file contains classes that implement an interface to the BioSQL database,
  # and some public methods
  #
  # == References
  #
  # * BioSQL
  # * Authors: Ewan Birney, Elia Stupka, Hilmar Lapp, Aaron Mackey
  # * Post-Cape Town changes by Hilmar Lapp.
  # * Singapore changes by Hilmar Lapp and Aaron Mackey.
  # * Migration of the MySQL schema to InnoDB by Hilmar Lapp
  # * comments to biosql - biosql-l@open-bio.or
  # * http://.....
  #

module Bio
  class SQL

    require 'bio/io/biosql/biosql'
    autoload :Sequence, 'bio/db/biosql/sequence'

    def self.fetch_id(id)
      Bio::SQL::Bioentry.find(id)
    end

    def fetch_by_seqfeature_id(id)
      Bio::SQL::Seqfeature.find(id) do |seqfeature|
        seqfeature.bioentry
      end

    end

    def self.fetch_accession(accession)
      Bio::SQL::Sequence.new(:entry=>Bio::SQL::Bioentry.find_by_accession(accession.upcase))
    end

    def self.exists_accession(accession)
      !Bio::SQL::Bioentry.find_by_accession(accession.upcase).nil?
    end

    def self.exists_database(name)
      !Bio::SQL::Biodatabase.first(:name=>name).nil?
    end

    def self.list_entries
      Bio::SQL::Bioentry.all.collect do|entry|
        {:id=>entry.bioentry_id, :accession=>entry.accession}
      end
    end

    def self.list_databases
      Bio::SQL::Biodatabase.all.collect do|entry|
        {:id=>entry.biodatabase_id, :name => entry.name}
      end
    end

    def self.delete_entry_id(id)
      Bio::SQL::Bioentry.delete(id)
    end

    def self.delete_entry_accession(accession)
      Bio::SQL::Bioentry.find_by_accession(accession.upcase).destroy!
    end

    def self.delete_all_entry
      Bio::SQL::Bioentry.delete_all()
    end
  end #biosql

end #Bio
