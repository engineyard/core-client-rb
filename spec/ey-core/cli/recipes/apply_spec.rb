require 'spec_helper'
require 'stringio'
require 'belafonte'
require 'ey-core/cli'
require 'ey-core/cli/subcommand'
require 'ey-core/cli/recipes'
require 'ey-core/cli/recipes/apply'

describe Ey::Core::Cli::Recipes::Apply do
  let(:argv) {[]}
  let(:stdout) {StringIO.new}
  let(:stderr) {StringIO.new}
  let(:stdin) {StringIO.new}
  let(:kernel) {FakeKernel.new}
  let(:apply) {described_class.new(argv, stdin, stdout, stderr, kernel)}
  let(:execute) {apply.execute!}
  let(:operator) {Object.new}
  let(:environment) {Object.new}

  before(:each) do
    allow_any_instance_of(described_class).
      to receive(:core_operator_and_environment_for).
      with(any_args).
      and_return([operator, environment])

    allow_any_instance_of(described_class).
      to receive(:run_chef).
      with(any_args).
      and_return(true)
  end

  context 'ey-core recipes apply --main' do
    let(:argv) {['--main']}

    it 'performs a main chef run' do
      expect(apply).to receive(:run_chef).with('main', environment)

      execute
      expect(kernel.exit_status).to eql(0)
    end
  end

  context 'ey-core recipes apply --custom' do
    let(:argv) {['--custom']}

    it 'performs a custom chef run' do
      expect(apply).to receive(:run_chef).with('custom', environment)
      
      execute
      expect(kernel.exit_status).to eql(0)
    end
  end

  context 'ey-core recipes apply --quick' do
    let(:argv) {['--quick']}

    it 'performs a quick chef run' do
      expect(apply).to receive(:run_chef).with('quick', environment)
      
      execute
      expect(kernel.exit_status).to eql(0)
    end
  end

  context 'ey-core recipes apply --full' do
    let(:argv) {['--full']}

    it 'performs both a main and a custom chef run' do
      expect(apply).to receive(:run_chef).with('main', environment)
      expect(apply).to receive(:run_chef).with('custom', environment)
      
      execute
      expect(kernel.exit_status).to eql(0)
    end
  end

  context 'attempting to use more than one run type flag' do
    let(:run_type_flags) {['--main', '--custom', '--quick', '--full']}
    let(:combinations) {run_type_flags.combination(2).to_a}

    it 'aborts with advice regarding the run type flags' do
      expect(kernel).
        to receive(:abort).
        with('Only one of --main, --custom, --quick, and --full may be specified.').
        and_call_original.
        exactly(combinations.length).
        times

      combinations.each do |combination|
        attempt = described_class.new(combination, stdin, stdout, stderr, kernel)

        expect(attempt.execute!).not_to eql(0)



      end
    end
  end
end
