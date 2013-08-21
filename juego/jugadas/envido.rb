#							Copyright 2013 Fabian Fiorotto
class Envido < Jugada

 attr_writer :reenvite
 def reenvite? 
	@reenvite
 end

 def initialize
	@reenvite = false
 end

 def puntos
	if @aceptada then
	 	return 2
	else
		if @reenvite then
			return 0
		else
			return 1
		end
	end
 end


 def self.puede_cantar?(mano,jugador,rexception = false)
	no_puede = false
	envidos = mano.jugadas.select{|e| e.instance_of?(Envido)}

	no_puede |= mano.mesa[0].has_key?(jugador) &&  envidos.empty?
	raise TrucoException , "El envido se canta con todos los naipes en la mano" if no_puede && rexception

	envido = envidos.last
	no_puede |= envido != nil && envido.equipo_ganador != nil
	raise TrucoException , "Ya se jugó el envido" if no_puede && rexception

	no_puede |= envido != nil && envido.aceptada
	raise TrucoException , "Ya lo aceptaste al envido" if no_puede && rexception

	no_puede |= envido != nil && envido.cantor.equipo == jugador.equipo
	#para los reenvites tengo que fijarme quien tiene el quiero
	raise TrucoException , "No tenes el quiero" if no_puede && rexception

	no_puede |= mano.jugadas.any?{|e| e.instance_of?(RealEnvido)}
	raise TrucoException , "Ya no se puede reenvitar mas" if no_puede && rexception

	no_puede |= envidos.size >= 2 && self == Envido
	raise TrucoException , "Ya no se puede reenvitar mas" if no_puede && rexception

	no_puede |= mano.jugadas.any?{|e| e.kind_of?(Flor)}
	raise TrucoException , "Cantaron flor" if no_puede && rexception

	return not(no_puede)
 end


 def pisar(mano)
	#si se canta envido se aceptan todos los envidos anteriores.
	mano.jugadas.select{|j| j.kind_of? Envido}.each do |envido|
	 @reenvite = true
	 envido.aceptada = true
	end
 end
 
 def nombre
	return "Envido"
 end
 
end
