#!/usr/bin/env ruby

require 'rubygems'
require "rbench"
require 'hashie'

require 'erector'
require File.dirname(__FILE__) + "/../../lib/garterbelt"

require File.dirname(__FILE__) + '/templates/garterbelt'
require File.dirname(__FILE__) + '/templates/erector'

TIMES = 10_000

RBench.run(TIMES) do
  # Garterbelt.max_pool_size = TIMES/100
  column :garterbelt
  column :erector
  
  user = Hashie::Mash.new(:username => 'baccigalupi', :email => 'baccigalupi@example.com', :name => 'Kane Baccigalupi')
  
  report "Simple Page Initializing" do
    garterbelt { GarterbeltTemplate.new(:user => user) }
    erector { ErectorTemplate.new(:user => user) }
  end
  
  report "Simple Page Rendering" do
    garterbelt { GarterbeltTemplate.new(:user => user).render }
    erector { ErectorTemplate.new(:user => user).to_html }
  end
  
  report "Simple Page, class level rendering" do
    garterbelt { GarterbeltTemplate.render(:user => user) }
    erector { ErectorTemplate.new(:user => user).to_html }
  end
end
puts GarterbeltTemplate._pool.inspect

# 4/13/2011, version 0.0.4, Oops none of the benchmarks were rendering, just initializing
# and the performance sucks
# 10_000
#                                           GARTERBELT | ERECTOR |
# -----------------------------------------------------------------
# Simple Page Initializing                        0.200 |   0.176 |
# Simple Page Rendering                          24.488 |   6.815 |
# Simple Page, class level rendering             24.594 |   6.775 |


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




