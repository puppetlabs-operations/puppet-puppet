Puppet::Parser::Functions.newfunction(:validate_environment) do

  confenv    = scope.lookupvar('::confenv')
  modulepath = scope.lookupvar('::settings::modulepath')
  server     = scope.lookupvar('::server')

  modulepath.split(':').each do |path|
    unless File.directory? path
      function_fail(["Invalid environment #{confenv} on server #{server}: module path #{path} does not exist."])
    end
  end
end
