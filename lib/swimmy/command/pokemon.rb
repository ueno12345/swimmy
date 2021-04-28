# coding: utf-8
module Swimmy
  module Command
    class Pokemon < Swimmy::Command::Base

      command "pokemon" do |client, data, match|
        client.say(channel: data.channel, text: PokemonInfoDisplayer.new.formater)
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

        def formater
	  pokemon = pokemoninfo_service

	  num = format("%03d", pokemon.fetch_pokemon_id)
          name = pokemon.fetch_pokemon_name
	  genus = pokemon.fetch_pokemon_genus
	  type0 = pokemon.fetch_pokemon_type0
	  type1 = pokemon.fetch_pokemon_type1
	  height = pokemon.fetch_pokemon_height / 10.0
	  weight = pokemon.fetch_pokemon_weight / 10.0
	  flavor_text = pokemon.fetch_pokemon_flavor_text      

          message = "--------------------------------------------------\n"+
                    "No#{num} #{name}\n"+
                    "#{genus}\n"+
		    "タイプ  #{type0} #{type1}\n"+
		    "たかさ  #{height}m\n"+
		    "おもさ  #{weight}kg\n"+
                    "#{flavor_text}\n"+
                    "--------------------------------------------------\n"+
		    "https://zukan.pokemon.co.jp/detail/#{num}"
          message
        end

        def pokemoninfo_service
	  Service::Pokemoninfo.new
	end

      end # class PokemonInfoDisplayer

    end # class Plan
  end # module Command
end # module Swimmy
