
<%@page import="com.tsp.gespro.bo.DatosUsuarioBO"%>
<%@page import="com.tsp.gespro.jdbc.UsuariosDaoImpl"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.jdbc.TipoRutaDaoImpl"%>
<%@page import="com.tsp.gespro.dto.TipoRuta"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el usuario tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
} else {
    
    int idEmpresa = user.getUser().getIdEmpresa();
    Empresa empresa = new Empresa();   
    EmpresaBO empresaBo = new EmpresaBO(user.getConn());    
    empresa = empresaBo.findEmpresabyId(idEmpresa); 
        
    //EmpresaPermisoAplicacion empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl(user.getConn()).findByPrimaryKey(empresaBo.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa());

    String verificadorSesionGuiaCerrada = "0";
    String cssDatosObligatorios = "border:3px solid red;";//variable para colocar el css del recuadro que encierra al input para la guia interactiva
    try{
        if(session.getAttribute("sesionCerrada")!= null){
            verificadorSesionGuiaCerrada = (String)session.getAttribute("sesionCerrada");
        }
    }catch(Exception e){}
    
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <jsp:include page="../include/keyWordSEO.jsp" />

        <title><jsp:include page="../include/titleApp.jsp" /></title>

        <jsp:include page="../include/skinCSS.jsp" />

        <jsp:include page="../include/jsFunctions_18.jsp"/>
        
        
             
        <script type="text/javascript">
            
            var map;
            var poly;
                        
            var directionDisplay;
            var directionsService;
            var directionsResult;
            
            var markerRoute = [];
            var global = [];
            var latLngRoute = [];
            var stops = [];
            
            function initialize() {
                
                var rendererOptions = {
                    draggable: true
                };
            
                directionsService = new google.maps.DirectionsService();
                directionsDisplay = new google.maps.DirectionsRenderer(rendererOptions);
                
                var leon = new google.maps.LatLng(21.123619,-101.680496);
                var mexico = new google.maps.LatLng(23.634501,-102.552784);
                var inicio;
                
                <%if(empresa.getLatitud()!=0 && empresa.getLongitud()!=0){ %>
                    inicio = new google.maps.LatLng(<%=empresa.getLatitud()%>,<%=empresa.getLongitud()%>);
                <%}else{%>
                    inicio = new google.maps.LatLng(19.433733654546185,-99.13178443908691);
                <%}%>
                var mapOptions = {
                  zoom: 15,
                  center: inicio,
                  mapTypeId: google.maps.MapTypeId.ROADMAP,
                  draggableCursor:'crosshair'
                };

                map = new google.maps.Map(document.getElementById('map_canvas'),
                    mapOptions);
                
                map.controls[google.maps.ControlPosition.TOP_RIGHT].push(
                FullScreenControl(map, 'Pantalla Completa',
                'Salir Pantalla Completa'));
                    
                google.maps.event.addListener(map, 'click', function(event) {
                    crearMarcadorBasico(event.latLng);
                });
                
                directionsDisplay.setMap(map);
                
                
                
            }
        
            function loadScript() {
                var script = document.createElement('script');
                script.type = 'text/javascript';
                script.src = 'https://maps.googleapis.com/maps/api/js?v=3&' +
                    'callback=initialize&key=AIzaSyDzMx9Abj9GxfPeqIvUc_Sh46ZmzIreljQ';
                document.body.appendChild(script);
            }

            window.onload = loadScript;
        
            function ruta() {
                 
                 
                 //valida marcadores
                 if(markerRoute.length<=1){
                    apprise('Debe agregar minimo 2 marcadores al mapa.', {'animate':true});
                    return;
                 }
                 //alert(markerRoute.length);
                 if(markerRoute.length>80){
                    apprise('No se pueden agregar mas de 80 marcadores al mapa.', {'animate':true});
                    return;
                 }
                
                //añadimos marcadores a arreglo
                var destination;
                for(var i = 0, marcador; marcador = markerRoute[i]; i ++){

                    if(marcador.getMap()!=null){
                       
                            stops.push({"Geometry":{"Latitude":marcador.getPosition().lat(),"Longitude":marcador.getPosition().lng()}});                           
                            destination = marcador.getPosition();
                            latLngRoute.push(destination);
                    }
                }  
                
               //alert("Marcadores --->" + latLngRoute.length);
               
               //quitamos markers
                if(markerRoute){
                    for(var i = 0, marcador; marcador = markerRoute[i]; i ++){
                        marcador.setMap(null);
                    }
                    markerRoute = [];
                    
                }
                
                $("#txt_marcadores_ruta").val(latLngRoute);//obtnemos marcadores en txt para guardar en bd
                    /*stops = [
                        {"Geometry":{"Latitude":51.507937,"Longitude":-0.076188}},
                        {"Geometry":{"Latitude":51.51168,"Longitude":-0.114155}},
                        {"Geometry":{"Latitude":51.5010063,"Longitude":-0.114155}},
                        {"Geometry":{"Latitude":51.5010063,"Longitude":-0.041407}},                        
                    ];*/

                    //var map = new window.google.maps.Map(document.getElementById("map_canvas"));

                    // new up complex objects before passing them around
                    //ar directionsDisplay = new window.google.maps.DirectionsRenderer();
                    //var directionsService = new window.google.maps.DirectionsService();

                    Tour_startUp(stops);

                    window.tour.loadMap(map, directionsDisplay);
                    window.tour.fitBounds(map);

                    if (stops.length > 1)
                        window.tour.calcRoute(directionsService, directionsDisplay);
                    
                    stops.splice(0,stops.length);//borra puntos
                    latLngRoute.splice(0,latLngRoute.length);
            };



        function Tour_startUp(stops) {
            if (!window.tour) window.tour = {
                updateStops: function (newStops) {
                    stops = newStops;
                },
                // map: google map object
                // directionsDisplay: google directionsDisplay object (comes in empty)
                loadMap: function (map, directionsDisplay) {
                    var myOptions = {
                        zoom: 13,
                        center: new window.google.maps.LatLng(51.507937, -0.076188), // default to London
                        mapTypeId: window.google.maps.MapTypeId.ROADMAP
                    };
                    map.setOptions(myOptions);
                    directionsDisplay.setMap(map);
                },
                fitBounds: function (map) {
                    var bounds = new window.google.maps.LatLngBounds();

                    // extend bounds for each record
                    jQuery.each(stops, function (key, val) {
                        var myLatlng = new window.google.maps.LatLng(val.Geometry.Latitude, val.Geometry.Longitude);
                        bounds.extend(myLatlng);
                    });
                    map.fitBounds(bounds);
                },
                calcRoute: function (directionsService, directionsDisplay) {
                    var batches = [];
                    var itemsPerBatch = 10; // google API max = 10 - 1 start, 1 stop, and 8 waypoints
                    var itemsCounter = 0;
                    var wayptsExist = stops.length > 0;

                    while (wayptsExist) {
                        var subBatch = [];
                        var subitemsCounter = 0;

                        for (var j = itemsCounter; j < stops.length; j++) {
                            subitemsCounter++;
                            subBatch.push({
                                location: new window.google.maps.LatLng(stops[j].Geometry.Latitude, stops[j].Geometry.Longitude),
                                stopover: true
                            });
                            if (subitemsCounter == itemsPerBatch)
                                break;
                        }

                        itemsCounter += subitemsCounter;
                        batches.push(subBatch);
                        wayptsExist = itemsCounter < stops.length;
                        // If it runs again there are still points. Minus 1 before continuing to 
                        // start up with end of previous tour leg
                        itemsCounter--;
                    }

                    // now we should have a 2 dimensional array with a list of a list of waypoints
                    var combinedResults;
                    var unsortedResults = [{}]; // to hold the counter and the results themselves as they come back, to later sort
                    var directionsResultsReturned = 0;

                    for (var k = 0; k < batches.length; k++) {
                        var lastIndex = batches[k].length - 1;
                        var start = batches[k][0].location;
                        var end = batches[k][lastIndex].location;

                        // trim first and last entry from array
                        var waypts = [];
                        waypts = batches[k];
                        waypts.splice(0, 1);
                        waypts.splice(waypts.length - 1, 1);

                        var request = {
                            origin: start,
                            destination: end,
                            waypoints: waypts,
                            travelMode: window.google.maps.TravelMode.DRIVING
                        };
                        (function (kk) {
                            directionsService.route(request, function (result, status) {
                                if (status == window.google.maps.DirectionsStatus.OK) {

                                    var unsortedResult = { order: kk, result: result };
                                    unsortedResults.push(unsortedResult);

                                    directionsResultsReturned++;

                                    if (directionsResultsReturned == batches.length) // we've received all the results. put to map
                                    {
                                        // sort the returned values into their correct order
                                        unsortedResults.sort(function (a, b) { return parseFloat(a.order) - parseFloat(b.order); });
                                        var count = 0;
                                        for (var key in unsortedResults) {
                                            if (unsortedResults[key].result != null) {
                                                if (unsortedResults.hasOwnProperty(key)) {
                                                    if (count == 0) // first results. new up the combinedResults object
                                                        combinedResults = unsortedResults[key].result;
                                                    else {
                                                        // only building up legs, overview_path, and bounds in my consolidated object. This is not a complete 
                                                        // directionResults object, but enough to draw a path on the map, which is all I need
                                                        combinedResults.routes[0].legs = combinedResults.routes[0].legs.concat(unsortedResults[key].result.routes[0].legs);
                                                        combinedResults.routes[0].overview_path = combinedResults.routes[0].overview_path.concat(unsortedResults[key].result.routes[0].overview_path);

                                                        combinedResults.routes[0].bounds = combinedResults.routes[0].bounds.extend(unsortedResults[key].result.routes[0].bounds.getNorthEast());
                                                        combinedResults.routes[0].bounds = combinedResults.routes[0].bounds.extend(unsortedResults[key].result.routes[0].bounds.getSouthWest());
                                                        $("#txt_recorrido_ruta").val(combinedResults.routes[0].overview_path);
                                                    }
                                                    count++;
                                                }
                                            }
                                        }
                                        $("#txt_recorrido_ruta").val(combinedResults.routes[0].overview_path);
                                        //alert("string --- > " + combinedResults.routes[0].overview_path.length);
                                        directionsDisplay.setDirections(combinedResults);
                                    }
                                }
                            });
                        })(k);
                    }
                }
            };
        }


                // --------------------------------------------------------------------------------------------------
            /*function calcRoute(){
                var rendererOptions = {
                    draggable: true
                };
                directionsService = new google.maps.DirectionsService();
                directionsDisplay = new google.maps.DirectionsRenderer(rendererOptions);
                
                
                var origin;
                var destination;
                var waypts = [];
                var latLngRoute = [];
                
                if(markerRoute.length<1){
                    apprise('No se han agregado marcadores al mapa.', {'animate':true});
                    return;
                }
                
               
                for(var i = 0, marcador; marcador = markerRoute[i]; i ++){

                    if(marcador.getMap()!=null){
                        if(i == 0){
                            origin = marcador.getPosition();  
                            latLngRoute.push(origin);
                        }else{
                            destination = marcador.getPosition();
                            latLngRoute.push(destination);
                            waypts.push({  //v.fre hasta 8  , v.Busines 25 wayps -> revisar opciones https://developers.google.com/maps/documentation/javascript/directions#Waypoints
                                location:destination,
                                stopover:true
                            });
                        }
                    }  
                }
                   
                
                waypts.pop();
                limpiarMapa();  //para que no se encimen puntos       
                                
                var request = {
                    origin: origin,
                    destination: destination,
                    travelMode: google.maps.TravelMode.DRIVING,
                    waypoints: waypts,
                    optimizeWaypoints: true

              };

              directionsService.route(request, function(result, status) {
                if (status == google.maps.DirectionsStatus.OK) {
                    var routes = result.routes;
                    var legs = routes[0].legs;
                    var overview_path = routes[0].overview_path;
                    $("#txt_recorrido_ruta").val(overview_path);
                    directionsDisplay.setDirections(result);

                }
              });

              $("#txt_marcadores_ruta").val(latLngRoute);
              directionsDisplay.setMap(map);       
            }*/
        
            function limpiarMapa(){
                
                 $("#txt_marcadores_ruta").val("");
                 $("#txt_recorrido_ruta").val("");
                 $("#txt_clientes_ruta").val("");
                 $("#txt_prospectos_ruta").val("");
                 
                var rendererOptions = {
                    draggable: true
                };
                directionsDisplay.setMap(null);
                //directionsDisplay = new google.maps.DirectionsRenderer(rendererOptions);
                
                if(markerRoute){
                    for(var i = 0, marcador; marcador = markerRoute[i]; i ++){
                        marcador.setMap(null);
                    }
                    markerRoute = [];
                    
                }
            
                $("#txt_direccion").val("");
            }

            function crearMarcadorBasico(location){
                //alert(location.lat() +"---" + location.lng());
                var marker = new google.maps.Marker({
                    position: location, 
                    map: map,
                    
                });
                google.maps.event.addListener(marker, 'click', function(event) {
                    quitarMarcador(event.latLng);
                });
                markerRoute.push(marker);
            }
        
            function quitarMarcador(location){
                for(var i = 0, marcador; marcador = markerRoute[i]; i ++){
                    if(marcador.getPosition().lat()==location.lat() && marcador.getPosition().lng()==location.lng()){
                        marcador.setMap(null);
                    }
                }
            }
            
            function buscarMarcador(){
                $.ajax({
                    type: "POST",
                    url: "mapaBuscador_ajax.jsp",
                    data: $("#form_mapa_buscador").serialize(),
                    beforeSend: function(objeto){
                        $("#div_map_resultado_buscar").html("");
                        $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("--EXITO-->", 0)>0){
                           $("#div_map_resultado_buscar").html(datos);
                           $("#ajax_loading").fadeOut("slow");
                       }else{
                           $("#ajax_loading").fadeOut("slow");
                           $("#ajax_message").html(datos);
                           $("#ajax_message").fadeIn("slow");
                       }
                    }
                });
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
        
            function buscarDireccion(){
                var address = $('#txt_direccion').val();
                var geocoder = new google.maps.Geocoder();
                geocoder.geocode({ 'address': address}, geocodeResult);
            }
        
            function geocodeResult(results, status) {
                if (status == 'OK') {
                    var mapOptions = {
                        center: results[0].geometry.location,
                        mapTypeId: google.maps.MapTypeId.ROADMAP
                    };
                    map.setOptions(mapOptions);
                    map.fitBounds(results[0].geometry.viewport);
                    
                    crearMarcadorBasico(results[0].geometry.location);
                    
                } else {
                    alert("Geocoding no tuvo éxito debido a: " + status);
                }
            }
        
            function grabar(){
                $.ajax({
                    type: "POST",
                    url: "logistica_nuevaRuta_ajax.jsp?id_p="+$("#cmb_promotor_buscar").val(),
                    data: $("#form_nueva_ruta").serialize(),
                    beforeSend: function(objeto){
                        $("#action_buttons").fadeOut("slow");
                        $("#div_map_resultado_buscar").html("");
                        $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("--EXITO-->", 0)>0){
                           $("#div_map_resultado_buscar").html(datos);
                           $("#ajax_loading").fadeOut("slow");
                           $("#ajax_message").fadeIn("slow");
                           apprise('<center><img src=../../images/info.png> <br/>'+ datos +'</center>',{'animate':true},
                                    function(r){
                                        location.href = "logistica.jsp";
                                    });
                       }else{
                           $("#ajax_loading").fadeOut("slow");
                           $("#ajax_message").html(datos);
                           $("#ajax_message").fadeIn("slow");
                           $("#action_buttons").fadeIn("slow");
                           $.scrollTo('#inner',800);
                       }
                    }
                });
            }
            
            function muestraMarcadorBusqueda(lat,lng,tipo,id){
                if(tipo=="clientes"){
                    var valor = $("#txt_clientes_ruta").val();
                    if(valor!=""){
                        valor = valor + "|";
                    }
                    $("#txt_clientes_ruta").val(valor + lat + "," + lng + "," + id);
                }else if(tipo=="prospectos"){
                    var valor = $("#txt_prospectos_ruta").val();
                    if(valor!=""){
                        valor = valor + "|";
                    }
                    $("#txt_prospectos_ruta").val(valor + lat + "," + lng + "," + id);
                }
                crearMarcadorBasico(new google.maps.LatLng(lat,lng));
                var mapOptions = {
                        center: new google.maps.LatLng(lat,lng),
                        zoom: 15,
                        mapTypeId: google.maps.MapTypeId.ROADMAP
                };
                map.setOptions(mapOptions);
            }
        
            function accionTipoRuta(obj){
                
                limpiarMapa();
                
                if(obj.value==1){
                    google.maps.event.addListener(map, 'click', function(event) {
                        crearMarcadorBasico(event.latLng);
                    });
                    $("#div_map_tool").show();
                }else{
                    google.maps.event.clearListeners(map, 'click');
                    $("#div_map_tool").hide();
                }
                
                if(obj.value==4 || obj.value==5){
                    $("#p_promotor_busqueda").show();
                }else{
                    $("#p_promotor_busqueda").hide();
                }
                
                if(obj.value==2 || obj.value==3 || obj.value==4 || obj.value==5){
                    if(obj.value==2 || obj.value==4){
                        $("#cmb_tipo_buscar").val("clientes");
                    }else if(obj.value==3){
                        $("#cmb_tipo_buscar").val("prospectos");
                    }else if(obj.value==5){
                        $("#cmb_tipo_buscar").val("cobranza");
                    }
                }else{
                    $("#cmb_tipo_buscar").val("todos");
                }
            
                $("#div_map_resultado_buscar").html("");
            }
            
            function ocultarMostrarDiasVisitaCliente(tipoRuta){
                if(tipoRuta == 2 || tipoRuta == 4){
                    document.getElementById("diasVisitaAlCliente1").style.display="block";
                    document.getElementById("diasVisitaAlCliente2").style.display="block";
                }else{
                    document.getElementById("diasVisitaAlCliente1").style.display="none";
                    document.getElementById("diasVisitaAlCliente2").style.display="none";
                }
            }
        
      </script>
                            
    </head>
    <body>
        <div class="content_wrapper">

            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>

            <!-- Inicio de Contenido -->
            <div id="content">
                
                <div class="inner" id="leito">
                    <h1>Log&iacute;stica - Nueva ruta</h1>
                    
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--<form id="form_data" name="form_data" action="" method="post">-->
                        <div class="twocolumn">
                            <div class="column_left">
                                <div class="header">
                                    <span>
                                        <img src="../../images/icon_logistica.png" alt="icon"/>
                                        Nueva ruta
                                    </span>
                                    <div class="switch" style="width:410px">

                                    </div>
                                </div>
                                <br class="clear"/>
                                <div class="content">
                                    <form id="form_nueva_ruta" name="form_nueva_ruta" action="" method="post">
                                        <input type="hidden" id="txt_recorrido_ruta" name="txt_recorrido_ruta"/>
                                        <input type="hidden" id="txt_marcadores_ruta" name="txt_marcadores_ruta"/>
                                        <input type="hidden" id="txt_clientes_ruta" name="txt_clientes_ruta"/>
                                        <input type="hidden" id="txt_prospectos_ruta" name="txt_prospectos_ruta"/>
                                        <p>
                                            <label>*Tipo de ruta:</label><br/>
                                            <%
                                            TipoRuta[] tipoRutasDto = new TipoRutaDaoImpl(user.getConn()).findAll();
                                            boolean auxBol = true;
                                            for(TipoRuta tipoRutaDto:tipoRutasDto){
                                                out.print("<input onclick=\"accionTipoRuta(this);ocultarMostrarDiasVisitaCliente("+tipoRutaDto.getIdTipoRuta()+");buscarMarcador();\" "+(auxBol?"checked":"")+" id=\"tipo_ruta_"+tipoRutaDto.getTipoRuta()+"\" name=\"txt_tipo_ruta\" value=\""+tipoRutaDto.getIdTipoRuta()+"\" type=\"radio\"/>"+tipoRutaDto.getTipoRuta()+"<br/>");
                                                auxBol = false;
                                            }
                                            %>
                                        </p>
                                        <br/>
                                        <p>
                                            <label>*Nombre:</label><br/>
                                            <input maxlength="100" type="text" id="txt_nombre_ruta" name="txt_nombre_ruta" style="width:300px;"/>
                                        </p>
                                        <br/>
                                        <p>
                                            <label>*Comentarios:</label><br/>
                                            <textarea id="txt_comentario_ruta" name="txt_comentario_ruta" cols="40" rows="3" style=""></textarea>
                                        </p>
                                        <br/>
                                        <p>
                                            <label>Repetir semanalmente:</label><br/>
                                            <input type="checkbox" class="checkbox" id="repetir_domingo" name="repetir_domingo" value="DOM"> <label for="repetir_domingo">Domingo</label>
                                            &nbsp;&nbsp;&nbsp;
                                            <input type="checkbox" class="checkbox" id="repetir_lunes" name="repetir_lunes" value="LUN"> <label for="repetir_lunes">Lunes</label>
                                            &nbsp;&nbsp;&nbsp;
                                            <input type="checkbox" class="checkbox" id="repetir_martes" name="repetir_martes" value="MAR"> <label for="repetir_martes">Martes</label>
                                            &nbsp;&nbsp;&nbsp;
                                            <input type="checkbox" class="checkbox" id="repetir_miercoles" name="repetir_miercoles" value="MIE"> <label for="repetir_miercoles">Miércoles</label>
                                            &nbsp;&nbsp;&nbsp;
                                        </p>
                                        <p>
                                            <input type="checkbox" class="checkbox" id="repetir_jueves" name="repetir_jueves" value="JUE"> <label for="repetir_jueves">Jueves</label>
                                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                            <input type="checkbox" class="checkbox" id="repetir_viernes" name="repetir_viernes" value="VIE"> <label for="repetir_viernes">Viernes</label>
                                            &nbsp;&nbsp;&nbsp;
                                            <input type="checkbox" class="checkbox" id="repetir_sabado" name="repetir_sabado" value="SAB"> <label for="repetir_sabado">Sábado</label>
                                            &nbsp;&nbsp;&nbsp; 

                                        </p>
                                        <br/>
                                        <div id="action_buttons">
                                            <p>
                                                <input type="button" id="enviar" value="Guardar" onclick="grabar();"/>
                                                <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                                            </p>
                                        </div>
                                    </form>
                                </div>
                            </div>
                            <div class="column_right">
                                <div class="header">
                                    <span>
                                        <img src="../../images/icon_logistica.png" alt="icon"/>
                                        Visor
                                    </span>
                                    <div class="switch" style="width:410px">

                                    </div>
                                </div>
                                <br class="clear"/>
                                <div class="content">
                                    <div id="div_map_tool">
                                        <input type="text" id="txt_direccion" name="txt_direccion" title="Ingresa la dirección a encontrar" style="width:200px"/>
                                        <input type="button" onclick="buscarDireccion();" value="Buscar"/>
                                    </div>
                                    <input type="button" onclick="ruta();" value="Calcular ruta"/>
                                    <input type="button" value="Limpiar" onclick="limpiarMapa();"/>
                                    <div id="map_canvas" style="height: 400px;width: auto">
                                        <img src="../../images/maps/ajax-loader.gif" alt="Cargando" style="margin: auto;"/>
                                    </div>
                                </div>
                            </div>
                        </div>
                                        
                        <!--<br class="clear"/>-->
                        <!-- APARTADO DE FILTRO -->
                        <div class="twocolumn">
                            <div class="column_left">
                                <div class="header">
                                    <span>
                                        <img src="../../images/icon_logistica.png" alt="icon"/>
                                        Filtros
                                    </span>
                                    <div class="switch" style="width:410px"></div>
                                </div>
                                <br class="clear"/>
                                <div class="content">
                                    <form id="form_mapa_buscador" name="form_mapa_buscador" action="" method="post">
                                        <p id="p_promotor_busqueda" style="display: none;">
                                            <br/>
                                            <label>Por Vendedor:</label><br/>
                                            <select id="cmb_promotor_buscar" name="cmb_promotor_buscar">
                                                <option value="0">Seleccione un Vendedor...</option>
                                                <%
                                                UsuariosBO usuariosBO = new UsuariosBO(user.getConn());
                                                Usuarios[] usuarios = usuariosBO.findUsuariosByRol(idEmpresa, RolesBO.ROL_GESPRO);
                                                for(Usuarios usuariosDto : usuarios){
                                                    DatosUsuario datosUsuario =  new DatosUsuarioBO(usuariosDto.getIdDatosUsuario(),user.getConn()).getDatosUsuario();
                                                    out.print("<option value=\""+usuariosDto.getIdUsuarios()+"\">"+datosUsuario.getApellidoPat() + (datosUsuario.getApellidoMat()!=null?" " + datosUsuario.getApellidoMat():"") + " " + datosUsuario.getNombre()+"</option>");
                                                }
                                                %>
                                            </select>
                                            
                                        </p>
                                                                             
                                        <p id="buscador_gral">
                                            <br/>  
                                            <label>Buscar:</label><br/>
                                            <input maxlength="30" type="text" id="txt_buscar" name="txt_buscar" style="width:300px" />
                                            <input type="hidden" id="cmb_tipo_buscar" name="cmb_tipo_buscar" value="todos"/>
                                            <!--<input type="image" src="../../images/icon_consultar.png" title="Buscar" onclick="buscarMarcador();"/>                                   
                                            <input type="button" value="Buscar" onclick="buscarMarcador();"/>-->         
                                            <br/>
                                        </p>                                                                            
                                            
                                            <p id="diasVisitaAlCliente1" style="display: none">
                                                <br/>
                                                <label>Por Días de Visita a Cliente:</label><br/>
                                                <input type="checkbox" class="checkbox" id="domingoReporte" name="domingoReporte" value="DOM"> <label for="domingoReporte">Domingo</label>
                                                &nbsp;&nbsp;&nbsp;
                                                <input type="checkbox" class="checkbox" id="lunesReporte" name="lunesReporte" value="LUN"> <label for="lunesReporte">Lunes</label>
                                                &nbsp;&nbsp;&nbsp;
                                                <input type="checkbox" class="checkbox" id="martesReporte" name="martesReporte" value="MAR"> <label for="martesReporte">Martes</label>
                                                &nbsp;&nbsp;&nbsp;
                                                <input type="checkbox" class="checkbox" id="miercolesReporte" name="miercolesReporte" value="MIE"> <label for="miercolesReporte">Miércoles</label>
                                                &nbsp;&nbsp;&nbsp;
                                            </p>
                                            <p id="diasVisitaAlCliente2" style="display: none">
                                                <input type="checkbox" class="checkbox" id="juevesReporte" name="juevesReporte" value="JUE"> <label for="juevesReporte">Jueves</label>
                                                &nbsp;&nbsp;&nbsp;
                                                <input type="checkbox" class="checkbox" id="viernesReporte" name="viernesReporte" value="VIE"> <label for="viernesReporte">Viernes</label>
                                                &nbsp;&nbsp;&nbsp;
                                                <input type="checkbox" class="checkbox" id="sabadoReporte" name="sabadoReporte" value="SAB"> <label for="sabadoReporte">Sábado</label>
                                                &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;
                                               
                                            </p>
                                            <br/>
                                     <input type="button" value="Buscar" onclick="buscarMarcador();"/>
                                    </form>
                                    <br/>
                                    <p>
                                        <div id="div_map_resultado_buscar" style="height: 210px;overflow: scroll;"></div>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <!-- FIN APARTADO DE FILTRO -->              
                </div>

                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>


    </body>
</html>
<%}%>
