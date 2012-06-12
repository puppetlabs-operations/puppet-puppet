# This config.ru madness was stolen from https://github.com/grempe/thin-proctitle

module Rack
  class Response
    def new_finish
      $0 = "#{$app_name} on port #{$port} (Serviced #{$count} requests): idle"
      old_finish
    end
    alias_method :old_finish, :finish
    alias_method :finish, :new_finish
  end

  class File
    # for some reason, serving a file doesn't call the finish method...
    def new_call(env)
      k = old_call(env)
      $0 = "#{$app_name} on port #{$port} (Serviced #{$count} requests): idle"
      k
    end
    alias_method :old_call, :call
    alias_method :call, :new_call
  end
end

class ProcTitle

  def initialize(app)
    # stolen from mongrel_proctitle plugin
    wd =  Dir.pwd.split("/")
    wd.pop; wd.pop
    $app_name = wd.last ? wd.last : 'puppet master'

    $app = app
    $count = 0
  end

  def call(env)
    $count += 1
    $port = env['SERVER_PORT']
    $0 = "#{$app_name} on port #{$port} (Serviced #{$count} requests): handling #{env['SERVER_NAME']}: #{env['REQUEST_METHOD']} #{env['PATH_INFO']}"
    $app.call(env)
  end

end
use ProcTitle

ARGV << "--rack"
require 'puppet/application/master'
# we're usually running inside a Rack::Builder.new {} block,
# therefore we need to call run *here*.
run Puppet::Application[:master].run

