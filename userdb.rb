#!/usr/bin/env ruby
# Id$ nonnax 2022-02-12 22:31:44 +0800
require 'gdbm'
require 'csv'
require 'forwardable'
require 'json'

class String
  def to_h
    JSON.parse(self, symbolize_names: true)
  end
end

class UserDB

  # extend Forwardable
  # def_delegator :@gdbm, :close
  attr_reader :picks, :keys
  
  def initialize(db:'udata.db', flive: 'uonline.csv', fpicks: 'upicks.csv', &block)
    @fname=db
    @live=CSV.read(flive)
             .flatten
    @picks=CSV.read(fpicks)
              .flatten
              .select{|k| self[k] } # discard upicks.csv junk              
  end

  def [](k)
    self.open do |db|
      db[k].to_h if db.key?(k)
    end
  end
  
  def grep(q, &block)
      open do |db|
        db
        .values
        .grep(q) # grep string values
        .select{ |u| @live.include?(u.to_h[:username]) }
        .map(&:to_h)
      end
  end
  
  def live_picks(&block)
    @live
    .intersection(@picks)
    .map(&block)
  end

  def reload_live(flive)
    @live=CSV.read(flive).flatten
  end

  def reload_picks(fpicks)
    @picks=CSV.read(fpicks).flatten
  end
  
  def live(range: (0..20), &block)
    @live.slice(range).map(&block)
  end

  def values(&block)
    @live.map do |k|
      val=self[k]
      block.call( val ) if block
      val
    end
  end

  def select(&)
    found=open do |db|
      db.select(&)
    end
    found.map{|_, v| v.to_h}.map
  end

  def reject(&)
    open do |db|
      db.reject(&)
    end
  end

  def open(&)
    GDBM.open(@fname, &) 
  end
end
