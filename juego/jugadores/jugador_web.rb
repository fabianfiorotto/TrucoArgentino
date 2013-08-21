#							Copyright 2013 Fabian Fiorotto
class JugadorWeb < Jugador

 attr_accessor :out

 def initialize(*args)
	super(*args)
	@buffer = Array.new
 end

 def server_send(message)
	self.put(message)
 end

 def put(message)
	stream_send( {:message => message}.to_json)
 end

 def sound_alert
	#aca podria enviar el nombre del archivo o algo asi por ahora es solo uno
	stream_send( {:sound => "bell" }.to_json)
 end


def tiempo_turno=(value)
	super(value)
	#avisa cuanto tiempo le queda al turno 0 si ya fue expulsado
	stream_send( {:turno => value}.to_json) if value == 60
	stream_send( {:turno => "stop" }.to_json) if value.nil?
end

def server_change_event(sala,*event_types)
	hash = Hash.new
	event_types.each do |event_type|
		data = case event_type
		when :mesa then
			mesa_data(sala)
		when :naipes then
			@naipes
		when :puntos then
			puntos_data(sala.juego)
		when :botones then
			send_botones(sala.juego)
		end
		hash.merge!({event_type => data})
	end
	stream_send(hash.to_json)

 end

 def send_status(sala)
  juego = sala.juego
  #envia un estado completo del juego. 
  #esto es para cuando se recarga la pagina.
  mesa = mesa_data(sala)
  puntos = puntos_data(juego)
  botones = send_botones(juego)
  if @tiempo_turno != nil then
	turno = @tiempo_turno < 0 ? 0 : @tiempo_turno
  else
	turno = "stop"
  end
  stream_send({:mesa => mesa , :naipes => @naipes  , :puntos =>  puntos , :botones => botones , :turno => turno }.to_json)
 end

 def stream_send(json)
   if @out.nil? then
	@buffer << json
   else
	@out << "data: #{json} \n\n"
   end
 end
 
 def clean_buffer
   while not(@buffer.empty?) && @out != nil do
	 @out << "data: #{@buffer.shift} \n\n"
   end
 end


 def mesa_data(sala)
   mesa = sala.juego.mano.mesa
   jugadores = sala.jugadores.clone
   if sala.num_jugadores == 2 then
      jugadores.reverse! if jugadores.first == self #para que muestre primero al oponente.
   elsif jugadores.include?(self)
		while jugadores.index(self) != 2 do
			jugadores << jugadores.shift
		end
		jugadores = jugadores[0..1].reverse + jugadores[2..3]
   end

   h_mesa = Hash.new
   jugadores.each do |j|
   	h_mesa[j.nombre] =  mesa.map{ |h| h[j] }.compact
   end
  return h_mesa;
 end

 def puntos_data(data)
		n = [ data.numero_puntos(self.equipo) , data.numero_puntos(self.equipo_contrario)]
		s = [ data.puntos(self.equipo) , data.puntos(self.equipo_contrario)]
		return { :n => n , :s => s }
 end


 def send_botones(juego)
	mano = juego.mano
	envido = nil ; flor = nil ;truco = nil 

	if FaltaEnvido.puede_cantar?(mano,self) then
	  envido = "Falta Envido"
	elsif  RealEnvido.puede_cantar?(mano,self) then
	  envido = "Real Envido"
	elsif Envido.puede_cantar?(mano,self) then
	  envido = "Envido"
	end

	if Flor.puede_cantar?(mano,self) then
	  flor = "Flor"
	elsif  ContraFlor.puede_cantar?(mano,self) then
	  flor = "Contraflor"	
	elsif FlorAlResto.puede_cantar?(mano,self) then
	  flor = "Flor al Resto"
	end

	if ValeCuatro.puede_cantar?(mano,self) then
	  truco = "Vale Cuatro"
	elsif ReTruco.puede_cantar?(mano,self) then
	  truco = "Retruco"
	elsif Truco.puede_cantar?(mano,self) then
	  truco = "Truco"
	end

	puntos = mano.falta_cantar_puntos?(self)
	responder = mano.falta_responder?(self)
	#envia los botones que deben mostrarse
	{:envido => envido , :truco => truco , :flor => flor , :responder => responder , :puntos => puntos}
 end
end
