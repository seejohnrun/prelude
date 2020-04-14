require 'spec_helper'

describe Prelude do
  it 'should have a version' do
    expect(Prelude::VERSION).to_not be_nil
  end

  it 'should not define any methods on classes it is not included into' do
    klass = Class.new(ActiveRecord::Base)
    expect(klass).not_to respond_to(:define_prelude)
  end

  it 'should be able to call preloaders on a single instance' do
    klass = Class.new(ActiveRecord::Base) do
      self.table_name = 'breweries'

      include Prelude::Preloadable

      define_prelude(:number) do |records|
        Hash.new { |h, k| h[k] = 42 } # answer is always 42
      end
    end

    expect(klass.new.number).to eq(42)
  end

  it 'should be able to batch multiple calls into one' do
    call_count = 0

    klass = Class.new(ActiveRecord::Base) do
      self.table_name = 'breweries'

      include Prelude::Preloadable

      define_prelude(:number) do |records|
        call_count += 1
        Hash.new { |h, k| h[k] = 42 } # answer is always 42
      end
    end

    5.times { klass.create! }

    expect(klass.all.map(&:number).uniq).to eq([42]) # all the same result
    expect(call_count).to eq(1) # only one call
  end

  it 'should be able to work with Arrays' do
    call_count = 0

    klass = Class.new(ActiveRecord::Base) do
      self.table_name = 'breweries'

      include Prelude::Preloadable

      define_prelude(:number) do |records|
        call_count += 1
        Hash.new { |h, k| h[k] = 42 } # answer is always 42
      end
    end

    records = 5.times.map { klass.new }
    numbers = records.map.with_prelude(&:number)

    expect(numbers.uniq).to eq([42]) # all the same result
    expect(call_count).to eq(1) # only one call
  end

  it 'should be able to chain Enumerators' do
    call_count = 0

    klass = Class.new(ActiveRecord::Base) do
      self.table_name = 'breweries'

      include Prelude::Preloadable

      define_prelude(:number) do |records|
        call_count += 1
        Hash.new { |h, k| h[k] = 42 } # answer is always 42
      end
    end

    records = 5.times.map { klass.new }
    numbers = records.map.with_prelude.with_index do |record, i|
      expect(record).to be_present
      expect(i).to be_a(Integer)
      record.number
    end

    expect(numbers.uniq).to eq([42]) # all the same result
    expect(call_count).to eq(1) # only one call
  end

end
