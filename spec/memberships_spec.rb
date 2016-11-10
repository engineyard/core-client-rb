require 'spec_helper'

describe "memberships" do
  let!(:user)         { create_user }
  let!(:client)       { create_client(user: user) }
  let!(:account)      { create_account(owner: user) }
  let!(:collaborator) { create_user }

  it "should create a membership for an email" do
    email = Faker::Internet.email

    membership = client.memberships.create!(account: account, role: "collaborator", email: email, redirect_url: "http://example.com")

    expect(membership.email).to eq(email)
    expect(membership.user).to be_nil
    expect(membership.role).to eq("collaborator")
    expect(membership.redirect_url).to eq("http://example.com")
  end

  it "should create a membership for a user" do
    membership = client.memberships.create!(account: account, role: "collaborator", user: collaborator)

    expect(membership.email).to eq(collaborator.email)
    expect(membership.user).to eq(collaborator)
    expect(membership.role).to eq("collaborator")
  end

  it "should get a membership" do
    membership = client.memberships.create!(account: account, role: "collaborator", user: collaborator)

    expect(client.memberships.get(membership.id)).to eq(membership)

    expect(account.memberships.size).to eq 1
    expect(account.memberships.first).to eq membership
  end

  it "should be able to accept invites", :mock_only do
    account = client.accounts.create!(owner: user, name: Faker::Name.first_name, type: "normal")
    collaborator  = client.users.create!(name: Faker::Name.name, email: Faker::Internet.email)

    collaborator.reload
    expect(collaborator.accounts.all).to be_empty
    account.reload
    expect(account.users.all.size).to eq 1
    expect(account.users.all.map(&:id)).to eq [user.id]
    expect(account.owners.all.size).to eq 1
    expect(account.owners.all.map(&:id)).to eq [user.id]

    invite = client.memberships.create!(account: account, role: "collaborator", user: collaborator)

    collaborator.reload
    expect(collaborator.accounts.all).to be_empty
    account.reload
    expect(account.users.all.size).to eq 1
    expect(account.users.all.map(&:id)).to eq [user.id]
    expect(account.owners.all.size).to eq 1
    expect(account.owners.all.map(&:id)).to eq [user.id]

    collaborator_client = create_client(user: collaborator)
    membership = collaborator_client.memberships.get(invite.id)
    membership.accept!

    collaborator.reload
    expect(collaborator.accounts.all.size).to eq 1
    expect(collaborator.accounts.first.id).to eq account.id
    account.reload
    expect(account.users.all.size).to eq 2
    expect(account.users.all.map(&:id).sort).to eq [user.id, collaborator.id].sort
    expect(account.owners.all.size).to eq 1
    expect(account.owners.all.map(&:id)).to eq [user.id]
  end

end
