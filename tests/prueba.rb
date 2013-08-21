require 'securerandom'
require 'json'

# mnt/mint/
require File.expand_path('../bot.rb', File.dirname(__FILE__))
require File.expand_path('../juego/juego_truco.rb', File.dirname(__FILE__))

require 'test/unit'
class TestTruco < Test::Unit::TestCase


 def setup
	@jugador1 = Jugador.new("test//1")
	@jugador1.nombre = "Jugador1"
	@jugador2 = Jugador.new("test//2")
	@jugador2.nombre = "Jugador2"
	@sala = Sala.new(2)
	@sala.agregar @jugador1
	@sala.agregar @jugador2  
	@sala.repartir #aca me da las cartas pero se las puedo sobreescribir
 end

 def forzar_naipes(jugador, *naipes)
  jugador.naipes.clear
  naipes.each do |naipe|
	jugador.naipes << naipe
  end
 end

 def test_envido
	@sala.cantar(@jugador1,Envido.new)
	@sala.responder(@jugador2,false)
	assert_raise( TrucoException ) {
		@sala.cantar(@jugador2,Envido.new)
	}
 end

 def test_realenvido
	mano = @sala.juego.mano
	@sala.cantar(@jugador1,Envido.new)
	assert(not(Envido.puede_cantar?(mano,@jugador1)), "No puede volver a cantar envido")
	assert(not(FaltaEnvido.puede_cantar?(mano,@jugador1)), "No puede volver a cantar envido")
	assert(Envido.puede_cantar?(mano,@jugador2), "Si puede cantar")
	@sala.cantar(@jugador2,Envido.new)
	@sala.responder(@jugador1,true)
	assert(not(RealEnvido.puede_cantar?(mano,@jugador1)), "ya dio el quiero")
 end
 
 def test_flor
 	forzar_naipes(@jugador1, Naipe[2,:BASTOS] , Naipe[3,:BASTOS] , Naipe[10,:BASTOS] )
	forzar_naipes(@jugador2, Naipe[11,:BASTOS] , Naipe[12,:BASTOS] , Naipe[5,:BASTOS] )
	mano = @sala.juego.mano
	assert(not(FlorAlResto.puede_cantar?(mano,@jugador1)), "No puede cantar flor al resto si no hay flor cantada")
	@sala.cantar(@jugador1,Envido.new)
	assert(not(Flor.puede_cantar?(mano,@jugador1)), "No puede cantar flor si canto envido")
	assert(Flor.puede_cantar?(mano,@jugador2), "Sí puede cantar antes de responder al envido")
	@sala.responder(@jugador2,false)
	assert(not(Flor.puede_cantar?(mano,@jugador2)), "No puede cantar flor si respondio un envido")
	@sala.irse(@jugador2)
	forzar_naipes(@jugador1, Naipe[2,:BASTOS] , Naipe[3,:BASTOS] , Naipe[10,:BASTOS] )
	forzar_naipes(@jugador2, Naipe[11,:BASTOS] , Naipe[12,:BASTOS] , Naipe[5,:BASTOS] )
	mano = @sala.juego.mano
	@sala.cantar(@jugador1, Flor.new)
	assert(FlorAlResto.puede_cantar?(mano,@jugador2), "Puede cantar flor al resto cuando hay flor cantada")
 end

 def test_truco
	@sala.cantar(@jugador1,Truco.new)
	assert_nothing_raised(TrucoException){
		@sala.responder(@jugador2,false)
	}
	assert(@sala.juego.numero_puntos(@jugador1.equipo) !=  @sala.juego.numero_puntos(@jugador2.equipo),"Deberia ir ganando el jugador 1")		
 end
 
 def test_faltaenvido
	forzar_naipes(@jugador1, Naipe[2,:BASTOS] , Naipe[3,:BASTOS] , Naipe[10,:ESPADAS] )
	forzar_naipes(@jugador2, Naipe[11,:BASTOS] , Naipe[12,:BASTOS] , Naipe[3,:ESPADAS] )
	
	@sala.cantar(@jugador1,Envido.new)
	@sala.cantar(@jugador2,Envido.new)
	@sala.cantar(@jugador1,RealEnvido.new)
	@sala.responder(@jugador2, true)
	@sala.cantar_puntos(@jugador1, 25)
	@sala.cantar_puntos(@jugador2, 20)
	@sala.irse(@jugador2)		
	assert(@sala.juego.numero_puntos(@jugador1) == 8, "Puntos acumulados deberian ser 2+2+3+1 = 8")

	forzar_naipes(@jugador2, Naipe[2,:BASTOS] , Naipe[3,:BASTOS] , Naipe[10,:ESPADAS] )
	forzar_naipes(@jugador1, Naipe[11,:BASTOS] , Naipe[12,:BASTOS] , Naipe[3,:ESPADAS] )
	@sala.cantar(@jugador2,FaltaEnvido.new)
	@sala.responder(@jugador1,true)
	@sala.cantar_puntos(@jugador2, 25)
	@sala.cantar_puntos(@jugador1, 20)
	assert((@sala.juego.numero_puntos(@jugador2) == 7) && @sala.juego.en_buenas?(@jugador2) , "Puntos por  la falta deberian ser ")
 end

 def test_empardes
	forzar_naipes(@jugador2, Naipe[2,:BASTOS] , Naipe[3,:BASTOS] , Naipe[10,:ESPADAS] )
	forzar_naipes(@jugador1, Naipe[2,:ESPADAS] , Naipe[3,:ESPADAS] , Naipe[10,:BASTOS] )
	jugador_mano1 = @sala.turno
	@sala.cantar(@jugador1,Envido.new)
	@sala.responder(@jugador2,true)
	@sala.cantar_puntos(@jugador1,25)
	@sala.cantar_puntos(@jugador2,25)
	@sala.irse(@jugador2)
	assert(@sala.juego.numero_puntos(jugador_mano1) >= 2 , "El mano deberia haber ganado.")
	jugador_mano2 = @sala.turno
	assert(not(jugador_mano2 == jugador_mano1) , "Deberia ser otro el mano")
	forzar_naipes(@jugador2, Naipe[2,:BASTOS] , Naipe[3,:BASTOS] , Naipe[10,:ESPADAS] )
	forzar_naipes(@jugador1, Naipe[2,:ESPADAS] , Naipe[3,:ESPADAS] , Naipe[10,:BASTOS] )
	@sala.cantar(@jugador1,Envido.new)
	@sala.responder(@jugador2,true)
	@sala.cantar_puntos(@jugador1,25)
	@sala.cantar_puntos(@jugador2,25)
	@sala.irse(@jugador2)
	assert(@sala.juego.numero_puntos(jugador_mano2) >= 2 , "El mano deberia haber ganado.")
 end
 
 def test_realenvido2
	mano = @sala.juego.mano
	@sala.cantar(@jugador1,Envido.new)
	@sala.cantar(@jugador2,RealEnvido.new)
	assert(not(mano.falta_cantar_puntos?(@jugador1)), "No puede cantar los puntos porque hay un envido no querido")
	@sala.responder(@jugador1,true)
	assert(mano.falta_cantar_puntos?(@jugador1), "Ahora si deberia tener que cantar puntos")
 end

 def test_reenvite
	mano = @sala.juego.mano
	@sala.cantar(@jugador1,Envido.new)
	@sala.cantar(@jugador2,RealEnvido.new)
	realenvido = @sala.juego.mano.jugadas.detect{|j| j.instance_of?(RealEnvido)}
	assert(realenvido.reenvite?, "El realenvido deberia estar marcado como reenvite")

	@sala.responder(@jugador1,false)

	@sala.irse(@jugador2)
	assert(@sala.juego.numero_puntos(@jugador2) == 2 , "Los reenvites no quieridos no suman puntos")
 end 
 
 def test_flortruco
	forzar_naipes(@jugador1, Naipe[2,:BASTOS] , Naipe[3,:BASTOS] , Naipe[1,:BASTOS] )
	forzar_naipes(@jugador2, Naipe[2,:ESPADAS] , Naipe[3,:ESPADAS] , Naipe[10,:BASTOS] )
	@sala.cantar(@jugador1, Flor.new)
	@sala.jugar(@jugador2,Naipe[2,:ESPADAS])
	@sala.cantar(@jugador1, Truco.new)
	@sala.responder(@jugador2,true)
	mano = @sala.juego.mano
	assert(not(mano.falta_cantar_puntos?(@jugador2)), "ya rechazo la flor")
 end
 
 def test_contraflor
	mano = @sala.juego.mano
	forzar_naipes(@jugador1, Naipe[2,:BASTOS] , Naipe[3,:BASTOS] , Naipe[1,:BASTOS] )
	forzar_naipes(@jugador2, Naipe[2,:ESPADAS] , Naipe[3,:ESPADAS] , Naipe[10,:ESPADAS] )
	@sala.cantar(@jugador1,Flor.new)
	assert(not(Flor.puede_cantar?(mano,@jugador2)),"no deberia poder responder con flor")
	assert(ContraFlor.puede_cantar?(mano,@jugador2,true),"deberia poder responder con la contra")
	@sala.cantar(@jugador2, ContraFlor.new)
	assert(not(Flor.puede_cantar?(mano,@jugador1)),"no deberia poder cantar flor de nuevo con la flor")
	assert(FlorAlResto.puede_cantar?(mano,@jugador1),"deberia poder cantar flor al resto")

	@sala.irse(@jugador1)
 end

 def test_empates
	forzar_naipes(@jugador1, Naipe[2,:BASTOS] , Naipe[3,:BASTOS] , Naipe[10,:ESPADAS] )
	forzar_naipes(@jugador2, Naipe[2,:ESPADAS] , Naipe[3,:ESPADAS] , Naipe[10,:BASTOS] )
	jugador_mano1 = @sala.turno
	@sala.jugar(@jugador1,Naipe[2,:BASTOS])
	@sala.jugar(@jugador2,Naipe[2,:ESPADAS])
	
	@sala.jugar(@jugador1,Naipe[3,:BASTOS])
	assert_nothing_raised(TrucoException){
		@sala.jugar(@jugador2,Naipe[3,:ESPADAS])
	}
	
	@sala.jugar(@jugador1,Naipe[10,:ESPADAS])
	assert_nothing_raised(TrucoException){
		@sala.jugar(@jugador2,Naipe[10,:BASTOS])
	}	
	assert(@sala.juego.numero_puntos(jugador_mano1) == 1 , "El mano deberia haber ganado.")
 end 
 
end
