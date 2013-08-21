#							Copyright 2013 Fabian Fiorotto
class Naipe

 attr_reader :palo
 attr_reader :numero

 PALOS = [ :BASTOS , :OROS , :COPAS , :ESPADAS ].freeze
 NUMEROS = ["uno","dos","tres","cuatro","cinco","seis","siete","ocho","nueve","diez","once","doce"].freeze

 def self.[](numero,palo)
   if numero.kind_of? String then
	raise TrucoException , "Formato de naipe incorrecto" unless (numero  =~ /^[0-9]+$/) || (NUMEROS.include? numero)
	numero = numero.to_i if numero  =~ /^[0-9]+$/
	numero = NUMEROS.index(numero) + 1 if NUMEROS.include? numero
   end
   if palo.kind_of? String then
	raise TrucoException , "Formato de naipe incorrecto" unless PALOS.map{ |p| p.to_s }.include? palo.upcase
	palo = palo.upcase.to_sym
   end

   new(numero,palo)
 end

 def initialize(numero,palo)
 	raise TrucoException , "Numero de carta no valido: "+numero.to_s unless numero > 0 && numero <=12
	raise TrucoException , "Nombre de palo incorrecto: "+ palo unless PALOS.include? palo
	@numero = numero ; @palo = palo
 end

 def == (unNaipe)
	return unNaipe.palo == @palo && unNaipe.numero == @numero
 end

 def to_s
	@numero.to_s + " de " + @palo.to_s
 end

 def to_json(*args)
	{"palo" => @palo, "numero" => @numero}.to_json(*args)
 end

 def >(naipe)
	return true if naipe.oculto?
	naipes_especiales = [Naipe[1,:ESPADAS],Naipe[1,:BASTOS],Naipe[7,:ESPADAS],Naipe[7,:OROS]]
	if naipes_especiales.include? naipe || naipes_especiales.include?(self) then
	 if naipes_especiales.include? self then
		i1 = naipes_especiales.index(self)
		i2 = naipes_especiales.index(naipe)
		return i2 == nil || i1 < i2
	 else
		return false
	 end
	end

	case (@numero)
	when 4..12 then 
			case naipe.numero
			when 4..12 then @numero > naipe.numero
			else return false
			end
	when 1..3 then 
			case naipe.numero
			when 4..12 then return true
			else return @numero > naipe.numero
			end
			
	end
 end


 def < (naipe)
	return (not (self == naipe || self > naipe))
 end
 
 def <=>(naipe)
	if(self > naipe) then
	 return 1
	else
	 if @numero == naipe.numero then #aunque no son iguales valen lo mismo en el juego
	  return 0
	 else
	  return -1
	 end
	end
 end

 def inspect 
 	"Naipe[#{@numero.to_s+","+@palo.to_s}]"
 end


 def oculto?
	false
 end

end
