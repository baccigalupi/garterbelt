stocking_dir =  File.dirname(__FILE__)

require 'active_support/core_ext/string/output_safety'
require stocking_dir + '/support/string'

require 'moneta'
require 'moneta/memory'
 
require stocking_dir + '/stocking'

require stocking_dir + '/renderers/renderer'
require stocking_dir + '/renderers/content_rendering'
require stocking_dir + '/renderers/closed_tag'
require stocking_dir + '/renderers/content_tag'
require stocking_dir + '/renderers/cache'
require stocking_dir + '/renderers/text'
require stocking_dir + '/renderers/comment'
require stocking_dir + '/renderers/doctype'
require stocking_dir + '/renderers/xml'

require stocking_dir + '/view'
require stocking_dir + '/page'
