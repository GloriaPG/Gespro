<%-- 
    Document   : MapaSeguimiento
    Created on : 24/05/2013, 11:42:08 AM
    Author     : Leonardo
--%>

<%@page import="com.tsp.gespro.util.StringManage"%>
<%@page import="com.tsp.gespro.bo.PosMovilEstatusBO"%>
<%@page import="com.tsp.gespro.dto.PosMovilEstatus"%>
<%@page import="com.tsp.gespro.dto.Ubicacion"%>
<%@page import="com.tsp.gespro.bo.UbicacionBO"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<!DOCTYPE html>

<% 
    int idPosMovilEstatus = -1;
    try{
        idPosMovilEstatus = Integer.parseInt(request.getParameter("idPosMovilEstatus"));
    }catch(Exception e){}
    if(idPosMovilEstatus>0){
        PosMovilEstatus pme = new PosMovilEstatus();
        PosMovilEstatusBO bO = new PosMovilEstatusBO(idPosMovilEstatus,user.getConn());
        pme = bO.getPosMovilEstatus();    
    
%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        
        
        <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
	<script type="text/javascript">
            var latitudEmpresa = <%=pme.getLatitud()%>;
            var longitudEmpresa = <%=pme.getLongitud()%>            
	  function initialize() {
	    var latlng = new google.maps.LatLng(latitudEmpresa,longitudEmpresa);
	    var myOptions = {
	      zoom: 10,
	      center: latlng,
        	mapTypeControl: true,
		mapTypeControlOptions: {style: google.maps.MapTypeControlStyle.DROPDOWN_MENU},
      		navigationControl: true,
      		navigationControlOptions: {style: google.maps.NavigationControlStyle.SMALL},
	        mapTypeId: google.maps.MapTypeId.ROADMAP
	    };
	    var mapita = new google.maps.Map(document.getElementById("map_seguimiento"), myOptions);

                var contentString =
                    '<h2 id="firstHeading" class="firstHeading"> <%=pme.getMensajeEstatus()%></h2>'+
                    '<div id="bodyContent">'+
        	    '<p>Fecha<br>'+
        	    '<%=pme.getFechaEstatus()%> <br></p>'+
                    <%if(!StringManage.getValidString(pme.getImagenSeguimiento()).equals("")){%>
                        '<img src="showImageSegumiento.jsp?image=<%=pme.getImagenSeguimiento()%>"  style="width:300px;height:200px;"/>'
                     <%}else{%>       
                         'Sin Imagen Registrada.'
                     <%}%> 
        	    '</div>';
 
				
 
		var marker = new google.maps.Marker({
                  position: latlng, 
                  map: mapita, 
                  title:"Seguimiento"
		});
                
                var infowindow = new google.maps.InfoWindow({
		    content: contentString
		});
                
                google.maps.event.addListener(marker, 'click', function() {
                    infowindow.open(mapita, marker);
                });
 
		infowindow.open(mapita, marker);
 
			
                
		
		
	  }      
	</script>
        
    </head>
    <body onload="initialize()">
        <!--<h1>Localización!</h1>        -->
        
        <!--<div id="map2" style="width:360px;height:200px;border:2px solid green;"></div>-->
        <!--<div id="map_canvas" style="width:900px;height:400px;border:2px solid green; margin: 0px auto;"></div>-->
        <div id="map_seguimiento" style="width:800px;height:675px;border:2px solid green;" ></div>
        
    </body>
</html>

<%}%>
