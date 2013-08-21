#							Copyright 2013 Fabian Fiorotto
class RealEnvido < Envido

 def puntos
	if @aceptada then
	 	return 3
	else
		if @reenvite then
			return 0
		else
			return 1
		end
	end
 end


 def self.puede_cantar?(mano,jugador,rexception = false)
	puede = super(mano,jugador,rexception)
	no_puede = not(puede) || mano.jugadas.select{|e| e.instance_of?(RealEnvido) || e.instance_of?(FaltaEnvido) }.size == 1
	raise TrucoException , "Ya no se puede reenvitar mas." if no_puede && rexception
	return not(no_puede)
 end

 def nombre
	"Real Envido"
 end

end
