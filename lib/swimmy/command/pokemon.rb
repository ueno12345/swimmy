# coding: utf-8
module Swimmy
  module Command
    class Pokemon < Swimmy::Command::Base

      command "pokemon" do |client, data, match|
        client.say(channel: data.channel, text: PokemonInfoDisplayer.new.style)
      end

      help do
        title "pokemon"
        desc "ランダムに選ばれたポケモンの情報を表示します．"
        long_desc "pokemon\n" +
                  "ランダムに選ばれたポケモンの図鑑番号，分類，タイプ，高さ，重さ，説明，公式ポケモン図鑑のURIを表示します．"  
      end

      ################################################################
      ### private inner class

      class PokemonInfoDisplayer

        def style
          pokemoninfo = Service::Pokemoninfo.new.fetch_info

          message = <<~EOS
          --------------------------------------------------
          No#{format("%03d", pokemoninfo[:number])} #{pokemoninfo[:name]}
          #{pokemoninfo[:genus]}
          タイプ  #{pokemoninfo[:type0]} #{pokemoninfo[:type1]}
          たかさ  #{pokemoninfo[:height].to_i / 10.0}m
          おもさ  #{pokemoninfo[:weight].to_i / 10.0}kg
          #{pokemoninfo[:flavor_text]}
          --------------------------------------------------
          https://zukan.pokemon.co.jp/detail/#{pokemoninfo[:number]}
          EOS
        end

      end # class PokemonInfoDisplayer

    end # class Plan
  end # module Command
end # module Swimmy
