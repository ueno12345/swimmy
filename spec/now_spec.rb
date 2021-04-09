RSpec.describe Swimmy::Service::Anniversary do
    anniversary = Swimmy::Service::Anniversary.new
    dummy_parsed = Array.new([
        Swimmy::Resource::Anniversary.new("1", "1", "あ"),
        Swimmy::Resource::Anniversary.new("1", "2", "い"),
        Swimmy::Resource::Anniversary.new("1", "2", "う")
    ])
    it "hit a anniversary" do
        allow(anniversary).to receive(:fetch_annual_anniversary_events).and_return(dummy_parsed)

        expect(
            anniversary.get_anniversay_event_titles_by_time(Time.parse("1/1"))
        ).to eq(Array.new(["あ"]))
    end

    it "hit multiple anniversaries" do
        allow(anniversary).to receive(:fetch_annual_anniversary_events).and_return(dummy_parsed)

        expect(
            anniversary.get_anniversay_event_titles_by_time(Time.parse("1/2"))
        ).to eq(Array.new(["い","う"]))
    end

    it "hit no anniversaries" do
        allow(anniversary).to receive(:fetch_annual_anniversary_events).and_return(dummy_parsed)

        expect(
            anniversary.get_anniversay_event_titles_by_time(Time.parse("1/3"))
        ).to eq(Array.new())
    end

    it "parse a anniversary" do
        dummy_fetched = "* [[1月1日|{{0}}1日]] - あ"
        expect(
            anniversary.parse_annual_anniversary_events(dummy_fetched)
        ).to eq(Array.new([Swimmy::Resource::Anniversary.new("1", "1", "あ")]))
    end

    it "parse multiple anniversaries" do
        dummy_fetched = "* [[1月1日|{{0}}1日]] - あ, い"
        expect(
            anniversary.parse_annual_anniversary_events(dummy_fetched)
        ).to eq(Array.new([
            Swimmy::Resource::Anniversary.new("1", "1", "あ"), 
            Swimmy::Resource::Anniversary.new("1", "1", "い")
            ]))
    end

    it "parse included link anniversary" do
        dummy_fetched = "* [[1月1日|{{0}}1日]] - [[あ]]"
        expect(
            anniversary.parse_annual_anniversary_events(dummy_fetched)
        ).to eq(Array.new([Swimmy::Resource::Anniversary.new("1", "1", "あ")]))
    end


end
