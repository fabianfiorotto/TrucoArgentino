#							Copyright 2013 Fabian Fiorotto
class Jugada

  attr_accessor :juego #algunas jugadas necesitan conocer el estado del juego. ej. faltaenvido
  attr_accessor :equipo_ganador
  attr_accessor :aceptada
  attr_accessor :cantor


  def puede_cantar?(mano,jugador,rexception = false)
	return true;
  end


  def pisar(mano)
	#quita las jugadas inferiores cuando corresponde.
	#por ejemplo el retruco pisa al truco.	
  end

  def nombre
	return ""
  end

end
