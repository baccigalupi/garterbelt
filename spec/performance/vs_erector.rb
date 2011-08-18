#!/usr/bin/env ruby

require 'rubygems'
require "rbench"
require 'hashie'

require 'erector'
require 'haml'

require File.dirname(__FILE__) + "/../../lib/garterbelt"

require File.dirname(__FILE__) + '/templates/garterbelt'
require File.dirname(__FILE__) + '/templates/erector'
haml =  File.read(File.dirname(__FILE__) + '/templates/ham.haml')

TIMES = 10_000

RBench.run(TIMES) do
  column :garterbelt
  column :erector
  column :haml
  
  user = Hashie::Mash.new(:username => 'baccigalupi', :email => 'baccigalupi@example.com', :name => 'Kane Baccigalupi')
  
  report "Simple Page Initializing" do
    garterbelt { GarterbeltTemplate.new(:user => user) }
    erector { ErectorTemplate.new(:user => user) }
    haml { Haml::Engine.new( haml ) }
  end
  
  object = Object.new
  object.instance_variable_set "@user", user
  object.instance_variable_set "@flash", nil
  
  report "Simple Page Rendering" do
    garterbelt { GarterbeltTemplate.new(:user => user).render }
    erector { ErectorTemplate.new(:user => user).to_html }
    haml { Haml::Engine.new( haml ).to_html(object, {:user => user, :flash => nil} ) }
  end
end

# This is all kind of outdated ... and the same test needs to happen with real requests from an app

# 4/13/2011, more stuff checking for 0.0.6
# 10_000                           GARTERBELT | ERECTOR | PERCENT DIFFERENCE
# --------------------------------------------------------------------------
# Simple Page Initializing              0.178 |   0.170 | 4.5% slower
# Simple Page Rendering                 6.971 |   6.613 | 5.1% slower
#
# 50_000                           GARTERBELT | ERECTOR | PERCENT DIFFERENCE
# --------------------------------------------------------------------------
# Simple Page Initializing              0.856 |   1.016 | 15.7% faster
# Simple Page Rendering                34.804 |  33.547 | 3.6% slower
#
# 100_000                          GARTERBELT | ERECTOR | PERCENT DIFFERENCE
# --------------------------------------------------------------------------
# Simple Page Initializing              1.678 |   1.911 | 12% faster
# Simple Page Rendering                69.654 |  67.422 | 3.2% slower
# 
# 500_0000                         GARTERBELT | ERECTOR | PERCENT DIFFERENCE
# --------------------------------------------------------------------------
# Simple Page Initializing              8.465 |   9.656 | 12.4% faster
# Simple Page Rendering               350.409 | 338.026 | 3.5% slower



# 4/13/2011, version 0.0.4, Removing RuPol from the lib, totally a flacid chick :(
# more work on performance later
#                                            GARTERBELT | ERECTOR |
# -----------------------------------------------------------------
# Simple Page Initializing                        0.178 |   0.173 | 2.8% slower
# Simple Page Rendering                           7.132 |   6.601 | 7.4% slower

# 4/13/2011, version 0.0.4, Oops none of the benchmarks were rendering, just initializing
# and the performance sucks
# 10_000
#                                           GARTERBELT | ERECTOR |
# -----------------------------------------------------------------
# Simple Page Initializing                        0.200 |   0.176 | 12% slower
# Simple Page Rendering                          24.488 |   6.815 | 72% slower
# Simple Page, class level rendering             24.594 |   6.775 | 72% slower


# 4/13/2011, version 0.0.4, performance regression
# 100_000
#                              GARTERBELT | ERECTOR |
# ----------------------------------------------------
# Simple Page Initialization              2.139 |   1.958 | 9.2% slower
# Simple Page Initialization              1.956 |   1.928 | 1.4% slower # removing opts.dup in view initialize
# Simple Page Initialization              1.595 |   1.929 | 17.2% faster # not passing the block in partial (feature withdrawal, not viable)
# Simple Page Initialization              1.663 |   1.914 | 13% faster # conditional passing of block in partial
# Simple Page Initialization              1.629 |   1.891 | 13.8% # conditional passing of block in other view methods

# 4/11/2011, version 0.0.1
# GARTERBELT = pooling at standard 1000 instances
# GARTERBELT_2 = pooling at 10% of sample time

# 10_000 times
#                                   GARTERBELT | ERECTOR |
# ---------------------------------------------------------------------
# Simple Page Initialization                 0.164 |   0.205 |    20% faster

# 100_000 times
#                                   GARTERBELT | GARTERBELT_2 | ERECTOR |
# ---------------------------------------------------------------------
# Simple Page Initialization                 1.857 | 1.828 | 1.932 |    3.8-5.3%/ faster

# 200_000 times
#                                   GARTERBELT | GARTERBELT_2 | ERECTOR |
# ---------------------------------------------------------------------
# Simple Page Initialization                 3.743 | 3.660 | 3.846 |    2.7-4.8% faster

# 500_000 times
#                                   GARTERBELT | GARTERBELT_2 | ERECTOR |
# ---------------------------------------------------------------------
# Simple Page Initialization                 9.420 | 9.422 | 9.637 |    2.3-2.2% faster




