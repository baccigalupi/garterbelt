lounge_dir =  File.dirname(__FILE__)

require 'active_support/core_ext/string/output_safety'
require 'support/string'

require 'ru_pol'
require 'moneta'
require 'moneta/memory'
 
require lounge_dir + '/lounge' 
require lounge_dir + '/renderers/renderer'
require lounge_dir + '/renderers/closed_tag'
require lounge_dir + '/renderers/content_rendering'
require lounge_dir + '/renderers/content_tag'
require lounge_dir + '/renderers/cache'
require lounge_dir + '/renderers/text'
require lounge_dir + '/renderers/comment'

require lounge_dir + '/view'
