require 'spec_helper'
require 'ey-core/cli'
require 'ey-core/cli/errors'
require 'ey-core/cli/subcommand'
require 'ey-core/cli/recipes'
require 'ey-core/cli/recipes/upload'

describe Ey::Core::Cli::Recipes::Upload do
  set_up_cli

  before(:each) do
    allow_any_instance_of(described_class).
      to receive(:run_chef).
      with(any_args).
      and_return(true)

    allow_any_instance_of(described_class).
      to receive(:upload_recipes).
      with(any_args).
      and_return(true)
  end

  context 'ey-core recipes upload' do
    it 'advises that it is uploading recipes for the current environment' do
      execute

      expect(standard_output).
        to match(/Uploading custom recipes for /)
    end

    it 'uploads the recipes' do
      expect(cli).to receive(:upload_recipes).with(environment, 'cookbooks/')

      execute
    end
    
    context 'successfully' do
      it 'advises that the upload completed' do
        execute

        expect(standard_output).
          to match(/Uploading custom recipes complete/)
      end
    end

    context 'unsuccessfully' do
      before(:each) do
        allow(cli).
          to receive(:upload_recipes).
          with(environment, 'cookbooks/').
          and_raise('big bada boom')
      end

      it 'aborts, advising that the upload failed' do
        status = execute

        expect(error_output).
          to match(/There was a problem uploading the recipes/)

        expect(status).not_to eql(0)
      end
    end
  end

  context 'ey-core recipes upload --apply' do
    arguments '--apply'

    it 'performs a custom chef run' do
      expect(cli).to receive(:run_chef).with('custom', environment)

      execute
    end
  end

  context 'ey-core recipes upload --path /some/path' do
    arguments '--file /some/path'

    it 'uploads the recipes from the given path' do
      expect(cli).to receive(:upload_recipes).with(environment, '/some/path')

      execute
    end
  end
end
