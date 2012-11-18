require 'spec_helper'


describe NormHash do
  before :each do
    @sample_words = ["a", "an", "ana", "and", "Ann", "awake", "conspiracy", "I",
                     "job", "people", "pious", "sheep", "wake", "woke"]
    @norm_hash = NormHash.new( @sample_words )
  end

  describe "#new" do
    it "takes 1 parameter and returns a NormHash object" do
      @norm_hash.should be_an_instance_of NormHash
    end
  end

  describe "#add_word" do
    context "when called with our custom string" do
      it "adds a normalized key to the hash" do
        word = 'normal'
        @norm_hash.add_word(word)
        @norm_hash.key?(word.norm_key).should == true
        @norm_hash[word.norm_key].include?(word).should == true
      end
    end
  end

  describe "#match_word" do
    context "when called with our custom string" do
      it "will find an approximate match to a misspelled input word" do
        word = 'peeeeple'
        @norm_hash.match_word(word).eql?('people').should == true
        word = 'pieass'
        @norm_hash.match_word(word).eql?('pious').should == true
      end

      it "will return 'NO SUGGESTION' when the input word is outside the range of misspellings" do
        bad_word = 'xyzxyzxyz'
        @norm_hash.match_word(bad_word).eql?('NO SUGGESTION').should == true
      end
    end
  end

end

