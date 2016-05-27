require 'belafonte'
require 'stringio'

def set_up_cli
  let(:argv) {[]}
  let(:stdout) {StringIO.new}
  let(:stderr) {StringIO.new}
  let(:stdin) {StringIO.new}
  let(:kernel) {FakeKernel.new}
  let(:cli) {described_class.new(argv, stdin, stdout, stderr, kernel)}
  let(:execute) {cli.execute!}
  let(:client) {create_client}
  let(:account) {create_account(client: client)}
  let(:app) {create_application(account: account, client: client)}
  let(:environment) {create_environment(account: account, app: app)}

  before(:each) do
    allow_any_instance_of(described_class).
      to receive(:core_operator_and_environment_for).
      with(any_args).
      and_return([client, environment])
  end
end

def arguments(command_line)
  let(:argv) {command_line.split(/\s+/)}
end
