# Scope-Filter

scope_filter is a filter- and search-library for ActiveRecord models using scopes.

You can define the filterable and sortable scopes and fields and filter records with the `scope_filter` method. 

This lib is fully compatible with [kaminari](https://github.com/amatsuda/kaminari) or [will_paginate](https://github.com/mislav/will_paginate) as it uses ActiveRecord scopes only.

## Install

add the following line to your Gemfile

`gem 'scope_filter'`

or install it via rubygems

`gem install scope_filter`

## Usage

Include `ScopeFilter::ActiveRecord` in your model and define the filterable and sortable fields with the `configure_scope_filter` method.

You can configure the filter with the following methods:

- `add_scope` and `add_scopes`: makes scopes of your model searchable (pass a boolean argument at the end to define if the scopes expect a parameter, defaults to false)
- `eq`: equal comparator
- `g`, `gt`: greater and greater than comparator
- `l`, `lt`: less and less than comparator
- `like`, `ilike`: like and ilike than comparator
- `null`, `not_null`: is null and is not null than comparator
- `sortable`: fields the resultset may be sorted by

The first argument defines the name of the filter parameter. You can define arbitrary filter fields, i.e.:

`config.like :firstname_ends_with, :field => 'firstname', :pattern => lambda { |v| "%#{v}" }`

### Example

```ruby
class Person < ActiveRecord::Base
  include ScopeFilter::ActiveRecord
  
  scope :dwarf,      where('age > ? AND height < ?', 16, 150)
  scope :bastard,    where('lastname IN (?)', %w(Snow Sand Rivers))
  scope :highborn,   where('lastname IN (?)', %w(Lannister Stark Targaryen Martell))
  scope :older_than, lambda { |age| where('age > ?', age) }
  scope :dead,       where('date_of_death IS NOT NULL')
  scope :dragon,     where('lastname = ?', 'Targaryen')
  
  configure_scope_filter do |config|
    config.add_scopes :dwarf, :bastard, :dead, :highborn
    config.add_scope  :older_than, true
    config.like       :firstname
    config.eq         :knight
    config.like       :firstname_ends_with, :field => 'firstname', :pattern => lambda { |v| "%#{v}" }
    config.null       :alive, :field => 'date_of_death'
    config.sortable   :lastname, :firstname
  end

end
```

use the `scope_filter` method to filter records, i.e.

```ruby
Person.scope_filter(:highborn => true, :knight => true, :_sort => 'lastname_desc')
```

which will return all highborn knights ordered descending by lastname.

Or use the params hash:

```ruby
Person.scope_filter(params[:filter])
```

## Author

[Lars Kuhnt](http://www.github.com/larskuhnt)
Copyright (c) 2011

## License

Published under the MIT License.

See [LICENSE](LICENSE) for details.


