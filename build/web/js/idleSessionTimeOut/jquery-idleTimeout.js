//######
//## This work is licensed under the Creative Commons Attribution-Share Alike 3.0 
//## United States License. To view a copy of this license, 
//## visit http://creativecommons.org/licenses/by-sa/3.0/us/ or send a letter 
//## to Creative Commons, 171 Second Street, Suite 300, San Francisco, California, 94105, USA.
//######

(function($){
 $.fn.idleTimeout = function(options) {
    var defaults = {
                        /*Para cambiar valores de tiempo, modificar jsp/include/header.jsp */
			inactivity: 20*60*1000, //20 Minutes = 1200000
			noconfirm: 10000, //10 Seconds
			sessionAlive: 600000, //600000 = 10 Minutes
			redirect_url: '../../jsp/inicio/login.jsp?action=logout',
			click_reset: true,
			alive_url: '../../jsp/inicio/mantenerSesionViva.jsp',
			logout_url: '../../jsp/inicio/login.jsp?action=logout'
		}
    
    //##############################
    //## Private Variables
    //##############################
    var opts = $.extend(defaults, options);
    var liveTimeout, confTimeout, sessionTimeout;
    var modal = "<div id='modal_pop'><p>Tu sesión esta a punto de expirar debido a inactividad.</p></div>";
    //##############################
    //## Private Functions
    //##############################
    var start_liveTimeout = function()
    {
      clearTimeout(liveTimeout);
      clearTimeout(confTimeout);
      liveTimeout = setTimeout(logout, opts.inactivity);
      
      if(opts.sessionAlive)
      {
        clearTimeout(sessionTimeout);
        sessionTimeout = setTimeout(keep_session, opts.sessionAlive);
      }
    }
    
    var logout = function()
    {
      //alert("Tu sesión esta a punto de expirar debido a inactividad.");
      confTimeout = setTimeout(redirect, opts.noconfirm);
      /*
      $(modal).dialog({
        buttons: {"Permanecer en sesion":  function(){
          $(this).dialog('close');
          stay_logged_in();
        }},
        modal: true,
        title: 'Inactividad del usuario'
      });
      */
     /**
      * Modificación: 21 Octubre 2011 @author: ISC Cesar Martinez poseidon24@hotmail.com
      * Modificado para funcionar con alerts APPRISE
      */

     apprise('Tu sesión esta a punto de expirar debido a inactividad en <span id="countdown"></span> segundos', {'runFunctionBefore':'cuentaRegresivaCerrarSesionInactiva('+opts.noconfirm/1000+')','verify':true, 'animate':true, 'textYes':'Permanecer en sesion', 'textNo':'Salir ahora'}, function(r)
        {
            if(r){
                // Usuario dio click 'Yes'
                stay_logged_in();
            }
            else {
                // Usuario dio click 'No'
                document.location.href=opts.logout_url;
            }
        });
    }
    
    var redirect = function()
    {
      if(opts.logout_url)
      {
        $.get(opts.logout_url);
      }
      window.location.href = opts.redirect_url;
    }
    
    var stay_logged_in = function(el)
    {
      start_liveTimeout();
      if(opts.alive_url)
      {
        $.get(opts.alive_url);
      }
    }
    
    var keep_session = function()
    {
      $.get(opts.alive_url);
      clearTimeout(sessionTimeout);
      sessionTimeout = setTimeout(keep_session, opts.sessionAlive);
    } 
    
    //###############################
    //Build & Return the instance of the item as a plugin
    // This is basically your construct.
    //###############################
    return this.each(function() {
      obj = $(this);
      start_liveTimeout();
      if(opts.click_reset)
      {
        $(document).bind('click', start_liveTimeout);
      }
      if(opts.sessionAlive)
      {
        keep_session();
      }
    });
    
 };
})(jQuery);

function cuentaRegresivaCerrarSesionInactiva(tiempoDeEspera){
          $('#countdown').countDown({
                startNumber: tiempoDeEspera,
                callBack: function() { }
        });
}
