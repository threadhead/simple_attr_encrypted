# simple_attr_encrypted [![Build Status](https://secure.travis-ci.org/threadhead/simple_attr_encrypted.png)](http://travis-ci.org/threadhead/simple_attr_encrypted?branch=master)

Simple attribute encryption for ActiveRecord. Simple, as in has few features. Directly inspired by [danpal's](https://github.com/danpal) [attr_encryptor](https://github.com/danpal/attr_encryptor)

Works only with ActiveRecord and has virtually no features, no dependencies. Simple.

If you would like many addition features, I highly recommend [attr_encryptor](https://github.com/danpal/attr_encryptor).

Install
-------

```shell
gem install simple_attr_encrypted
```

or add the following to your Gemfile:

```ruby
gem 'simple_attr_encrypted'
```

and run `bundle install` from the command line.

Usage
-----
`simple_attr_encrypted` works off the premise that your salt and key are stored in environment variables. Much safer than keeping them in your code or database.

```shell
export ENCRYPTED_ATTRIBUTE_SALT=987654321
export ENCRYPTED_ATTRIBUTE_KEY=mysekritkey
```

Obviously, you should change the salt to a random, large integer, and the key to a long string of characters (up to 256).

An initializtion vector will be store in the database along with your encrpyted string field.

```shell
rails generate migration AddEncryptedAndIvToModel encrypted_item:string, encrypted_item_iv:string
```

```ruby
class AddEncryptedAndIvToModel < ActiveRecord::Migration
  def change
    add_column :widgets, :encrypted_item, :string
    add_column :widgets, :encrypted_item_iv, :string
  end
  # no need to index either of these columns
end
```

and don't forget to migrate:

```shell
rake db:migrate
```

Now you need to add two lines to your model:

```ruby
class User < ActiveRecord::Base
  include ActiveRecord::SimpleAttrEncrypted
  encrypted_attribute 'item'
end
```

Note: `item` will be the attribute of the unencrypted string.

Now you can:

```ruby
i = Item.create!  # => true
i.encrypted_item_iv  # => "LGZyLJO1rGGhfH6y+lXojg=="
i.item   # => nil
i.item = "sumptin"  # => "sumptin"
i.encrypted_item  # => "9XxxrnTvfHLkAMVl4PBTJA==\n"
i.save  # => true
i.item  # => "sumptin"
```



Contributing
------------

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
---------

Copyright (c) 2012 Karl Smith. It is free software, and may be redistributed under the terms specified in the LICENSE file.

