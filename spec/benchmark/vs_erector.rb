#!/usr/bin/env ruby

require 'rubygems'
require "rbench"
require 'hashie'

require 'erector'
require File.dirname(__FILE__) + "/../../lib/markup_lounge"

require File.dirname(__FILE__) + '/templates/lounge'
require File.dirname(__FILE__) + '/templates/erector'

TIMES = 500_000

RBench.run(TIMES) do
  LoungeTemplate.max_pool_size TIMES/10
  column :markup_lounge
  column :erector
  
  report "Simple Page Rendering" do
    user = Hashie::Mash.new(:username => 'baccigalupi', :email => 'baccigalupi@example.com', :name => 'Kane Baccigalupi')
    erector { ErectorTemplate.new(:user => user) }
    markup_lounge { LoungeTemplate.new(:user => user) }
  end
end

# 4/11/2011, version 0.0.1, standard pooling
# MARKUP_LOUNGE = pooling at standard 1000 instances
# MARKUP_2 = pooling at 10% of sample time

# 10_000 times
#                               MARKUP_LOUNGE | ERECTOR |
# ---------------------------------------------------------------------
# Simple Page Rendering                 0.164 |   0.205 |    20% faster

# 100_000 times
#                               MARKUP_LOUNGE | MARKUP_2 | ERECTOR |
# ---------------------------------------------------------------------
# Simple Page Rendering                 1.857 | 1.828 | 1.932 |    3.8-5.3%/ faster

# 200_000 times
#                               MARKUP_LOUNGE | MARKUP_2 | ERECTOR |
# ---------------------------------------------------------------------
# Simple Page Rendering                 3.743 | 3.660 | 3.846 |    2.7-4.8% faster

# 500_000 times
#                               MARKUP_LOUNGE | MARKUP_2 | ERECTOR |
# ---------------------------------------------------------------------
# Simple Page Rendering                 9.420 | 9.422 | 9.637 |    2.3-2.2% faster




