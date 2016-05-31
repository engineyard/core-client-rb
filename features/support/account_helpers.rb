module AccountHelpers
  def account_named(name)
    client.accounts.first(name: name)
  end

  def known_accounts
    begin
      recall_fact(:known_accounts)
    rescue
      memorize_fact(:known_accounts, [])
    end
  end

  def first_account
    known_accounts.first.reload
  end

  def last_account
    known_accounts.last.reload
  end

  def create_account(options={})
    creator = options[:creator] || create_client
    client  = options[:client]

    attributes = options[:account] || {}
    attributes[:type] ||= "beta" # get around awsm billing requirements for tests
    attributes[:name] ||= SecureRandom.hex(6)

    if client
      attributes[:owner] ||= begin
                               client.users.current
                             rescue Ey::Core::Response::NotFound
                             end
    end
    attributes[:owner] ||= create_user(client: client)

    created_account = (client || creator).accounts.create!(attributes)

    if client
      client.accounts.get!(created_account.identity)
    else
      created_account
    end
  end

  def create_user(options={})
    creator = options[:creator] || create_client
    client  = options[:client]

    attributes = options[:user] || {}
    attributes[:name] ||= Faker::Name.name
    attributes[:email] ||= Faker::Internet.email

    created_user = creator.users.create!(attributes)

    if client
      client.users.get!(created_user.identity)
    else
      created_user
    end
  end

  def create_provider(options={})
    account = options[:account] || create_account(options)

    attributes = options[:provider] || {}
    attributes[:type] ||= :aws
    attributes[:provisioned_id] ||= SecureRandom.hex(8)
    attributes[:credentials] ||= case attributes[:type]
                                 when :aws then
                                   {
                                     :instance_aws_secret_id  => SecureRandom.hex(6),
                                     :instance_aws_secret_key => SecureRandom.hex(6),
                                     :aws_secret_id           => SecureRandom.hex(6),
                                     :aws_secret_key          => SecureRandom.hex(6),
                                     :aws_login               => Faker::Internet.email,
                                     :aws_pass                => SecureRandom.hex(6),
                                   }
                                 when :azure then
                                   {
                                   }
                                 end

    account.providers.create!(attributes).resource!
  end
end

World(AccountHelpers)
