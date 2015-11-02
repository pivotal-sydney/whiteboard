shared_examples_for "an action occurring within the standup's timezone" do
  let(:time_zone_name) { double(:time_zone_name) }

  specify do
    expect(Standup).to receive(:find_by).and_return(double(:standup, time_zone_name: time_zone_name))
    expect(Time).to receive(:use_zone).with(time_zone_name)
  end
end
