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

class Hash
  def method_missing(m, *args, **h, &)
    fetch(m)
  end
end

class UserDB
  # extend Forwardable
  # def_delegator :@gdbm, :close
  attr_reader :live, :picks, :keys
  
  def initialize(f, f_online='usersonline.csv', f_picks='userspicks.csv', &block)
    @fname=f
    @live=CSV.read(f_online).flatten
    p @picks=CSV.read(f_picks).flatten
  end
  
  def grep(q, online: false, &block)
    self.open do |db| 
      db.values.grep(q).map do |e|
        h = JSON.parse(e, symbolize_names: true)
        if online
          next unless live.include?(h[:username])
        end
        block[h] if block
        h
      end
    end
  end

  def reload_live(f_online)
    @live=CSV.read(f_online).flatten
  end

  def reload_picks(f_picks)
    @picks=CSV.read(f_picks).flatten
  end
  
  def keys(online: false, &block)
    self.open do |db| 
      db.keys.select do |e|
        online? ? live.include?(e) : e 
      end
    end
  end

  def values(&block)
    found=nil
    open do |db|
      found=db.values.map{ |v| 
        h=v.to_h
        block[h] if block
        h
      }.map
    end
  end

  def online(&block)
    open do |db|
      found=db.select do |k, v| 
        live.include?(k)
      end
      found.map do |_, v|
        h=v.to_h
        block[h] if block
        h
      end.map
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
