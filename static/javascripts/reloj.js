	jQuery.fn.dibujar_reloj = function( fraccion ){
	  //var canvas = document.getElementById('reloj')
	  canvas = $(this)[0]
	  var context = canvas.getContext("2d");
      var centerX = canvas.width / 2;
      var centerY = canvas.height / 2;
      var radius = 30;
      context.beginPath();
      context.arc(centerX, centerY, radius, 0, 2 * Math.PI, false);
      context.fillStyle = '#116d02';
      context.fill();
      context.lineWidth = 3;
      context.strokeStyle = '#003300';
      context.stroke();
      context.beginPath();
      context.arc(centerX, centerY, radius, - Math.PI / 2 , - Math.PI / 2 + 2 * Math.PI * fraccion, false);
	  if(fraccion < 1 && fraccion != 0 ){
		  context.lineTo(centerX, centerY);
		  context.lineTo(centerX, centerY-radius);
	  }
      context.fillStyle = '#bccdb9';
      context.fill();
      context.lineWidth = 1;
      context.strokeStyle = '#003300';
      context.stroke();
	}


	jQuery.fn.correr_temoporizador = function(time,maxtime,inverval){
		if(this.data("timer")){
			clearInterval(this.data("timer"));
		}
		var t = (maxtime - time) / maxtime;
		var this_object = this;
		var timer = setInterval(function(){
			this_object.dibujar_reloj( t );
			if(t >= 1){
				clearInterval(timer);
				this_object.trigger('timeout')
			}
			t += inverval / maxtime;
		},1000 * inverval );
		this.data("timer" , timer);
	}
	
	jQuery.fn.stop = function(){
		timer = this.data("timer");
		if(timer){
			clearInterval(timer);
		}
	}
	
	jQuery.fn.timeout = function(func){
		this.bind("timeout",func);
	}
