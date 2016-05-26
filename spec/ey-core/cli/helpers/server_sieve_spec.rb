require 'spec_helper'
require 'ey-core/cli/helpers/server_sieve'

module Ey
  module Core
    module Cli
      module Helpers
        describe ServerSieve do
          # Set up individual servers
          let(:app_master_server) {Object.new}
          let(:app_slave_server) {Object.new}
          let(:solo_server) {Object.new}
          let(:db_master_server) {Object.new}
          let(:db_slave_server) {Object.new}
          let(:util_frank_server) {Object.new}
          let(:util_johnny_server) {Object.new}

          # Set up server groups
          let(:all_apps) {[app_master_server, app_slave_server, solo_server]}
          let(:all_db_master) {[db_master_server, solo_server]}
          let(:all_dbs) {[db_master_server, db_slave_server, solo_server]}
          let(:all_utils) {[util_frank_server, util_johnny_server]}
          let(:all_servers) {all_apps + all_dbs + all_utils}

          # Set up the upstream servers API
          let(:servers_api) {Object.new}
          before(:each) do
            allow(servers_api).
              to receive(:all).
              with(no_args).
              and_return(all_servers)

            allow(servers_api).
              to receive(:all).
              with(role: 'app_master').
              and_return([app_master_server])

            allow(servers_api).
              to receive(:all).
              with(role: 'solo').
              and_return([solo_server])

            allow(servers_api).
              to receive(:all).
              with(role: 'app').
              and_return([app_slave_server])

            allow(servers_api).
              to receive(:all).
              with(role: 'db_master').
              and_return([db_master_server])

            allow(servers_api).
              to receive(:all).
              with(role: 'solo').
              and_return([solo_server])

            allow(servers_api).
              to receive(:all).
              with(role: 'db_slave').
              and_return([db_slave_server])

            allow(servers_api).
              to receive(:all).
              with(role: 'db_master').
              and_return([db_master_server])

            allow(servers_api).
              to receive(:all).
              with(role: 'solo').
              and_return([solo_server])

            allow(servers_api).
              to receive(:all).
              with(role: 'db_slave').
              and_return([db_slave_server])

            allow(servers_api).
              to receive(:all).
              with(role: 'util').
              and_return(all_utils)

            allow(servers_api).
              to receive(:all).
              with(role: 'util', name: 'frank').
              and_return([util_frank_server])

          end

          describe '#filtered' do
            let(:options) {{}}
            let(:sieve) {described_class.new(servers_api, options)}
            let(:filtered_servers) {sieve.filtered}

            context 'when all servers are requested' do
              let(:options) {{all: true}}

              it 'is all of the servers known to the server api' do
                all_servers.each do |server|
                  expect(filtered_servers).to include(server)
                end
              end
            end

            context 'when app servers are requested' do
              let(:options) {{app_servers: true}}

              it 'includes app_master servers' do
                expect(filtered_servers).to include(app_master_server)
              end

              it 'includes app (slave) servers' do
                expect(filtered_servers).to include(app_slave_server)
              end

              it 'includes solo servers' do
                expect(filtered_servers).to include(solo_server)
              end
            end

            context 'when db servers are requested' do
              let(:options) {{db_servers: true}}

              it 'includes db_master servers' do
                expect(filtered_servers).to include(db_master_server)
              end

              it 'includes db_slave servers' do
                expect(filtered_servers).to include(db_slave_server)
              end

              it 'includes solo servers' do
                expect(filtered_servers).to include(solo_server)
              end
            end

            context 'when db master is requested' do
              let(:options) {{db_master: true}}

              it 'includes db_master servers' do
                expect(filtered_servers).to include(db_master_server)
              end

              it 'includes solo servers' do
                expect(filtered_servers).to include(solo_server)
              end

              it 'excludes db_slave servers' do
                expect(filtered_servers).not_to include(db_slave_server)
              end
            end

            context 'when all utils are requested' do
              let(:options) {{utilities: 'all'}}

              it 'includes all utility servers' do
                all_utils.each do |server|
                  expect(filtered_servers).to include(server)
                end
              end
            end

            context 'when a specific util is requested' do
              let(:options) {{utilities: 'frank'}}

              it 'includes the requested util' do
                expect(filtered_servers).to include(util_frank_server)
              end

              it 'excludes all other utils' do
                expect(filtered_servers).not_to include(util_johnny_server)
              end
            end

            context 'when multiple filters are active' do
              
              # Release the Kraken!
              let(:options) {
                {
                  all: true,
                  app_servers: true,
                  db_servers: true,
                  db_master: true,
                  utilities: 'all'
                }
              }

              it 'contains no duplicates' do
                all_servers.each do |server|
                  count = filtered_servers.select {|item| item == server}.length
                  expect(count).to eql(1)
                end
              end
            end

            context 'when no filters are provided' do
              it 'is empty' do
                expect(filtered_servers).to be_empty
              end
            end
          end
        end
      end
    end
  end
end
