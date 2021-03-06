#!/usr/bin/env ruby

require 'pathname'

class MisspellerApp

  def usage
    puts 'Usage: misspeller.rb [path_to_dictionary]'
    puts 'This program generates misspelled words from a dictionary text file.  If you dont pass the dictionary file in, it will look for ./good_words.txt in the current directory.  If its not there, you can pass in or copy /usr/share/dict/words which is available on most Unix systems.'
  end

  def initialize(dict_path)
    @@vowels = ['a','e','i','o','u']
    @@good_words=[]
    begin
      file = File.open(Pathname.new(dict_path).realpath.to_s)
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

if __FILE__ == $0
  if ARGV.length > 0
    if ARGV[0] == '--help'
      usage
      exit
    else
      dict_path = ARGV[0]
    end
  else
    dict_path = './good_words.txt'
  end

  app = MisspellerApp.new(dict_path)
  app.run
end


