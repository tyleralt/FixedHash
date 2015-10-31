require 'test/unit'
require_relative 'hash'

class HashTest < Test::Unit::TestCase
  def setup
    #will initialize with a size of 307
    @large = FixedHash.new 300
    #will initialize with a size of 7
    @small = FixedHash.new 5
  end

  def test_init
    hash = FixedHash.new 3
    assert_not_nil hash
  end

  def test_zero_load
    assert_equal(@large.load(), 0)
    assert_equal(@small.load(), 0)
  end
  def add_simple_set_helper
    @large['1'] = 'sample1'
    @large['2'] = 'sample2'
    @large['3'] = 'sample3'
    @large['4'] = 'sample4'
    @large['5'] = 'sample5'

    @small['1'] = 'sample1'
    @small['2'] = 'sample2'
    @small['3'] = 'sample3'
    @small['4'] = 'sample4'
  end

  def test_non_zero_load
    add_simple_set_helper()
    assert_equal(@large.load(), 5/307)
    assert_equal(@small.load(), 5/7)
  end

  def test_full_load
    (1..307).each do |i|
      @large[i.to_s] = 'sample' + i.to_s
    end
    (1..7).each do |i|
      @small[i.to_s] = 'sample' + i.to_s
    end
    assert_equal(@large.load(), 1)
    assert_equal(@small.load(), 1)
  end

  def availabel_slots_all
    assert_equal(@large.available_slots(), 307)
    assert_equal(@small.available_slots(), 7)
  end

  def test_available_slots_some
    (1..150).each do |i|
      @large[i.to_s] = 'sample' + i.to_s
    end
    (1..3).each do |i|
      @small[i.to_s] = 'sample' + i.to_s
    end
    assert_equal(@large.available_slots(), 307 - 150)
    assert_equal(@small.available_slots(), 7 - 3)
  end

  def test_available_slots_none
    (1..307).each do |i|
      @large[i.to_s] = 'sample' + i.to_s
    end
    (1..7).each do |i|
      @small[i.to_s] = 'sample' + i.to_s
    end
    assert_equal(@large.available_slots(), 0)
    assert_equal(@small.available_slots(), 0)
  end

  def test_adding_value
    @small.set('sample', 4)
    @large['sample'] = 4
  end

  def test_getting_values
    @small.set('sample', 4)
    @large.set('sample', 4)
    assert_equal(@small.get('sample'), 4)
    assert_equal(@large.get('sample'), 4)
  end

  def test_getting_and_setting_values_by_braket_method
    @small['sample'] = 4
    @large['sample'] = 4
    assert_equal(@small['sample'], 4)
    assert_equal(@large['sample'], 4)
  end

  def test_adding_multiple_and_getting_values
    (1..150).each do |i|
      @large[i.to_s] = 'sample' + i.to_s
    end
    (1..3).each do |i|
      @small[i.to_s] = 'sample' + i.to_s
    end
    (1..150).each do |i|
      assert_equal(@large[i.to_s], 'sample' + i.to_s)
    end
    (1..3).each do |i|
      assert_equal(@small[i.to_s], 'sample' + i.to_s)
    end
  end

  def test_garunteed_adding_values_until_load_is_1_no_deletes
    (1..307).each do |i|
      @large[i.to_s] = 'sample' + i.to_s
    end
    (1..7).each do |i|
      @small[i.to_s] = 'sample' + i.to_s
    end
    (1..307).each do |i|
      assert_equal(@large[i.to_s], 'sample' + i.to_s)
    end
    (1..7).each do |i|
      assert_equal(@small[i.to_s], 'sample' + i.to_s)
    end
  end

  def test_deleting_values
    (1..150).each do |i|
      @large[i.to_s] = 'sample' + i.to_s
    end
    (1..3).each do |i|
      @small[i.to_s] = 'sample' + i.to_s
    end
    (1..150).each do |i|
      assert_equal('sample' + i.to_s, @large.delete(i.to_s))
    end
    (1..3).each do |i|
      assert_equal('sample' + i.to_s, @small.delete(i.to_s))
    end
    (1..150).each do |i|
      assert_nil(@large[i.to_s])
    end
    (1..3).each do |i|
      assert_nil(@small[i.to_s])
    end
  end

  def test_load_same_on_value_delete
    (1..150).each do |i|
      @large[i.to_s] = 'sample' + i.to_s
    end
    (1..3).each do |i|
      @small[i.to_s] = 'sample' + i.to_s
    end
    large_load = @large.load()
    small_load = @small.load()
    (1..100).each do |i|
      @large.delete(i.to_s)
    end
    (1..2).each do |i|
      @small.delete(i.to_s)
    end
    assert_equal(large_load, @large.load())
    assert_equal(small_load, @small.load())
  end

  def test_available_slots_changed_on_delete
    (1..150).each do |i|
      @large[i.to_s] = 'sample' + i.to_s
    end
    (1..3).each do |i|
      @small[i.to_s] = 'sample' + i.to_s
    end
    (1..100).each do |i|
      @large.delete(i.to_s)
    end
    (1..2).each do |i|
      @small.delete(i.to_s)
    end
    assert_equal(307-50, @large.available_slots())
    assert_equal(7-1, @small.available_slots())
  end

  def test_delete_many_then_write_over
    (1..200).each do |i|
      @large[i.to_s] = 'sample' + i.to_s
    end
    (1..100).each do |i|
      @large.delete(i.to_s)
    end
    (201..400).each do |i|
      @large[i.to_s] = 'sample' + i.to_s
    end
    (101..400).each do |i|
      assert_equal('sample' + i.to_s, @large[i.to_s])
    end
  end

  def test_set_returns_true_until_over
    (1..307).each do |i|
      #in ruby everything not false or nil is true
      assert_not_nil(@large.set(i.to_s, 'sample'+i.to_s))
    end
    puts @large.load().to_s
    puts @large.available_slots().to_s
    (308..350).each do |i|
      assert_equal(false, @large.set(i.to_s, 'sample'+i.to_s))
    end
  end

  def test_overwriting_with_set
    (1..100).each do |i|
      @large[i.to_s] = 'sample' + i.to_s
    end
    (1..100).each do |i|
      @large[i.to_s] = 'sampleNext' + i.to_s
    end
    (1..100).each do |i|
      assert_equal('sampleNext' + i.to_s, @large[i.to_s])
    end
  end

  def test_get_on_element_not_present
    (1..100).each do |i|
      @large[i.to_s] = 'sample' + i.to_s
    end
    assert_nil(@large['randomString'])
  end
end
