require 'spec_helper'
require 'ey-core/cli'
require 'ey-core/cli/errors'
require 'ey-core/cli/subcommand'
require 'ey-core/cli/recipes'
require 'ey-core/cli/recipes/download'

describe Ey::Core::Cli::Recipes::Download do
  set_up_cli

  before(:each) do
    allow_any_instance_of(described_class).
      to receive(:untar).
      with(any_args).
      and_return(true)

    allow_any_instance_of(described_class).
      to receive(:ungzip).
      with(any_args).
      and_return(true)
  end

  context 'ey-core recipes download' do
    context 'with an existing cookbooks directory' do
      before(:each) do
        allow(File).to receive(:exist?).with("cookbooks").and_return(true)
      end

      it 'fails out, advising that the cookbooks already exist locally' do
        status = execute

        expect(error_output).
          to include(
            'Cannot download recipes, cookbooks directory already exists.'
          )

        expect(status).to eql(255)
      end
    end

    context 'with no cookbooks directory' do
      before(:each) do
        allow(File).to receive(:exist?).with("cookbooks").and_return(false)

        allow(environment).
          to receive(:download_recipes).
          and_return('cookbooks.tar.gz')

        allow(cli).
          to receive(:ungzip)

        allow(cli).
          to receive(:untar)
      end

      it 'advises that the cookbooks are being downloaded' do
        execute

        expect(standard_output).to include('Downloading recipes'.green)
      end

      it 'downloads the cookbooks archive' do
        expect(environment).
          to receive(:download_recipes).
          and_call_original

        execute
      end

      it 'advises that the downloaded archive is being extracted' do
        execute

        expect(standard_output).
          to include('Extracting recipes to \'cookbooks/\''.green)
      end

      it 'unarchives the downloaded archive' do
        allow(environment).to receive(:download_recipes).and_return('cookbooks.tar.gz')
        expect(cli).
          to receive(:ungzip).
          with('cookbooks.tar.gz').
          and_return('cookbooks.tar')

        expect(cli).
          to receive(:untar).
          with('cookbooks.tar', './').
          and_return(true)

        execute
      end

      it 'exits cleanly' do
        expect(execute).to eql(0)
      end
    end
  end
end
