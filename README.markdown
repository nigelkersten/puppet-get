This is a Puppet function aimed at helping solve the problem of data/model
separation.

It will get the value of a named variable from external and internal data
locations by convention.

`get('myvar')` will look in the following locations, returning the first
  value that exists in the following order.

  * `data::$calling_class::myvar`
  * `data::$calling_module::myvar`
  * `$calling_class::data::myvar`
  * `$calling_module::data::myvar`
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

and if none of the above are defined, would return 'default value'."


The example/ directory is laid out to illustrate how this works. You can run the examples
from this directory as follows:

  `puppet apply --verbose --modulepath ./example/modules --libdir ./lib example/apply.pp`
