#							Copyright 2013 Fabian Fiorotto
class Flor < Jugada

 attr_accessor :achicado

 def initialize
	@achicado = false
 end

 def puntos
	#si el rival se achica con flor le suma un punto extra.
	#puede haber 2 en un mismo equipo.
	return 3 + (@achicado ? 1 : 0)
 end

 def self.puede_cantar?(mano,jugador,rexception = false)
	no_puede = not(mano.tiene_flor?(jugador))
	raise TrucoException , "No seas hablador al cuete. No tenes flor" if no_puede && rexception	
 
	no_puede |= mano.mesa[0].has_key?(jugador)
	raise TrucoException , "La flor se canta con todos los naipes en la mano" if no_puede && rexception
	
	envidos = mano.jugadas.select{|e| e.instance_of?(Envido)}
	no_puede |= envidos.any?{ |e| e.cantor.equipo == jugador.equipo }
	raise TrucoException , "No podes cantar flor porque ya cantaste envido." if no_puede && rexception
	
	no_puede |= envidos.any?{ |e| e.aceptada != nil}
	raise TrucoException , "No podes cantar flor porque ya se quiso el envido." if no_puede && rexception

	no_puede |= mano.jugadas.any?{ |e| e.kind_of?(Flor) && e.cantor == jugador } #el compañero tambien puede cantar
	raise TrucoException , "Ya la cantaste a la flor." if no_puede && rexception

	no_puede |= mano.jugadas.any?{ |e| 
			e.instance_of?(ContraFlor) || e.instance_of?(FlorAlResto) || 
			(e.instance_of?(Flor) && e.aceptada != nil) 
	}
	raise TrucoException , "Ya se cantó la flor." if no_puede && rexception

	if (self == Flor) then #la contra si se puede
		no_puede |=  mano.jugadas.any?{ |e| e.instance_of?(Flor) && e.cantor.equipo_contrario == jugador.equipo } 
		raise TrucoException , "Ya te cantaron flor. Hechale la contra!." if no_puede && rexception
	end	
		
	return not(no_puede)
 end

 def pisar(mano)
	#la flor pisa todos los envidos
	mano.jugadas.delete_if{ |e| e.kind_of?(Envido) }
 end
 
 def nombre
	"Flor"
 end

end
