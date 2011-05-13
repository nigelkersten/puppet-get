This is a Puppet function aimed at helping solve the problem of data/model
separation.

It will get the value of a named variable from external and internal data
locations by convention.

This is much like the proposals in http://projects.puppetlabs.com/issues/6079
however it is significantly lighter weight, and by employing the Puppet DSL
itself for the values, you are free to use the existing conditional language
features, as well as mix and match with alternative solutions such as the
extlookup() function.

`get('myvar')` will look in the following locations, returning the first
  value that exists in the following order.

  * `data::$calling_class::myvar`
  * `data::$calling_module::myvar`
  * `$calling_class::data::myvar`
  * `$calling_module::data::myvar`
  * optional second argument to the function

You do not need to manually include any of these data classes. This function
will automatically load them if needed.

*WARNING:* Do not declare resources in the above classes. They *will* get included
and evaluated. Only declare variables. This function relies upon convention.

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

  * `$data::foo::bar::myvar`
  * `$data::foo::myvar`
  * `$foo::bar::data::myvar`
  * `$foo::data::myvar`

and if none of the above are defined, would return 'default value'."


The example/ directory is laid out to illustrate how this works. You can run the examples
from this directory as follows:

  `puppet apply --verbose --modulepath ./example/modules --libdir ./lib example/apply.pp`

To test the lookup order, comment or uncomment the various declarations of `$x` in:

  * `example/apply.pp`
  * `example/modules/data/manifests/foo/bar.pp`
  * `example/modules/data/manifests/foo.pp`
  * `example/modules/foo/manifests/bar/data.pp`
  * `example/modules/foo/manifests/bar.pp`
  * `example/modules/foo/manifests/data.pp`

Suggestions for improvement welcome.
