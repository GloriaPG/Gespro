<%-- 
    Document   : formulario
    Created on : 07/08/2016, 09:05:02 PM
    Author     : Fabian
--%>

<%@page import="com.tsp.gespro.hibernate.pojo.Punto"%>
<%@page import="com.tsp.gespro.Services.Allservices"%>
<%@page import="com.tsp.gespro.hibernate.dao.ProyectoDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Proyecto"%>
<%@page import="java.util.List"%>
<%@page import="com.google.gson.Gson"%>
<%@page import="com.tsp.gespro.hibernate.pojo.HibernateUtil"%>
<%@page import="org.hibernate.Session"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:directive.page import="com.tsp.gespro.hibernate.dao.CoberturaDAO"/>
<jsp:directive.page import="com.tsp.gespro.hibernate.pojo.Cobertura"/>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
//Verifica si el usuario tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
}
String paramId = null;
try {
    paramId = request.getParameter("id");
} catch (Exception ex) {
    paramId = "0";
}
int id;
try {
    id = Integer.parseInt(paramId);
} catch (NumberFormatException ex) {
    id = 0;
}
List<Proyecto> proyectoList = new ProyectoDAO().lista();
Cobertura cobertura = new CoberturaDAO().getById(id);
Allservices allservices = new Allservices();
List<Punto> puntosList = allservices.queryPuntoDAO("where id_cobertura = " + id);
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <title><jsp:include page="../include/titleApp.jsp" /></title>
        <style>
            .right_position {
                text-align: right;
            }
            #frm_productos p {
                width: 100%;
            }
            #frm_productos p label {
                width: 20%;
            }
        </style>

        <jsp:include page="../include/keyWordSEO.jsp" />
        <jsp:include page="../include/skinCSS.jsp" />
        <jsp:include page="../include/jsFunctions.jsp"/>
        <script type="text/javascript">
            $(document).ready(function(){
                ocultarTipoDePuntos();
                cargarPaises();
            });
            
            function cargarPaises() {
                $.getJSON( "/Gespro/json/countriesToCities.json", function( data ) {
                    $.each( data, function( key, val ) {
                        $('#selector-pais').append($('<option>', { 
                            value: key,
                            text : key 
                        }));
                    });
                });
            }
            
            
            function cargarCiudades( pais ) {
                // limpiamos el selector
                $('#selector-ciudad')
                    .find('option')
                    .remove()
                    .end()
                    .append('<option value="0">Seleccione una ciudad</option>');
                //consultamos los paise y las ciudades
                $.getJSON( "/Gespro/json/countriesToCities.json", function( data ) {
                    $.each( data, function( key, val ) {
                        // si encontramos el pais, obtenemos las ciudades y las agremaos
                        if( key == pais ) {
                            $.each(val, function( indice, ciudad ){
                                $('#selector-ciudad').append($('<option>', { 
                                    value: ciudad,
                                    text : ciudad 
                                }));                            
                            });
                        }
                    });
                });
            }
            function seleccionarTipoPunto( tipoDePuntos ){
                ocultarTipoDePuntos();
                if (tipoDePuntos == "cliente") {
                    $("#contenedor-cliente").show("slow");
                    $("#guardarLugares").val(0);
                }
                if (tipoDePuntos == "ciudad") {
                    $("#contenedor-pais").show("slow");
                    $("#guardarLugares").val(0);
                }
                if (tipoDePuntos == "lugar") {
                    $("#guardarLugares").val(1);
                }
            }
            
            function ocultarTipoDePuntos(){
                $("#contenedor-cliente").hide("slow");
                $("#contenedor-pais").hide("slow");
            }
            
            function agregarZonaDelCliente( idCliente ) {
                 $.getJSON( "/Gespro/jsp/catCoberturas/ajax_cliente_punto.jsp?id="+idCliente, function( data ) {
                    $("#puntos").append(
                            '<div class="punto">'+
                                '<input type="hidden" class="punto" name="punto_id[]" value="0" readonly=""/>'+
                                '<input type="text" class="punto" name="punto_nombre[]" value="'+data['ciudad']+'" readonly=""/>'+
                                '<input type="text" class="punto" name="punto_longitud[]" value="'+data['longitud']+'" readonly=""/>'+
                                '<input type="text" class="punto" name="punto_latitud[]" value="'+data['latitud']+'" readonly=""/>'+
                                '<input type="hidden" class="punto" name="punto_tipo[]" value="1" readonly=""/>'+
                                '<button class="boton-eliminar-punto">Eliminar</button>'+
                                '<br>'+
                            '</div>'
                    );
                });
            }
            
            function agregarZonaCiudad( ciudad ) {
                $("#puntos").append(
                        '<div class="punto">'+
                            '<input type="hidden" class="punto" name="punto_id[]" value="0" readonly=""/>'+
                            '<input type="text" class="punto" name="punto_nombre[]" value="'+ciudad+'" readonly=""/>'+
                            '<input type="text" class="punto" name="punto_longitud[]" value="0" readonly=""/>'+
                            '<input type="text" class="punto" name="punto_latitud[]" value="0" readonly=""/>'+
                            '<input type="hidden" class="punto" name="punto_tipo[]" value="2" readonly=""/>'+
                            '<button class="boton-eliminar-punto">Eliminar</button>'+
                            '<br>'+
                        '</div>'
                );
            }
            
            function guardar(){ 
                    $.ajax({
                        type: "POST",
                        url: "ajax.jsp",
                        data: $("#frm_action").serialize(),
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                            $("#ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            console.log("Datos");
                            console.log(datos);
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               $("#ajax_message").html("Los datos se guardaron correctamente.");
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").fadeIn("slow");
                               apprise('<center><img src=../../images/info.png> <br/>Los datos se guardaron correctamente.</center>',{'animate':true},
                                        function(r){
                                                javascript:window.location.href = "catCoberturas_list.jsp";
                                                parent.$.fancybox.close();  
                                        });
                           }else{
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").html("Ocurrió un error al intentar guardar los datos.");
                               $("#ajax_message").fadeIn("slow");
                               $("#action_buttons").fadeIn("slow");
                           }
                        }
                    });   
                }
            
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
                var inicio = new google.maps.LatLng(19.433733654546185,-99.13178443908691);
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
            
           function puntos() {
                 //valida marcadores
                 if(markerRoute.length<1){
                    apprise('Debe agregar minimo 1 marcador al mapa.', {'animate':true});
                    return;
                 }
                 //Valida marcadores;
                 if(markerRoute.length>80){
                    apprise('No se pueden agregar mas de 80 puntos a la vez.', {'animate':true});
                    return;
                 }
                
                //Recogemos los puntos.
                for(var i = 0, marcador; marcador = markerRoute[i]; i ++){
                    if(marcador.getMap()!=null){
                       var lat=marcador.getPosition().lat();
                       var lng=marcador.getPosition().lng();
                       var pointLocation=lat+","+lng;
                       var ciudad="Ciudad de México";
                       $.get( "https://maps.googleapis.com/maps/api/geocode/json?&latlng="+pointLocation, function( data ) {
                            if(data.status=="OK"){
                               ciudad=data.results[0].address_components[5].long_name; 
                            }
                       });
                       $("#puntos").append(
                            '<div class="punto">'+
                                '<input type="hidden" class="punto" name="punto_id[]" value="0" readonly=""/>'+
                                '<input type="text" class="punto" name="punto_nombre[]" value="'+ciudad+'" readonly=""/>'+
                                '<input type="text" class="punto" name="punto_longitud[]" value="'+lng+'" readonly=""/>'+
                                '<input type="text" class="punto" name="punto_latitud[]" value="'+lat+'" readonly=""/>'+
                                '<input type="hidden" class="punto" name="punto_tipo[]" value="3" readonly=""/>'+
                                '<button class="boton-eliminar-punto">Eliminar</button>'+
                            '</div>'
                       );
                    }
                }
                apprise("Los puntos se guardaran cuando guardes la cobertura.",{'info':true, 'animate':true});
                
               //Quitamos markers
                if(markerRoute){
                    for(var i = 0, marcador; marcador = markerRoute[i]; i ++){
                        marcador.setMap(null);
                    }
                    markerRoute = [];
                    
                }
               
            };

            function limpiarMapa() {
                
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
      </script>
        <script type="text/javascript">
            $(document).ready(function(){
                ocultarTipoDePuntos();
                cargarPaises();
            });
            
            function cargarPaises() {
                $.getJSON( "/Gespro/json/countriesToCities.json", function( data ) {
                    $.each( data, function( key, val ) {
                        $('#selector-pais').append($('<option>', { 
                            value: key,
                            text : key 
                        }));
                    });
                });
            }
            
            
            function cargarCiudades( pais ) {
                // limpiamos el selector
                $('#selector-ciudad')
                    .find('option')
                    .remove()
                    .end()
                    .append('<option value="0">Seleccione una ciudad</option>');
                //consultamos los paise y las ciudades
                $.getJSON( "/Gespro/json/countriesToCities.json", function( data ) {
                    $.each( data, function( key, val ) {
                        // si encontramos el pais, obtenemos las ciudades y las agremaos
                        if( key == pais ) {
                            $.each(val, function( indice, ciudad ){
                                $('#selector-ciudad').append($('<option>', { 
                                    value: ciudad,
                                    text : ciudad 
                                }));                            
                            });
                        }
                    });
                });
            }
            
            
            function guardar(){ 
                    $.ajax({
                        type: "POST",
                        url: "ajax.jsp?accion=guardar",
                        data: $("#frm_action").serialize(),
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                            $("#ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            console.log("Datos");
                            console.log(datos);
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               $("#ajax_message").html("Los datos se guardaron correctamente.");
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").fadeIn("slow");
                               apprise('<center><img src=../../images/info.png> <br/>Los datos se guardaron correctamente.</center>',{'animate':true},
                                        function(r){
                                                javascript:window.location.href = "catCoberturas_list.jsp";
                                                parent.$.fancybox.close();  
                                        });
                           }else{
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").html("Ocurrió un error al intentar guardar los datos.");
                               $("#ajax_message").fadeIn("slow");
                               $("#action_buttons").fadeIn("slow");
                           }
                        }
                    });   
                }
        </script>
        
    </head>
    <body>
        <!--- Inicialización de variables --->
        <jsp:useBean id="helper" class="com.tsp.gespro.hibernate.dao.CoberturaDAO"/>
        <jsp:useBean id="usuariosModel" class="com.tsp.gespro.hibernate.dao.UsuariosDAO"/>
        
        <jsp:useBean id="clienteModel" class="com.tsp.gespro.hibernate.dao.ClienteDAO"/>
        <jsp:useBean id="services" class="com.tsp.gespro.Services.Allservices"/>
        <!--- @obj : Objeto de moneda a editar --->
        <c:set var="obj" value="${Cobertura}"/>
        <c:if test="${not empty param.id}">
            <fmt:parseNumber var="id" integerOnly="true" type="number" value="${param.id}" />
            <c:set var="obj" value="${helper.getById(id)}"/>
            <c:set var="where" value="where id_cobertura = ${id}"/>
            <c:set var="puntoLista" value="${services.queryPuntoDAO(where)}"/>
        </c:if>
        <c:if test="${empty param.id}">
            <fmt:parseNumber var="id" integerOnly="true" type="number" value="${param.id}" />
            <c:set var="obj" value="${helper.getById(0)}"/>
            <c:set var="where" value=""/>
        </c:if>
            
           <div class="content_wrapper">
            <jsp:include page="../include/header.jsp" flush="true"/>
            <jsp:include page="../include/leftContent.jsp"/>
            <!-- Inicio de Contenido -->
            <div id="content">
                <div class="inner" id="leito">
                    <h1>Cobertura</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>
                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    
                    <div class="twocolumn">
                        <div class="column_left">
                            <div class="header">
                                <span>                                    
                                    <img src="../../images/camion_icono_16.png" alt="icon"/>
                                    ${not empty param.id ? "Editar Cobertura" : "Nueva Cobertura"}
                                    ${not empty param.id ? param.id : ""}
                                </span>
                            </div>
                            <br class="clear"/>
                            <form action="" method="post" id="frm_action">
                            <div class="content">
                                    <input type="hidden" id="id" name="id" value="${ not empty obj.idCobertura ? obj.idCobertura :"0"}" />
                                    <p>
                                        <label>* Nombre:</label><br/>
                                        <input maxlength="45" type="text" id="nombre" name="nombre" style="width:300px"
                                               value="${not empty obj.nombre ? obj.nombre : ""}"
                                               data-validation="length"
                                               data-validation-length="1-45"
                                               data-validation-error-msg="El nombre debe tener de 1 a 45 caracteres."
                                               required
                                               />
                                    </p>
                                    <br/>
                                    <p>
                                        <label>* Tipo de punto:</label><br/>
                                        <input type="radio" name="punto" value="ciudad"> Ciudad
                                        <input type="radio" name="punto" value="cliente"> Cliente
                                        <input type="radio" name="punto" value="lugar"> Lugar
                                    </p>
                                    <br/>
                                    <div id="contenedor-cliente">
                                        <br/>                                    
                                        <p>
                                            <label>Cliente:</label><br/>
                                            <c:set var="clientes" value="${clienteModel.lista()}"/>
                                            <select id="idCliente" name="idCliente" style="width:300px;">
                                                <option value="0">Seleccione un cliente</option>
                                                <c:forEach items="${clientes}" var="cliente">
                                                    <option value="${cliente.idCliente}">${cliente.nombreComercial}</option>
                                                </c:forEach>
                                            </select><br>
                                        </p>
                                        <br/>
                                    </div>
                                    <div id="contenedor-pais">
                                        <p>
                                            <label>País:</label><br/>
                                            <select id="selector-pais" name="selector_pais" style="width:300px;">
                                                <option value="0">Seleccione un país</option>
                                            </select>
                                        </p>
                                        <p>
                                            <label>Ciudad:</label><br/>
                                            <select id="selector-ciudad" name="selector_ciudad" style="width:300px;">
                                                <option value="0">Seleccione una ciudad</option>
                                            </select>
                                        </p>
                                        <br/>
                                    </div>
                                    <br/>
                                    <button id="boton-agregar-zona" type="button">Agregar zona</button>
                                    <br/>
                                    <br/>
                                    <p>
                                        <label>Zona:</label><br/>
                                        <div id="puntos">
                                            <c:forEach items="<%=puntosList%>" var="punto">
                                                <div class="punto">
                                                    <input type="hidden" class="punto" name="punto_id[]" value="${punto.idPunto}" readonly=""/>
                                                    <input type="text" class="punto" name="punto_nombre[]" value="${punto.lugar}" readonly=""/>
                                                    <input type="text" class="punto" name="punto_longitud[]" value="${punto.longitud}" readonly=""/>
                                                    <input type="text" class="punto" name="punto_latitud[]" value="${punto.latitud}" readonly=""/>
                                                    <input type="hidden" class="punto" name="punto_tipo[]" value="${punto.tipo}" readonly=""/>
                                                    <button class="boton-eliminar-punto">Eliminar</button>
                                                </div>
                                                <br>
                                            </c:forEach>
                                        </div>
                                    </p>
                                    <div id="action_buttons">
                                        <p>
                                            <input type="submit" id="enviar" value="Guardar" class="btn"/>
                                            <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                                        </p>
                                    </div>                                       
                                </div>
                                    
                            </form>
                        </div>
                        <div class="column_right">
                                    <div class="header">
                                        <span>
                                            <img src="../../images/icon_logistica.png" alt="icon"/>
                                            Lugar
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
                                        <input type="button" onclick="puntos();" value="Recoger puntos"/>
                                        <input type="button" value="Limpiar" onclick="limpiarMapa();"/>
                                        <div id="map_canvas" style="height: 400px;width: auto">
                                            <img src="../../images/maps/ajax-loader.gif" alt="Cargando" style="margin: auto;"/>
                                        </div>
                                    </div>
                            </div>       
                     </div>
                    <!--TODO EL CONTENIDO VA AQUÍ-->

                </div>

                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
        <script src="http://cdnjs.cloudflare.com/ajax/libs/jquery-form-validator/2.3.26/jquery.form-validator.min.js"></script>
        <script>

         $(document).ready(function() {
            $.validate({
                 lang: 'en',
                 modules : 'toggleDisabled',
                 disabledFormFilter : 'form.toggle-disabled',
                 showErrorDialogs : true
             });
            $("#frm_action").submit(function(e){
               e.preventDefault();
               guardar();
            });
            $( "#selector-pais" ).change(function() {
                cargarCiudades( $("#selector-pais").val() );
            });
            $('input[name=punto]').change(function() {
                var tipoDePuntos = $(this).val();
                seleccionarTipoPunto( tipoDePuntos );
            });
            $('#boton-agregar-zona').click(function() {
                var tipoDePunto = $("input[type='radio'][name='punto']:checked").val();
                if ( tipoDePunto == "cliente" ) {
                    agregarZonaDelCliente( $( "#idCliente" ).val() );
                }
                if ( tipoDePunto == "ciudad" ) {
                    agregarZonaCiudad( $("#selector-ciudad").val() );
                }
            });
            $('.boton-eliminar-punto').click(function() {
                $(this).parent().remove();
            });
        });
        </script>
    </body>
</html>
