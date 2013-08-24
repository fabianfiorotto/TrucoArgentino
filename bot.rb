# encoding: UTF-8
#							Copyright 2013 Fabian Fiorotto

class Bot

 def initialize
  @jugadores = Array.new()
 end

 def input(id,mensaje)
	jugador = buscar(id)
	begin 
		if(mensaje[0..0] == '<' || mensaje[0..0] == '>') then
			com = mensaje[1..-1].split(" ")
			command(jugador,com[0],*com[1..-1])
		else
			chat jugador,mensaje
		end
	rescue TrucoException => e
		 jugador.server_send(e.message)
	rescue Exception => e
		 jugador.server_send(e.message+"\n"+e.backtrace.join("\n"))
	end
   return "Echo" 
 end

 def chat(jugador,mensaje)
	sala = buscar_sala(jugador,false)
	if sala.nil? then
		@jugadores.each do |j|
			s = buscar_sala(j,false)
			j.server_send((jugador.nombre.nil? ? "Anonimo" : jugador.nombre )+" dice: "+mensaje) if s.nil? && jugador != j
		end
	else
		sala.jugadores.each do |j| 
			j.server_send((jugador.nombre.nil? ? "Anonimo" : jugador.nombre )+" dice: "+mensaje) if jugador != j
		end
	end
 end

 def command(jugador,com , *args)
	case(com)
	 when "unirse" then unirse(jugador,*args)
	 when "jugar" then jugar(jugador,*args)
	 when "naipes" then mostrar_naipes(jugador)
	 when "mesa" then mostrar_mesa(jugador)
	 when "cantar" then cantar(jugador,*args)
	 when "responder","contestar" then responder(jugador,*args)
	 when "son" then cantar_puntos(jugador,*args)
	 when "puntos" then mostrar_puntos(jugador)
	 when "repartir" then repartir(jugador)
	 when "irse" , "irsealmaso" then irseAlMaso(jugador)
	 when "soy" then nombrar(jugador,*args)
	 #--
	 when "ayuda" then mostrar_ayuda(jugador,*args)
	 when "status" then status(jugador,*args)
	 when "abandonar","salir" then abandonar(jugador)
	 when "exit" then return "exit"
	 when "reload" then reload(*args)
	 when "forzar" then forzar(jugador)
	 when "inspect" then inspect(jugador,*args)
	 else raise TrucoException , "Comando desconocido escriba >ayuda para ver los comandos disponibles"
	end 	
 end

 def unirse(jugador,isala,nombre)
  nsala = $salas.index{ |s| not  s.buscar(jugador).nil? }
  raise TrucoException ,"Ya estas jugando en la sala nº#{nsala+1}. Solo se puede jugar en una sala a la vez." unless nsala.nil?
  raise TrucoException ,"Numero de sala invalido." unless isala =~ /^[0-9]+$/

  jugador.nombre = nombre
  sala = $salas[isala.to_i-1]
  sala.jugadores.each do |j| 
	j.server_send(nombre+" se unio a la sala.")
	j.sound_alert
  end
  sala.agregar jugador
  jugador.server_send("Te uniste a la sala nº#{isala} con el nombre "+nombre)

  if sala.num_jugadores == sala.jugadores.count then
	sala.jugadores.each{|j| j.server_send("Comienza el juego.")}
	sala.comenzar
	sala.jugadores.each do |j|
		mostrar_naipes(j)
		turno(j,sala)
	end  
  else
	mostrar_jugadores_restantes(sala)
  end

 end

 def buscar(id)
	pos = @jugadores.index{|j| j.id == id}
	if pos.nil? then
		jugador = instanciar_jugador(id)
		@jugadores <<  jugador
	else
	 	jugador = @jugadores.at(pos)
	end
	return jugador
 end

 def instanciar_jugador(id)
	#deberia sobreescribirlo los que heredan.
	JugadorTelnet.new(id) 
 end

 def buscar_sala(jugador , re = true)
	sala = $salas.detect{|s|  not  s.buscar(jugador).nil? }
	raise TrucoException , "No estas jugando en una sala. " if sala.nil? && re 
	return sala
 end

 def repartir(jugador)
	juego = Juego.new
	juego.repartir([jugador])
	return jugador.inspect
 end


 def jugar(jugador,numero,de,palo)
	raise TrucoException , "No tenes ningun naipe en la mano" if jugador.naipes.empty?
	naipe = Naipe[numero,palo]
	raise TrucoException , "Los ochos y los nueves son para jugar al chinchon" if naipe.numero == 8 || naipe.numero == 9
	sala = buscar_sala jugador
	alfinalizarmano = proc { |j | j.server_change_event sala , :mesa , :naipes  } 
	sala.jugar(jugador,naipe, &alfinalizarmano) 
	mano_nueva = sala.num_jugadores * 3 == sala.jugadores.inject(0){|sum,j|sum += j.naipes.size}
	jugador.server_change_event sala , :naipes
	sala.jugadores.each do  |j|
		 j.server_send(jugador.nombre + " jugó el "+naipe.to_s) unless jugador.id == j.id
		 j.server_change_event sala , :mesa 
		 if  mano_nueva  then
			#se dieron las cartas de nuevo
			 mostrar_naipes(j)
			j.server_change_event sala , :puntos 
		 end	
		 turno j , sala
	end
	flornegada = sala.juego.mano.jugadas.detect{ |j| j.cantor == jugador && j.instance_of?(Flor) && j.equipo_ganador != jugador.equipo }
	if flornegada != nil then
		sala.jugadores.each do  |j|
			message = j === jugador ? "Negaste la flor. " : (jugador.nombre+ " nego su flor. ")
			j.server_send(message.+"Los puntos son para el oponente.")
		end
	end
	jugador.server_change_event sala , :botones 
 end

 def mostrar_naipes(jugador)
		mensaje = "Tus naipes son: \n"
		jugador.naipes.each do |n|
			mensaje += n.to_s + "\n"
		end
		if jugador.naipes.empty? then
		 mensaje = "Ya no te quedan naipes."
		end
		jugador.server_send(mensaje)
		jugador.server_change_event nil , :naipes
 end

 def turno(jugador,sala = nil)
    sala = buscar_sala(jugador) if sala.nil?
	j = sala.turno
	if j != jugador then
		jugador.server_send  "Es el turno de "+j.nombre
	else
		jugador.server_send  "Te toca jugar a vos."
	end
 end

 def turno_envido(jugador,sala = nil)
    sala = buscar_sala(jugador) if sala.nil?
	j = sala.turno_envido
	j ||= sala.turno_flor
	sala.jugadores.each do |j1|
		if j != j1 then
			j1.server_send "Es el turno de #{j.nombre} para cantar sus puntos"  unless j.nil?
		else
			j1.server_send "Te toca cantar tus puntos."
		end
		if j.nil? then
			turno(j1, sala)
		end
	end
 end


 def mostrar_mesa(jugador)
	#deberia mostar el estado de la mesa
    sala = buscar_sala jugador
	raise TrucoException , "Todavia no ha comenzado el juego" if sala.juego.nil?
	mesa = sala.juego.mano.mesa
	ganadoras = sala.juego.mano.ganadoras
	mensaje = ""
	mesa.each_index do |i|
	  unless mesa[i].empty? then
		 case i
			when 0 then mensaje += "Primera:"
			when 1 then mensaje += "\nSegunda:"
			when 2 then mensaje += "\nTercera:"
		 end	 
		 mesa[i].each_pair do | j,naipe|
			if ganadoras[i].include? naipe then
			  mensaje += "\n(*)"
			else
			  mensaje += "\n( )"
			end
			mensaje += "  #{j.nombre} jugó el #{naipe}"
			
		 end
	  end
	end
	mensaje = "No se han jugado naipes todavia" if mensaje == ""
	jugador.server_send(mensaje)
	#mostrar jugadas
	jugadas = sala.juego.mano.jugadas
	mostrar_turno_envido = false
	jugadas.each do |jugada|
		mensaje = jugada.cantor == jugador ?  "Cantaste " : jugada.cantor.nombre + " cantó " 
		mensaje += jugada.nombre
		if jugada.aceptada != nil then
		   if jugada.aceptada then 	
			if jugada.equipo_ganador != nil then
				if sala.num_jugadores == 4 then
					mensaje += jugador.equipo == jugada.cantor.equipo ? ", ustedes ganaron" : ", ellos ganaron"
				else
					mensaje += jugador == jugada.cantor ?  ", vos ganaste" : ", él ganó"
				end
			elsif jugada.kind_of?(Envido)
				 mostrar_turno_envido = true
			end
		  else
			 mensaje += " pero no fue aceptad@"
		  end
		else
		  mensaje += " pero nadie contestó nada"
		end
		jugador.server_send mensaje
		turno_envido(jugador,sala) if mostrar_turno_envido
	end
	turno(jugador,sala) unless mostrar_turno_envido
	jugador.server_change_event sala , :mesa , :naipes, :puntos, :botones
 end


 def mostrar_puntos(jugador)
	sala = buscar_sala(jugador)
	 mensaje = ""
	if sala.num_jugadores == 2 then
		mensaje += "Mis puntos: " + sala.juego.puntos(jugador.equipo).to_s
	else
		mensaje += "Nuestros puntos: " + sala.juego.puntos(jugador.equipo).to_s
	end
	mensaje += "\nSus puntos: " + sala.juego.puntos(jugador.equipo_contrario).to_s
	jugador.server_send mensaje
	jugador.server_change_event sala , :puntos
 end


 def mostrar_ayuda(jugador,comando = nil)
	jugador.server_send  
%Q(Comandos disponibles:
 unirse: a una sala
 jugar: una carta
 cantar: envido truco o flor
 irse: al maso
 responder: quiero o no quiero
 mesa: muestra estado de la mesa
 naipes: muestra tus naipes)
 end


 def cantar(jugador,canto)
	jugada = case canto
				when "envido" 	then Envido.new
				when "realenvido" then RealEnvido.new
				when "faltaenvido" then FaltaEnvido.new
				when "flor" 	then Flor.new
				when "contraflor" then ContraFlor.new
				when "floralresto" then  FlorAlResto.new
				when "truco" 	then Truco.new
				when "retruco" 	then ReTruco.new
				when "valecuatro" then ValeCuatro.new
			   end

	raise TrucoException , "Que cantaste??" if jugada.nil?
	sala = buscar_sala jugador
	sala.cantar(jugador,jugada)
	sala.jugadores.each do |j| 
		j.server_send(jugador.nombre + " cantó "+jugada.nombre) unless jugador.id == j.id
		j.server_change_event sala , :botones
	end
 end

 def irseAlMaso(jugador)
	sala = buscar_sala jugador
	sala.irse(jugador)
	sala.jugadores.each do |j|
		 j.server_send(jugador.nombre + " se fue al maso ") unless jugador.id == j.id
		 jugador.server_change_event sala , :botones , :mesa , :naipes , :puntos
		 mostrar_naipes(j)
		 turno j , sala
	end	
 end


 def responder(jugador,*args)
	sala = buscar_sala jugador
	if args[0] == "meachico" || (args[0] == "me" && args[1] == "achico") then
		sala.achicarse(jugador)
		return;
	end
	querido = true if args[0] == "quiero" && args.size == 1
	querido = false if args[0] == "no" && args[1] == "quiero" && args.size == 2
	#TODO y el paso y quiero?
	raise TrucoException , "Que??  ¿queres o no queres?" if querido.nil?
	sala.responder(jugador,querido)
	sala.jugadores.each{|j| j.server_send(jugador.nombre + " dice "+ (args * " ") ) unless jugador.id == j.id}
	if  sala.juego.mano.jugadas.empty? then
		#se dieron las cartas de nuevo
		sala.jugadores.each do  |j|
			  mostrar_naipes(j)
			  j.server_change_event sala, :botones , :mesa , :puntos , :naipes 
		end
		turno(jugador,sala)
	else
		sala.jugadores.each{ |j| j.server_change_event sala, :botones }
	end
	if sala.juego.mano.puntos_envido.empty? && sala.juego.mano.jugadas.detect{ |j| j.kind_of?(Envido) && j.aceptada } != nil then
		#si nadie canto sus puntos y hay un envido aceptado entonces tengo que decir quien comienza a cantar.
		turno_envido(jugador,sala)
	end
 end


 def cantar_puntos(jugador,puntos)
  raise TrucoException , "Puntos no validos" unless puntos=~ /^[0-9]+$/ || puntos == "buenas"
  puntos = puntos == "buenas" ? 0 : puntos.to_i 
  sala = buscar_sala jugador
  sala.cantar_puntos(jugador,puntos)
  #--Detectar mentira
	mano = sala.juego.mano
	if mano.puntos_envido.size == sala.num_jugadores then
		p =	mano.puntos_envido.values.max
		ganador = mano.ganador_envido(sala)
		if p != mano.calcular_puntos(ganador) then
			sala.jugadores.each do |j|
				persona = j === jugador ? "Sos" : (jugador.nombre + " es")
				j.server_send( persona + " un mentiroso los puntos son para el contrario")
			end
		end
	end
  #--
  if puntos == 0 then
	sala.jugadores.each{|j| j.server_send( jugador.nombre + " dice que son buenas.") unless jugador.id == j.id}
  else
  	sala.jugadores.each{|j| j.server_send( jugador.nombre + " cantó "+puntos.to_s) unless jugador.id == j.id}
  end
  turno_envido(jugador,sala)
  jugador.server_change_event sala, :botones
 end

 def abandonar(jugador)
  sala = buscar_sala jugador
  sala.jugadores.each{|j| j.server_send( jugador.nombre + " abandona la sala. ") unless jugador.id == j.id }
  sala.abandonar jugador 
  mostrar_jugadores_restantes(sala)
 end

 def nombrar(jugador,nombre)
	sala = buscar_sala(jugador,false)
	raise TrucoException , "Tenés que salir de la sala para cambiarte el nombre" unless sala.nil?
	if @jugadores.include?{|j| j.nombre == nombre} then
		raise TrucoException , "Ya existe un jugador con ese nombre"
	else
		jugador.nombre = nombre
	end
	jugador.server_send("Cambiaste tu nombre por "+ nombre)
 end

 def mostrar_jugadores_restantes(sala)
  	faltan = sala.num_jugadores - sala.jugadores.count
  	mensaje = faltan == 1 ? "Falta solo un jugador para comenzar el juego." : "Faltan #{faltan.to_s} jugadores para comenzar el juego."
  	sala.jugadores.each{ |j| j.server_send( mensaje ) }
 end

 def status(jugador)
	sala = buscar_sala jugador
	unless sala.nil? || sala.juego.nil? then
	 jugador.send_status(sala)
	end
 end

 def eliminar_inactivos
	begin
	$salas.each do |sala|
		if sala.juego != nil then
			jugadores = sala.eliminar_inactivos
			jugadores.each do |jugador|
				  jugador.server_send("Fuiste expulsado de la sala por inactividad")
				  sala.jugadores.each{|j| j.server_send( jugador.nombre + " fue expulsado de la sala por inactividad" ) }
				  mostrar_jugadores_restantes(sala)
			end
		end
	end
	rescue Exception => e
		print e.message
	end
	
 end

=begin #DEBUG
 def forzar(jugador)
	sala = buscar_sala jugador
	forzar_naipes(jugador, Naipe[2,:BASTOS] , Naipe[3,:BASTOS] , Naipe[1,:BASTOS])
	jugador.server_change_event sala , :naipes
 end
 
 
 def forzar_naipes(jugador, *naipes)
  jugador.naipes.clear
  naipes.each do |naipe|
	jugador.naipes << naipe
  end
 end

 def reload(*args)
	load args[0]
 end

 def inspect(jugador,*args)
  	sala = buscar_sala jugador
	jugador.server_send jugador.inspect
 end
=end

end
