#							Copyright 2013 Fabian Fiorotto
class Sala
 
  attr_reader :jugadores
  attr_reader :num_jugadores
  attr_reader :juego

  def initialize(jugadores)
	@num_jugadores = jugadores
	@jugadores = Array.new()
	@juego = nil
	@mano = 0
	@turno = @mano
  end

  def agregar(jugador)
	raise TrucoException , "La sala esta llena" unless @jugadores.count < @num_jugadores
	raise TrucoException , "Ya existe un jugador con ese nombre en la sala"	unless @jugadores.index{|j| j.nombre == jugador.nombre}.nil?
	
	equipo1 = @jugadores.select{|j| j.equipo == 1}.size
	equipo2 = @jugadores.select{|j| j.equipo == 2}.size
	jugador.equipo = equipo1 < equipo2 ? 1 : 2
	
	@jugadores << jugador
	if @jugadores.count == @num_jugadores then
	  @juego = Juego.new #comienza un nuevo juego
	end
  end

  def buscar(jugador)
	@jugadores.index{|j| j.id == jugador.id}
  end

  def repartir
	 @juego.repartir(@jugadores)
  end

  def jugar(jugador,naipe , &alfinalizarmano)
	raise TrucoException , "Todavia no ha comenzado el juego" if @juego.nil?
	@juego.jugar(jugador,naipe)	
	
	if juego.mano.finalizada? then
		unless alfinalizarmano.nil? then
			#cambiar esto por un sistema de eventos
			@jugadores.each{ |j| alfinalizarmano.call(j) }
			sleep 2
		end
		terminar
	end
	if @juego.finalizado? then 
		@juego = Juego.new
		repartir
	end
	pasar_turno 
  end

  def cantar(jugador,jugada)
	raise TrucoException , "Todavia no ha comenzado el juego" if @juego.nil?
	@juego.cantar(jugador,jugada)
	pasar_turno 
  end

  def responder(jugador,querido)
	@juego.responder(jugador,querido)
	#puede finalizar por truco no querido
	if juego.mano.finalizada? then
		terminar
	end
	if @juego.finalizado? then 
		@juego = Juego.new
		repartir
	end
	pasar_turno 
  end

  def achicarse(jugador)
	@juego.achicarse.jugador
  end

  def comenzar
		repartir
		pasar_turno
  end

  def terminar
		@juego.terminar_mano(self)
		repartir
		@mano = (@mano == @jugadores.size-1) ? 0 : @mano + 1 
  end

  def desempatar(empatados)
		n1 = @num_jugadores - 1
		indx  = (@mano..n1).detect { |i| empatados.include?(@jugadores[i]) }
		indx |= (0..@mano).detect { |i| empatados.include?(@jugadores[i]) }	
		@jugadores[indx]	  
  end

  def cantar_puntos(jugador,puntos)  
	@juego.cantar_puntos(jugador,puntos,self)
	pasar_turno 
  end

  def turno
	#devulve el jugador que debería jugar. Pero si otro se adelanta la carta es valida.
	nronda =@juego.mano.mesa.index{|r| r.size < @num_jugadores }
	ronda = @juego.mano.mesa[nronda]
	n1 = @num_jugadores - 1
	if nronda == 0 then
	 primero = @mano
	else
	 ganando = @juego.mano.ganadoras[nronda-1]
	 if ganando.size == 1 then
		#el primero que juega es el que gano la mano anterior .
		ronda_anterior = @juego.mano.mesa[nronda-1]
		ganador = ronda_anterior.respond_to?(:key) ? ronda_anterior.key(ganando.first) : ronda_anterior.index(ganando.first)
		primero = @jugadores.index ganador
	 else
		primero = @mano 
	 end
	end 

	(primero..n1).each { |i| return @jugadores[i] unless ronda.has_key? @jugadores[i] }
	(0..primero).each { |i| return @jugadores[i] unless ronda.has_key? @jugadores[i] }
	return @jugadores[@mano]
  end

  def turno_envido
	#turno para cantar el envido.
	puntos = @juego.mano.puntos_envido
	@jugadores.each{ |j| puntos[j] = 0 if @juego.mano.mesa[2][j].instance_of?(NaipeOculto) }
	n1 = @num_jugadores - 1
	return nil if not(@juego.mano.jugadas.any?{|j| ( j.kind_of?(Envido)) && j.aceptada})
	(@mano..n1).each { |i| return @jugadores[i] unless puntos.has_key? @jugadores[i] }
	(0..@mano).each { |i| return @jugadores[i] unless puntos.has_key? @jugadores[i] }
	return nil #ya cantaron todos
  end

  def turno_flor
	#solo cantan los que tienen flor
	puntos = @juego.mano.puntos_envido
	n1 = @num_jugadores - 1
	mano = @juego.mano
	return nil if not(mano.jugadas.any?{|j| j.kind_of?(Flor) && j.aceptada})
	(@mano..n1).each { |i| return @jugadores[i] unless puntos.has_key?(@jugadores[i])  || not(mano.tiene_flor?(@jugadores[i]))}
	(0..@mano).each { |i| return @jugadores[i] unless puntos.has_key?(@jugadores[i]) || not(mano.tiene_flor?(@jugadores[i]))}
	return nil #ya cantaron todos
  end

  def irse(jugador)
	#TODO voy a probar los nuevos naipes
	# ver que pasa por ejemplo con la flor si el tipo oculta sus naipes pero la canto deberia 
	# poder validar igual
	if @num_jugadores == 4 then
		companiero = @jugadores.detect{|j| j.equipo == jugador.equipo && not(jugador === j) }
		if not(companiero.naipes.empty?) then		 
			while not(jugador.naipes.empty?) do
				@juego.mano.jugar(jugador,NaipeOculto.new(jugador.naipes.shift));
			end
		return;
		end
	end
	#TODO elimianar esto despues es solo de prueba!!
	
	@juego.irse(jugador)
	terminar
	if @juego.finalizado? then 
		@juego = Juego.new
		repartir
	end
	pasar_turno 
  end

  def abandonar(jugador)
	@jugadores.delete(jugador)
	@juego = nil
  end

  def eliminar_inactivos
	aeliminar = Array.new
	#esto se llama periodicamente desde el bot.
	@jugadores.select{ |j|  j.tiempo_turno != nil }.each do | jugador |
		jugador.tiempo_turno = jugador.tiempo_turno - 5
		if jugador.tiempo_turno <= - 5 then
			#da 5 segundo de diferencia por el delay
			aeliminar << jugador
			abandonar(jugador)
		end
	end
	return aeliminar
  end

  def pasar_turno
	#este metodo cancela el turno de un jugador y se lo activa al siguiente

	jugada = @juego.mano.jugadas.detect{ | j| j.kind_of?(Envido) && j.aceptada.nil? }
	jugada ||= @juego.mano.jugadas.detect{ | j| j.kind_of?(Truco) && j.aceptada.nil? }
	if jugada != nil then
		@jugadores.each do |jugador|
			if jugador.equipo == jugada.cantor.equipo then
				jugador.tiempo_turno = nil
			else
				jugador.tiempo_turno = 60
			end
		end
	else			
		jugador_turno = turno_envido
		jugador_turno ||= turno_flor
		jugador_turno ||= turno
		@jugadores.each do |jugador|
			jugador.tiempo_turno = nil unless jugador_turno == jugador
		end
		jugador_turno.tiempo_turno = 60 unless jugador_turno.nil?
	end
  end
  
end
