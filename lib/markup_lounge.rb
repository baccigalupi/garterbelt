lounge_dir =  File.dirname(__FILE__)

require 'ru_pol'
require 'active_support/core_ext/string/output_safety'
 
require lounge_dir + '/renderers/renderer'
require lounge_dir + '/renderers/closed_tag'
require lounge_dir + '/renderers/content_tag'
require lounge_dir + '/renderers/text'
require lounge_dir + '/view'
