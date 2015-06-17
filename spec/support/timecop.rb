RSpec.configure do |config|
  config.after(:each) { Timecop.return }
  config.before(:each) do |example|
    if time_scale = example.metadata[:scale]
      Timecop.scale(time_scale)
    end
  end
end
