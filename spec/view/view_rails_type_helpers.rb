require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Garterbelt::View, "Rails Style Helpers" do
  describe 'inputs' do
    describe '#input' do
      it 'defaults to type of text'
    end
    
    describe 'checkbox' do
      
    end
  end
  
  describe '#form' do
    describe 'method option' do
      describe ':put' do
        it 'builds _method hidden input with the correct attribute'
        it 'sets the form method attribute to post'
      end
      
      describe ':delete' do
        it 'builds _method hidden input with the correct attribute'
        it 'sets the form method attribute to post'
      end
      
      it 'defaults to :post when none is given'
      it 'can be set to :get too'
      it 'has that Rails fraud detector thingy when available'
    end
  end
  
  describe '#image' do
    describe 'class level image path' do
      it 'has a default class image path /images'
      it 'class level image path can be customized'
      it 'class level image path is inherited'
    end
    
    it 'takes the file name as first argument constructs a full path for the img src'
    
    describe 'alt text' do
      it 'humanizes the file name by default'
      it 'can be customize through options'
    end
    
    it 'takes other attributes'
    
    describe 'expiration tagging' do
      it 'includes one related to the file updated time in seconds'
    end
  end
  
  describe '#auto_discovery' do
    #  auto_discovery_link_tag # =>
    #     <link rel="alternate" type="application/rss+xml" title="RSS" href="http://www.currenthost.com/controller/action" />
    #  auto_discovery_link_tag(:atom) # =>
    #     <link rel="alternate" type="application/atom+xml" title="ATOM" href="http://www.currenthost.com/controller/action" />
    #  auto_discovery_link_tag(:rss, {:action => "feed"}) # =>
    #     <link rel="alternate" type="application/rss+xml" title="RSS" href="http://www.currenthost.com/controller/feed" />
    #  auto_discovery_link_tag(:rss, {:action => "feed"}, {:title => "My RSS"}) # =>
    #     <link rel="alternate" type="application/rss+xml" title="My RSS" href="http://www.currenthost.com/controller/feed" />
    #  auto_discovery_link_tag(:rss, {:controller => "news", :action => "feed"}) # =>
    #     <link rel="alternate" type="application/rss+xml" title="RSS" href="http://www.currenthost.com/news/feed" />
    #  auto_discovery_link_tag(:rss, "http://www.example.com/feed.rss", {:title => "Example RSS"}) # =>
    #     <link rel="alternate" type="application/rss+xml" title="Example RSS" href="http://www.example.com/feed" />
  end
  
  describe '#script_include' do
    #   javascript_include_tag "xmlhr" # =>
    #     <script type="text/javascript" src="/javascripts/xmlhr.js"></script>
    #
    #   javascript_include_tag "xmlhr.js" # =>
    #     <script type="text/javascript" src="/javascripts/xmlhr.js"></script>
    #
    #   javascript_include_tag "common.javascript", "/elsewhere/cools" # =>
    #     <script type="text/javascript" src="/javascripts/common.javascript"></script>
    #     <script type="text/javascript" src="/elsewhere/cools.js"></script>
    #
    #   javascript_include_tag "http://www.railsapplication.com/xmlhr" # =>
    #     <script type="text/javascript" src="http://www.railsapplication.com/xmlhr.js"></script>
    #
    #   javascript_include_tag "http://www.railsapplication.com/xmlhr.js" # =>
    #     <script type="text/javascript" src="http://www.railsapplication.com/xmlhr.js"></script>
    #
    #   javascript_include_tag :defaults # =>
    #     <script type="text/javascript" src="/javascripts/prototype.js"></script>
    #     <script type="text/javascript" src="/javascripts/effects.js"></script>
    #     ...
    #     <script type="text/javascript" src="/javascripts/application.js"></script>
    #
    # * = The application.js file is only referenced if it exists
    #
    # Though it's not really recommended practice, if you need to extend the default JavaScript set for any reason
    # (e.g., you're going to be using a certain .js file in every action), then take a look at the register_javascript_include_default method.
    #
    # You can also include all javascripts in the javascripts directory using <tt>:all</tt> as the source:
    #
    #   javascript_include_tag :all # =>
    #     <script type="text/javascript" src="/javascripts/prototype.js"></script>
    #     <script type="text/javascript" src="/javascripts/effects.js"></script>
    #     ...
    #     <script type="text/javascript" src="/javascripts/application.js"></script>
    #     <script type="text/javascript" src="/javascripts/shop.js"></script>
    #     <script type="text/javascript" src="/javascripts/checkout.js"></script>
    #
    # Note that the default javascript files will be included first. So Prototype and Scriptaculous are available to
    # all subsequently included files.
    #
    # If you want Rails to search in all the subdirectories under javascripts, you should explicitly set <tt>:recursive</tt>:
    #
    #   javascript_include_tag :all, :recursive => true
    #
    # == Caching multiple javascripts into one
    #
    # You can also cache multiple javascripts into one file, which requires less HTTP connections to download and can better be
    # compressed by gzip (leading to faster transfers). Caching will only happen if config.perform_caching
    # is set to <tt>true</tt> (which is the case by default for the Rails production environment, but not for the development
    # environment).
    #
    # ==== Examples
    #   javascript_include_tag :all, :cache => true # when config.perform_caching is false =>
    #     <script type="text/javascript" src="/javascripts/prototype.js"></script>
    #     <script type="text/javascript" src="/javascripts/effects.js"></script>
    #     ...
    #     <script type="text/javascript" src="/javascripts/application.js"></script>
    #     <script type="text/javascript" src="/javascripts/shop.js"></script>
    #     <script type="text/javascript" src="/javascripts/checkout.js"></script>
    #
    #   javascript_include_tag :all, :cache => true # when config.perform_caching is true =>
    #     <script type="text/javascript" src="/javascripts/all.js"></script>
    #
    #   javascript_include_tag "prototype", "cart", "checkout", :cache => "shop" # when config.perform_caching is false =>
    #     <script type="text/javascript" src="/javascripts/prototype.js"></script>
    #     <script type="text/javascript" src="/javascripts/cart.js"></script>
    #     <script type="text/javascript" src="/javascripts/checkout.js"></script>
    #
    #   javascript_include_tag "prototype", "cart", "checkout", :cache => "shop" # when config.perform_caching is true =>
    #     <script type="text/javascript" src="/javascripts/shop.js"></script
  end
  
  describe '#stylesheet_include' do
    # same as above but for stylesheets
  end
  
  describe 'favicon' do
  end
  
end