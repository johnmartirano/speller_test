#!/usr/bin/env ruby

require 'pathname'

require './lib/norm_hash.rb'
require './lib/matcher.rb'

class SpellApp

  def usage
    puts 'Usage: speller.rb [path_to_dictionary]'
    puts 'Speller requires a flat text dictionary file, either passed in on the command line or it will look for /usr/share/dict/words which is available on most Unix systems.'
  end

  def initialize(dict_path,stdin)
    @stdin = stdin

    good_words=[]
    begin
      file = File.open(Pathname.new(dict_path).realpath.to_s)
      file.each do |line|
        good_words << line.strip
      end
    rescue
      usage
      exit
    end
    
    @norm_hash=NormHash.new( good_words )
  end
  
  def run
    print ' > '
    STDOUT.flush
  
    @stdin.each do |command|
      puts @norm_hash.match_word(command.strip)
      print " > "
      STDOUT.flush
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
    dict_path = '/usr/share/dict/words'
  end

  app = SpellApp.new(dict_path,STDIN)
  app.run
end


