
# String class customized for key generation
# key is encded with norm_key method. 
class String

  # vowels converted to 'a' during key generation
  def vowels
    @@vowels = ['e','i','o','u'] unless defined? @@vowels
    @@vowels
  end

  def norm_key
    ## profiling, then optimizing and then combining these two methods 
    ## shaved a total of 33% off full word list load time, 21 sec still too long
    # self.downcase.convert_vowels!.no_repeats
    self.downcase.convert_vowels_and_no_repeats
  end

  # remove repeating chars
  def no_repeats
    removed = []
    self.chars.to_a.reduce(nil) do |prev,cur|
      removed << cur if !prev.eql?(cur)
      cur 
    end
    removed.join
  end

  # vowels converted to 'a' during key generation
  def convert_vowels!
    # self.chars.to_a.reduce('') do |sum,n|
    #   sum += ((vowels.include?(n)) ? 'a' : n )
    # end

    # 13% faster than above
    (0...self.length).each { |n| self[n]='a' if vowels.include?(self[n]) }
    self
  end

  # convert vowels to 'a' and remove repeats
  # 33% faster than first implementation 
  def convert_vowels_and_no_repeats
    removed = []
    self.chars.to_a.reduce(nil) do |prev,cur|
      cur = 'a' if vowels.include?(cur) 
      removed << cur unless prev.eql?(cur)
      cur 
    end
    removed.join
  end
end

# Hash class extended to provide for storing coded keys 
# and dictionary word pairs.  Words whose keys hash to the 
# same location will be stored together in an array.
# When match_word is called with a misspelled word,
# the Matcher will attempt to disambiguate.
class NormHash < Hash

  # initialize the hash with an enum of dictionary words
  def initialize( word_enum )
    word_enum.each { |word| self.add_word( word ) }
  end

  # add a dictionary word to the hash for later spelling match
  def add_word( word )
    word_list = self[word.norm_key]
    if word_list.nil?
      self[word.norm_key] = [ word ]
    else
      word_list << word
    end
  end

  # match makes the final match from the set of words whose
  # norm_keys were hashed to the same location.
  def match_word( word )
    Matcher.match( word, self[word.norm_key] ) 
  end
end

