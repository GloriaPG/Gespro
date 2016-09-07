<%-- 
    Document   : Mapa
    Created on : 10/01/2013, 11:35:33 AM
    Author     : Leonardo
--%>

<%@page import="com.tsp.gespro.factory.EstadoEmpleadoDaoFactory"%>
<%@page import="com.tsp.gespro.dto.EstadoEmpleado"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.dto.EmpleadoBitacoraPosicion"%>
<%@page import="com.tsp.gespro.jdbc.EmpleadoBitacoraPosicionDaoImpl"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.dto.Ubicacion"%>
<%@page import="com.tsp.gespro.bo.UbicacionBO"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<!DOCTYPE html>

<% 
    /*
    * Recepción de valores
    */
    
    int idEmpleado = Integer.parseInt(request.getParameter("idUsuario"));
    UsuarioBO usuarioBO = new UsuarioBO(user.getConn());
    Usuarios empleado = null;
    DatosUsuario datosUsuarioDto = null;

    if (idEmpleado > 0){
        usuarioBO = new UsuarioBO(user.getConn(),idEmpleado);
        empleado = usuarioBO.getUser();

         datosUsuarioDto =  usuarioBO.getDatosUsuario();
        }
    
    double lat = 0;
    double lan = 0;
    try{
        EmpleadoBitacoraPosicionDaoImpl bitacoraDao = new EmpleadoBitacoraPosicionDaoImpl();
        String filtro = " ID_USUARIO = "+ empleado.getIdUsuarios()+ " ORDER BY FECHA DESC LIMIT 0,1";
        EmpleadoBitacoraPosicion bitEmp = bitacoraDao.findByDynamicWhere(filtro,null)[0];
        
        lat = bitEmp.getLatitud();
        lan =  bitEmp.getLongitud();
    }catch(Exception e){
        lat = empleado.getLatitud();
        lan =  empleado.getLongitud();
    }
    
%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>        
        
        <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
	<script type="text/javascript">
          var map;
            
	  function initialize() {
	    var latlng = new google.maps.LatLng(<%=lat%>,<%=lan%>);
	    var myOptions = {
	      zoom: 15,
	      center: latlng,
        	mapTypeControl: true,
		mapTypeControlOptions: {style: google.maps.MapTypeControlStyle.DROPDOWN_MENU},
      		navigationControl: true,
      		navigationControlOptions: {style: google.maps.NavigationControlStyle.SMALL},
	        mapTypeId: google.maps.MapTypeId.ROADMAP
	    };
	    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
            
            map.controls[google.maps.ControlPosition.TOP_RIGHT].push(
                FullScreenControl(map, 'Pantalla Completa',
                'Salir Pantalla Completa'));  
 


                <%
                //int idestado = 0;
                EstadoEmpleado estadoDto = EstadoEmpleadoDaoFactory.create().findByPrimaryKey(empleado.getIdEstadoEmpleado());
                String nombreMarcador = (datosUsuarioDto.getNombre()!=null?datosUsuarioDto.getNombre():"") + " " + (datosUsuarioDto.getApellidoPat()!=null?" " + datosUsuarioDto.getApellidoPat():"") + " " +(datosUsuarioDto.getApellidoMat()!=null?" " + datosUsuarioDto.getApellidoMat():"");

               %>       
                var contentString = ""
                        + "<div class='map_dialog'>"
                        + "    <b>Promotor</b></br>" + "<%=nombreMarcador.replaceAll("\\\"", "&quot;")%>"  + "<br/>"
                        + "    <b>Estado:</b> " + "<%=(estadoDto!=null?estadoDto.getNombre():"SIN DETALLE")%>" + "<br/>"
                        + "    <li> <a title='Detalles' onclick='muestraDetallesPromotor("+"<%=empleado.getIdUsuarios()%>"+",1);'>Detalles </a> </li> <br/>"
                        + "    <li> <a title='Hist&oacute;rico' onclick='muestraDetallesPromotor("+"<%=empleado.getIdUsuarios()%>"+",2);'>Hist&oacute;rico </a> </li><br/>"                           
                        + "    <li> <a title='Mensaje' onclick='muestraDetallesPromotor("+"<%=empleado.getIdUsuarios()%>"+",4);'>Mensaje </a> </li> <br/>"                        
                        + "</div>";
 
		/*var infowindow = new google.maps.InfoWindow({
		    content: contentString
		});	*/	
                var icon = "";
                var title = "";
                <%                          
                    
                    long s = (new Date()).getTime();
                        long d = 0; 
                        try{
                            EmpleadoBitacoraPosicionDaoImpl bitacoraDao = new EmpleadoBitacoraPosicionDaoImpl();
                            String filtro = " ID_USUARIO = "+ empleado.getIdUsuarios() + " ORDER BY ID_BITACORA_POSICION DESC LIMIT 0,1";
                            EmpleadoBitacoraPosicion bitEmp = bitacoraDao.findByDynamicWhere(filtro,null)[0];
                            
                            d = bitEmp.getFecha().getTime();
                            //d = empleado.getFechaHora().getTime();
                        }catch(Exception e){}
                        long diferencia = s - d;
                        System.out.println("-------DIFERENCIA: "+diferencia);
                        if(diferencia < 300000){
                        %>
                            icon = "../../images/estatusEmpleado/icon_activoTrabajando.png",
                        <%}else{%>
                            icon = "../../images/estatusEmpleado/icon_desactivado.png",
                            <%}%>                    
                    
                    title = "Promotor"; <%
                    
                   %>
    
 
		var marker = new google.maps.Marker({
                  position: latlng, 
                  map: map, 
                  title:title,
                  icon: icon
		});
 
		//infowindow.open(map,marker);
                
                
                var infoBubble = new InfoBubble({
                  map: map,
                  content: '<div class="infoBubble">'+contentString+'</div>',
                  //position: new google.maps.LatLng(-32.0, 149.0),             
                  shadowStyle: 1,
                  padding: 2,
                  backgroundColor: '#CCFFFF',
                  borderRadius: 7,
                  arrowSize: 10,
                  borderWidth: 2,
                  borderColor: '#319AF6',
                  disableAutoPan: false,
                  hideCloseButton: false,
                  arrowPosition: 30,
                  backgroundClassName: 'transparent',
                  arrowStyle: 1
                });
    
                
		google.maps.event.addListener(marker, 'click', function() {
		  infoBubble.open(map,marker);
		});
                
                infoBubble.open(map,marker);
		
	  }
          
          
          function ubicaMapaHistorico(latitud, longitud) {
	    var latlng = new google.maps.LatLng(latitud,longitud);
	    var myOptions = {
	      zoom: 15,
	      center: latlng,
        	mapTypeControl: true,
		mapTypeControlOptions: {style: google.maps.MapTypeControlStyle.DROPDOWN_MENU},
      		navigationControl: true,
      		navigationControlOptions: {style: google.maps.NavigationControlStyle.SMALL},
	        mapTypeId: google.maps.MapTypeId.ROADMAP
	    };
	    var map = new google.maps.Map(document.getElementById("map_canvas"), myOptions); 
//	    

                var contentString =
                    '<h2 id="firstHeading" class="firstHeading"> <%=empleado.getNumEmpleado()%></h2>'+
                    '<div id="bodyContent">'+
        	    '<p>Empleado<br>'+
        	    '<%=(datosUsuarioDto.getNombre()!=null?datosUsuarioDto.getNombre():"") + " " + (datosUsuarioDto.getApellidoPat()!=null?" " + datosUsuarioDto.getApellidoPat():"") + " " +(datosUsuarioDto.getApellidoMat()!=null?" " + datosUsuarioDto.getApellidoMat():"")%></p>'+                    
        	    '</div>';
 
		var infowindow = new google.maps.InfoWindow({
		    content: contentString
		});		
 
		var marker = new google.maps.Marker({
	      position: latlng, 
	      map: map, 
	      title:"Título del Globo"
		});
 
		infowindow.open(map,marker);
 
		/*	
		google.maps.event.addListener(marker, 'click', function() {
		  infowindow.open(map,marker);
		});
		*/
               
               
               
               
               
	  }
          
          function agregaMarcador(lat, lng, title){
                var crear = 0;
                if(global.length > 0){
                    for(var i = 0, marcador; marcador = global[i]; i ++){
                        var posicion = marcador.getPosition();
                        var posicion2 = new google.maps.LatLng(lat,lng);
                        if(posicion.lat()==posicion2.lat() && posicion.lng()==posicion2.lng()){
                            crear = 0;
                            if(marcador.getMap()==null){
                                marcador.setMap(map);
                            }else{
                                marcador.setMap(null);
                            }
                        }else{
                            crear = 1;
                        }
                    }
                }else{
                    crear = 1;
                }
            //crear = 1;
                if(crear == 1){
                    var marcadorBasico = creaMarcadorBasico(
                            lat,
                            lng,
                            title
                        )
                    global.push(
                      marcadorBasico  
                    );
                    marcadorBasico.setMap(map);
                }
            }
          
	</script>
        
    </head>
    <body onload="initialize()">
        <!--<h1>Localización!</h1>        -->
        
        <!--<div id="map2" style="width:360px;height:200px;border:2px solid green;"></div>-->
        <div id="map_canvas" style="width:500px;height:500px;border:2px solid green;"></div>
        
    </body>
</html>
