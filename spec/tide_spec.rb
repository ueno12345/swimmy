require "date"
require "time"

test_time1 = Time.new(1,1,1,7,30,0)
test_time2 = Time.new(1,1,1,14,30,0)

RSpec.describe Swimmy::Command::Tide::TideDataMessage do
  tide = Swimmy::Command::Tide::TideDataMessage.new
  
  it "parse date(nil)" do
    expect(
      tide.parse2date(nil)
    ).to eq(Date.today)
  end

  it "parse date(YY-MM-DD)" do
    expect(
      tide.parse2date("100-1-1")
    ).to eq(Date.new(100,1,1))
  end

  it "parse date(MM-DD)" do
    expect(
      tide.parse2date("1-1")
    ).to eq(Date.new(Date.today.year,1,1))
  end

  it "parse date(wrong date)" do
    expect(
      tide.parse2date("2021-4-40")
    ).to eq(nil)
  end

  it "parse date(wrong text)" do
    expect(
      tide.parse2date("error")
    ).to eq(nil)
  end

  it "parse time" do
    expect(
      tide.parse2time("01:01")
    ).to eq(Time.new(1, 1, 1, 1, 1, 0))
  end

  it "parse str(2time)" do
    expect(
      tide.parse2str([test_time1, test_time2])
    ).to eq("07:30, 14:30")
  end

  it "parse str(1time)" do
    expect(
      tide.parse2str([test_time1])
    ).to eq("07:30")
  end

  it "calc maxsp(4time)" do
    expect(
      tide.calc_maxsp_time([test_time1, test_time2], [test_time1 + 3.hour, test_time2 + 2.hour])
    ).to eq([Time.new(1,1,1,9,0,0),Time.new(1,1,1,12,30,0),Time.new(1,1,1,15,30,0)])

    expect(
      tide.calc_maxsp_time([test_time1 + 3.hour, test_time2 + 2.hour], [test_time1, test_time2])
    ).to eq([Time.new(1,1,1,9,0,0),Time.new(1,1,1,12,30,0),Time.new(1,1,1,15,30,0)])
  end

  it "calc maxsp(3time)" do
    expect(
      tide.calc_maxsp_time([test_time1, test_time2], [test_time1 + 3.hour])
    ).to eq([Time.new(1,1,1,9,0,0),Time.new(1,1,1,12,30,0)])

    expect(
      tide.calc_maxsp_time([test_time1 + 3.hour], [test_time1, test_time2])
    ).to eq([Time.new(1,1,1,9,0,0),Time.new(1,1,1,12,30,0)])
  end

  it "calc maxsp(2time)" do
    expect(
      tide.calc_maxsp_time([test_time1], [test_time1 + 3.hour])
    ).to eq([Time.new(1,1,1,9,0,0)])
  end
  
end
