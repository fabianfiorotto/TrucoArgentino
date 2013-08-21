
function mostrar_botones(botones_object){

 if(botones_object.responder){
 	$("#quiero,#noquiero").show();
 }else{
	$("#quiero,#noquiero").hide();
 }	

 switch(botones_object.envido){
   case "Falta Envido" :
	$("#faltaenvido").prop("disabled",false);
	$("#realenvido").prop("disabled",false);
	$("#envido").prop("disabled",false); 
	break;
   case "Real Envido":
	$("#envido").prop("disabled",false);
	$("#realenvido").prop("disabled",false);
	$("#faltaenvido").prop("disabled",true);
 	break;
   case "Envido" :
	$("#envido").prop("disabled",false);
	$("#realenvido").prop("disabled",true);
	$("#faltaenvido").prop("disabled",true);
  	break;
   default:
	$("#envido").prop("disabled",true);
	$("#realenvido").prop("disabled",true);
	$("#faltaenvido").prop("disabled",true);
	break;
 }

 if(botones_object.flor){
	 switch(botones_object.flor){
		 case "Flor":
			$("#jugadasflor").hide();
			$("#flor").prop("disabled",false);
		 break;
		 case "Contraflor":
			$("#jugadasflor").show();
			$("#flor").prop("disabled",true);
			$("#contraflor,#meachico").prop("disabled",false);
			$("#noquiero").show();
		 break;
		 default:
			$("#jugadasflor").show();
			$("#flor,#contraflor,#meachico").prop("disabled",true);
			$("#quiero,#noquiero").show();
		 break;
	 }
 }else{
	$("#flor").prop("disabled",true);
	$("#jugadasflor").hide();
 }

 if(botones_object.truco){
	canto = "";
	switch(botones_object.truco){
	  case "Truco": 
		$("#truco").data("canto","truco") ;
		break;
	  case "Retruco":
		$("#truco").data("canto","retruco");
		break;
	  case "Vale Cuatro":
		$("#truco").data("canto","valecuatro");
		break;
	}
	$("#truco").prop("disabled",false)
		.html(botones_object.truco)
		
 }else{
	$("#truco").prop("disabled",true);
 }

 if(botones_object.puntos){
	$("#sonbuenas").show();
	$("#puntosenvido,[for=puntos]").show();
 }else{
	$("#sonbuenas").hide();
	$("#puntosenvido,[for=puntos]").hide();
 }


}

$(document).ready(function(){
	
		$("#truco").data("canto",truco);
		$("#truco").click(function(){
			cantar($(this).data("canto"));
		});
});
