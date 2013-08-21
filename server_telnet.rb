#							Copyright 2013 Fabian Fiorotto
require 'socket'               # Get sockets from stdlib

bot = Bot.new
server = TCPServer.open(2000)  # Socket to listen on port 2000

if __FILE__ == $0 then
	Thread.start{
		loop{
			bot.eliminar_inactivos
			sleep 5
		}
	}
end

loop { 
	Thread.start(server.accept ) do |client|                         # Servers run forever 
	  id = "telnet//"+client.getpeername
	  jugador = bot.buscar(id)
	  jugador.out = client
	  client.puts("Bienvenido al truco:")
	  loop{
		  result =  bot.input id , client.gets 
		  #client.puts result
		  client.close if result == "exit"
	  }
	end
}
