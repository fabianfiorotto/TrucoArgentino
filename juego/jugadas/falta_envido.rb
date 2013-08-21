#							Copyright 2013 Fabian Fiorotto
class FaltaEnvido < Envido

 def equipo_ganador=(value)
	super(value)
	#se podria jugar a 2 faltas tambien 
	@puntos = juego.puntos_faltan(value == 1 ? 2 : 1)
 end 

 def puntos
	 @aceptada ? @puntos : 1
 end

 def self.puede_cantar?(mano,jugador,rexception = false)
	puede = super(mano,jugador,rexception)

	no_puede = not(puede) || mano.jugadas.select{|e| e.instance_of?(FaltaEnvido) }.size == 1
	raise TrucoException , "Ya no se puede reenvitar mas." if no_puede && rexception
	return not(no_puede)
 end

 def querida=(value)
  mano.jugadas.delete_if{ |e| e.kind_of?(Envido) } if value
  super(value)
 end
 
 def nombre
	"Falta Envido"
 end

end
