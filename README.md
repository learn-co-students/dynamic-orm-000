# Building an ORM

## Note

This lab requires some setup so run this in your terminal, make sure you have Postgres installed and running.

``` shell
createdb dynamic_orm_test
createdb dynamic_orm_development
psql -f spec/db/programmer_seed.sql -d dynamic_orm_development
psql -f spec/db/state_seed.sql -d dynamic_orm_development
```

This will create a test and development database you can poke around
in with `rake console`.  
![](http://media1.giphy.com/media/LXTQN2kRbaqAw/200.gif)

Points of interest


Be sure to checkout the files in spec/db/. They have the seed data for
the tests.

The [Inflecto](https://github.com/mbj/inflecto) gem will help you with
pluralizing and singularizing words. [Docs
here](https://github.com/mbj/inflecto/blob/master/lib/inflecto.rb)

Assignment
==========

You'll be building your own ORM. The class you will be building is Base
located inside the FlactiveRecord module.

```ruby
module FlactiveRecord
  class Base
  end
end
```

The API
-

All of the classes that inherit from your ORM will have the following
class methods:
* .all
* .column_names
* .connection
* .exec
* .find
* .table_name

The instance methods will be created dynamically based on the column
names. A Programmer instance will have the following methods:
* \#id  
* \#id=
* \#language
* \#language=
* \#name
* \#name=

You will find 2 classes defined in the tests

```ruby
class State < FlactiveRecord::Base
end

class Programmer < FlactiveRecord::Base
end
```

DO NOT MODIFY THESE CLASSES. All functionality will be added by
inheriting from FlactiveRecord::Base

Tips
----

### How to get a list of columns from postgres

```
SELECT column_name
FROM information_schema.columns
WHERE table_name='#{table_name}'
```

### Changing self, and hooking into inheritance

Whenever a class is inherited, ruby calls the superclass'
`self.inherited` method and passes it the class that inherited it.

```ruby
class SoSuper
  def self.inherited(base)
    puts "#{base} inherited #{self}"
  end
end

class NotSuper < SoSuper
end
#=> NotSuper inherited SoSuper
```

Notice that inside the inherited class, `self` is `SoSuper`. We can
change self to be the inherited class by using `.class_eval`

```ruby
class SoSuper
  def self.inherited(base)
    puts "self is the class #{self}"
    base.class_eval do
      puts "self is the class #{self}"
    end
  end
end

class NotSuper < SoSuper
end
# => self is the class SoSuper
# => self is the class NotSuper
```

### Connecting to the Database
Use our DBConnection object to run sql commands.

In your `Base` class you can wrap your methods using

```ruby
def self.exec(sql, args=[])
  DBConnection.instance.exec(sql, args)
end

def self.connection
  DBConnection.instance.connection
end
```
