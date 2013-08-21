#							Copyright 2013 Fabian Fiorotto
class FlorAlResto < Flor


 def equipo_ganador=(value)
	super(value)
	@puntos = juego.puntos_faltan(value)
 end 

 def self.puede_cantar?(mano,jugador,rexception = false)
	return mano.tiene_flor?(jugador) &&
	 mano.jugadas.any?{|j|
		j.kind_of?(Flor) && 
		not(j.instance_of?(FlorAlResto)) &&
		j.aceptada.nil? && 
		j.cantor.equipo == jugador.equipo_contrario
	}
 end

 def pisar(mano)
	#la contraflor pisa todos los envidos y las flores
	mano.jugadas.delete_if{ |e| e.kind_of?(Envido) || e.kind_of?(Flor) }
 end

 def puntos
	@aceptada ? @puntos : 1
 end

 def nombre
	"Contra flor al resto"
 end

end
