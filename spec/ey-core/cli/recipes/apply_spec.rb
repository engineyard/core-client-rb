require 'spec_helper'
require 'ey-core/cli/recipes/apply'

describe Ey::Core::Cli::Recipes::Apply do
  set_up_cli

  before(:each) do
    allow_any_instance_of(described_class).
      to receive(:run_chef).
      with(any_args).
      and_return(true)
  end

  context 'ey-core recipes apply' do
    it 'performs a main chef run' do
      expect(cli).to receive(:run_chef).with('main', environment, {no_wait: nil, verbose: nil, watch: nil})

      execute
      expect(kernel.exit_status).to eql(0)
    end
  end

  context 'ey-core recipes apply --quick' do
    arguments '--quick'

    it 'performs a quick chef run' do
      expect(cli).to receive(:run_chef).with('quick', environment, {no_wait: nil, verbose: nil, watch: nil})
      
      execute
      expect(kernel.exit_status).to eql(0)
    end
  end

end
