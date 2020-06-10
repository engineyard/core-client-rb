# Ey::Core #

Official Engine Yard Core API Ruby client and CLI utility.

## Installation ##

Add this line to your application's Gemfile:

    gem 'ey-core'

And then execute:

    $ bundle

Or install it yourself for ad-hoc or CLI usage:

    $ gem install ey-core

## Usage ##

There are two ways to use this gem: you can install it to use as a client library for writing your own Engine Yard Cloud integrations, or you can use the `ey-core` CLi app to use our curated integrations.

### CLI Usage ###

The CLI app, `ey-core`, is the replacement for the `ey` command that was provided by the now mostly deprecated`engineyard` gem. The old gem is still updated as need be, but is effectively just a slightly different UI for the `ey-core` command.
Like the `git` command, `ey-core` is like a gateway to other commands.

Rather than attempting to provide an exhaustive writeup of all of the commands provided by `ey-core`, this document will instead describe what are likely the most common use cases and leave you to read up on the remainder via the `help` command.

#### Use Case: Getting Help ####

Arguably the most important command in the app is `ey-core help`. Given no arguments, it provides the list of second-level commands avaiable for use. From that point, each argument is expected to be a command from the next level of the hierarchy.

For example, if one wishes to learn about the `servers` second-level command, they would do `ey-core help servers`.

For commands in even deeper levels, one just adds each level of chain after the `help` command. Try this in your terminal: `ey-core help recipes apply`

#### Use Case: Deploying An App ####

The `ey-core deploy` command allows one to deploy a new revision of an existing application in an existing environment. The command itself has several options, some of which may or may not be required depending on several factors. To guarantee the best result and remove a good deal of uncertainty in the process, we've opted to describe a somewhat verbose invocation of the command in this document.

Let's start with some assumptions:

* The name of our Engine Yard account is `MyAwesomeCompany` (you can get a real account name with `ey-core accounts`)
* That account has an environment named `awesome_production` (you can get a real environment name with `ey-core environments`)
* That account has an application named `awesome_app` (you can get a real application name with `ey-core applications`)
* The aforementioned application is already associated with the environment

As mentioned, some of the options for the `deploy` command are optional, and all of the topics discussed in our assumptions are effectively optional. That said, we suggest specifying *all* of these options to ensure absolutely that the proper application is deployed to the proper environment in the proper account.

All that said, to deploy the application to its latest git ref and the same migration command as the last deployment, you would issue the following command:

`$ ey-core deploy --account MyAwesomeCompany --environment awesome_production --app awesome_app`

You can also specify a git ref to use if you'd like to deploy a specific version or branch of the app:

`$ ey-core deploy --account MyAwesomeCompany --environment awesome_production --app awesome_app --ref feature/new-ui`

Say that you want to change the way your migrations are run during the deploy. You can specify the migration command:

`$ ey-core deploy --account MyAwesomeCompany --environment awesome_production --app awesome_app --migrate 'bundle exec rake db:migrate:new_hotness'`

Additionally, if you wish to skip migrations for the deployment, you can do that, too:

`$ ey-core deploy --account MyAwesomeCompany --environment awesome_production --app awesome_app --no-migrate`

Any of the invocations that we've talked about so far will stream the deployment log as it runs. If you'd rather do a fire-and-forget style deployment and check in on it later, you can add the `--no-wait` flag. If, however, you'd like to see even more information spit out during the deploy, you can add the `--verbose` flag.

That's about all there is to deployment so long as you consider the application, environment, and account to be required options. You can read more about any of the commands that we've mentioned in this use case by running the following in your terminal:

* `ey-core help accounts`
* `ey-core help applications`
* `ey-core help deploy`
* `ey-core help environments`

### Client Library Usage ###

Uses [cistern](https://github.com/lanej/cistern) to wrap RESTful resources nicely.

```ruby
client.users.current  # =>
<Ey::Core::Client::User
  id="0037000000uLmCe",
  name="Josh Lane",
  email="jlane@engineyard.com",
  accounts_url="https://api.engineyard.com/users/0037000000uLmCe/accounts"
>
```

#### Authentication ####

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

#### Mock ####

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

#### Testing ####

By default, specs are run against the core mock. In order to run them against awsm mocked mode instead, run `MOCK_CORE=false bundle exec rspec`


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
