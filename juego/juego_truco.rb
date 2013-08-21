#							Copyright 2013 Fabian Fiorotto
=begin
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. For more
    infotmation see the file licence.txt  or visit
    http://www.gnu.org/licenses/gpl-3.0.html
=end

=begin
    Este programa es software libre: usted puede redistribuirlo y/o modificarlo
    conforme a los téminos de la Licencia Pública General de GNU publicada por
    la Fundación para el Software Libre, ya sea la versión 3 de esta Licencia o
    (a su elección) cualquier versión posterior.

    Este programa se distribuye con el deseo de que le resulte útil,
    pero SIN GARANTÍAS DE NINGÚN TIPO; ni siquiera con las garantías implícitas de
    COMERCIABILIDAD o APTITUD PARA UN PROPÓSITO DETERMINADO Para mas información
    ver el fichero licence.txt o visita la web:
    http://www.spanish-translator-services.com/espanol/t/gnu/gpl-ar.html
=end



[
  'jugada.rb',
  'jugadas/todas.rb',
  'truco_exception.rb',
  'naipe.rb',
  'naipe_oculto.rb',
  'mano.rb',
  'juego.rb',
  'jugador.rb',
  'jugadores/jugador_telnet.rb',
  'jugadores/jugador_web.rb',
  'sala.rb'
].each{ |file | require File.expand_path(file, File.dirname(__FILE__)) }


$salas = Array.new(20){ |i| Sala.new( i < 10 ? 2 : 4) }
