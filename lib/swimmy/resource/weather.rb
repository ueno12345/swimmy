#
# 天気を表すオブジェクト
#
# 通常は，Service::Weather が返すオブジェクトとして利用するので，
# 直接このクラスの #new を呼ぶことは，少ない．
#
# weather = Swimmy::Resource::Weather.new(place, rainfalls)
#
# place は，場所を示すオブジェクト．
# rainfalls は，雨量 (mm/h) を表す Array
#
# rainfalls[0] は，現在の雨量
# rainfalls[1] は，10分後の雨量
# ...
# rainfalls[6] は，60分後の雨量
#
# 利用例は，Service::Weather の説明を参照
#
module Swimmy
  module Resource
    class Weather
      def initialize(place, rainfalls)
        @place, @rainfalls = place, rainfalls
      end

      def to_s
        hdr = "#{@place.name}の雨量は:\n"

        pwr = @rainfalls.map.with_index {|power, i|
          "#{i*10}分後は #{rain_power_to_string(power)} (#{power}mm/h)"
        }.join("\n")

        return hdr + pwr
      end

      private

      def rain_power_to_string(power)
        if power == 0
          return "降っていない"
        elsif power < 10
          return "雨"
        elsif power < 20
          return "やや強い雨"
        elsif power < 30
          return "強い雨"
        elsif power < 50
          return "激しい雨"
        elsif power < 80
          return "非常に激しい雨"
        elsif power >= 80
          return "猛烈な雨"
        else
          return "よく分からない"
        end
      end
    end # class Weather
  end # module Resource
end # module Swimmy
