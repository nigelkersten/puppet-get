Puppet::Parser::Functions::newfunction(:get, :type => :rvalue, :doc =>
  "Get the value of a named variable from external and internal data
  locations by convention.

  get('myvar') will look in the following locations, returning the first
  value that exists in the following order.
    * data::$calling_class::myvar
    * data::$calling_module::myvar
    * $calling_class::data::myvar
    * $calling_module::data::myvar
    * optional second argument to the function

  You do not need to manually include any of these data classes. This function
  will automatically load them if needed.

  This function was designed primarily to be used to set the default value for
  a class parameter at definition time. When used in this way, you are still
  free to set the class parameter at declaration time.

  A more concrete example:

    # class definition
    class foo::bar( $myvar = get('myvar', 'default value') ) {
      ...
    }

    # class declaration
    class { 'foo::bar': }

  would return the first defined variable of:
    * $data::foo::bar::myvar
    * $data::foo::myvar
    * $foo::bar::data::myvar
    * $foo::data::myvar

  and if none of the above are defined, would return 'default value'.") do |args|

  unless varname = args[0]
    raise Puppet::ParseError, "get(): requires at least one argument"
  end

  if args.length > 2
    raise Puppet::ParseError, "get(): cannot accept more than two arguments"
  end

  # Ensure include is loaded
  include_class = Puppet::Parser::Functions.function(:include)

  loaded_classes = catalog.classes
  caller_class = self.resource.name.downcase
  caller_module = caller_class.split("::")[0]

  external_data_class = "data::#{caller_class}"
  internal_data_class = "#{caller_class}::data"
  external_data_module = "data::#{caller_module}"
  internal_data_module = "#{caller_module}::data"

  lookup_order = [ external_data_class, external_data_module,
                   internal_data_class, internal_data_module, ]
  lookup_order.uniq!  # if caller_class == caller_module

  value = :undefined
  lookup_order.each do |lookup_location|
    if value == :undefined
      unless loaded_classes.include?(lookup_location)
        # Try loading the class to find the value but
        # suppress errors
        begin
          send(include_class, lookup_location)
          value = lookupvar("#{lookup_location}::#{varname}")
        rescue
        end
      end
    end
  end

  return value unless value == :undefined
  return args[1] unless args[1].nil?
  raise Puppet::ParseError, "Unable to get data value for '#{args[0]}'"
end

