#							Copyright 2013 Fabian Fiorotto
class Truco < Jugada

 def initialize

 end

 def puntos
	return @aceptada ? 2 : 1
 end


 def self.puede_cantar?(mano,jugador,rexception = false)
	puede = not(mano.jugadas.any?{|e| e.kind_of? Truco})
	raise TrucoException , "El truco ya esta cantado" if not(puede) && rexception
	return puede
 end

 def nombre
	"Truco"
 end

 def pisar(mano)
	flor = mano.jugadas.detect{ | j| j.instance_of?(Flor) ||  (j.cantor.equipo != self.cantor.equipo) }
	flor.aceptada = false unless flor.nil?
 end
 
end
