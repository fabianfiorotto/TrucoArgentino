require 'socket'      # Sockets are in standard library

hostname = 'localhost'
port = 2000

s = TCPSocket.open(hostname, port)


Thread.start(s) do |s1| 
	loop{
		puts s1.gets
	 }
end


loop{
  s.puts( gets );
}

s.close 
