require 'spec_helper'


describe "SpellTest" do
  before :all do
    @good_words=[]
    file = File.open(File.expand_path(File.dirname(__FILE__) + '/../good_words.txt'))
    file.each do |line|
      @good_words << line.strip
    end
    
    timer do
      puts "Loading #{@good_words.length} good words..."
      @norm_hash = NormHash.new( @good_words )
    end

    @bad_words=[]
    file = File.open(File.expand_path(File.dirname(__FILE__) + '/../bad_words.txt'))
    file.each do |line|
      @bad_words << line.strip
    end
  end

  describe "Matching the generated misspelled words" do
    it "should not produce 'NO SUGGESTION'" do
      timer do
        puts "Matching and testing #{@bad_words.length} bad words..."
        @bad_words.each do |bad_word|
          good_word = @norm_hash.match_word( bad_word )
          good_word.eql?('NO SUGGESTION').should == false
        end
      end
    end
  end

end

