
 $(document).ready(function(){
	 
	$("#arte-naipe-selector").change(function(){
		arte_naipe = $(this).val();

		$.ajax({
			url: "set_arte",
			type: "post",
			data: {arte_naipes: arte_naipe },
			success: function(){
				$.ajax({
					url: "console_send",
					type: "post",
					data: {chat: ">status" }
				});
			}
		});

	});
 });


function dar_naipes(naipes_array){
 $("#naipes").empty();
 naipes_array.forEach(function(naipe) { 
	$( "#naipes" ).append( 
		$("<img/>" , { src: naipe_src(naipe) } )
			.css("width","120px")
			.attr("alt",naipe.numero.toString()+" de "+ naipe.palo)
			.click(function(){ client_send(">jugar "+$(this).attr("alt")); })
	);
 });
}


function mostrar_mesa(mesa_object){
 $("#mesa").empty();
 nombres  = Object.keys(mesa_object);
 nombres.forEach(function(nombre) {
	div = $("<div/>").addClass("monton")
	div.append($("<p/>").html(nombre));
	mesa_object[nombre].forEach(function(naipe,index) { 
		div.append( 
			$("<img/>" , { src: naipe_src(naipe) } )
				.css("width","120px")
				.attr("alt",naipe.numero.toString()+" de "+ naipe.palo)
				.attr("title",naipe.numero.toString()+" de "+ naipe.palo)
				.addClass(["primera","segunda","tercera"][index])
		);
	});
	$("#mesa").append(div);
 });
}


function naipe_src(naipe){
 if(naipe.oculto){
	  file_name = "atras.png"
 }else{
	  file_name = naipe.palo.toLowerCase() +"_" + naipe.numero.toString() + ".png"
 }
 return "/baraja_espanola/"+arte_naipe+"/" +file_name;
}
