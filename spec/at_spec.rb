RSpec.describe "At command test" do
  before do
    # create dummy data
    @now = Time.parse("2021/4/1 00:00:00 JST")
  end

  it "create occurence from recurrence whose interval is once" do
    recurrence =
      Swimmy::Resource::Recurrence.new(
        "test_command",
        "test_user",
        "test_channel",
        "2021/4/2 00:00:00 JTS",
        Swimmy::Resource::Interval::ONCE,
        "true"
      )
    occurence = Swimmy::Resource::Occurence.new(recurrence, @now)
    expect(occurence.exec_time).to eq(Time.parse("2021/4/2 00:00:00 JST"))
  end

  it "faile to create occurence from finished recurrence" do
    recurrence =
      Swimmy::Resource::Recurrence.new(
        "test_command",
        "test_user",
        "test_channel",
        "2021/3/31 00:00:00 JST",
        Swimmy::Resource::Interval::ONCE,
        "true"
      )
    expect{Swimmy::Resource::Occurence.new(recurrence, @now)}.to raise_error(RuntimeError)
  end

  it "create occurence from recurrence whose interval is everyday" do
    recurrence =
      Swimmy::Resource::Recurrence.new(
        "test_command",
        "test_user",
        "test_channel",
        "2021/3/1 23:00:00 JST",
        Swimmy::Resource::Interval::DAY,
        "true"
      )
    occurence = Swimmy::Resource::Occurence.new(recurrence, @now)
    expect(occurence.exec_time).to eq(Time.parse("2021/4/1 23:00:00 JST"))
  end

  it "faile to create occurence from disabled recurrence" do
    recurrence =
      Swimmy::Resource::Recurrence.new(
        "test_command",
        "test_user",
        "test_channel",
        "2021/3/31 00:00:00 JST",
        Swimmy::Resource::Interval::ONCE,
        "false"
      )
    expect{Swimmy::Resource::Occurence.new(recurrence, @now)}.to raise_error(RuntimeError)
  end

  it "return true from should_execute?" do
    recurrence =
      Swimmy::Resource::Recurrence.new(
        "test_command",
        "test_user",
        "test_channel",
        "2021/4/2 00:00:00 JST",
        Swimmy::Resource::Interval::ONCE,
        "true"
      )

    occurence = Swimmy::Resource::Occurence.new(recurrence, @now)
    expect(occurence.should_execute?(Time.parse("2021/4/3 00:00:00 JST"))).to be true
  end

  it "create occurence 7 times" do
    recurrence =
      Swimmy::Resource::Recurrence.new(
        "test_command",
        "test_user",
        "test_channel",
        "2021/4/1 12:00:00 JST",
        Swimmy::Resource::Interval::DAY,
        "true"
      )

    time = Time.parse("2021/4/1 00:00:00 JST")
    occurence = Swimmy::Resource::Occurence.new(recurrence, time)
    for i in 0..6 do
      expect(occurence.should_execute?(time)).to eq false
      date = time.to_date
      time = Time.parse("#{date.next_day} #{time.strftime("%T %z")}")
      expect(occurence.should_execute?(time)).to eq true
      occurence = Swimmy::Resource::Occurence.new(recurrence, time)
    end
    p occurence.exec_time
    expect(occurence.exec_time).to eq(Time.parse("2021/4/8 12:00 JST"))
  end
end
