module Swimmy
  module Service
    class Pokemoninfo   
      #API仕様:https://pokeapi.co/docs/v2

      def initialize()
        @POKEMON_URI = "https://pokeapi.co/api/v2/pokemon/#{rand(898)}/"
        @POKEMON_SPECIES_URI = JSON.parse(URI.open(@POKEMON_URI, &:read))["species"]["url"]
	@POKEMON_TYPE0_URI = JSON.parse(URI.open(@POKEMON_URI, &:read))["types"][0]["type"]["url"]
	if JSON.parse(URI.open(@POKEMON_URI, &:read))["types"][1] != nil then
	  @POKEMON_TYPE1_URI = JSON.parse(URI.open(@POKEMON_URI, &:read))["types"][1]["type"]["url"]
        end
      end

      def fetch_pokemon_id
	id = JSON.parse(URI.open(@POKEMON_URI, &:read))["id"]
      end

      def fetch_pokemon_name
        i = 0
        while JSON.parse(URI.open(@POKEMON_SPECIES_URI, &:read))["names"][i]["language"]["name"] != "ja-Hrkt" do
          i = i + 1
        end
        name = JSON.parse(URI.open(@POKEMON_SPECIES_URI, &:read))["names"][i]["name"]
      end

       def fetch_pokemon_genus
         i = 0
         while JSON.parse(URI.open(@POKEMON_SPECIES_URI, &:read))["genera"][i]["language"]["name"] != "ja-Hrkt" do
           i = i + 1
         end
         name = JSON.parse(URI.open(@POKEMON_SPECIES_URI, &:read))["genera"][i]["genus"]
       end

      def fetch_pokemon_type0
 	type0 = JSON.parse(URI.open(@POKEMON_TYPE0_URI, &:read))["names"][0]["name"]
      end

      def fetch_pokemon_type1
 	if @POKEMON_TYPE1_URI != nil then
	  type1 = JSON.parse(URI.open(@POKEMON_TYPE1_URI, &:read))["names"][0]["name"]
	end
      end

      def fetch_pokemon_height
	height  = JSON.parse(URI.open(@POKEMON_URI, &:read))["height"]
      end
      
      def fetch_pokemon_weight
	weight = JSON.parse(URI.open(@POKEMON_URI, &:read))["weight"] 
      end

      def fetch_pokemon_flavor_text
        n = 0
	while JSON.parse(URI.open(@POKEMON_SPECIES_URI, &:read))["flavor_text_entries"][n]["language"]["name"] != "ja-Hrkt" do
	  n = n + 1
        end
        flavor_text = JSON.parse(URI.open(@POKEMON_SPECIES_URI, &:read))["flavor_text_entries"][n]["flavor_text"]
      end
	
    end # class Pokemoninfo
  end # module Service
end # module Swimmy
