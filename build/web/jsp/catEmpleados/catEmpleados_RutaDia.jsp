<%-- 
    Document   : catEmpleados_RutaDia
    Created on : 22/10/2014, 10:35:37 AM
    Author     : 578
--%>

<%@page import="com.tsp.gespro.factory.ProspectoDaoFactory"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.dto.Prospecto"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.util.DateManage"%>
<%@page import="com.tsp.gespro.factory.ClienteDaoFactory"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.bo.EmpleadoBitacoraPosicionBO"%>
<%@page import="com.tsp.gespro.factory.EmpleadoBitacoraPosicionDaoFactory"%>
<%@page import="com.tsp.gespro.dto.EmpleadoBitacoraPosicion"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    
//Verifica si el usuario tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
} else {
   
    
    /*
     * Parámetros
     */
    
    
    
    int idEmpleado = 0;    
    int idUsuario = 0;// Acceso desde left content
    int menu = 0;
    try {
        idUsuario = Integer.parseInt(request.getParameter("idUsuario"));        
    } catch (NumberFormatException e) {
    }
    try {
        menu = Integer.parseInt(request.getParameter("menu"));        
    } catch (NumberFormatException e) {
    }
    
    if(idUsuario==0){
        try {
            idEmpleado = Integer.parseInt(request.getParameter("idEmpleado"));
        } catch (NumberFormatException e) {
        }
    }else{
        idEmpleado = idUsuario;    
        
    }
        System.out.println("*****+++++++++++++ " + menu);
        System.out.println("*****++++++++usu+++++ " + idUsuario);
    
    
    
    
    int idEmpresa = user.getUser().getIdEmpresa(); 
    Cliente[] clientesDtos = null;
    Prospecto[] prospectosDto = null;
    Usuarios empleadoConsultado = null;
    UsuariosBO empleadoBO = new UsuariosBO(user.getConn());
    String nombreEmpleado="" ;
    Date  now = new Date();
    DatosUsuario datosUsuarioDto = null;
    
    try {
        empleadoBO = new UsuariosBO(idEmpleado,user.getConn());
        empleadoConsultado = empleadoBO.getUsuario();
        
        UsuarioBO usuarioBO = new UsuarioBO(user.getConn());
        usuarioBO = new UsuarioBO(user.getConn(),idEmpleado);
        datosUsuarioDto =  usuarioBO.getDatosUsuario();
        datosUsuarioDto =  usuarioBO.getDatosUsuario();
        
        
        nombreEmpleado = (datosUsuarioDto.getNombre()!=null?datosUsuarioDto.getNombre():"") + " " + (datosUsuarioDto.getApellidoPat()!=null?" " + datosUsuarioDto.getApellidoPat():"") + " " +(datosUsuarioDto.getApellidoMat()!=null?" " + datosUsuarioDto.getApellidoMat():"");
    } catch (Exception e) {
    }
    
    
    String buscar_fechamin = "";
    String buscar_fechamax = "";
    Date fechaMin=null;
    Date fechaMax=null;
    
    try{
        fechaMin = new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("q_fh_min"));
        buscar_fechamin = DateManage.formatDateToSQL(fechaMin);
    }catch(Exception e){
        buscar_fechamin = DateManage.formatDateToSQL(now);
    }
    /*try{ //uso un solo campo de fecha par que seleccione un dia y no un lapso
        fechaMax = new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("q_fh_max"));
        buscar_fechamax = DateManage.formatDateToSQL(fechaMax);
    }catch(Exception e){}*/
    
    String filtroBusqueda = " AND FECHA BETWEEN '"+buscar_fechamin+" 00:00:00' AND '"+buscar_fechamin+" 23:59:59' GROUP BY LATITUD,LONGITUD ";
    String filtroBusquedaEncoded = java.net.URLEncoder.encode(filtroBusqueda, "UTF-8");
    String strParamsExtra  =""+idEmpleado ;
    String parametrosExtraEncoded = java.net.URLEncoder.encode(strParamsExtra , "UTF-8");
    String parametrosPaginacion="menu="+menu;
    
    
    Empresa empresa = new Empresa();    
    EmpresaBO empresaBo = new EmpresaBO(user.getConn());    
    empresa = empresaBo.findEmpresabyId(idEmpresa); 
       
%>

<!DOCTYPE html>
<html>
    <head>        
        <link rel="shortcut icon" href="../../images/favicon.ico">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <jsp:include page="../include/keyWordSEO.jsp" />

        <title><jsp:include page="../include/titleApp.jsp" /></title>

        <jsp:include page="../include/skinCSS.jsp" />

        <jsp:include page="../include/jsFunctions.jsp"/>
        
        <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&libraries=geometry&sensor=true"></script>         
        <script type="text/javascript">
            
           var global = [];            
           var map;
           
           var poly = [];
           var polyPoints = [];
           var clientes = [];
           var prospectos = [];
            
           var directionDisplay;
           var directionsService; 
           
           var timer;
           var velocidad;
           var isPaused = true;
           
           
          
                
             <%
    
                /*   ------------------- Filtro Ruta Dia  -----------  */
    
                EmpleadoBitacoraPosicionBO empleadoBitacoraPosicionBO = new EmpleadoBitacoraPosicionBO(user.getConn());
                EmpleadoBitacoraPosicion[] rutaSeguida = new EmpleadoBitacoraPosicion[0];
                        
                if(idEmpleado>0){
                    rutaSeguida = empleadoBitacoraPosicionBO.findEmpleadoBitacoraPosicions(-1, idEmpleado , -1, -1, filtroBusqueda );                          
                }
                
               
    
                /* -------------------------- Inicio Marcadores----------------------------------------------*/
                
                //clientes
                try{
                    clientesDtos = ClienteDaoFactory.create().findWhereIdEmpresaEquals(idEmpresa);
                }catch(Exception e){}        
                        
                for(Cliente clienteDto:clientesDtos){
                    if(clienteDto.getLatitud()!=0 && clienteDto.getLongitud()!=0){                      
                        String nombreCliente = clienteDto.getNombreComercial();
                        String dialogoCliente = ""
                             + "<div class='map_dialog'>"
                             + "    Cliente:<br/>" + nombreCliente.replaceAll("\\\"", "&quot;") + "<br/><br/>"
                             + "   <li> <a title='Detalles' onclick='muestraDetallesCliente(" + clienteDto.getIdCliente() + ",1)'>Detalles </a> </li> <br/>"
                             //+ "   <li> <a title='Pagos' onclick='muestraDetallesCliente(" + clienteDto.getIdCliente() + ",2)'>Pagos </a> </li> <br/>"
                             + " </div>";
                        %>
                            
                             /* crear marcadores */                  
                              clientes.push(
                                     creaMarcador(
                                         <%=clienteDto.getLatitud()!=0?clienteDto.getLatitud():0 %>,
                                         <%=clienteDto.getLongitud()!=0?clienteDto.getLongitud():0 %>,
                                         "<%=nombreCliente.replaceAll("\\\"", "&quot;") %>",
                                         "../../images/maps/map_marker_cte.png",
                                         "<%=dialogoCliente %>"
                                     )
                                );
                         
                        <%
                    }
                }
                %>     
                    
                    
                <%
                
                try{
                    prospectosDto = ProspectoDaoFactory.create().findWhereIdEmpresaEquals(idEmpresa);
                }catch(Exception e){}  
                
                for(Prospecto prospectoDto:prospectosDto){
                    String nombreCliente = prospectoDto.getContacto();
                    String dialogoCliente = ""
                        + "<div class='map_dialog'>"
                        + "    Prospecto:<br/>" + nombreCliente.replaceAll("\\\"", "&quot;") + "<br/><br/>"
                        + "    <li> <a title='Detalles' onclick='muestraDetallesProspecto(" + prospectoDto.getIdProspecto() + ",1)'>Detalles </a> </li><br/>"
                        + "</div>";
                    %>
                    prospectos.push(
                        creaMarcador(
                            <%=prospectoDto.getLatitud() %>,
                            <%=prospectoDto.getLongitud() %>,
                            "<%=nombreCliente.replaceAll("\\\"", "&quot;") %>",
                            "../../images/maps/map_marker_pros.png",
                            "<%=dialogoCliente %>"
                        )
                    );         
                    <%
                }
                %>    
                    
                    
             /* -------------------------- Fin Marcadores----------------------------------------------*/ 
             
             function initialize() {  
                 
                 
                 
                $('#vel').bind('keyup mouseup', function () {
                    if($('#vel').val() > 50){
                        velocidad = $('#vel').val();     
                    }else{
                        velocidad = 50;
                    }
                    
                });                  
                 
                 
                var inicio;                
                <%if(rutaSeguida.length >0 ){
                    int element = (int) rutaSeguida.length / 3;   //solo para centrar 1er tercio ruta               
                %>
                    inicio = new google.maps.LatLng(<%=rutaSeguida[element].getLatitud()%>, <%=rutaSeguida[element].getLongitud()%>);
                <%}else{%>    
                    inicio= new google.maps.LatLng(<%=empresa.getLatitud()%>,<%=empresa.getLongitud()%>);//mexico
                <%}%> 
                
                
                var mapOptions = {
                  zoom: 12,//16
                  center: inicio,
                  mapTypeId: google.maps.MapTypeId.ROADMAP
                };

                map = new google.maps.Map(document.getElementById('map_canvas'),
                mapOptions);
                
                map.controls[google.maps.ControlPosition.TOP_RIGHT].push(
                FullScreenControl(map, 'Pantalla Completa',
                'Salir Pantalla Completa'));  
                                
               showRoute();//Mostramos ruta                
               
           }  
             
           /* -------------------------------Inicio polylinea----------------------------------------------*/
            function showRoute(){
                
                //Linea tipo flecha (estatica)                
                 var flecha = {
                    path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW
                 };
                
                
                var van = {                   
                    path: "M32.343,12.865c-1.191-5.411-6.369-3.912-6.369-3.912c-0.331,0-0.947-0.232-0.947-0.232s-2.391-2.302-3.218-3.912 "+
                    "c-0.991-1.961-2.512-1.664-2.512-1.664h-6.821c-3.9,0.209-4.044,3.042-5.609,4.606C5.28,9.338,5.28,9.086,5.28,9.086 "+
                    "c-3.966-0.066-3.911,1.96-3.911,1.96v5.224c-0.573,2.093,3.911,1.08,3.911,1.08s-0.043-3.405,3.659-3.593 "+
                    "c4.672,0,4.925,3.845,4.925,3.845h6.887l0.066-1.133c0,0,0.231-2.778,3.834-2.92c3.592-0.11,3.592,3.185,4.473,3.723 "+
                    "C30.017,17.856,33.543,18.297,32.343,12.865z M14.878,9.713H8.311c0,0,0.871-5.873,6.567-4.463V9.713z M16.443,9.713V5.03 "+
                    "c4.782-0.243,3.791,1.521,5.178,2.602c1.377,1.089,1.443,2.082,1.443,2.082H16.443z "+
                    "M11.583,18.176c0,1.289-1.035,2.324-2.314,2.324c-1.299,0-2.336-1.036-2.336-2.324c0-1.311,1.037-2.336,2.336-2.336 "+
                    "C10.548,15.839,11.583,16.865,11.583,18.176z "+
                    "M27.372,18.176c0,1.289-1.057,2.324-2.346,2.324c-1.289,0-2.325-1.036-2.325-2.324c0-1.311,1.036-2.336,2.325-2.336"+
                    "C26.315,15.839,27.372,16.865,27.372,18.176z ",  
                    fillColor: "#FF0033",
                    scale: 1,
                    strokeColor: 'black',                    
                    fillOpacity: 1,
                    rotation: 240,                    
                }; 
                                
                
                //Propiedades polilyne
                // (estatica)
                var polyOptions = {
                    strokeColor: '#00CC00',
                    path: poly,
                    icons: [
                        {
                            icon: flecha,
                            offset: '100%',
                            repeat: '5%'                     
                        },
                        {
                            icon: van,
                            offset: '1%'
                        }
                    ]
                };
                    
        
        
                //Creamos polyline y recibe propiedades
                poly = new google.maps.Polyline(polyOptions);
                
                
                 <%//llenamos arreglo con posiciones
                       
                        for(EmpleadoBitacoraPosicion datosPunto : rutaSeguida){                            
                           out.print("poly.getPath().push(creaLatLng("+datosPunto.getLatitud()+","+datosPunto.getLongitud()+"));"); 
                        };  
                        
                        
                 %>
                
                //Mostramos ruta en mapa y marcadores de inicio               
                poly.setMap(map);
                for(var i = 0, marcador; marcador = clientes[i]; i ++){
                    marcador.setMap(map);
                }/*
                for(var i = 0, marcador; marcador = prospectos[i]; i ++){
                    marcador.setMap(map);
                }*/
                
    
                //Inicia Animación
                loop();
                
           }
            
            //Crera obj latlang
            function creaLatLng(lat, lng){
                return new google.maps.LatLng(lat,lng);
            }
            
            
            //loop
            function loop(){
                var count = 0;
                    timer = window.setInterval(function() { 
                        if(!isPaused){ 
                            count = (count + 1) % 200;                  
                            var icons = poly.get('icons');
                            icons[1].offset = (count / 2) + '%';
                            poly.set('icons', icons);   
                        }  
                        
                      }, velocidad);//milisegundos
            }
            
            
            
            //Play movimiento animado 
            function play() {     
                isPaused = false;
            }
            
            //Stop movimiento animado
            function stop() { 
                clearInterval(timer);
                isPaused = true; 
                loop();
            }
            
             //Pause movimiento animado
            function pause() {   
                isPaused = true;  
            }
            
            /* -------------------------------Fin polylinea----------------------------------------------*/
            
            /* ------------------------------- Metodos proposito general ----------------------------------------------*/
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
                return marcador;
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
          
          
          function mostrarCalendario(){
                //fh_min
                //fh_max

                var dates = $('#q_fh_min, #q_fh_max').datepicker({
                        //minDate: 0,
			changeMonth: true,
			//numberOfMonths: 2,
                        //beforeShow: function() {$('#fh_min').css("z-index", 9999); },
                        beforeShow: function(input, datepicker) {
                            setTimeout(function() {
                                    $(datepicker.dpDiv).css('zIndex', 998);
                            }, 500)},
			onSelect: function( selectedDate ) {
				var option = this.id == "q_fh_min" ? "minDate" : "maxDate",
					instance = $( this ).data( "datepicker" ),
					date = $.datepicker.parseDate(
						instance.settings.dateFormat ||
						$.datepicker._defaults.dateFormat,
						selectedDate, instance.settings );
				dates.not( this ).datepicker( "option", option, date );
			}
		});

            }
             /* ------------------------------- Metodos detalle elementos ----------------------------------------------*/
                         
             
             
             
             function muestraDetallesCliente(id, tipo){
                var url = "";
                switch(tipo){
                    case 1:
                        url = "../mapa/detallesCliente_ajax.jsp";
                        break;
                    case 2:
                        url = "../mapa/pagosCliente_ajax.jsp";
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
                        url = "../mapa/detallesProspecto_ajax.jsp";
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
                           
                           $("#div_content_detalle").show();
                           $.scrollTo('#inner',800);
                           
                       }else{
                           $("#ajax_loading").fadeOut("slow");
                           $("#ajax_message").html(datos);
                           $("#ajax_message").fadeIn("slow");
                           //$("#action_buttons").fadeIn("slow");
                           $.scrollTo('#inner',800);
                       }
                    }
                });
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
                    
                }             
            }
            
            
            
            function agregaMarcador(lat, lng, title){
                //alert(lat +"--"+lng+"--"+title);
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
            
            
            
            
            function creaMarcadorBasico(lat,lng,title){
                var marcador = new google.maps.Marker({
                        position: new google.maps.LatLng(lat,lng), 
                        title:title,
                        animation: google.maps.Animation.DROP
                    });
                return marcador;
            }
             
             /* ------------------------------- Fin Metodos detalle elementos ----------------------------------------------*/
             
            
           //llamamos initialize al cargar dom   
           google.maps.event.addDomListener(window, 'load', initialize);   
           
           
            
        
        </script>
    </head>
    <body>
        <div class="content_wrapper">

            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>
            
            <!-- Inicio de Contenido -->
            <div id="content">
                
                <div class="inner">
                    <h1>Ruta del Día</h1>
                    
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                                        
                    <div class="twocolumn">
                        <div class="column_left">
                            <div class="header">
                                <span>          
                                    Opciones Avanzadas &dArr;
                                </span>
                            </div>                            
                            <div class="content" style="display: none;">
                                <br>
                                <b>Mostrar:</b>
                                <br>
                                <input id="clientes" type="checkbox" onclick="muestraMarcador(this);" checked="true"/>Clientes<br/>
                                <input id="prospectos" type="checkbox" onclick="muestraMarcador(this);"/>Prospectos<br/>
                                <br>
                                <b>Busqueda:</b>
                                <br>
                                <div id="search">
                                    <form action="catEmpleados_RutaDia.jsp?<%=parametrosPaginacion%>" id="search_form_advance" name="search_form_advance" method="post"> 
                                        <input type="hidden" id="idEmpleado" name="idEmpleado" value="<%=idEmpleado%>"/>
                                        <%if(menu == 0){%>
                                        <p>
                                        Empleado
                                                    <select id="q_idvendedor" name="q_idvendedor" class="flexselect">
                                                        <option></option>
                                                        <%= new UsuariosBO().getUsuariosByRolHTMLCombo(idEmpresa, RolesBO.ROL_GESPRO, idUsuario) %>                                                        
                                                    </select>
                                        </p> 
                                        <br>
                                        <%}%>
                                        <p>
                                            Por Fecha &raquo;&nbsp;&nbsp;
                                            Día:
                                            <input maxlength="15" type="text" id="q_fh_min" name="q_fh_min" style="width:100px"
                                                    value="" readonly/>
                                            <!--&nbsp; &laquo; &mdash; &raquo; &nbsp;
                                            <label>Hasta:</label>
                                            <input maxlength="15" type="text" id="q_fh_max" name="q_fh_max" style="width:100px"
                                                value="" readonly/>-->
                                        </p>     
                                        <br>
                                        <div id="action_buttons">
                                            <p>
                                            <input type="button" id="buscar" value="Buscar" onclick="$('#search_form_advance').submit();"/>
                                            </p>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                        <div class="column_right" >
                            <div class="header">
                                <span>          
                                    Detalles &dArr;
                                </span>
                            </div>                            
                            <div id="div_content_detalle" class="content" style="display: none;">   
                                <div id="div_map_resultado_buscar" style="width: 510px; height: 200px;overflow: scroll;">
                                    <table class="data" width="100%" cellpadding="0" cellspacing="0" >
                                        <thead>
                                          <tr><center><h3>Historial Ubicaciones</h3></center></tr>
                                          <tr>
                                            <th>Fecha</th>
                                            <th>Latitud</th>
                                            <th>Longitud</th>
                                            <th>Ubicar</th>
                                          </tr>
                                        </thead>
                                    <tbody>
                            <%if(rutaSeguida.length > 0){
                                for(EmpleadoBitacoraPosicion bitacoraPosicion:rutaSeguida){%>                    
                                    <tr>
                                        <td><%=new SimpleDateFormat("dd/MM/yyyy HH:mm").format(bitacoraPosicion.getFecha())%></td>                                        
                                        <td><%=bitacoraPosicion.getLatitud()%></td>
                                        <td><%=bitacoraPosicion.getLongitud()%></td>      
                                        <td>                                            
                                            <a href="javascript:void(0)"  onclick="agregaMarcador('<%=bitacoraPosicion.getLatitud()%>'  ,  '<%=bitacoraPosicion.getLongitud()%>'  ,  '<%=new SimpleDateFormat("dd/MM/yyyy HH:mm").format(bitacoraPosicion.getFecha())%>')"> 
                                            <img src="../../images/icon_movimiento.png" alt="Ubicar"/>
                                            </a> 
                                        </td>
                                    <tr>
                                   <%}%>
                                    </tbody>
                                </table>       
                                <!-- INCLUDE OPCIONES DE EXPORTACIÓN-->
                                 <!--<//jsp:include page="../include/reportExportOptions.jsp" flush="true">
                                <//jsp:param name="idReport" value="<%//= ReportBO.BITACORA_POSICION_REPORT %>" />
                                <//jsp:param name="parametrosCustom" value="<%//= filtroBusquedaEncoded %>" />
                                <//jsp:param name="parametrosExtra" value="<%//=parametrosExtraEncoded%>" />
                                <///jsp:include>-->
                                <!-- FIN INCLUDE OPCIONES DE EXPORTACIÓN-->    
                                    
                                    
                            <%}else{%>
                                </tbody>
                                 </table>
                                    No se encontr&oacute; informaci&oacute;n.
                           <%}%>                                        
                                        
                                </div>  
                            </div>
                        </div>
                    </div>                    
                    <br class="clear"/>
                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_mapa.png" alt="icon"/>
                                Mapa&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=nombreEmpleado%>                               
                            </span>
                            <div class="switch" style="">
                                <table>
                                    <tbody>                                            
                                            <tr>
                                                <td><b>Controles:</b>&nbsp;
                                                    <img src="../../images/control_play_blue.png" alt="icon" onclick="play();" style="cursor: pointer;" title="Reproducir"/>
                                                    <img src="../../images/control_pause_blue.png" alt="icon" onclick="pause();" style="cursor: pointer;" title="Pausar"/>
                                                    <img src="../../images/control_stop_blue.png" alt="icon" onclick="stop();" style="cursor: pointer;" title="Detener"/>
                                                    &nbsp;&nbsp;&nbsp;
                                                    <label for="time">Velocidad(ms):</label>
                                                    <input type="number" name="vel" id="vel" value="50" min="50" max="1000" step="50" disable="true" />
                                                </td>                                               
                                            </tr>                                            
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <br class="clear"/>
                        <div class="content">   
                            <div id="map_canvas" style="height:500px; position: relative; background-color: rgb(229, 227, 223); overflow: hidden;">                                
                                <div>
                                    <canvas class="loader"></canvas>
                                    <script>
                                        $(document).ready(function() {
                                            $('.loader').ClassyLoader({
                                                percentage: 100,
                                                speed: 20,
                                                fontSize: '50px',
                                                diameter: 80,
                                                lineColor: 'rgba(155,155,155,1)',
                                                remainingLineColor: 'rgba(200,200,200,0.4)',
                                                lineWidth: 10,
                                                
                                            });
                                        });
                                    </script>                                    
                                </div>
                            </div>  
                        </div>
                        
                    </div>
                <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                </div>

                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>
        <script>
            mostrarCalendario();            
        </script>
    </body>
</html>
<% } %>