require File.dirname(__FILE__) + '/yell/logger' #monkey patch for Logger#<<
require File.dirname(__FILE__) + '/yell/adapters/logstash/version'
require File.dirname(__FILE__) + '/yell/adapters/logstash/file_logger'
require File.dirname(__FILE__) + '/yell/adapters/logstash/controller_filters'
require File.dirname(__FILE__) + '/yell/adapters/logstash/middleware'