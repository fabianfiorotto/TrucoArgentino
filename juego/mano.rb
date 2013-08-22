#							Copyright 2013 Fabian Fiorotto
class Mano

 attr_reader :mesa
 attr_reader :puntos_envido
 attr_reader :jugadas
 attr_reader :num_jugadores

 def initialize(num_jugadores)
	@num_jugadores = num_jugadores
	@puntos_envido = Hash.new
	@jugadas = Array.new
	@mesa = Array.new(3){ Hash.new }
	@ronda = 0;
 end


 def jugar(jugador,naipe)
	#aca solo se encarga de dejar el naipe en la mesa es problema del juego si puede o no.
	ronda = 0
	while not @mesa[ronda][jugador].nil? && ronda <= 2
 		ronda +=1
	end
	if ronda <= 2 then
		@mesa[ronda][jugador] = naipe
	end
	#si jugue un naipe y habia flor cantada la doy por ganada.
	flor = @jugadas.detect{ |j| j.equipo_ganador.nil? && j.instance_of?(Flor) && j.cantor.equipo != jugador.equipo }
	unless flor.nil? then
		flor.aceptada = false
		flor.equipo_ganador = jugador.equipo_contrario
	end
	if ronda == 2 && se_comio_la_flor?(jugador) then
		#Tenia flor y no la canto. punto para el contrario
		#si se va sin mostrar los naipes zafa (no es un bug)
		flor = Flor.new
		flor.cantor = jugador
		flor.equipo_ganador = jugador.equipo_contrario
		flor.aceptada = false
		@jugadas.delete_if{|j| j.kind_of?(Envido) && j.equipo_ganador == jugador.equipo} #si ganaste algun envido te los quita. 
		@jugadas << flor
	end 
 end

 def cantar(jugador,jugada)
	jugada.cantor = jugador
	#la flor no tiene respuesta gana el que la canta salvo. Se responde achicandose o con contra.
	jugada.equipo_ganador = jugador.equipo if jugada.instance_of?(Flor)
	@jugadas << jugada
 end

 def cantar_puntos(jugador,puntos,sala = nil)	
	jugada = @jugadas.first
	if jugada.kind_of? Envido then
		raise TrucoException , "Primero tenes que aceptar el envido." unless jugada.aceptada
		raise TrucoException , "Puntos no validos." unless ((0..7).include?(puntos) || (20..33).include?(puntos)) 
	end

	if jugada.kind_of? Flor then
		raise TrucoException , "Puntos no validos." unless ((0..7).include?(puntos) || (20..38).include?(puntos)) 
	end

	if jugada.kind_of?(Envido) || jugada.kind_of?(Flor) then
		raise TrucoException , "Ya cantaste tus puntos" if @puntos_envido.has_key? jugador
		@puntos_envido[jugador] = puntos
		if @puntos_envido.size == @num_jugadores then
			p =	@puntos_envido.values.max
			ganador = ganador_envido(sala)
			equipo_ganador = p == calcular_puntos(ganador) ? ganador.equipo : ganador.equipo_contrario #mentiroso
			#todas las jugadas no solo el primer envido
			@jugadas.select{ |j| j.kind_of?(Envido) || j.kind_of?(Flor) }.each do |j|
						j.equipo_ganador = equipo_ganador
			end	
		end
	end
 end

 def ganador_envido(sala)
	p =	@puntos_envido.values.max
	empate = @puntos_envido.values.inject(0){ |sum, p1 | sum += p == p1 ? 1 : 0 } > 1
	if empate then
		empatados = Array.new
		@puntos_envido.each_pair do | j1 , p1| 
			empatados << j1 if p1 == p
		end
		return sala.desempatar(empatados)
	else
		return @puntos_envido.respond_to?(:key) ? @puntos_envido.key(p) : @puntos_envido.index(p) #compatible 1.8 y >=1.9
	end
 end

 def responder(jugador,querida)
  jugada = @jugadas.detect{|e| e.aceptada.nil?}
  raise TrucoException , "¿Que "+ (querida ? "queres" : "no queres") +" qué? Nadie cantó nada" if jugada.nil?
  raise TrucoException , "No tenés el quiero." if jugada.cantor.equipo == jugador.equipo
  unless querida then
	if jugada.kind_of?(Envido) || jugada.kind_of?(Flor) then
	    @jugadas.select{|e| e.kind_of?(Envido) || e.kind_of?(Envido) }.each do |e|
			e.equipo_ganador = jugador.equipo_contrario 
		end
	else
		jugada.equipo_ganador = jugador.equipo_contrario 
    end
  end
  jugada.aceptada = querida
 end

 def achicarse(jugador)
  flores = @jugadas.select{|e| e.instance_of?(Flor) || e.cantor.equipo == jugador.equipo_contrario}
  raise TrucoException , "No te cantaron flor" if flores.empty?
  flores.each do |flor|
	flor.achicado = true
	flor.aceptada = false
  end
 end


 def estado
   @mesa.map do |e|   
	ganando e
   end
 end

 def finalizada?
	naipes_jugados =  @mesa.inject(0){ |sum, e| sum += e.size }
	if (naipes_jugados == @num_jugadores  * 3) then
	 return true
	end

	rondas = @mesa.map{|e| ganando(e)}

	naipes_jugados =  @mesa[0..1].inject(0){ |sum, e| sum += e.size } #la tercera no importa ahora.

	if (( rondas[0] == 0 && rondas[1] != 0 ) || ( rondas[0] != 0 && rondas[1] == 0 ))  && naipes_jugados == @num_jugadores  * 2 then
		#quedo parda la primera y se define en segunda.
		#si queda parda en segunda gana el que tiene primera
		return true;
	end 

	if rondas[0] != 0 && rondas[0] == rondas[1] && naipes_jugados == @num_jugadores  * 2 then
	 #si alguien gana la primera y la segunda no hace falta jugar la tercera
	 return true
	end 

	if @jugadas.last.kind_of?(Truco) && not( @jugadas.last.aceptada.nil?) && not( @jugadas.last.aceptada ) then
		#un truco no querido finaliza la partida.
		return true
    end

	if @jugadas.last.instance_of? IrseAlMaso then
		return true
	end

	if @jugadas.any?{ |j| j.kind_of?(FlorAlResto) && j.aceptada && j.equipo_ganador != nil } then
		return true
	end

	if @mesa[2].has_value?(Naipe[1,:ESPADAS]) then
		return true
	end
	

	return false
 end 

 def ganador	
	rondas = @mesa.map{|e| ganando(e)}
	#rondas.remove(0)
	equipo1 = rondas.select{ |e| e == 1 }.size
	equipo2 = rondas.select{ |e| e == 2 }.size
	if equipo1 == equipo2 then
	  if rondas[0] != 0 then
		return rondas[0] 
	  else
		#necesito saber quien es mano para resolver un empate completo
		
	  end	  
	end
	return equipo1 > equipo2 ? 1 : 2 
 end

 def ganando(ronda)
	#devuleve el equipo ganador o cero si hay empate

	empate = 0 #valor del empate

	naipes = ronda.values.sort
	
	if(naipes.empty?) then
		return empate
	end

	max = naipes.pop
	ganador = ronda.respond_to?(:key) ? ronda.key(max) : ronda.index(max)
	
	pardas = naipes.select do |n| 
	 j = ronda.respond_to?(:key) ? ronda.key(n) : ronda.index(n)
	 (max <=> n) == 0  && ganador.equipo != j.equipo 
	end

	if pardas.empty? then
	 return ganador.equipo
	else
	 return empate	 
	end
 end


 def calcular_puntos(jugador)
	naipes = jugador.naipes
	naipes << @mesa[0][jugador] if @mesa[0].has_key? jugador #la primer carta que esta en la mesa

	freq = naipes.map{ |e| e.palo }.inject(Hash.new(0)) { |h,v| h[v] += 1 ; h }
	palo = naipes.map{ |e| e.palo }.sort_by { |v| freq[v] }.last
	if freq[palo] == 1 then
	  return naipes.map{ |e| valor(e) }.max
	end
	flor = @jugadas.any?{|j| j.kind_of?(Flor)}
	if freq[palo] == 2 || flor then
		return 20 + naipes.select{ |e| e.palo == palo }.inject(0){|sum,e| sum += valor(e) }	
	end
	#Esta escondiendo la flor!!
	menor = naipes.map{ |e| valor(e) }.min
	return 20 - menor + naipes.select{ |e| e.palo == palo }.inject(0){|sum,e| sum += valor(e) }	
 end

 def tiene_flor?(jugador)
	naipes = jugador.naipes.clone
	@mesa.each do |ronda|
	 naipes << ronda[jugador] if ronda.has_key?(jugador)
	end
	primero = naipes.first.palo
	return naipes.inject(true){ |mismopalo,naipe| mismopalo &= primero == naipe.palo}
 end

 def valor(naipe)
	(1..7).include?(naipe.numero) ? naipe.numero : 0
 end

 def puntos(equipo)
	@jugadas.select{|j| j.equipo_ganador == equipo}.inject(0){ |sum,j| sum += j.puntos }
 end

 def terminar(sala = nil) 
	rondas =  @mesa.map{ |e|   ganando e}
	jugada = @jugadas.detect{|j| j.kind_of?(Truco) || j.instance_of?(IrseAlMaso)} #puede ser retruco	
	
	if rondas == [0,0,0] && jugada.nil? then #triple emparde!!
		maximo_naipe = @mesa[2].values.max
		empardaron = @mesa[2].keys{ |j| (@mesa[2][j] <=> maximo_naipe) == 0 }
		gana = sala.desempatar(empardaron)
		rondas[2] = gana.equipo
	end
	
	freq = rondas.inject(Hash.new(0)) { |h,v| h[v] += 1 if v != 0; h }
	if jugada.nil? then
		jugada = JugarCallados.new
		@jugadas << jugada
	end
	if jugada.equipo_ganador.nil? then
		jugada.equipo_ganador  = freq.key(freq.values.max) 
	end 
		
 end

 def ganadoras
	#devuelve un array con las ganadoras de cada mesa
	@mesa.map do |ronda|
	  naipes = ronda.values.sort
	  max = naipes.last
	  naipes.select do |n| 
		 (max <=> n) == 0
	  end
	end
 end


def falta_cantar_puntos?(jugador = nil)
   @jugadas
	.select{ |j| (j.kind_of?(Envido) || j.kind_of?(Flor)) }
	.all?{ |j|
		j.aceptada && 
		j.equipo_ganador.nil? &&
		(jugador.nil?  || not(@puntos_envido.has_key?(jugador))) 
	} && @jugadas.any?{ |j| (j.kind_of?(Envido) || j.kind_of?(Flor)) }
 end

 def falta_responder?(jugador = nil)
  #con la flor no es necesario responder. Jugar una carta es sinonimo de rechazarla.
  @jugadas.any?{|j| 
	(jugador.nil? || j.cantor.equipo != jugador.equipo) &&
	j.aceptada.nil? && not(j.instance_of?(Flor)) 
  } 
 end

 def se_comio_la_flor?(jugador)
	return tiene_flor?(jugador) && @mesa[2][jugador].instance_of?(Naipe) && #si es oculto no cuenta
	not(@jugadas.any?{ |j| 
		j.instance_of?(ContraFlor) || j.instance_of?(FlorAlResto) ||
		(j.instance_of?(Flor) && (j.cantor == jugador || j.achicado)) 
	})
 end

end
