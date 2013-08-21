#							Copyright 2013 Fabian Fiorotto
class IrseAlMaso < Jugada

 def initialize
	@aceptada = true
 end

 def juego=(value)
	super(value)
	jugadas = value.mano.jugadas
	mano = @juego.mano
 	@puntos = 1 if jugadas.any?{|j| (j.kind_of?(Envido) || j.kind_of?(Flor))}
	@puntos = 1 if mano.mesa[0].size == mano.num_jugadores # si termino la primer ronda.
	@puntos = 2 if @puntos.nil?
 end

 def cantor=(value)
	super(value)
	@equipo_ganador = value.equipo_contrario
 end
 

 def puntos
	@puntos
 end

 def nombre
	"irse al maso"
 end

end
