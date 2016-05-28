require 'spec_helper'
require 'ey-core/cli'
require 'ey-core/cli/subcommand'
require 'ey-core/cli/accounts'

describe Ey::Core::Cli::Accounts do
  set_up_cli

  context 'ey-core recipes accounts' do
    it 'lists my account ids' do
      execute

      expect(standard_output).to match(/#{Regexp.escape(account.id)}/)
    end

    it 'lists my account names' do
      execute

      expect(standard_output).to match(/#{Regexp.escape(account.name)}/)
    end
  end
end
