# Ey::Core

Official Ruby Engine Yard Core API Client.

## Installation

Add this line to your application's Gemfile:

    gem 'ey-core'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ey-core

## Usage

Uses [cistern](https://github.com/lanej/cistern) to wrap RESTful resources nicely. See [rdoc](https://docbox.engineyard.com/core/branch/master/index.html).

```ruby
client.users.current  # =>
<Ey::Core::Client::User
  id="0037000000uLmCe",
  name="Josh Lane",
  email="jlane@engineyard.com",
  accounts_url="https://api.engineyard.com/users/0037000000uLmCe/accounts"
>
```

### Authentication

* Via Token

```ruby
Ey::Core::Client.new(token: "943662ea7d0fad349eeae9f69adb521d")
```

* Via HMAC

```ruby
Ey::Core::Client.new(
  :auth_id  => "943662ea7d0fad",
  :auth_key => "943662ea7d0fad349eeae9f69adb521d",
  :logger   => Logger.new(STDOUT),
)
```

### Mock

Mock is disabled by default.

```ruby
Ey::Core::Client.mocking? # => false
Ey::Core::Client.mock!
Ey::Core::Client.mocking? # => true
```

Reset the mock

```ruby
Ey::Core::Client.reset!
```

### Testing

By default, specs are run against the core mock. In order to run them against awsm mocked mode instead, run `MOCK_CORE=false bundle exec rspec`

## Releasing

    $ gem install gem-release
    $ gem bump -trv (major|minor|patch) --host https://geminst:XXX@nextgem.engineyard.com/

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
