#							Copyright 2013 Fabian Fiorotto
require 'sinatra';
require 'erb'
require 'securerandom'
require 'json'

require File.expand_path('bot.rb', File.dirname(__FILE__))
require File.expand_path('juego/juego_truco.rb', File.dirname(__FILE__))

# mnt/mint/
require File.expand_path('bot.rb', File.dirname(__FILE__))
#---------
class BotWeb < Bot
	  
  def instanciar_jugador(id)
	JugadorWeb.new(id) 
  end

 end
##_

class TrucoArgentino < Sinatra::Base

  configure do
	Thread.start{
		loop{
			$botweb.eliminar_inactivos unless $botweb.nil?
			sleep 5
		}
	}
  end


  enable :sessions
  set server: 'thin', connections: {}
  #set :environment, :production

  before do   # Before every request, make sure they get assigned an ID.
    session[:session_id] ||= SecureRandom.uuid
    session[:arte_naipes] ||= "gabriel_fuentes"
	$botweb = BotWeb.new if $botweb.nil?
  end

  set :static, true
  set :public_dir , File.dirname(__FILE__) + '/static'

  get '/' do
	@salas = $salas
	id = "web//"+session[:session_id]
	jugador = $botweb.buscar(id)
	nsala = @salas.index{ |s| not  s.buscar(jugador).nil? }
	if nsala then
		redirect '/truco'
	else
		erb :salas
	end  
  end


  get '/truco' do
  	id = "web//"+session[:session_id]
	jugador = $botweb.buscar(id)
	@sala = $botweb.buscar_sala(jugador,false)
	if @sala.nil? then
		redirect '/'
	else
		@artes = {
			"heraclio_fournier" => "Heraclio Fournier" ,  
			"justo_rodero" => "Justo Rodero" ,
			"gabriel_fuentes" => "Gabriel Fuentes" ,
		}
		erb :truco
	end  
  end


  post '/console_send' do
	id = "web//"+session[:session_id]
	$botweb.input(id,params['chat'])
  end

  get '/stream', provides: 'text/event-stream' do
   stream :keep_open do |out|
	id = "web//"+session[:session_id]
 	jugador = $botweb.buscar(id)
	jugador.out = out
	jugador.clean_buffer
    out.callback { jugador.out = nil  } 
   end
 end

 post '/set_arte' do
	session[:arte_naipes] = params['arte_naipes']
 end
 
end

if __FILE__ == $0 then
  TrucoArgentino.run!
end

