module Swimmy
  module Service
    class Pokemoninfo   
      #API仕様:https://pokeapi.co/docs/v2

      def initialize()
        @POKEMON_URI = "https://pokeapi.co/api/v2/pokemon/#{rand(898)}/"
        @POKEMON_SPECIES_URI = JSON.parse(URI.open(@POKEMON_URI, &:read))["species"]["url"]
        @POKEMON_TYPE0_URI = JSON.parse(URI.open(@POKEMON_URI, &:read))["types"][0]["type"]["url"]
        if JSON.parse(URI.open(@POKEMON_URI, &:read))["types"][1] then
	      @POKEMON_TYPE1_URI = JSON.parse(URI.open(@POKEMON_URI, &:read))["types"][1]["type"]["url"]
        end
      end

      def fetch_info
        info ={}

        info[:number] = JSON.parse(URI.open(@POKEMON_URI, &:read))["id"]
        (JSON.parse(URI.open(@POKEMON_SPECIES_URI, &:read))["names"]).each{|names|
        if names["language"]["name"] == "ja-Hrkt" then
          info[:name] = names["name"] 
        end
        }
        (JSON.parse(URI.open(@POKEMON_SPECIES_URI, &:read))["genera"]).each{|genera|
        if genera["language"]["name"] == "ja-Hrkt" then
          info[:genus] = genera["genus"]
        end
        }
        info[:type0] = JSON.parse(URI.open(@POKEMON_TYPE0_URI, &:read))["names"][0]["name"]
        if @POKEMON_TYPE1_URI then
          info[:type1] = JSON.parse(URI.open(@POKEMON_TYPE1_URI, &:read))["names"][0]["name"]
        end
        info[:height] = JSON.parse(URI.open(@POKEMON_URI, &:read))["height"]
        info[:weight] = JSON.parse(URI.open(@POKEMON_URI, &:read))["weight"] 
        (JSON.parse(URI.open(@POKEMON_SPECIES_URI, &:read))["flavor_text_entries"]).each{|flavor_text_entries|
        if flavor_text_entries["language"]["name"] == "ja-Hrkt" then
          info[:flavor_text] = flavor_text_entries["flavor_text"]
        end
        }

        info
      end
	
    end # class Pokemoninfo
  end # module Service
end # module Swimmy
