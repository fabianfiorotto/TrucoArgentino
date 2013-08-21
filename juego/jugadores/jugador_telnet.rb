class JugadorTelnet < Jugador
 
 attr_accessor :out

 def server_send(message)
	self.put(message)
 end

 def put(message)	
	if @nombre == "franco"
		message.sub!(/\n/ , "\r\n")
		message << "\r\n"
	end
	out.puts message if @id == "telnet//"+out.getpeername
 end


 def server_change_event(sala,*event_types)
	
 end

 def send_turno(*args)
 end

 def sound_alert(*args)
	#podria usar aplay
 end

end
