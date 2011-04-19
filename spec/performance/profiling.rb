#!/usr/bin/env ruby

require 'rubygems'
require "rbench"
require 'hashie'

require File.dirname(__FILE__) + "/../../lib/garterbelt"
require File.dirname(__FILE__) + '/templates/garterbelt'

TIMES = 10_000

require 'ruby-prof'

# Profile the code
@view = Garterbelt::View.new
@tag = Garterbelt::ContentTag.new(:type => :p, :view => @view) do
  @view._buffer << Garterbelt::ContentTag.new(:type => :span, :view => @view, :content => 'spanning')
  @view._buffer << Garterbelt::Text.new(:content => ' so much time here', :view => @view)
end

result = RubyProf.profile do
  TIMES.times do
    @tag.render
  end
end

# Print a graph profile to text
printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, 0)
