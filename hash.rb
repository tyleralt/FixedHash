require 'Prime'
#This is a fixed sized hashmap used for memory efficient hashing
#on average constant time sets, and gets times load ratio O(load/1-load) (until very full is inconsequential)
#sets are guaranteed at load < 1
#keep in mind that a delete does not decrease load but allows another set to takes its place without increasing load
class FixedHash

  #this is class used to hold the key (guarantee gets) and value
  class TableEntry
    attr_reader :key
    attr_accessor :value
    def initialize(key, value)
      @key = key
      @value = value
    end
    #is used to remove but leave as placeholder
    def make_placeholder()
      value = @value
      @key = nil
      @value = nil
      return value
    end

    def is_placeholder?
      return @key == nil
    end
  end

  #this will initialize the a new FixedHash with a size of the given argument or larger
  def initialize(size)
    @size = get_good_size(size)
    @table = Array.new @size
    @population = 0
    @used_spaces = 0
  end

  def get_good_size (desired_size)
    #ensure fulfills size = 4i + 3, and is prime
    #see https://en.wikipedia.org/wiki/Quadratic_probing for details
    remainder = desired_size % 4
    possible_size = desired_size + (3 - remainder)
    loop do
      if (Prime.prime?(possible_size)) then
        return possible_size
      else
        possible_size += 4
      end
    end
  end

  #given a non null key and at least one unused space grantees and entry
  def set(key, value)
    if (location = get_location_of_key(key))
      @table[location].value = value
      return true
    end

    match_available_space = lambda do |bucket_contents|
      if (!bucket_contents || bucket_contents.is_placeholder?)
        return true
      else
        return false
      end
    end
    if (location = quadratic_hash_search(key , match_available_space))
      @table[location] = TableEntry.new(key, value)
      @population += 1
      @used_spaces += 1
      return true
    else
      return false
    end
  end

  def get (key)
    if (location = get_location_of_key(key))
      return @table[location].value
    else
      return nil
    end
  end

  #return nil if not found the location otherwise
  def get_location_of_key(key)
    match_key = lambda do |bucket_contents|
      if (bucket_contents && !bucket_contents.is_placeholder? && bucket_contents.key == key)
        return true
      else
        return false
      end
    end
    return quadratic_hash_search(key, match_key)
  end

  def delete(key)
    if (location = get_location_of_key(key))
      @used_spaces -= 1
      return @table[location].make_placeholder()
    else
      return nil
    end
  end

  # returns the filled buckets / size for use in deciding efficiency
  def load()
    return @population/@size
  end

  # return the available slots including the ones acting as placeholders
  def available_slots()
    return @size - @used_spaces
  end

  # defines instance[key] = value syntax
  def []=(key , value)
    set(key, value)
  end

  # defines gotten_value = instance[key] syntax
  def [] (key)
    get(key)
  end

  #finds the first address that returns true for the space_matcher_function
  #returns address of space or nil if none were found
  def quadratic_hash_search (string, space_matcher_lambda)
    hash = string.hash % @size
    (0..(@size - 1)).each do |i|
      probe = @table[i]
      if i.odd?
        probe = ((hash + i**2) % @size).abs
      else
        probe = ((hash - i**2) % @size).abs
      end
      if space_matcher_lambda.call(@table[probe])
        return probe
      end
    end
    return nil
  end

  private :quadratic_hash_search, :get_good_size, :get_location_of_key
end
