#							Copyright 2013 Fabian Fiorotto
class ContraFlor < Flor

 def initialize
	@aceptada = nil
 end

 def puntos
	return @aceptada ? 6 : 4
 end
 
 def self.puede_cantar?(mano,jugador,rexception = false)
	puede = super(mano,jugador,rexception)
	flor = mano.jugadas.any?{ |j| j.instance_of?(Flor) && j.cantor.equipo = jugador.equipo_contrario }
	rais TrucoException , "No se canto flor" if not(flor) && rexception
	return puede & flor
 end

 def pisar(mano)
	#la flor pisa todos los envidos
	mano.jugadas.delete_if{ |e| e.instance_of?(Flor) }
 end

 def nombre
	"Contraflor"
 end

end
