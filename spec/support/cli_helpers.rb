def set_up_cli
  let(:argv) {[]}
  let(:stdout) {StringIO.new}
  let(:stderr) {StringIO.new}
  let(:stdin) {StringIO.new}
  let(:kernel) {FakeKernel.new}
  let(:cli) {described_class.new(argv, stdin, stdout, stderr, kernel)}
  let(:execute) {cli.execute!}
  let(:operator) {Object.new}
  let(:environment) {Object.new}
end
