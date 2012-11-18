
# Matcher.match attempts to select best match for an input_word from 
# an array of possabilities. The algorithm used is an experiment 
# which attempts to determine the 'distance' between each 2 words.
# This algorithm would be useless on arbitrary word comparisons but given
# the grouping of normalized words in NormHash, it may be better than 
# random selection
class Matcher

  # The reverse of the repeating rule will apply in matching
  #   eg mispelled 'shep' (input) could match to 'sheep' (target) even though 
  #   mispelled word rules will never permute 'sheep' (input) to 'shep' 
  # If filtered out, it would prevent some bad choices such as 
  #   'por' (input) matches 'porr' (target) instead of 'par'
  # But accepting it catches cases such as 
  #   'shep' (input) matches 'sheep' (target)

  def self.match( input_word, word_list=[] )
    if word_list.nil?
      return "NO SUGGESTION"
    elsif word_list.include? input_word
      return input_word
    else
      # word_list.sample
      the_match, distance = self.do_match( input_word, word_list )
      if distance == 1
        return "NO SUGGESTION"
      else
        return the_match
      end
    end
  end


  protected

  def self.do_match( input_word, word_list )
    closest = ['',1.0]
    closest = word_list.reduce(closest) do |still_closest,target_word| 
      dist = word_distance( input_word, target_word )
      if dist <= still_closest[1]
        still_closest = [target_word, dist]
      end
      still_closest
    end
    closest
  end

  # word_distance attempts to score (0-1) how different 2 words are, 
  # its an experiment which compares 2 words on char-position coincidence, 
  # In the event one word is longer, it shifts the smaller word for
  # multiple comparisons and then performs a bitwise or on the results.
  #
  # Since case is ignored and repeats are removed (from the input_word only)
  # one edge-case that must be considered is when a vowel permutation
  # results in a repeat vowel which is then removed.
  #
  # Examples:      target=>misspelling=>matcher_encoding
  #                louse=>luuse=>luse          appeal=>appeel=>apel
  # good  listserv louse louse lose loose tool appeal appeal appeal appeal  
  # bad   lestsurv luse   luse luse luse  tiol apel     apel  apel 
  #       *x***x** *xxxx|xx*** *x**|*xx** *x** **xxxx|xxxxx*|xx**xx ****x*
  #
  # The code below is dynamic enough to handle any argument length, 
  # (ie word length diff) but as an example, it is merely doing the following:
  #
  # # This example based on comparing 'apel' to 'appeal' as seen above
  # a = [true, true, false, false, false, false]
  # args = [[false, false, false, false, false, true], 
  #         [false, false, true, true, false, false]]
  # p=eval 'Proc.new{|x,y,z| x|y|z}'
  # distance_vector = a.zip(*args).collect(&p)
  # # => [true, true, true, true, false, true]
  # sum = distance_vector.reduce(0) {|sum,cur| sum += cur ? 1 : 0 }
  # 1 - sum/distance_vector.length.to_f
  #
  def self.word_distance( input_word, target_word)
    # use downcase and no_repeats because repeats are randomly errors anyway
    # and lack of repeats will not effect score because of shifting
    input_word = input_word.no_repeats.downcase
    target_word = target_word.downcase

    if input_word.length <= target_word.length 
      short_word = input_word
      long_word = target_word
    else
      short_word = target_word
      long_word = input_word
    end

    # create arrays for comparison
    diff_arrays = create_diff_arrays(short_word, long_word)
    the_proc = bitwise_proc( diff_arrays.length+1 )
    first_array = diff_arrays.shift
    distance_vector = first_array.zip(*diff_arrays).collect(&the_proc)
    sum = distance_vector.reduce(0) {|sum,cur| sum += cur ? 1 : 0 }
    1 - sum/distance_vector.length.to_f
  end

  # Given two strings input_word and target_word, create_diff_arrays
  # creates 1 or more arrays representing the differences between these
  # 2 words.  The number of arrays generated is 
  # num_arrays = ABS(input_word.length-target_word.length) + 1
  #
  # The shorter word is placed at position 0...num_arrays
  # and compared with the longer word. So:
  # pious pious  OR  appeal appeal appeal OR ann
  # pius   pius      apel    apel    apel    enn
  # 11000 00011      110000 001100 000001    011
  # 
  def self.create_diff_arrays(input_word, target_word)
    length_diff = target_word.length - input_word.length
    word_diffs = []
    (0..length_diff).each do |n|
      word_diffs << Array.new(target_word.length)
      word_diffs[n] = compare_words(target_word, ' '*n+input_word) 
    end
    word_diffs
  end

  # Compares 2 words of equal length, returning an array
  # of booleans.  Elements are true if word1[i]==word2[i] 
  def self.compare_words( word1, word2 )
    diff = []
    (0...word1.length).each do |n|
      diff[n] = word1[n] == word2[n]
    end
    diff
  end

  # Return the bitwise proc with indicated number of arguments, 
  # Create and store the proc if necessary.
  def self.bitwise_proc( arg_length )
    @@proc_hash={} unless defined? @@proc_hash
    the_proc = @@proc_hash[arg_length] || @@proc_hash[arg_length] = make_bitwise_proc(arg_length)
  end

  # make_bitwise_proc generates a Proc with arbitrary number of arguments 
  # which will peform a bitwise or on the arguments. 
  # arg_length is the number of arguments to construct the Proc with. 
  # This will produce Procs of the following form:
  # eval 'Proc.new{|a1,a2,a3| a1|a2|a3}'
  def self.make_bitwise_proc( arg_length )
    proc_string = 'Proc.new{|a1'
    proc_bitwise_string = 'a1'
    (2..arg_length).each do |arg_num|
      proc_string += ',' + 'a' + arg_num.to_s
      proc_bitwise_string += '|' + 'a' + arg_num.to_s
    end
    proc_string += "| #{proc_bitwise_string} }"
    eval proc_string
  end

end
 
