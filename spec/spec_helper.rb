
require 'norm_hash'
require 'matcher'

# timer for profiling long-running test routines
def timer(method=nil, *args)
  start_time = Time.now
  if block_given?
    yield
  else
    send(method, args)
  end
  end_time = Time.now
  puts "Time elapsed #{(end_time - start_time)} seconds"
end
 
