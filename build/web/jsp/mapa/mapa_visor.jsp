<%-- 
    Document   : mapa_visor
    Created on : 4/01/2013, 06:12:13 PM
    Author     : Luis
--%>

<%@page import="com.tsp.gespro.bo.ProspectoBO"%>
<%@page import="com.tsp.gespro.bo.DatosUsuarioBO"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.dto.Prospecto"%>
<%@page import="com.tsp.gespro.jdbc.EmpleadoBitacoraPosicionDaoImpl"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page import="com.tsp.gespro.dto.EstadoEmpleado"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.factory.EstadoEmpleadoDaoFactory"%>
<%@page import="com.tsp.gespro.factory.EmpleadoBitacoraPosicionDaoFactory"%>
<%@page import="com.tsp.gespro.dto.EmpleadoBitacoraPosicion"%>
<%@page import="com.tsp.gespro.factory.ClienteDaoFactory"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el usuario tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
} else {
    
        ///RECUPERAMOS LOS DATOS DE LA SESION
       
        String buscarTipoEnte = (String)request.getSession().getAttribute("buscarTipoEnte");
        String lat = (String)request.getSession().getAttribute("lat");
        String lng = (String)request.getSession().getAttribute("lng");
        String tipo = (String)request.getSession().getAttribute("tipo");
        String aux = (String)request.getSession().getAttribute("aux");
        String promId = (String)request.getSession().getAttribute("promId");
        String promTipo = (String)request.getSession().getAttribute("promTipo");
        String cooredenadasPromotor = (String)request.getSession().getAttribute("cooredenadasPromotor");
        String promotorTipo = (String)request.getSession().getAttribute("promotorDetalles");
        String latCl = (String)request.getSession().getAttribute("latCl");
        String lngCl = (String)request.getSession().getAttribute("lngCl");
        String cooredenadasCliente = (String)request.getSession().getAttribute("cooredenadasCliente");
        String clieId = (String)request.getSession().getAttribute("clieId");
        String clieTipo = (String)request.getSession().getAttribute("clieTipo");
        String clienteDetalles = (String)request.getSession().getAttribute("clienteDetalles");
        String cooredenadasPros = (String)request.getSession().getAttribute("cooredenadasPros");
        String prosId = (String)request.getSession().getAttribute("prosId");
        String prosTipo = (String)request.getSession().getAttribute("prosTipo");
        String prosDetalles = (String)request.getSession().getAttribute("prosDetalles");
        String latPros = (String)request.getSession().getAttribute("latPros");
        String lngPros = (String)request.getSession().getAttribute("lngPros");
                
        
        //VACIAMOS LOS DATOS DE SESION       
        request.getSession().setAttribute("buscarTipoEnte","");
        request.getSession().setAttribute("lat","");
        request.getSession().setAttribute("lng","");
        request.getSession().setAttribute("promotores","");
        request.getSession().setAttribute("aux","");
        request.getSession().setAttribute("promId","");
        request.getSession().setAttribute("promTipo","");
        request.getSession().setAttribute("cooredenadasPromotor","");
        request.getSession().setAttribute("promotorDetalles","");       
        request.getSession().setAttribute("cooredenadasCliente","");
        request.getSession().setAttribute("clienteDetalles","");
        request.getSession().setAttribute("clieId","");
        request.getSession().setAttribute("clieTipo","");
        request.getSession().setAttribute("clienteDetalles","");
        request.getSession().setAttribute("cooredenadasProspecto","");
        request.getSession().setAttribute("prosDetalles","");
        request.getSession().setAttribute("prosId","");
        request.getSession().setAttribute("prosTipo","");
      
        ///
    
    String buscar = request.getParameter("q")!=null? new String(request.getParameter("q").getBytes("ISO-8859-1"),"UTF-8") :"";
    String filtroBusqueda = "";
    if (!buscar.trim().equals(""))
        filtroBusqueda = " AND (NOMBRE_COMERCIAL LIKE '%" + buscar + "%' )";         
   
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
    Cliente[] clientesDto = null;
    Prospecto[] prospectosDto = null;
    Usuarios[] empleadosDto = null;
    Empresa empresa = new Empresa();   
   
    if(idEmpresa > 0){
                 
        EmpresaBO empresaBo = new EmpresaBO(user.getConn());    
        empresa = empresaBo.findEmpresabyId(idEmpresa); 
            
        try{
            ClienteBO clienteBO = new ClienteBO(user.getConn());
            clientesDto = clienteBO.findClientes(0, idEmpresa , 0, 0, " AND (LATITUD <> 0 AND LONGITUD <> 0 AND LATITUD <> 'null' AND LONGITUD <> 'null' AND LATITUD IS NOT NULL AND LONGITUD IS NOT NULL ) ");            
        }catch(Exception e){}
        try{
            ProspectoBO prospectoBO = new ProspectoBO(user.getConn());
            prospectosDto = prospectoBO.findProspecto(0, idEmpresa, 0, 0, " AND (LATITUD <> 0 AND LONGITUD <> 0 AND LATITUD IS NOT NULL AND LONGITUD IS NOT NULL ) ");           
        }catch(Exception e){}
        try{
            System.out.println("########################");
        
            UsuariosBO empleadoBO = new UsuariosBO(user.getConn());
            empleadosDto = empleadoBO.findUsuarios(0, idEmpresa, 0, 0, " AND ID_DISPOSITIVO != -1  AND (LATITUD <> 0 AND LONGITUD <> 0 AND LATITUD IS NOT NULL AND LONGITUD IS NOT NULL ) ");
        }catch(Exception e){}
    }
       
    //VARIABLE PARA OCULTAR DISEÑOS DEL HTML POR SI SE VA A MOSTRAR EN IFRAME:
    int dashboard = 0;
    try{
        dashboard = Integer.parseInt(request.getParameter("dashboard"));
    }catch(NumberFormatException ex){}
    
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <jsp:include page="../include/keyWordSEO.jsp" />

        <title><jsp:include page="../include/titleApp.jsp" /></title>

        <jsp:include page="../include/skinCSS.jsp" />

        <jsp:include page="../include/jsFunctions.jsp"/>
        
        <style type="text/css">
            .map_dialog input{
                width: 100%;
            }
        </style>
        
        <script type="text/javascript">
            
            var map;
            var poly;
            
            var medirListener;
            var medirDistance;
            var medirLastPoint;
            
            var directionDisplay;
            var directionsService;
            
            var drawingManager;
            var formaDibujada;
            
            var clientes = [];
            var prospectos = [];
            var promotores = [];
            var vehiculos = [];
            var puntos = [];
            
            var global = [];
            var markerRoute2 = [];
            var markerRoute;
            
            function initialize() {
                
                var rendererOptions = {
                    draggable: false
                };
                
                directionsService = new google.maps.DirectionsService();
                directionsDisplay = new google.maps.DirectionsRenderer(rendererOptions);
                
                //var inicio = new google.maps.LatLng(21.123619,-101.680496);//leon
                //var inicio = new google.maps.LatLng(23.634501,-102.552784);//mexico
                var inicio = new google.maps.LatLng(<%=empresa.getLatitud()%>,<%=empresa.getLongitud()%>);
                                
                var mapOptions = {
                  zoom: 15,
                  center: inicio,
                  mapTypeId: google.maps.MapTypeId.ROADMAP
                };

                map = new google.maps.Map(document.getElementById('map_canvas'),
                    mapOptions);
                    
                map.controls[google.maps.ControlPosition.TOP_RIGHT].push(
                FullScreenControl(map, 'Pantalla Completa',
                'Salir Pantalla Completa'));  
                
                directionsDisplay.setMap(map);
                
                drawingManager = new google.maps.drawing.DrawingManager({
                    drawingControl: false,
                    drawingControlOptions: {
                      position: google.maps.ControlPosition.TOP_CENTER,
                      drawingModes: [
                            google.maps.drawing.OverlayType.CIRCLE,
                            google.maps.drawing.OverlayType.POLYGON,
                            google.maps.drawing.OverlayType.RECTANGLE
                      ]
                    },
                    circleOptions:{
                        editable: true,
                        clickable: true
                    },
                    polygonOptions:{
                        editable: false,
                        clickable: true
                    },
                    rectangleOptions:{
                        editable: true,
                        clickable: true
                    }
                  });
                 drawingManager.setMap(map);
                 
                 google.maps.event.addListener(drawingManager, 'overlaycomplete', function(event) {
                    drawingManager.setOptions({
                        drawingMode: null
                    });
                    formaDibujada = event.overlay;
                    if (event.type == google.maps.drawing.OverlayType.CIRCLE){
                        google.maps.event.addListener(formaDibujada, 'radius_changed', function() {
                            $('#txt_map_radius').val(formaDibujada.getRadius().toFixed(2));
                            verificaMarcadores(formaDibujada.getBounds());
                        });
                        google.maps.event.addListener(formaDibujada, 'center_changed', function() {
                            $('#txt_map_radius').val(formaDibujada.getRadius().toFixed(2));
                            verificaMarcadores(formaDibujada.getBounds());
                        });
                        $('#txt_map_radius').val(formaDibujada.getRadius().toFixed(2));
                        verificaMarcadores(formaDibujada.getBounds());
                    }else if(event.type == google.maps.drawing.OverlayType.RECTANGLE) {
                        google.maps.event.addListener(formaDibujada, 'bounds_changed', function() {
                            verificaMarcadores(formaDibujada.getBounds());
                        });
                        verificaMarcadores(formaDibujada.getBounds());
                    }else if(event.type == google.maps.drawing.OverlayType.POLYGON) {
                        verificaMarcadores(polygonBounds(formaDibujada));
                    }
                  });
                
                fillMap();
                
            }
            
            function polygonBounds(polygon){
                var bounds = new google.maps.LatLngBounds();
                var path = polygon.getPath();
                for (var i = 0; i < path.getLength(); i++) {
                    var unit = path.getAt(i);
                    bounds.extend(unit);
                    
                }
                return bounds;
            }
            
            var divBuscar = 0
            function mostrarOcultarDirecciones(){
                if(divBuscar==1){
                    $("#div_map_tool_buscar").hide();
                    divBuscar = 0;
                }else{
                    $("#div_map_tool_buscar").show();
                    divBuscar = 1;
                }
            }
            
            function circulov2(){
                if(!formaDibujada){
                    drawingManager.setOptions({
                        drawingMode: google.maps.drawing.OverlayType.CIRCLE
                    });
                    $("#btn_map_medir").hide();
                    $("#btn_map_rectangulo").hide();
                    $("#btn_map_poligono").hide();
                    $("#div_map_buscar").hide();
                    $("#btn_map_buscar").hide();
                    $("#div_map_tool_circulo").show();
                    $("#btn_map_circulo").val('Parar');
                }else{
                    formaDibujada.setMap(null);
                    formaDibujada = null;
                    limpiarMapa();
                    $("#btn_map_medir").show();
                    $("#btn_map_rectangulo").show();
                    $("#btn_map_poligono").show();
                    $("#div_map_buscar").show();
                    $("#btn_map_buscar").show();
                    $("#div_map_tool_circulo").hide();
                    $("#btn_map_circulo").val('Círculo');
                }
            }
            
            function rectangulov2(){
                if(!formaDibujada){
                    drawingManager.setOptions({
                        drawingMode: google.maps.drawing.OverlayType.RECTANGLE
                    });
                    $("#btn_map_medir").hide();
                    $("#btn_map_circulo").hide();
                    $("#btn_map_poligono").hide();
                    $("#div_map_buscar").hide();
                    $("#btn_map_buscar").hide();
                    $("#div_map_tool_rectangulo").show();
                    $("#btn_map_rectangulo").val('Parar');
                }else{
                    formaDibujada.setMap(null);
                    formaDibujada = null;
                    limpiarMapa();
                    $("#btn_map_medir").show();
                    $("#btn_map_circulo").show();
                    $("#btn_map_poligono").show();
                    $("#div_map_buscar").show();
                    $("#btn_map_buscar").show();
                    $("#div_map_tool_rectangulo").hide();
                    $("#btn_map_rectangulo").val('Rectángulo');
                }
            }
            
            function poligonov2(){
                if(!formaDibujada){
                    drawingManager.setOptions({
                        drawingMode: google.maps.drawing.OverlayType.POLYGON
                    });
                    $("#btn_map_medir").hide();
                    $("#btn_map_circulo").hide();
                    $("#btn_map_rectangulo").hide();
                    $("#div_map_buscar").hide();
                    $("#div_map_tool_poligono").show();
                    $("#btn_map_buscar").hide();
                    $("#btn_map_poligono").val('Parar');
                }else{
                    formaDibujada.setMap(null);
                    formaDibujada = null;
                    limpiarMapa();
                    $("#btn_map_medir").show();
                    $("#btn_map_circulo").show();
                    $("#btn_map_rectangulo").show();
                    $("#div_map_buscar").show();
                    $("#btn_map_buscar").show();
                    $("#div_map_tool_poligono").hide();
                    $("#btn_map_poligono").val('Polígono');
                }
            }
        
            function fillMap(){
                <%
                for(Cliente clienteDto:clientesDto){
                    String nombreCliente = clienteDto.getNombreComercial();
                    String dialogoCliente = ""
                         + "<div class='map_dialog'>"
                         + "   <b>Cliente:</b><br/>" + nombreCliente.replaceAll("\\\"", "&quot;") + "<br/><br/>"
                         + "   <li> <a title='Detalles' onclick='muestraDetallesCliente(" + clienteDto.getIdCliente() + ",1)'>Detalles </a> </li> <br/>"
                         //+ "   <li> <a title='Pagos' onclick='muestraDetallesCliente(" + clienteDto.getIdCliente() + ",2)'>Pagos </a> </li> <br/>"
                         + " </div>";
                    %>
                     clientes.push(
                         creaMarcador(
                             <%=clienteDto.getLatitud()!=0?clienteDto.getLatitud():0%>,
                             <%=clienteDto.getLongitud()!=0?clienteDto.getLongitud():0%>,
                             "<%=nombreCliente.replaceAll("\\\"", "&quot;") %>",
                             "../../images/maps/map_marker_cte.png",
                             "<%=dialogoCliente %>"
                         )
                     );
                    <%
                }
                %>
                <%
                for(Prospecto prospectoDto:prospectosDto){
                    String nombreCliente = prospectoDto.getContacto();
                    String dialogoCliente = ""
                        + "<div class='map_dialog'>"
                        + "    <b>Prospecto:</b><br/>" + nombreCliente.replaceAll("\\\"", "&quot;") + "<br/><br/>"
                        + "    <li> <a title='Detalles' onclick='muestraDetallesProspecto(" + prospectoDto.getIdProspecto() + ",1)'>Detalles </a> </li><br/>"
                        + "</div>";
                    %>
                    prospectos.push(
                        creaMarcador(
                            <%=prospectoDto.getLatitud()!=0?prospectoDto.getLatitud():empresa.getLatitud() %>,
                            <%=prospectoDto.getLongitud()!=0?prospectoDto.getLongitud():empresa.getLongitud()%>,
                            "<%=nombreCliente.replaceAll("\\\"", "&quot;") %>",
                            "../../images/maps/map_marker_pros.png",
                            "<%=dialogoCliente %>"
                        )
                    );         
                    <%
                }
                %>
                <%
                
                for(Usuarios empleadoDto:empleadosDto){
                    
                    EmpleadoBitacoraPosicion bitEmp = null;
                    try{
                        EmpleadoBitacoraPosicionDaoImpl bitacoraDao = new EmpleadoBitacoraPosicionDaoImpl();
                        String filtro = " ID_USUARIO = "+ empleadoDto.getIdUsuarios()+ " ORDER BY FECHA DESC LIMIT 0,1";
                        bitEmp = bitacoraDao.findByDynamicWhere(filtro,null)[0];                       
                    }catch(Exception e){
                    
                    }
                    
                    
                    DatosUsuario datosUsuario = new DatosUsuarioBO(empleadoDto.getIdDatosUsuario(),user.getConn()).getDatosUsuario();
                    
                    EstadoEmpleado estadoDto = EstadoEmpleadoDaoFactory.create().findByPrimaryKey(empleadoDto.getIdEstadoEmpleado());
                    String nombreMarcador = datosUsuario.getNombre() + " " + datosUsuario.getApellidoPat() +" "+ datosUsuario.getApellidoMat();
                    String dialogoMarcador = ""
                        + "<div class='map_dialog'><b>";                        
                        dialogoMarcador += "Promotor";
                        dialogoMarcador += ":</b></br>" + nombreMarcador.replaceAll("\\\"", "&quot;") + "<br/>"
                        + "    <b>Estado:</b> " + (estadoDto!=null?estadoDto.getNombre():"SIN DETALLE") + "<br/>"
                        + "    <li> <a title='Detalles' onclick='muestraDetallesPromotor("+empleadoDto.getIdUsuarios()+",1);'>Detalles </a> </li> <br/>"
                        + "    <li> <a title='Hist&oacute;rico' onclick='muestraDetallesPromotor("+empleadoDto.getIdUsuarios()+",2);'>Hist&oacute;rico </a> </li><br/>"                        
                        + "    <li> <a title='Mensaje' onclick='muestraDetallesPromotor("+empleadoDto.getIdUsuarios()+",4);'>Mensaje </a> </li> <br/>"
                        
                        + "</div>";
                    %>
                    promotores.push(
                        creaMarcador(
                            <%=bitEmp.getLatitud()!=0?bitEmp.getLatitud():empresa.getLatitud()%>,
                            <%=bitEmp.getLongitud()!=0?bitEmp.getLongitud():empresa.getLongitud()%>,
                            "<%=nombreMarcador.replaceAll("\\\"", "&quot;") %>", 
                            <% long s = (new Date()).getTime();
                            long d = 0; 
                            try{
                                d = bitEmp.getFecha().getTime();                                
                            }catch(Exception e){}
                            long diferencia = s - d;
                            System.out.println("-------DIFERENCIA: "+diferencia);
                            if(diferencia < 300000){
                            %>
                                icon = "../../images/estatusEmpleado/icon_activoTrabajando.png",
                            <%}else{%>
                                icon = "../../images/estatusEmpleado/icon_desactivado.png",
                            <%}%>
                                                                                               
                                "<%=dialogoMarcador%>"
                            )
                    );
                    <%
                }
                %>
                
            }
        
            function limpiarMapa(){
                
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
            
                for(var i = 0, marcador; marcador = clientes[i]; i ++){
                    marcador.setMap(null);
                }
            
                for(var i = 0, marcador; marcador = prospectos[i]; i ++){
                    marcador.setMap(null);
                }
                for(var i = 0, marcador; marcador = promotores[i]; i ++){
                    marcador.setMap(null);
                }
                /*for(var i = 0, marcador; marcador = vehiculos[i]; i ++){
                    marcador.setMap(null);
                }*/
                for(var i = 0, marcador; marcador = puntos[i]; i ++){
                    marcador.setMap(null);
                }
            }

            function loadScript() {
                var script = document.createElement('script');
                script.type = 'text/javascript';
                script.src = 'https://maps.googleapis.com/maps/api/js?libraries=geometry,drawing&sensor=false&' +
                    'callback=initialize';
                document.body.appendChild(script);
            }

            window.onload = loadScript;
            
            function creaMarcador(lat,lng,title,img,content){
                var marcador = new google.maps.Marker({
                        position: new google.maps.LatLng(lat,lng), 
                        title:title,
                        animation: google.maps.Animation.DROP,
                        icon:img
                    });
                var infowindow = new google.maps.InfoWindow({
                    content: content
                });
                google.maps.event.addListener(marcador, 'click', function() {
                    infowindow.open(map,marcador);
                });
                /*var infoBubble = new InfoBubble({
                  map: map,
                  content: '<div class="infoBubble">'+content+'</div>',
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
        
                google.maps.event.addListener(marcador, 'click', function() {
                    infoBubble.open(map, marcador);
                });*/
                
        
                return marcador;
            }
        
            function creaMarcadorBasico(lat,lng,title){
                var marcador = new google.maps.Marker({
                        position: new google.maps.LatLng(lat,lng), 
                        title:title,
                        animation: google.maps.Animation.DROP
                    });
                return marcador;
            }
            
            function muestraMarcador(chk){
                switch(chk.id){
                    case "clientes":
                        if(chk.checked){
                            for(var i = 0, marcador; marcador = clientes[i]; i ++){
                                marcador.setMap(map);
                            }
                        }else{
                            for(var i = 0, marcador; marcador = clientes[i]; i ++){
                                marcador.setMap(null);
                            }
                        }
                        break;
                    case "prospectos":
                        if(chk.checked){
                            
                            for(var i = 0, marcador; marcador = prospectos[i]; i ++){
                                marcador.setMap(map);
                            }
                        }else{
                            for(var i = 0, marcador; marcador = prospectos[i]; i ++){
                                marcador.setMap(null);
                            }
                        }
                        break;
                    case "promotores":
                        if(chk.checked){
                            
                            for(var i = 0, marcador; marcador = promotores[i]; i ++){
                                marcador.setMap(map);
                            }
                        }else{
                            for(var i = 0, marcador; marcador = promotores[i]; i ++){
                                marcador.setMap(null);
                            }
                        }
                        break;
                    case "vehiculos":
                        if(chk.checked){
                            
                            for(var i = 0, marcador; marcador = vehiculos[i]; i ++){
                                marcador.setMap(map);
                            }
                        }else{
                            for(var i = 0, marcador; marcador = vehiculos[i]; i ++){
                                marcador.setMap(null);
                            }
                        }
                        break;
                    case "puntos":
                        if(chk.checked){
                            
                            for(var i = 0, marcador; marcador = puntos[i]; i ++){
                                marcador.setMap(map);
                            }
                        }else{
                            for(var i = 0, marcador; marcador = puntos[i]; i ++){
                                marcador.setMap(null);
                            }
                        }
                        break;
                }             
            }
            
            function buscarMarcador(){
                $.ajax({
                    type: "POST",
                    url: "mapaBuscador_ajax.jsp",
                    data: $("#form_mapa_buscador").serialize(),
                    beforeSend: function(objeto){
                        //$("#action_buttons").fadeOut("slow");
                        $("#div_map_resultado_buscar").html("");
                        $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("--EXITO-->", 0)>0){
                           $("#div_map_resultado_buscar").html(datos);
                           $("#ajax_loading").fadeOut("slow");
                           //$("#ajax_message").fadeIn("slow");
                           //apprise('<center><img src=../../images/info.png> <br/>'+ datos +'</center>',{'animate':true},
                           //         function(r){
                           //             location.href = "catSucursales_list.jsp";
                           //         });
                       }else{
                           $("#ajax_loading").fadeOut("slow");
                           $("#ajax_message").html(datos);
                           $("#ajax_message").fadeIn("slow");
                           //$("#action_buttons").fadeIn("slow");
                           //$.scrollTo('#inner',800);
                       }
                    }
                });
            }
            
            function muestraMarcadorBusqueda(lat,lng,tipo,aux){
                
                var tipoDatos = "";
                if(tipo == "clientes"){
                    tipoDatos = "clientes";
                }else if(tipo == "promotores"){
                    tipoDatos = "promotores";
                } else if(tipo == "prospectos"){
                    tipoDatos = "prospectos";
                }
                
                cargarSesion2(lat,lng,tipo,aux,tipoDatos);
                switch(tipo){
                    case "clientes":
                        for(var i = 0, marcador; marcador = clientes[i]; i ++){
                            var posicion = marcador.getPosition();
                            var posicion2 = new google.maps.LatLng(lat,lng);
                            if(posicion.lat()==posicion2.lat() && posicion.lng()==posicion2.lng()){
                                if(marcador.getMap()==null){
                                    var mapOptions = {
                                            center: posicion,
                                            zoom: 15,
                                            mapTypeId: google.maps.MapTypeId.ROADMAP
                                    };
                                    map.setOptions(mapOptions);
                                    marcador.setMap(map);
                                }else{
                                    marcador.setMap(null);
                                }
                            }
                        }
                        break;
                    case "prospectos":
                        for(var i = 0, marcador; marcador = prospectos[i]; i ++){
                            var posicion = marcador.getPosition();
                            var posicion2 = new google.maps.LatLng(lat,lng);
                            if(posicion.lat()==posicion2.lat() && posicion.lng()==posicion2.lng()){
                                if(marcador.getMap()==null){
                                    var mapOptions = {
                                            center: posicion,
                                            zoom: 15,
                                            mapTypeId: google.maps.MapTypeId.ROADMAP
                                    };
                                    map.setOptions(mapOptions);
                                    marcador.setMap(map);
                                }else{
                                    marcador.setMap(null);
                                }
                            }
                        }
                        break;
                    case "promotores":
                        for(var i = 0, marcador; marcador = promotores[i]; i ++){
                            var posicion = marcador.getPosition();
                            var posicion2 = new google.maps.LatLng(lat,lng);
                            if(posicion.lat()==posicion2.lat() && posicion.lng()==posicion2.lng()){
                                if(marcador.getMap()==null){
                                    var mapOptions = {
                                            center: posicion,
                                            zoom: 15,
                                            mapTypeId: google.maps.MapTypeId.ROADMAP
                                    };
                                    map.setOptions(mapOptions);
                                    marcador.setMap(map);
                                }else{
                                    marcador.setMap(null);
                                }
                            }
                        }
                        break;
                    case "vehiculos":
                        for(var i = 0, marcador; marcador = vehiculos[i]; i ++){
                            var posicion = marcador.getPosition();
                            var posicion2 = new google.maps.LatLng(lat,lng);
                            if(posicion.lat()==posicion2.lat() && posicion.lng()==posicion2.lng()){
                                if(marcador.getMap()==null){
                                    var mapOptions = {
                                            center: posicion,
                                            zoom: 15,
                                            mapTypeId: google.maps.MapTypeId.ROADMAP
                                    };
                                    map.setOptions(mapOptions);
                                    marcador.setMap(map);
                                }else{
                                    marcador.setMap(null);
                                }
                            }
                        }
                        break;
                    case "puntos":
                        for(var i = 0, marcador; marcador = puntos[i]; i ++){
                            var posicion = marcador.getPosition();
                            var posicion2 = new google.maps.LatLng(lat,lng);
                            if(posicion.lat()==posicion2.lat() && posicion.lng()==posicion2.lng()){
                                if(marcador.getMap()==null){
                                    var mapOptions = {
                                            center: posicion,
                                            zoom: 15,
                                            mapTypeId: google.maps.MapTypeId.ROADMAP
                                    };
                                    map.setOptions(mapOptions);
                                    marcador.setMap(map);
                                }else{
                                    marcador.setMap(null);
                                }
                            }
                        }
                        break;
                    
                }  
            }
        
            function muestraDetallesPromotor(id, tipo){
                var url = "";
                switch(tipo){
                    case 1:
                        url = "detallesPromotor_ajax.jsp";
                        break;
                    case 2:
                        url = "historicoPromotor_ajax.jsp";
                        break;
                    case 3:
                        url = "cobrosPromotor_ajax.jsp";
                        break;
                    case 4:
                        //url = "mensajePromotor_ajax.jsp";
                        var htmlForm = ""
                            + "<form method='POST' action='' id='frm_mensaje_promotor'>"
                            + "<input type='hidden' name='id' value='" + id + "'>"
                            + "<p>"
                            + "<label>Enviar mensaje a vendedor:</label><br/>"
                            + "<textarea name='txt_mensaje' id='txt_mensaje' rows='8' cols='60'></textarea>"
                            + "</p>"
                            + "<div id='frm_mensaje_action_buttons'>"
                            + "<input type='button' id='enviar' value='Enviar' onclick='enviarMensaje();'/>"
                            + "</div>"
                            + "</form>";
                        $("#div_map_resultado_buscar").html(htmlForm);
                        break;
                    case 5:
                        url = "rutasPromotor_ajax.jsp";
                        break;
                    case 6:
                    url = "pedidosPromotor_ajax.jsp";
                    break;
                }
                if(url!=""){
                    muestraVentanaDetalles(url,id);
                }
            }
        
            function muestraDetallesCliente(id, tipo){
                
                cargarSesion2(id,tipo,"","","detallesCliente");
                var url = "";
                switch(tipo){
                    case 1:
                        url = "detallesCliente_ajax.jsp";
                        break;
                    case 2:
                        url = "pagosCliente_ajax.jsp";
                        break;
                }
                if(url!=""){
                    muestraVentanaDetalles(url,id);
                }
            }
        
            function muestraDetallesProspecto(id, tipo){
                var url = "";
                switch(tipo){
                    case 1:
                        url = "detallesProspecto_ajax.jsp";
                        break;
                }
                if(url!=""){
                    muestraVentanaDetalles(url,id);
                }
            }
        
            function muestraVentanaDetalles(url, id){
                
                $.ajax({
                    type: "GET",
                    url: url,
                    //data: $("#form_mapa_buscador").serialize(),
                    data: {id:id},
                    beforeSend: function(objeto){
                        //$("#action_buttons").fadeOut("slow");
                        $("#div_map_resultado_buscar").html("");
                        $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("--EXITO-->", 0)>0){
                           $("#div_map_resultado_buscar").html(datos);
                           $("#ajax_loading").fadeOut("slow");
                           datePicker();
                           //$("#ajax_message").fadeIn("slow");
                           //apprise('<center><img src=../../images/info.png> <br/>'+ datos +'</center>',{'animate':true},
                           //         function(r){
                           //             location.href = "catSucursales_list.jsp";
                           //         });
                       }else{
                           $("#ajax_loading").fadeOut("slow");
                           $("#ajax_message").html(datos);
                           $("#ajax_message").fadeIn("slow");
                           //$("#action_buttons").fadeIn("slow");
                           //$.scrollTo('#inner',800);
                       }
                    }
                });
            }
            
            function actualizarHistorico(id){
                $.ajax({
                    type: "GET",
                    url: "historicoPromotor_ajax.jsp",
                    //data: $("#form_mapa_buscador").serialize(),
                    data: {id:id,fechaDe:$("#txt_fecha_de").val(),fechaA:$("#txt_fecha_a").val()},
                    beforeSend: function(objeto){
                        //$("#action_buttons").fadeOut("slow");
                        $("#div_map_resultado_buscar").html("");
                        $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("--EXITO-->", 0)>0){
                           $("#div_map_resultado_buscar").html(datos);
                           $("#ajax_loading").fadeOut("slow");
                           datePicker();
                           //$("#ajax_message").fadeIn("slow");
                           //apprise('<center><img src=../../images/info.png> <br/>'+ datos +'</center>',{'animate':true},
                           //         function(r){
                           //             location.href = "catSucursales_list.jsp";
                           //         });
                       }else{
                           $("#ajax_loading").fadeOut("slow");
                           $("#ajax_message").html(datos);
                           $("#ajax_message").fadeIn("slow");
                           //$("#action_buttons").fadeIn("slow");
                           //$.scrollTo('#inner',800);
                       }
                    }
                });
            }
            
            var timeout;
            
            function reproducirHistorico(i){
                limpiarMapa();
                centrarMapa(i,null);
                
            }
            function cambiaRuta(idRuta){
                location.href = "logistica_consulta.jsp?idRuta="+idRuta;
                
            }
        
            function centrarMapa(i,obj){
                if(obj!=null){
                    obj.setMap(null);
                }
                var arr = document.getElementsByName("marcadores_buscar");
                if(arr.length>0 && i<arr.length){
                   
                   var pos = arr[i].value.split(",");
                   var mapOptions = {
                        center: new google.maps.LatLng(pos[0],pos[1]),
                        mapTypeId: google.maps.MapTypeId.ROADMAP
                    };
                    map.setOptions(mapOptions);
                    
                    var marcador = new google.maps.Marker({
                        position: new google.maps.LatLng(pos[0],pos[1]), 
                        title:"marcador",
                        animation: google.maps.Animation.DROP,
                        map:map
                    });
                   
                   //timeout = setTimeout("centrarMapa("+(i+1)+","+marcador+")",1500);
                   timeout = setTimeout(function(){
                       centrarMapa(i+1,marcador,1);
                   },2000);
                
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
        
            function medir(){
                if(medirListener){
                    $("#btn_map_circulo").show();
                    $("#btn_map_rectangulo").show();
                    $("#div_map_buscar").show();
                    $("#btn_map_buscar").show();
                    $("#btn_map_medir").val('Medir');
                    $("#div_map_medir_tool").hide();
                    $("#btn_map_poligono").show();
                    medirListener = null;
                    medirDistance = 0;
                    medirLastPoint = null;
                    poly.setMap(null);
                    poly = null;
                    $('#txt_map_distance').val('0');
                    google.maps.event.clearListeners(map, 'click');
                    var mapOptions = {
                        draggableCursor:null
                    };
                    map.setOptions(mapOptions);
                }else{
                    $("#btn_map_circulo").hide();
                    $("#btn_map_rectangulo").hide();
                    $("#btn_map_poligono").hide();
                    $("#div_map_buscar").hide();
                    $("#btn_map_buscar").hide();
                    $("#btn_map_medir").val('Parar');
                    $("#div_map_medir_tool").show();
                    var polyOptions = {
                        strokeColor: '#000000',
                        strokeOpacity: 1.0,
                        strokeWeight: 3,
                        editable:false
                    }
                    poly = new google.maps.Polyline(polyOptions);
                    poly.setMap(map);
                    medirListener = addLatLng;
                    medirDistance = 0;
                    medirLastPoint = null;
                    $('#txt_map_distance').val('0');
                    google.maps.event.addListener(map, 'click', medirListener);
                    var mapOptions = {
                        draggableCursor:'crosshair'
                    };
                    map.setOptions(mapOptions);
                }
                
            }
        
            var circuloListener;
            var circle;
            var markerCircle;
        
            function circulo(){
                if(circuloListener){
                    $("#btn_map_medir").show();
                    $("#div_map_circulo_tool").hide();
                    $("#btn_map_circulo").val('Circulo');
                    circuloListener = null;
                    circle.setMap(null);
                    circle=null;
                    markerCircle.setMap(null);
                    google.maps.event.clearListeners(map, 'click');        
                    limpiarMapa();
                    
                }else{
                    $("#btn_map_medir").hide();
                    $("#btn_map_circulo").val('Parar');
                    circuloListener = fCirculoListener;
                    google.maps.event.addListener(map, 'click', circuloListener);
                }
                
            }
        
            function aumentaCirculo(){
                var radius = circle.getRadius();
                if(radius<<10000){
                    circle.setRadius(radius + 50);
                    verificaMarcadores(circle.getBounds());
                }
            }
        
            function disminuyeCirculo(){
                var radius = circle.getRadius();
                if(radius>500){
                    circle.setRadius(radius - 50);
                    verificaMarcadores(circle.getBounds());
                }
            }
        
            function fCirculoListener(event){
                if(!circle){
                    $("#div_map_circulo_tool").show();
                    markerCircle = new google.maps.Marker({
                        position: event.latLng, 
                        map: map,
                        draggable: true
                    });
                    circle = new google.maps.Circle({
                        map: map,
                        clickable: false,
                        // metres
                        radius: 1000,
                        fillColor: '#fff',
                        fillOpacity: .6,
                        strokeColor: '#313131',
                        strokeOpacity: .4,
                        strokeWeight: .8,
                        center: event.latLng
                    });

                    circle.bindTo('center', markerCircle, 'position');

                    var bounds = circle.getBounds();
                    verificaMarcadores(bounds);

                    google.maps.event.addListener(markerCircle, 'dragend', function() {
                        //latLngCenter = new google.maps.LatLng(markerCircle.position.lat(), markerCircle.position.lng());
                        bounds = circle.getBounds();
                        verificaMarcadores(bounds);
                    });

                }
            }
            
            function verificaMarcadores(bounds){
                for(var i = 0, marcador; marcador = clientes[i]; i ++){
                    if(bounds.contains(marcador.getPosition())){
                        marcador.setMap(map);
                    }else{
                        marcador.setMap(null);
                    }
                }
                
                for(var i = 0, marcador; marcador = prospectos[i]; i ++){
                    if(bounds.contains(marcador.getPosition())){
                        marcador.setMap(map);
                    }else{
                        marcador.setMap(null);
                    }
                }
                
                for(var i = 0, marcador; marcador = promotores[i]; i ++){
                    if(bounds.contains(marcador.getPosition())){
                        marcador.setMap(map);
                    }else{
                        marcador.setMap(null);
                    }
                }
                
                /*for(var i = 0, marcador; marcador = vehiculos[i]; i ++){
                    if(bounds.contains(marcador.getPosition())){
                        marcador.setMap(map);
                    }else{
                        marcador.setMap(null);
                    }
                }*/
                
                for(var i = 0, marcador; marcador = puntos[i]; i ++){
                    if(bounds.contains(marcador.getPosition())){
                        marcador.setMap(map);
                    }else{
                        marcador.setMap(null);
                    }
                }
            }
        
            function addLatLng(event) {

                var path = poly.getPath();

                // Because path is an MVCArray, we can simply append a new coordinate
                // and it will automatically appear
                path.push(event.latLng);

                if(medirLastPoint){
                    var distance = google.maps.geometry.spherical.computeDistanceBetween(medirLastPoint, event.latLng);
                    //medirDistance += (distance/1000) ;
                    medirDistance += (distance) ;
                    $('#txt_map_distance').val(medirDistance.toFixed(2));                
                }
                medirLastPoint = event.latLng;
                
                // Add a new marker at the new plotted point on the polyline.
                /*var marker = new google.maps.Marker({
                  position: event.latLng,
                  title: '#' + path.getLength(),
                  map: map
                });*/
          }
      
          function enviarMensaje(){
              $.ajax({
                    type: "POST",
                    url: "envioMensajePromotor_ajax.jsp",
                    data: $("#frm_mensaje_promotor").serialize(),
                    beforeSend: function(objeto){
                        //$("#action_buttons").fadeOut("slow");
                        //$("#div_map_resultado_buscar").html("");
                        $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("--EXITO-->", 0)>0){
                           $("#div_map_resultado_buscar").html(datos);
                           $("#ajax_loading").fadeOut("slow");
                           //$("#ajax_message").fadeIn("slow");
                           //apprise('<center><img src=../../images/info.png> <br/>'+ datos +'</center>',{'animate':true},
                           //         function(r){
                           //             location.href = "catSucursales_list.jsp";
                           //         });
                       }else{
                           $("#ajax_loading").fadeOut("slow");
                           $("#ajax_message").html(datos);
                           $("#ajax_message").fadeIn("slow");
                           //$("#action_buttons").fadeIn("slow");
                           //$.scrollTo('#inner',800);
                       }
                    }
                });
          }
          
          function datePicker() {
            if($( "#txt_fecha_de" )){
                $( "#txt_fecha_de" ).datepicker({
                  changeMonth: true,
                  changeYear: true,
                  dateFormat: "dd/mm/yy"
                });
            }
            if($( "#txt_fecha_a" )){
                $( "#txt_fecha_a" ).datepicker({
                  changeMonth: true,
                  changeYear: true,
                  dateFormat: "dd/mm/yy"
                });
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
            function crearMarcadorBasico(location){
                var marker = new google.maps.Marker({
                    position: location, 
                    map: map
                });
                google.maps.event.addListener(marker, 'click', function(event) {
                    quitarMarcador(event.latLng);
                });
                markerRoute2.push(marker);
            }
            function quitarMarcador(location){
                for(var i = 0, marcador; marcador = markerRoute2[i]; i ++){
                    if(marcador.getPosition().lat()==location.lat() && marcador.getPosition().lng()==location.lng()){
                        marcador.setMap(null);
                    }
                }
            }
            
      </script>
            
            
      <script language="javascript1.1">
         
          var dn;
          c1=new Image(); c1x="../../images/reloj/c1.png";
          c2=new Image(); c2x="../../images/reloj/c2.png";
          c3=new Image(); c3x="../../images/reloj/c3.png";
          c4=new Image(); c4x="../../images/reloj/c4.png";
          c5=new Image(); c5x="../../images/reloj/c5.png";
          c6=new Image(); c6x="../../images/reloj/c6.png";
          c7=new Image(); c7x="../../images/reloj/c7.png";
          c8=new Image(); c8x="../../images/reloj/c8.png";
          c9=new Image(); c9x="../../images/reloj/c9.png";
          c0=new Image(); c0x="../../images/reloj/c0.png";
          cb=new Image(); cbx="../../images/reloj/c0.png";
          cam=new Image(); camx="../../images/reloj/cam.png";
          cpm=new Image(); cpmx="../../images/reloj/cpm.png";

          function extract(h,m,s,type){
                  if (!document.images)
                          return;
                  if (h<=9){
                          //document.images.a.src=cb.src;
                          document.getElementById("a").src=cbx;
                          document.getElementById("b").src=eval("c"+h+"x");
                  }
                  else {
                          document.getElementById("a").src=eval("c"+Math.floor(h/10)+"x");
                          document.getElementById("b").src=eval("c"+(h%10)+"x");
                  }
                  if (m<=9){
                          document.getElementById("d").src=c0x;
                          document.getElementById("e").src=eval("c"+m+"x");
                  }
                  else {
                          document.getElementById("d").src=eval("c"+Math.floor(m/10)+"x");
                          document.getElementById("e").src=eval("c"+(m%10)+"x");
                  }
                  if (s<=9){
                          document.getElementById("g").src=c0x;
                          document.getElementById("h").src=eval("c"+s+"x");
                  }
                  else {
                          document.getElementById("g").src=eval("c"+Math.floor(s/10)+"x");
                          document.getElementById("h").src=eval("c"+(s%10)+"x");
                  }
                  /*if (dn=="AM") 
                          document.j.src=cam.src;
                  else 
                          document.images.j.src=cpm.src;*/
          }

         /* function show3(){
                  if (!document.images)
                          return;
                  var Digital=new Date();
                  var hours=Digital.getHours();
                  var minutes=Digital.getMinutes();
                  var seconds=Digital.getSeconds();
                  dn="AM" ;
                  if ((hours>=12)&&(minutes>=1)||(hours>=13)){
                          dn="PM";
                          hours=hours-12;
                  }
                  if (hours==0)
                          hours=12;
                  extract(hours,minutes,seconds,dn);
                  setTimeout("show3()",1000);
          }*/
                               
          var minutes=4;
          var seconds=60;
          function show3(){
                  if (!document.images)
                          return;                  
                  var hours=0;
                  
                  seconds = seconds - 1;
                  if(seconds == 0){
                      seconds=60;
                      minutes = minutes - 1;
                  }        
                  dn="AM" ;                                    
                  extract(hours,minutes,seconds,dn);
                  setTimeout("show3()",1000);
          }

          //-->

      </script>             
    </head>
    <body <%if(dashboard == 1){%>class="nobg"<%}%>>
        <div class="content_wrapper">

            <%if(dashboard == 0){%>
            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>
            <%}%>

            <!-- Inicio de Contenido -->
            <div <%if(dashboard == 0){%>id="content"<%}%>>
                
                <div class="inner">
                    <%if(dashboard == 0){%>
                    <h1>Mapas</h1>
                    <div>
                        <tr>
                            <td>
                                <img src="../../images/reloj/letrero.png" name="letrero" id="letrero"><img src="../../images/reloj/c0.png" name="a" id="a"><img src="../../images/reloj/c0.png" name="b" id="b"><img src="../../images/reloj/colon.png" name="c" id="c"><img src="../../images/reloj/c0.png" name="d" id="d"><img src="../../images/reloj/c0.png" name="e" id="e"><img src="../../images/reloj/colon.png" name="f" id="f"><img src="../../images/reloj/c0.png" name="g" id="g"><img src="../../images/reloj/c0.png" name="h" id="h">
                        <li><a href="mapa_visor.jsp" title="Refrescar" >Refrescar</a></li>
                            </td>
                        </tr>
                    </div>
                    <%}%>

                    
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--<form id="form_data" name="form_data" action="" method="post">-->
                    <div class="twocolumn" style="margin: 1px 0 1px 0;">
                            <div class="column_left" style="height: 488px; <%if(dashboard == 1){%>visibility: hidden<%}%>">
                                <div class="header">
                                    <span>
                                        <img src="../../images/icon_mapa.png" alt="icon"/>
                                        Opciones
                                    </span>
                                    <div class="switch" style="width:410px">

                                    </div>
                                </div>
                                <br class="clear"/>
                                <div class="content">
                                    <label><h4>Mostrar en Mapa:</h4></label>
                                    <p>
                                        <input id="clientes" type="checkbox" onclick="muestraMarcador(this);"/>Clientes<br/>
                                        <input id="prospectos" type="checkbox" onclick="muestraMarcador(this);"/>Prospectos<br/>
                                        <input id="promotores" type="checkbox" onclick="muestraMarcador(this);"/>Promotores<br/>
                                        <!--<input id="vehiculos" type="checkbox" onclick="muestraMarcador(this);"/>Veh&iacute;culos<br/>-->
                                        <!--<input id="puntos" type="checkbox" onclick="muestraMarcador(this);"/>Puntos de inter&eacute;s-->
                                        <!--<input type="button" onclick="calcRoute();" value="Ruta"/>-->
                                    </p>
                                    </br>
                                    <p>
                                        <form id="form_mapa_buscador" name="form_mapa_buscador" action="" method="post">
                                            <label><h4>Busqueda Avanzada: <h4></label>
                                            <input maxlength="30" type="text" id="txt_buscar" name="txt_buscar" style="width:300px" value=""/>
                                            <select id="cmb_tipo_buscar" name="cmb_tipo_buscar">
                                                <option value="todos" selected>Todos</option>
                                                <option value="clientes">Clientes</option>
                                                <option value="prospectos">Prospectos</option>
                                                <option value="promotores">Promotores</option>   
                                            </select>
                                            <!--<input type="image" src="../../images/icon_consultar.png" title="Buscar" onclick="buscarMarcador();"/>-->
                                            <input type="button" value="Buscar" onclick="buscarMarcador();"/>
                                        </form>
                                    </p>
                                    <p>
                                        <br/>
                                        <div id="div_map_resultado_buscar" style="height: 210px;overflow: scroll;"></div>
                                    </p>
                                </div>
                            </div>
                                <div class="column_right" <%if(dashboard == 1){%>style="position: absolute; width: 99.5%;"<%}%>>
                                <div class="header">
                                    <span>
                                        <img src="../../images/icon_mapa.png" alt="icon"/>
                                        Visor
                                    </span>
                                    <div class="switch" style="width:410px">

                                    </div>
                                </div>
                                <br class="clear"/>
                                <div class="content">
                                    
                                    <input type="image" src="../../images/maps/tool_medir_distancia.png" id="btn_map_medir" value="Medir" title="Medir distancia" onclick="medir();"/>
                                    <input type="image" src="../../images/maps/tool_puntos_circulo.png" id="btn_map_circulo" value="C&iacute;rculo" title="Seleccionar puntos por círculo" onclick="circulov2();"/>
                                    <input type="image" src="../../images/maps/tool_puntos_rectangulo.png" id="btn_map_rectangulo" value="Rect&aacute;ngulo" title="Seleccionar puntos por rectánculo" onclick="rectangulov2();"/>
                                    <input type="image" src="../../images/maps/tool_puntos_poligono.png" id="btn_map_poligono" value="Pol&iacute;gono" title="Seleccionar puntos por polígono" onclick="poligonov2();"/>
                                    <input type="image" src="../../images/maps/tool_mostrar_ocultar.png" id="btn_map_buscar" value="Buscar" title="Mostrar/Ocultar buscador de direcciones" onclick="mostrarOcultarDirecciones();"/>
                                    
                                    <span id="div_map_medir_tool" style="display: none;">
                                        Herramienta Medir distancia:<br/>
                                        Dibuje una linea sobre el mapa haciendo click en él.<br/>
                                        Distancia: <input id="txt_map_distance" type="text" size="5" readonly /> mts.
                                    </span>
                                    <div id="div_map_tool_circulo" style="display: none;">
                                        Herramienta Seleccionar puntos por c&iacute;rculo:<br/>
                                        Hacer click sobre el mapa para comenzar a trazar.<br/>
                                        Rango de b&uacute;squeda:<input id="txt_map_radius" type="text" size="5" readonly /> mts.
                                    </div>
                                    <div id="div_map_tool_rectangulo" style="display: none;">
                                        Herramienta Seleccionar puntos por rect&aacute;ngulo:<br/>
                                        Hacer click sobre el mapa para comenzar a trazar.
                                    </div>
                                    <div id="div_map_tool_poligono" style="display: none;">
                                        Herramienta Seleccionar puntos por pol&iacute;gono:<br/>
                                        Hacer click sobre el mapa para comenzar a trazar.
                                    </div>
                                    <div id="div_map_tool_buscar" style="display: none;">
                                        <input type="text" id="txt_direccion" name="txt_direccion" title="Ingresa la dirección a encontrar" style="width:200px"/>
                                        <input type="image" src="../../images/maps/tool_mostrar_ocultar.png" title="Buscar dirección" onclick="buscarDireccion();" value="Buscar"/>
                                    </div>
                                    <!--
                                    <input type="button" id="btn_map_medir" value="Medir" onclick="medir();"/>
                                    <span id="div_map_medir_tool" style="display: none;">
                                        <input id="txt_map_distance" type="text" size="5" readonly /> km
                                    </span>
                                    <input type="button" id="btn_map_circulo" value="C&iacute;rculo" onclick="circulov2();"/>
                                    <input type="button" id="btn_map_rectangulo" value="Rect&aacute;ngulo" onclick="rectangulov2();"/>
                                    <input type="button" id="btn_map_poligono" value="Pol&iacute;gono" onclick="poligonov2();"/>
                                    -->
                                    <!--<input type="button" id="btn_map_circulo" value="Circulo" onclick="circulo();"/>
                                    <span id="div_map_circulo_tool" style="display: none;">
                                        <input id="circulo_plus" type="button" value="+" onclick="aumentaCirculo();"/>
                                        <input id="circulo_less" type="button" value="-" onclick="disminuyeCirculo()"/>
                                    </span>-->
                                    <!--<input type="button" value="Limpiar" onclick="limpiarMapa();"/>-->
                                    <div id="map_canvas" style="height: 400px;width: auto">
                                        <img src="../../images/maps/ajax-loader.gif" alt="Cargando" style="margin: auto;"/>
                                    </div>
                                </div>
                            </div>
                        </div>
                    <!--</form>-->
                </div>
                <%if(dashboard == 0){%>
                <jsp:include page="../include/footer.jsp"/>
                <%}%>
            </div>
            <!-- Fin de Contenido-->
        </div>
    <%if(dashboard == 0){%>
    <script type="text/javascript">
        var pagina = 'mapa_visor.jsp';        
        function redireccion() {
            document.location.href=pagina;
        }
        //show3();
         setTimeout("redireccion()",300000);//para 5 segundos
        //setTimeout("redireccion()",300000);//para 5 minutos
        setTimeout("show3()",0);
        
        
        
        
        
        ///---------------------
        
        
        function cargarSesion(){
                    //var busqueda = document.getElementById("txt_buscar");                                
                    $.ajax({
                        type: "POST",
                        url: "mapa_busqueda_sesion_ajax.jsp",
                        data: $("#form_mapa_buscador").serialize(),
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                            $("#ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){                               
                                            //document.location.href=pagina; 
                                            $("#ajax_loading").fadeOut("slow");
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
            
            function cargarSesion2(va1,va2,va3,va4,mode){
                 //alert(va1+","+va2+","+va3+","+va4+","+mode);
                    //var busqueda = document.getElementById("txt_buscar");                                
                    $.ajax({
                        type: "POST",
                        url: "mapa_busqueda_sesion_ajax.jsp",
                        data: {lat : va1, lng : va2, tipo : va3, aux : va4, mode : mode},
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                            $("#ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){                               
                                            document.location.href=pagina; 
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
            
                                   
                    buscarMarcador();
                    <%if(cooredenadasPromotor!= null && cooredenadasPromotor.equals("si")){%>
                        setTimeout("muestraMarcadorBusqueda('<%=lat%>','<%=lng%>','<%=tipo%>','<%=aux%>')", 2000);
                    <%}%>
                    <%if(promotorTipo != null && promotorTipo.equals("si")){%>
                        setTimeout("muestraDetallesPromotor('<%=promId%>','<%=promTipo%>')",5000);
                    <%}%>
                    <%if(cooredenadasCliente != null && cooredenadasCliente.equals("si")){%>
                        setTimeout("muestraMarcadorBusqueda('<%=latCl%>','<%=lngCl%>','<%=tipo%>','<%=aux%>')",2000);
                    <%}%>  
                    <%if(clienteDetalles != null && clienteDetalles.equals("si")){%>
                        setTimeout("muestraDetallesCliente('<%=clieId%>','<%=clieTipo%>')",5000);
                    <%}%>   
                    <%if(cooredenadasPros != null && cooredenadasPros.equals("si")){%>
                        setTimeout("muestraMarcadorBusqueda('<%=latPros%>','<%=lngPros%>','<%=tipo%>','<%=aux%>')",2000);
                    <%}%>  
                    <%if(prosDetalles != null && prosDetalles.equals("si")){%>
                        setTimeout("muestraDetallesProspecto('<%=prosId%>','<%=prosTipo%>')",5000);
                    <%}%>
        
        
        
        ///-----------------------
        
        
        
        
        
        
    </script>
    <%}%>
    
    
    
    
    
    </body>
    
    <%if(dashboard == 1){%>
    <script type="text/javascript">
            function marcaCheckBox(){
                $('#clientes').click();
                $('#prospectos').click();
                $('#promotores').click();                
            }
        setTimeout("marcaCheckBox()",6000);
     </script>
    <%}%>
    
</html>
<%}%>