# encoding: UTF-8
#							Copyright 2013 Fabian Fiorotto
class Juego

  attr_reader :mano

  def initialize()
	@puntos_buenas = 15
	@puntos = [0,0]
  end

 def repartir(jugadores)
	unless @mano.nil? then
		@puntos[0] += self.mano.puntos(1)
		@puntos[1] += self.mano.puntos(2)
	end
	@mano = Mano.new(jugadores.size)
	naipesJugados = Array.new
	jugadores.each do |jugador|
		jugador.naipes.clear
		3.times{
			r = rand(40)
			r = rand(40) until not naipesJugados.include? r
			naipesJugados << r
			palo = Naipe::PALOS[ r / 10 ]
			numero =  (r % 10) > 6 ? r % 10 + 3  : r % 10 + 1
			jugador.naipes << Naipe[numero,palo]  
		}
	end	
 end

 def jugar(jugador,naipe)
	raise TrucoException , "No tenés esa carta en la mano." unless jugador.naipes.include? naipe
	raise TrucoException , "¿Y si cantas tus puntos mejor? " if @mano.falta_cantar_puntos?(jugador)
	raise TrucoException , "Todavia quedan jugadores sin cantar sus puntos" if @mano.falta_cantar_puntos?	
	raise TrucoException , "Creo que cantaron algo. ¿Queres o no queres?" if @mano.falta_responder?(jugador)
	raise TrucoException , "Espera que respondan." if @mano.falta_cantar_puntos?	
	#es el turno del jugador?
	@mano.jugar(jugador,naipe)
 	jugador.naipes.delete naipe
 end
 
 def cantar(jugador,jugada)
  if jugada.class.puede_cantar?(@mano,jugador,true) then
   jugada.cantor = jugador
   jugada.juego = self
   jugada.pisar(@mano)
   @mano.cantar(jugador,jugada)
  end
 end

 def responder(jugador,querido)
  mano.responder(jugador,querido)
 end
 
 def achicarse(jugador)
	mano.achicarse(jugador)
 end
 
 def cantar_puntos(jugador,puntos,sala)
  mano.cantar_puntos(jugador,puntos,sala)
 end

 def puntos(equipo)
	equipo = equipo.equipo if equipo.kind_of? Jugador
	p = @puntos[equipo-1] + mano.puntos(equipo)
	if p >= @puntos_buenas then
		return (p - @puntos_buenas).to_s + " BUENAS"
	else
		return p.to_s + " MALAS"		
	end
 end

 def en_buenas?(param)
    equipo = param.kind_of?(Jugador) ? param.equipo : param
	p = @puntos[equipo-1] + mano.puntos(equipo)
	return p >= @puntos_buenas
 end

 def numero_puntos(param)
	equipo = param.kind_of?(Jugador) ? param.equipo : param
	p = @puntos[equipo-1] + mano.puntos(equipo)
	if p >= @puntos_buenas then
		return (p - @puntos_buenas)
	else
		return p	
	end
 end
 
 def puntos_faltan(equipo)
	p = @puntos[equipo-1] + mano.puntos(equipo)
	@puntos_buenas * 2 - p
 end
 
 def irse(jugador)
	truco = mano.jugadas.detect{ |j| j.kind_of?(Truco)}
	if truco.nil? then
		jugada = IrseAlMaso.new
		jugada.juego = self
		@mano.cantar(jugador,jugada)
		jugada.equipo_ganador= jugador.equipo_contrario
	else
		truco.aceptada = false if truco.aceptada.nil?
		truco.equipo_ganador = jugador.equipo_contrario
	end
 end

 def terminar_mano(sala = nil)
	mano.terminar(sala)
 end

 def finalizado?
	p1 = @puntos[0] + mano.puntos(1)
	p2 = @puntos[1] + mano.puntos(2)
	return p1 >= @puntos_buenas * 2 || p2 >= @puntos_buenas * 2
 end

end
