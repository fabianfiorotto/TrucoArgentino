#							Copyright 2013 Fabian Fiorotto
class Jugador
 
	attr_reader :id
	attr_accessor :nombre
	attr_accessor :naipes
	attr_accessor :chats
	attr_accessor :equipo # valores 1 o 2
	attr_accessor :tiempo_turno

	def initialize(id)
		@id = id
		@naipes = Array.new
	end

    def equipo_contrario
	  return nil if @equipo.nil?
	  return @equipo == 1 ? 2 : 1
	end

end
