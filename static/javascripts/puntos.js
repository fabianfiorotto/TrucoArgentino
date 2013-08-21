
function mostrar_puntos(puntos_object){
 $("#mis_puntos").html(puntos_object.s[0]);
 $("#sus_puntos").html(puntos_object.s[1]);


 $(".mis_fosforos").each(function( index ) {

	r = index * 5;
	if (puntos_object.n[0] > r){
	 p = 5;
	 if (puntos_object.n[0] <= r + 5){
		p = (puntos_object.n[0]-r) % 5 == 0 ? 5 : (puntos_object.n[0]-r) % 5;
	 }
	 $(this).attr("src","fosforos/"+p+".png").css("visibility","visible");
	}else{
	 $(this).css("visibility","hidden");
	}

 });

 $(".sus_fosforos").each(function( index ) {

	r = index * 5;
	if (puntos_object.n[1] > r){
	 p = 5;
	 if (puntos_object.n[1] <= r + 5){
		p = (puntos_object.n[1]-r) % 5 == 0 ? 5 : (puntos_object.n[1]-r) % 5;
	 }
	 $(this).attr("src","fosforos/"+p+".png").css("visibility","visible");
	}else{
	 $(this).css("visibility","hidden");
	}

 });
 
}
