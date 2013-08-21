#							Copyright 2013 Fabian Fiorotto
class NaipeOculto 
#Es el naipe que se mestra de lomo. Sirve para representar cuando te vas al maso.

 attr_reader :cara

 def palo
	@cara.palo
 end
 
 def numero
	@cara.numero
 end

 def initialize(naipe)
	@cara = naipe
 end

 def < (naipe)
	true
 end

 def > (naipe)
	false
 end


 def to_s
	"?? de ??????"
 end

 
 def oculto?
	true
 end

 def to_json(*args)
	{"palo" => "??????", "numero" => "??" , :oculto => true}.to_json(*args)
 end

end
