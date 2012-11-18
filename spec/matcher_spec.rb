require 'spec_helper'

describe Matcher do
  describe "#match" do
    context "when the input_word is an allowable permutation" do
      it "will select one of the words in word_list as a match for input_word" do
        input_word = 'apel'
        word_list = ['appeal','apple']
        match = Matcher.match(input_word, word_list)
        word_list.include?(match).should == true
      end
      it "will find an approximate match to a misspelled input word" do
        word_list = ["people", "pious"]
        word = 'peeeeple'
        Matcher.match(word,word_list).eql?('people').should == true
        word = 'pieass'
        Matcher.match(word,word_list).eql?('pious').should == true
      end
    end

    context "when the input_word is included in the word_list" do
      it "will return the input_word" do
        input_word = 'apple'
        word_list = ['appeal','apple','appl','appple']
        Matcher.match(input_word,word_list).eql?(input_word).should == true
      end
    end

    context "when the word_list is nil" do
      it "will return 'NO SUGGESTION'" do
        bad_word = 'xyzxyzxyz'
        word_list = ['appeal','apple']
        Matcher.match(bad_word,nil).eql?('NO SUGGESTION').should == true
      end
    end
  end
end

