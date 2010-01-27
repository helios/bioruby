# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'bio'
require 'pathname'
require 'ruby-prof'



module Bio
  class TestBiosqlLoading < Test::Unit::TestCase
    #include RubyProf::Test
    #RubyProf::Test::PROFILE_OPTIONS[:printers]=[RubyProf::FlatPrinter, RubyProf::GraphHtmlPrinter,RubyProf::CallTreePrinter]
    #RubyProf.measure_mode = RubyProf::MEMORY
    bioruby_root = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4)).cleanpath.to_s
    TestDataPath = Pathname.new(File.join(bioruby_root, '', 'data')).cleanpath.to_s
    TestDataFastaTiny = File.join(TestDataPath, 'fasta', '454_tiny.fasta')
    TestDataFastaHuge = File.join(TestDataPath, 'fasta', '454_huge.fasta')

    def setup
      @connection = Bio::SQL.establish_connection({'development'=>{'hostname'=>'localhost','database'=>"bioseq", 'adapter'=>"mysql", 'username'=>"febo", 'password'=>nil}},'development')
    end

    def teardown
      Bio::SQL.delete_all_entry
    end

    def test_01_loading_fasta_tiny
      load_data(TestDataFastaTiny)
    end

 #   def test_02_loading_fasta_huge
 #    load_data(TestDataFastaHuge)
 #   end

    def load_data(file_name)
      first_db = Bio::SQL::Biodatabase.find(:first)
      Bio::FastaFormat.open(file_name) do |ff|
        ff.each do |entry|
          #assert_equal("",entry.to_biosequence)
          assert_not_nil(Bio::SQL::Sequence.new(:biosequence=>entry.to_biosequence, :biodatabase=>first_db))
        end
      end
    end
  end
end
