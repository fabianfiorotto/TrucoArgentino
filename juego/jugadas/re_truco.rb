# encoding: UTF-8
#							Copyright 2013 Fabian Fiorotto
class ReTruco < Truco
 
 def puntos
	return @aceptada ? 3 : 2 
 end
 
 def self.puede_cantar?(mano,jugador,rexception = false)
	 truco = mano.jugadas.detect{|e| e.kind_of? Truco}
	 no_puede = truco.nil?	
	 raise TrucoException , "Nadie cantó truco" if no_puede && rexception
	 no_puede |= truco.nil? || truco.cantor.equipo == jugador.equipo 
	 raise TrucoException , "No tenes el quiero" if no_puede && rexception
	 no_puede |= mano.jugadas.any?{|e| e.instance_of?(ReTruco) || e.instance_of?(ValeCuatro) }
	 raise TrucoException , "El retruco ya esta cantado" if no_puede && rexception
	 return not(no_puede)
 end

 def pisar(mano)
	mano.jugadas.delete_if{ |e| e.kind_of?(Truco) }
 end

 def nombre
	"Retruco"
 end

end
