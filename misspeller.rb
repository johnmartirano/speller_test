#!/usr/bin/env ruby

class MisspellerApp

  def usage
    puts 'Usage: misspeller.rb'
    puts 'This program generates misspelled words from a dictionary text file.  It expects a dictionary file in the current directory called dict_words.txt'
    puts 'If that file is not present, you can copy it from /usr/share/dict on most Unix systems.'
  end

  def initialize()
    @@vowels = ['a','e','i','o','u']
    @@good_words=[]
    begin
      file = File.open('./dict_words.txt')
      file.each do |line|
        @@good_words << line.strip
      end
    rescue
      usage
      exit
    end
  end
  
  def run
    while true
      puts misspell(@@good_words.sample)
      STDOUT.flush
      #sleep 0.1
    end
  end

  def misspell(word)
    bad_word = word.chars.inject('') do |sum,c|
      if rand(0..1) == 0
        sum += c
      else
        sum += apply_rule(c) 
      end
    end
  end

  def apply_rule(char)
    rule = rand(0..2)
    if rule == 0
      return char.swapcase
    elsif @@vowels.include? char
      return @@vowels.sample
    else
      return char+char
    end
  end

end

app = MisspellerApp.new()
app.run

