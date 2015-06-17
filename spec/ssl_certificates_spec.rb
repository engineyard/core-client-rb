require 'spec_helper'

describe 'as a user' do
  let!(:hmac_client) { create_hmac_client }
  let!(:user)        { hmac_client.users.create!(name: Faker::Name.name, email: Faker::Internet.email) }
  let(:client)       { create_client }
  let(:account)      { client.accounts.create!(owner: user, name: Faker::Name.first_name) }

  let(:random_cert) do
    key  = OpenSSL::PKey::RSA.new(1024)
    name = OpenSSL::X509::Name.parse("/CN=example.org")

    # NB: the order in which these attributes are set seems to be
    # important in making it self-signed and not just a certificate
    # with a mystery issuer. It's not clear which attributes have
    # the ordering requirement.
    cert = OpenSSL::X509::Certificate.new
    cert.version    = 2
    cert.serial     = Time.now.tv_sec            # monotonically increasing
    cert.not_before = Time.now - (7 * 24 * 60 * 60) # allow for plenty of clock skew
    cert.not_after  = Time.now + (10 * 356 * 24 * 60 * 60) # allow for plenty of clock skew
    cert.subject    = name
    cert.public_key = key.public_key
    cert.issuer     = name

    cert.sign(key, OpenSSL::Digest::SHA1.new)

    { cert: cert.to_pem, key: key.to_pem }
  end

  def create_ssl_certificate(params={})
    params = {
      account: account,
      name: "#{Faker::Name.first_name}_cert",
    }.merge!(params)

    unless params[:self_sign]
      params[:public_certificate] = random_cert[:cert]
      params[:private_key] = random_cert[:key]
    end

    client.ssl_certificates.create!(params).resource!
  end

  it "can create an ssl certificate" do
    ssl_certificate = create_ssl_certificate
    expect(ssl_certificate.id).to be
    expect(ssl_certificate.public_certificate.strip).to eq(random_cert[:cert].strip)
    expect(ssl_certificate.private_key.strip).to eq(random_cert[:key].strip)
  end

  it "create a self signed certificate" do
    ssl_certificate = create_ssl_certificate(name: "self-signed", self_sign: true)

    expect(ssl_certificate.certificate_chain).to eq(nil)
    expect(ssl_certificate.id).to be
    expect(ssl_certificate.name).to eq("self-signed")
    expect(ssl_certificate.self_signed).to eq(true)
    expect(ssl_certificate.private_key.strip).not_to eq(random_cert[:key].strip)
    expect(ssl_certificate.public_certificate.strip).not_to eq(random_cert[:cert].strip)
  end

  it "can get a created ssl certificate" do
    ssl_certificate = create_ssl_certificate
    ssl_certificate = client.ssl_certificates.get(ssl_certificate.id)
    expect(ssl_certificate).to be
  end

  it "can update an ssl certificate", focus: true do
    ssl_certificate = create_ssl_certificate
    ssl_certificate.name = "changed"
    ssl_certificate.save!

    ssl_certificate = client.ssl_certificates.get(ssl_certificate.id)
    expect(ssl_certificate.name).to eq("changed")
  end

  it "can destroy a ssl certificate" do
    ssl_certificate = create_ssl_certificate
    expect { ssl_certificate.destroy }.to change { client.ssl_certificates.all.size }.by(-1)
    expect(client.ssl_certificates.get(ssl_certificate.id).deleted_at).to_not be(nil)
  end

  describe "from account" do
    it "can get a list of ssl certificates for an account" do
      create_ssl_certificate

      other_account = client.accounts.create!(owner: user, name: Faker::Name.first_name)
      create_ssl_certificate(account: other_account, name: "other")

      expect(account.ssl_certificates.size).to eq(1)
    end
  end
end
