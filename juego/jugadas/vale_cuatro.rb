#							Copyright 2013 Fabian Fiorotto
class ValeCuatro < Truco
 
 def puntos
	return @aceptada ? 4 : 3 
 end
 
 def self.puede_cantar?(mano,jugador,rexception = false)
	 retruco = mano.jugadas.detect{|e| e.kind_of? ReTruco}
	 no_puede = retruco.nil?
	 raise TrucoException , "Nadie cantó retruco" if no_puede && rexception
	 no_puede |= retruco.nil? || retruco.cantor.equipo == jugador.equipo
	 raise TrucoException , "No tenes el quiero" if no_puede && rexception
	 no_puede |= mano.jugadas.any?{|e| e.kind_of? ValeCuatro}
	 raise TrucoException , "El vale cuatro ya esta cantado" if no_puede && rexception
	 return not(no_puede)
 end

 def pisar(mano)
	mano.jugadas.delete_if{ |e| e.kind_of?(Truco) }
 end


 def nombre
	"Vale cuatro"
 end
end
