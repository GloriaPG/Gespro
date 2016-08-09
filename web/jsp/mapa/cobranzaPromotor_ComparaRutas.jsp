
<%@page import="com.tsp.gespro.bo.DatosUsuarioBO"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.factory.ProspectoDaoFactory"%>
<%@page import="com.tsp.gespro.util.StringManage"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page import="com.tsp.gespro.factory.RutaMarcadorDaoFactory"%>
<%@page import="com.tsp.gespro.dto.RutaMarcador"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.dto.Prospecto"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page import="com.tsp.gespro.dto.EmpleadoBitacoraPosicion"%>
<%@page import="com.tsp.gespro.jdbc.EmpleadoBitacoraPosicionDaoImpl"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.jdbc.RutaDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Ruta"%>
<%@page import="com.tsp.gespro.bo.RutaBO"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    
//Verifica si el usuario tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
} else {
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
     /*
     * Parámetros
     */
    String idUsuario = request.getParameter("idUsuario")!=null? new String(request.getParameter("idUsuario").getBytes("ISO-8859-1"),"UTF-8") :"";   
    String idRuta = request.getParameter("idRuta")!=null? new String(request.getParameter("idRuta").getBytes("ISO-8859-1"),"UTF-8") :"";   
    String fechaIni = request.getParameter("fInicio")!=null? new String(request.getParameter("fInicio").getBytes("ISO-8859-1"),"UTF-8") :"";
    String fechaFin = request.getParameter("fFin")!=null? new String(request.getParameter("fFin").getBytes("ISO-8859-1"),"UTF-8") :"";
    
    UsuariosBO promotor = new UsuariosBO(Integer.parseInt(idUsuario),user.getConn());
    Usuarios empleado = promotor.getUsuario();
    DatosUsuario datosUsuario = new DatosUsuarioBO(empleado.getIdDatosUsuario(),user.getConn()).getDatosUsuario();
    
    RutaBO rutaBO = new RutaBO(user.getConn());
    Ruta rutaDto = null;

    if(idRuta.equals("")){  
        rutaDto = rutaBO.getRutaByIdUsuario(Integer.parseInt(idUsuario),user.getConn());
        %>
        <script type="text/javascript"> 
        iRuta = <%=rutaDto.getIdRuta()%>;
        </script>
        <% 
        
    }else{
        RutaDaoImpl rutaDaoImpl = new RutaDaoImpl(user.getConn()); 
        rutaDto = rutaBO.findRutabyId(Integer.parseInt(idRuta), user.getConn()); 
        %>
        <script type="text/javascript"> 
        iRuta = <%=idRuta%>;
        </script>
        <% 
    }
    
    
    
    
    int diferenciaEnDias = 5; 
    Date fechaActual = Calendar.getInstance().getTime();
    long hoy2 = fechaActual.getTime(); 
    long cincoDias = diferenciaEnDias * 24 * 60 * 60 * 1000; 
    Date fechaCincoDias = new Date(hoy2 - cincoDias);   

    SimpleDateFormat formateador = new SimpleDateFormat("yyyy-MM-dd") ;

    String hoy = formateador.format(fechaActual);
    String haceCincoDias = formateador.format(fechaCincoDias);

    EmpleadoBitacoraPosicionDaoImpl empleadoBitacoraPosicionDaoImpl = new EmpleadoBitacoraPosicionDaoImpl(user.getConn());          
    EmpleadoBitacoraPosicion[] checks;

    System.out.println("***------------------------------------------------------***");
    
    if(fechaIni.equals("")&&fechaFin.equals("")){
       checks = empleadoBitacoraPosicionDaoImpl.findByDynamicWhere(" ID_USUARIO = '"+ idUsuario + "' AND FECHA BETWEEN '" + hoy + " 00:00:01" +"' AND '"+ hoy + " 23:59:59" +"'  GROUP BY latitud,longitud " , null) ; 
       //checks = empleadoBitacoraPosicionDaoImpl.findByDynamicWhere(" ID_USUARIO = '"+ idUsuario + "' AND FECHA BETWEEN '2013/07/04' AND '"+ hoy +"'", null) ; //para pruebas empleado = 24  
        
    }else{

       Date date = new SimpleDateFormat("dd/MM/yyyy").parse(fechaIni);
       String txtIni = new SimpleDateFormat("yyyy/MM/dd 00:00:01").format(date);
       Date date2 = new SimpleDateFormat("dd/MM/yyyy").parse(fechaFin);
       String txtFin = new SimpleDateFormat("yyyy/MM/dd 23:59:59").format(date2);
      
       checks = empleadoBitacoraPosicionDaoImpl.findByDynamicWhere(" ID_USUARIO = '"+ idUsuario + "' AND FECHA >= '"+ txtIni +"' AND FECHA <= '"+ txtFin +"' GROUP BY latitud,longitud ", null) ;
       
    }
    
    
    /****
     * 
     */
        
  
    
    Cliente[] clientesDto = null;
    Prospecto[] prospectosDto = null;
    Empresa empresa = new Empresa();   
      
    

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
        
        <script type="text/javascript">
            var global = [];
            
            //*************Mapa 1 Ruta asignada
            var map;
            var poly;
            
            var directionDisplay;
            var directionsService;
            
            
            function initialize() {
                
                var rendererOptions = {
                    draggable: false
                };
                
                directionsService = new google.maps.DirectionsService();
                directionsDisplay = new google.maps.DirectionsRenderer(rendererOptions);
                
                                
                <%
                RutaMarcador marcador = null;
                try{
                    RutaMarcador[] rutaMarcadorCentrar = RutaMarcadorDaoFactory.create(user.getConn()).findByDynamicWhere("ID_RUTA = " + rutaDto.getIdRuta() + " ORDER BY ID_RUTA_MARCADOR ASC", new Object[0]);
                    marcador = new RutaMarcador();                    
                    marcador = rutaMarcadorCentrar[0];
                    
                }catch(Exception e){}
                %>
                        
                var coordenadaRuta = new google.maps.LatLng(<%=marcador.getLatitudMarcador()%>,<%=marcador.getLongitudMarcador()%>);
                
                var mapOptions = {
                  zoom: 14,
                  center: coordenadaRuta,
                  mapTypeId: google.maps.MapTypeId.ROADMAP
                };

                map = new google.maps.Map(document.getElementById('map_canvas'),
                    mapOptions);
                
                showRoute();
                
                directionsDisplay.setMap(map);
                
                initialize2();
                                
            }
        
            function loadScript() {
                var script = document.createElement('script');
                script.type = 'text/javascript';
                script.src = 'https://maps.googleapis.com/maps/api/js?libraries=geometry,drawing&sensor=false&' +
                    'callback=initialize';
                document.body.appendChild(script);
            }

            window.onload = loadScript;
            
            function showRoute(){
                
                var polyOptions = {
                    strokeColor: '#000000',
                    strokeOpacity: 1.0,
                    strokeWeight: 3,
                    editable:false
                } ;
                
                
                var poly = new google.maps.Polyline(polyOptions);
                poly.setMap(map);
                
                <%
                    String lineaRuta = rutaDto.getRecorridoRuta();
                    lineaRuta =  lineaRuta.replaceAll("\\),\\(", "|");
                    lineaRuta =  lineaRuta.replaceAll("\\)", "");
                    lineaRuta =  lineaRuta.replaceAll("\\(", "");

                    String[] puntosRuta = lineaRuta.split("\\|");
                    
                    RutaMarcador[] rutaMarcadores = RutaMarcadorDaoFactory.create(user.getConn()).findByDynamicWhere("ID_RUTA = " + rutaDto.getIdRuta() + " ORDER BY ID_RUTA_MARCADOR ASC", new Object[0]);
                    
                    if(rutaMarcadores.length<=10){
                    
                        for(String datosPunto:puntosRuta){
                            String[] latLng = datosPunto.split(",");
                            out.print("poly.getPath().push(creaLatLng("+latLng[0]+", "+latLng[1]+"));");                        
                        };
                    }
                    
                    
                    int visitados = 0; 
                    boolean primero = true;
                    int j = 0;
                    for(RutaMarcador rutaMarcador : rutaMarcadores){
                     j = j + 1;
                            if(primero){
                %>
/*                                var mapOptions = {
                                    zoom: 14,
                                    center: creaLatLng(<%=rutaMarcador.getLatitudMarcador() %>,<%=rutaMarcador.getLongitudMarcador() %>),
                                    mapTypeId: google.maps.MapTypeId.ROADMAP
                                  };
*/
                <%
                                primero = false;
                            }

                            System.out.println("..........."+rutaMarcador.getLatitudMarcador());  
                            System.out.println("..........."+rutaMarcador.getLongitudMarcador());

                %>                                
                         var encontrado = 0;     
                         var imagen="../../images/maps/numbers_red/number_"+<%=j%>+".png";
                         var estatusVisita = "No Visitado";
                <%   
                       
                        for(EmpleadoBitacoraPosicion datosPuntos:checks){ 
                            
                          
                %>

                                        //var puntoA = new google.maps.LatLng(<%=datosPuntos.getLatitud()%>, <%=datosPuntos.getLongitud()%>);
                                        //var puntoB = new google.maps.LatLng(<%=rutaMarcador.getLatitudMarcador()%>,<%=rutaMarcador.getLongitudMarcador()%>);
                                        //distancia entre 2 puntos expresada en metros
                                        //var distancia = google.maps.geometry.spherical.computeDistanceBetween(puntoA , puntoB);
                                        var distancia = getDistanceFromLatLonInMeters(<%=datosPuntos.getLatitud()%>, <%=datosPuntos.getLongitud()%>, <%=rutaMarcador.getLatitudMarcador()%>,<%=rutaMarcador.getLongitudMarcador()%>);

                                        imagen = "";
                                        estatusVisita = "";


                                        if(distancia>30 && encontrado ==0){
                                            imagen = "../../images/maps/numbers_red/number_"+<%=j%>+".png";
                                            estatusVisita = "No Visitado";  
                                           
                                        } else {                                           
                                            imagen = "../../images/maps/numbers_green/number_"+<%=j%>+".png";
                                            estatusVisita = "Visitado";                                             
                                            encontrado=1;                                              
                                        }       

                            <%    

                        }

                        %>     
                              
                         
                             
                        creaMarcadorRuta(
                             <%=rutaMarcador.getLatitudMarcador() %>,
                             <%=rutaMarcador.getLongitudMarcador() %>,
                             "Marcador",
                             imagen,
                             estatusVisita
                         );

                        <%

                        }
                    
                       
                    
                    %>
                
            }
            
                    
            function creaMarcadorRuta(lat,lng,title,img,content){
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
                marcador.setMap(map);
                
             
                
                //infowindow.open(map,marcador);//muestra informacion de marcador
            }
            
            //*****************   mapa 2 Ruta Realizada*****************************
            
            var map2;
            var poly2;           
       
            var marcaSuc2;
            var markerRoute;
            
            var directionDisplay2;
            var formaDibujada;
            var drawingManager;
            
            var clientes = [];
            var prospectos = [];
            var promotores = [];
            var vehiculos = [];
            var puntos = [];
            var markerRoute2 = [];       

            var medirListener;
            
            
            function initialize2() {
                   
                var rendererOptions2 = {
                    draggable: false
                };
                
                directionsService2 = new google.maps.DirectionsService();
                directionsDisplay2 = new google.maps.DirectionsRenderer(rendererOptions2);
                                                       
                var coordenadaRuta = new google.maps.LatLng(<%=marcador.getLatitudMarcador()%>,<%=marcador.getLongitudMarcador()%>);
                
                var mapOptions2 = {
                  zoom: 14,
                  center: coordenadaRuta,
                  mapTypeId: google.maps.MapTypeId.ROADMAP
                };
                
                map2 = new google.maps.Map(document.getElementById('map_canvas2'), mapOptions2);
                directionsDisplay2.setMap(map2);   
                
                
                
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
                 drawingManager.setMap(map2);
                 
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
                
                
                rutaMapa();
                fillMap();
                
                 
                                                
            }
            
            function rutaMapa(){
                
                muestraDetallesPromotor(<%=idUsuario%>); 
                
                var polyOptions2 = {
                    strokeColor: '#000000',
                    strokeOpacity: 1.0,
                    strokeWeight: 3,
                    editable:false
                };
                var poly2 = new google.maps.Polyline(polyOptions2);
                poly2.setMap(map2);
                
                var puntosTotales =0;
                var visitados = 0;   
                var marcadoresVisitados = [];
                <%                             
                                
                    if(checks.length<=10){//Imprimir linea si solo tiene 10 puntos o menos
                        for(EmpleadoBitacoraPosicion lineaPuntos:checks){                       
                                out.print("poly2.getPath().push(creaLatLng("+lineaPuntos.getLatitud()+","+lineaPuntos.getLongitud()+"));");                        
                        }
                    }
                    int i = 0;
                    for(EmpleadoBitacoraPosicion datosPuntos:checks){ 
                            i = i +1;
                            %>  
                                                       
                            var encontrado = 0;    
                            var puntosTotales = <%=rutaMarcadores.length%>;
                            <%
                            
                            for(RutaMarcador rutaMarcador : rutaMarcadores){ 
                                
                                    %>
                                          
                                             
                                        
                                        var puntoA = new google.maps.LatLng(<%=datosPuntos.getLatitud()%>, <%=datosPuntos.getLongitud()%>);
                                        var puntoB = new google.maps.LatLng(<%=rutaMarcador.getLatitudMarcador()%>,<%=rutaMarcador.getLongitudMarcador()%>);
                                        //distancia entre 2 puntos expresada en metros   
                                        //var distancia = google.maps.geometry.spherical.computeDistanceBetween(puntoA , puntoB);
                                        var distancia = getDistanceFromLatLonInMeters(<%=datosPuntos.getLatitud()%>, <%=datosPuntos.getLongitud()%>, <%=rutaMarcador.getLatitudMarcador()%>,<%=rutaMarcador.getLongitudMarcador()%>);

                                        var imagen2 = "";
                                        var estatusVisita2 = "";
                                        
                                        
                                        if(distancia>30 && encontrado ==0){
                                            imagen = "../../images/maps/numbers_red/number_"+<%=i%>+".png";
                                            estatusVisita = "No Visitado <br>" + "<%=datosPuntos.getFecha()%>" ;
                                            
                                        } else {                                           
                                            imagen = "../../images/maps/numbers_green/number_"+<%=i%>+".png";
                                            estatusVisita = "Visitado <br>" + "<%=datosPuntos.getFecha()%>" ;     
                                             
                                            if(encontrado == 0){  
                                                
                                                  visitados += 1;                                                   
                                                    
                                                  var result = $.inArray(<%=rutaMarcador.getIdRutaMarcador()%>,marcadoresVisitados);   
                                                 
                                                  if(result == -1){                                                         
                                                      marcadoresVisitados.push(<%=rutaMarcador.getIdRutaMarcador()%>);
                                                  }                                                        
                                            }
                                            
                                            encontrado=1;                                            
                                            
                                        }       


                            <%

                            } 
                            %>

                            creaMarcadorRuta2(
                                             <%=datosPuntos.getLatitud() %>,
                                             <%=datosPuntos.getLongitud() %>,
                                             "Marcador",
                                             imagen,                
                                             estatusVisita                                
                                         );        
                             <%

                    }
                
                    %> 
                  
                        
                console.log(marcadoresVisitados);    //imprimir array en chrome                
                var porcentajeCumplido = ((marcadoresVisitados.length * 100) /  puntosTotales); 
                if(porcentajeCumplido>0)
                    porcentajeCumplido = porcentajeCumplido;
                else
                    porcentajeCumplido = 0;
                    
                var div = document.getElementById("percent");
                div.textContent = "Cumplimiento: " + porcentajeCumplido + " %";
                var text = div.textContent;
                
            } 
            
            
            function creaMarcadorRuta2(lat,lng,title,img,content){
                var marcador2 = new google.maps.Marker({
                        position: new google.maps.LatLng(lat,lng), 
                        title:title,
                        animation: google.maps.Animation.DROP,
                        icon:img
                    });
                var infowindow2 = new google.maps.InfoWindow({
                    content: content
                });
                google.maps.event.addListener(marcador2, 'click', function() {
                    infowindow2.open(map2,marcador2);
                });
                marcador2.setMap(map2);
                //infowindow2.open(map2,marcador2);//muestra informacion de marcador
                
            }            
          
           
            
            function creaLatLng(lat, lng){
                return new google.maps.LatLng(lat,lng);
            }
            
            
            //******Historico promotor bitacora
            
            
            function muestraDetallesPromotor(idUsuario){
                muestraVentanaDetalles("historicoPromotor_ajax.jsp",idUsuario);
                muestraRutasPromotor("rutasPromotor_ajax.jsp",idUsuario);
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
                       }else{
                           
                           $("#ajax_loading").fadeOut("slow");
                           $("#ajax_message").html(datos);
                           $("#ajax_message").fadeIn("slow");
                           
                       }
                    }
                });
            }
            
            
            function muestraRutasPromotor(url, id){                  
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
                           $("#div_map_resultado_rutas").html(datos);
                           $("#ajax_loading").fadeOut("slow");
                           datePicker();                          
                       }else{
                           
                           $("#ajax_loading").fadeOut("slow");
                           $("#ajax_message").html(datos);
                           $("#ajax_message").fadeIn("slow");
                           
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
          
          
            
            function creaMarcadorBasico(lat,lng,title,img){
                var marcador = new google.maps.Marker({
                        position: new google.maps.LatLng(lat,lng), 
                        title:title,
                        animation: google.maps.Animation.DROP,
                        icon:img
                    });
                return marcador;
            }
            
            
            function cambiaRuta(idRuta){                   
                    window.location.href = "cobranzaPromotor_ComparaRutas.jsp?idUsuario="+<%=idUsuario%>+"&idRuta="+idRuta;                          
                
            }
            
            function actualizarHistorico(id){
                if(getNumeroDeDias()<=5){
                
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
                }else{ 
                    $("#div_valida_rango_fecha").fadeIn("slow");
                    $("#div_valida_rango_fecha").html('El rango entre fechas no debe ser mayor a 5 días.');        
                    $("#div_valida_rango_fecha").fadeOut("slow");
                }
            }
            
            
            function reproducirHistorico(){                
                window.location.href = "cobranzaPromotor_ComparaRutas.jsp?idUsuario="+<%=idUsuario%>+"&idRuta="+ iRuta +"&fInicio=" + $("#txt_fecha_de").val() + "&fFin="+ $("#txt_fecha_a").val();                  
            }
            
            //Calculamos los dias de diferencia entre fechas
            function getNumeroDeDias(){
                var d1 = $('#txt_fecha_de').val().split("/");
                var dat1 = new Date(d1[2], parseFloat(d1[1])-1, parseFloat(d1[0]));
                var d2 = $('#txt_fecha_a').val().split("/");
                var dat2 = new Date(d2[2], parseFloat(d2[1])-1, parseFloat(d2[0]));

                var fin = dat2.getTime() - dat1.getTime();
                var dias = Math.floor(fin / (1000 * 60 * 60 * 24))  

                return dias;
            }
            
            // Llena el mapa 2, de la derecha, donde se muestra el recorrido real
            // asi como las capas para visualizar Clientes, Prospectos y Empleados
            function fillMap(){
                <%
                
                
                double latitudMin = 0; 
                double latitudMax = 0; 
                double longitudMin = 0;
                double longitudMax =0;
                double tolerancia = 0.02 ; //Equivalencia 0.01	0°0’36"	1.113 km   ( * 2  = 2.226 km)  http://www.sunearthtools.com/dp/tools/pos_earth.php?lang=es#accuracy
                String cQuery = "";
                
                //CICLO INNECESARIO, NO CUMPLE CON EL REQUERIMIENTO DE FILTRAR A LOS CLIENTES Y PROSPECTOS
                // QUE ESTAN A MAXIMO 1 KM DE DISTANCIA DEL PUNTO INICIAL
                //for(RutaMarcador rutaMarcador:rutaMarcadores){ 
                    
                        // Filtramos a 1 km de tolerancia de X punto
                        /*
                        latitudMin = Double.parseDouble(rutaMarcador.getLatitudMarcador()) - tolerancia;
                        latitudMax = Double.parseDouble(rutaMarcador.getLatitudMarcador())+ tolerancia;
                        
                        longitudMin = Double.parseDouble(rutaMarcador.getLongitudMarcador()) - tolerancia;
                        longitudMax = Double.parseDouble(rutaMarcador.getLongitudMarcador())+ tolerancia;
                
                        cQuery =" ID_EMPRESA =  " + idEmpresa +" AND (LATITUD BETWEEN " + latitudMin +" AND " + latitudMax + " OR LONGITUD BETWEEN " + longitudMin +" AND " + longitudMax + ")";
                        */
                
                        cQuery = " ID_EMPRESA =  " + idEmpresa;
                        
                        //--clientes 
                        clientesDto = new ClienteBO(user.getConn()).findClientes(-1, idEmpresa, 0, 100, " AND ID_CLIENTE IN (SELECT DISTINCT ID_CLIENTE FROM relacion_cliente_vendedor WHERE ID_USUARIO = " + empleado.getIdUsuarios()  + ")");
                        //ClienteDaoFactory.create(user.getConn()).findByDynamicWhere( cQuery , null);
                        
                            for(Cliente clienteDto:clientesDto){
                                
                                String nombreCliente = "";
                                if(StringManage.getValidString(clienteDto.getNombreComercial()).length()>0 ){
                                    nombreCliente =  StringManage.getValidString(clienteDto.getNombreComercial());  
                                }else{
                                    nombreCliente = "Cliente";
                                }
                                String dialogoCliente = ""
                                     + "<div class='map_dialog'>"
                                     + "    Cliente:<br/>" + nombreCliente.replaceAll("\\\"", "&quot;") + "<br/><br/>"
                                     + " </div>";
                                %>
                                        
                                        
                                 clientes.push(
                                     creaMarcador(
                                         <%=clienteDto.getLatitud() %>,
                                         <%=clienteDto.getLongitud() %>,
                                         "<%=nombreCliente.replaceAll("\\\"", "&quot;") %>",
                                         "../../images/maps/map_marker_cte.png",
                                         "<%=dialogoCliente %>"
                                     )
                                 );
                                <%
                            }
                            
                            
                         //--prospectos   
                         prospectosDto = ProspectoDaoFactory.create(user.getConn()).findByDynamicWhere( cQuery , null);   
                            
                        for(Prospecto prospectoDto : prospectosDto){
                        String nombreCliente = prospectoDto.getRazonSocial();// + (prospectoDto.getApellidoMaterno()!=null || prospectoDto.getApellidoMaterno().trim().equals("")?" " + prospectoDto.getApellidoMaterno():"") + " "  + prospectoDto.getNombre();
                        String dialogoCliente = ""
                            + "<div class='map_dialog'>"
                            + "    Prospecto:<br/>" + nombreCliente.replaceAll("\\\"", "&quot;") + "<br/><br/>"
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
                
                <%
                //****
                //Empleado[] empleadosDto = EmpleadoDaoFactory.create().findWhereIdEmpresaEquals(idEmpresa);                
                UsuariosBO empleadoBO = new UsuariosBO(user.getConn());
                Usuarios[] empleadosDto = empleadoBO.findUsuariosByRol(idEmpresa, RolesBO.ROL_GESPRO);
                EmpleadoBitacoraPosicionDaoImpl bitacoraDao = new EmpleadoBitacoraPosicionDaoImpl(user.getConn());
                //****
                for(Usuarios empleadoDto : empleadosDto){
                    DatosUsuario datosUsuarioDto = new DatosUsuarioBO(empleadoDto.getIdDatosUsuario(),user.getConn()).getDatosUsuario();
                    String nombreMarcador = datosUsuarioDto.getApellidoPat() + (datosUsuarioDto.getApellidoMat()!=null?" " + datosUsuarioDto.getApellidoMat():"") + " " + datosUsuarioDto.getNombre();
                    String dialogoMarcador = ""
                        + "<div class='map_dialog'>"
                        + "    <b>Vendedor:</b> " + nombreMarcador.replaceAll("\\\"", "&quot;") + "<br/>"
                    //    + "    <b>Estado:</b> " + (estadoDto!=null?estadoDto.getNombre():"") 
                        + "</div>";
                    %>
                    promotores.push(
                        creaMarcador(
                            <%=empleadoDto.getLatitud() %>,
                            <%=empleadoDto.getLongitud() %>,
                            "<%=nombreMarcador.replaceAll("\\\"", "&quot;") %>",
                            
                            <%
                                {
                            
                                long s = (new Date()).getTime();
                                long d = 0; 
                                try{
                                    String filtro = " ID_USUARIO = "+ empleadoDto.getIdUsuarios()+ " ORDER BY ID_BITACORA_POSICION DESC LIMIT 0,1";
                                    EmpleadoBitacoraPosicion bitEmp = bitacoraDao.findByDynamicWhere(filtro,null)[0];

                                    d = bitEmp.getFecha().getTime();
                                    //d = empleadoDto.getFechaHora().getTime();
                                }catch(Exception e){}
                                long diferencia = s - d;
                                //System.out.println("-------DIFERENCIA: "+diferencia);
                                if(diferencia < 300000){
                                %>
                                    '../../images/estatusEmpleado/icon_activoTrabajando.png',
                                <%}else{%>
                                    '../../images/estatusEmpleado/icon_desactivado.png',
                                <%}
                                
                                }
                                                        
                            %>
                                
                            "<%=dialogoMarcador %>"
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
                for(var i = 0, marcador; marcador = vehiculos[i]; i ++){
                    marcador.setMap(null);
                }
                for(var i = 0, marcador; marcador = puntos[i]; i ++){
                    marcador.setMap(null);
                }
            }
            
            function muestraMarcador(chk){
                switch(chk.id){
                    case "clientes":
                        if(chk.checked){
                            for(var i = 0, marcador; marcador = clientes[i]; i ++){
                                marcador.setMap(map2);
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
                                marcador.setMap(map2);
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
                                marcador.setMap(map2);
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
                                marcador.setMap(map2);
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
                                marcador.setMap(map2);
                            }
                        }else{
                            for(var i = 0, marcador; marcador = puntos[i]; i ++){
                                marcador.setMap(null);
                            }
                        }
                        break;
                }             
            }
            
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
                    infowindow.open(map2,marcador);
                });
                return marcador;
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
                    google.maps.event.clearListeners(map2, 'click');
                    var mapOptions = {
                        draggableCursor:null
                    };
                    map2.setOptions(mapOptions);
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
                    poly.setMap(map2);
                    medirListener = addLatLng;
                    medirDistance = 0;
                    medirLastPoint = null;
                    $('#txt_map_distance').val('0');
                    google.maps.event.addListener(map2, 'click', medirListener);
                    var mapOptions = {
                        draggableCursor:'crosshair'
                    };
                    map2.setOptions(mapOptions);
                }
                
            }
        
            var circuloListener;
            var circle;
            var markerCircle;
        
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
                        map: map2,
                        draggable: true
                    });
                    circle = new google.maps.Circle({
                        map: map2,
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
                    map2.setOptions(mapOptions);
                    map2.fitBounds(results[0].geometry.viewport);
                    
                    crearMarcadorBasico(results[0].geometry.location);
                    
                } else {
                    alert("Geocoding no tuvo éxito debido a: " + status);
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
          
          function verificaMarcadores(bounds){
                for(var i = 0, marcador; marcador = clientes[i]; i ++){
                    if(bounds.contains(marcador.getPosition())){
                        marcador.setMap(map2);
                    }else{
                        marcador.setMap(null);
                    }
                }
                
                for(var i = 0, marcador; marcador = prospectos[i]; i ++){
                    if(bounds.contains(marcador.getPosition())){
                        marcador.setMap(map2);
                    }else{
                        marcador.setMap(null);
                    }
                }
                
                for(var i = 0, marcador; marcador = promotores[i]; i ++){
                    if(bounds.contains(marcador.getPosition())){
                        marcador.setMap(map2);
                    }else{
                        marcador.setMap(null);
                    }
                }
                
                for(var i = 0, marcador; marcador = vehiculos[i]; i ++){
                    if(bounds.contains(marcador.getPosition())){
                        marcador.setMap(map2);
                    }else{
                        marcador.setMap(null);
                    }
                }
                
                for(var i = 0, marcador; marcador = puntos[i]; i ++){
                    if(bounds.contains(marcador.getPosition())){
                        marcador.setMap(map2);
                    }else{
                        marcador.setMap(null);
                    }
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
                        
            
            
            
            function getDistanceFromLatLonInMeters(lat1,lon1,lat2,lon2) {
                var R = 6371000; // Radius of the earth in meters
                var dLat = deg2rad(lat2-lat1);  // deg2rad below
                var dLon = deg2rad(lon2-lon1); 
                var a = 
                  Math.sin(dLat/2) * Math.sin(dLat/2) +
                  Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * 
                  Math.sin(dLon/2) * Math.sin(dLon/2)
                  ; 
                var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
                var d = R * c; // Distance in km
                return d;
            }

            function deg2rad(deg) {
              return deg * (Math.PI/180)
            }
            
        </script>

   
    </head>
    <body>
        
        <div class="content_wrapper"> 
        <jsp:include page="../include/header.jsp" flush="true"/>
        <jsp:include page="../include/leftContent.jsp"/>    
            
            <div id="content">
                <span id="nomPromo" style="color: #0074cc; font-weight: bold; padding-left: 350px; position: absolute;">
                    <h1>Vendedor: <%=datosUsuario.getNombre()+" "+datosUsuario.getApellidoPat()+" "+datosUsuario.getApellidoMat()%>
                        <h3><div id="percent"></div><h3>
                    </h1>
                </span>
                <div class="inner" style="margin-top: 10px;">
                    <div class="twocolumn">  
                        
                        <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                        <div id="ajax_message" class="alert_warning" style="display: none;"></div>
                        
                        <div class="column_left">  
                            <div class="header">
                                <span><img src="../../images/icon_mapa.png" alt="icon">
                                    Ruta Programada  ID: <%=rutaDto.getIdRuta() %>
                                </span>
                             </div>   
                             <br class="clear">
                             <div class="content">

                                <!-- Inicio de Contenido -->                                
                                <div style="width: 510px; height: 512px;">                               
                                    <br class="clear"/>                                    
                                        <div id="map_canvas" style="height: 500px; position: relative; background-color: rgb(229, 227, 223); overflow: hidden;">
                                            <!-- <img src="../../images/maps/ajax-loader.gif" alt="Cargando" style="margin: auto;"/>-->
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
                                                                
                                            <!-- Fin de Contenido-->
                             </div>
                        </div>                         
                         
                        
                        <div class="column_right">
                            <div class="header">
                                <span><img src="../../images/icon_mapa.png" alt="icon">
                                    Ruta Realizada
                                </span>
                            </div> 
                            <br class="clear">
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

                                <div id="rutaSeguida" style="width: 510px; height: 490px; overflow: hidden;">
                                     <!-- Inicio de Contenido -->
                                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                                    <div style="width: 510px; height: 480px;">                               
                                        <br class="clear"/>                                    
                                            <div id="map_canvas2" style="height: 470px; position: relative; background-color: rgb(229, 227, 223); overflow: hidden;">
                                                <!--<img src="../../images/maps/ajax-loader.gif" alt="Cargando" style="margin: auto;"/>-->
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
                                         
                                     <!-- Fin de Contenido-->                                    
                                </div>   
                            </div>
                        </div>    
                        
                        <div class="column_left">  
                            <div class="header">
                                <span><img src="../../images/icon_mapa.png" alt="icon">
                                    Rutas Asignadas
                                </span>
                             </div>   
                             <br class="clear">
                             <div class="content">

                                            <!-- Inicio de Contenido -->
                                                <div style="width: 510px; height: 313px;">                               
                                                    <br class="clear"/>   
                                                    <div id="div_map_resultado_rutas" style="width: 510px; height: 300px;overflow: scroll;">                                     
                                                    </div>
                                                                                       
                                                </div>
                                                                
                                            <!-- Fin de Contenido-->
                             </div>
                        </div>
                       
                        <div class="column_right">
                            <div id="div_valida_rango_fecha" class="alert_warning" style="display: none;"></div>
                            <div class="header">
                                <span><img src="../../images/icon_mapa.png" alt="icon">
                                    Opciones
                                </span>
                            </div> 
                            <br class="clear">
                            <div class="content">                                
                                <span>
                                    Selecciona los  registros que quieras ver en el mapa:
                                </span>
                                <p>
                                    <input id="clientes" type="checkbox" onclick="muestraMarcador(this);"/>Clientes asignados a Vendedor<br/>
                                    <input id="prospectos" type="checkbox" onclick="muestraMarcador(this);"/>Prospectos<br/>
                                    <input id="promotores" type="checkbox" onclick="muestraMarcador(this);"/>Vendedores<br/>
                                    <!--<input id="vehiculos" type="checkbox" onclick="muestraMarcador(this);"/>Veh&iacute;culos<br/>
                                    <input id="puntos" type="checkbox" onclick="muestraMarcador(this);"/>Puntos de inter&eacute;s
                                    <input type="button" onclick="calcRoute();" value="Ruta"/>-->
                                    <br>
                                    
                                </p>                                
                                <br><br>
                                
                                <div id="div_map_resultado_buscar" style="width: 510px; height: 200px;overflow: scroll;">                                     
                                </div>
                                
                                
                        </div>
                                
                    </div>
                        
                    <div id="action_buttons">
                            <p>                                
                                <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                            </p>
                    </div>   
                    
                </div>  
                <jsp:include page="../include/footer.jsp"/>                
            </div>
        </div>
        
    </body>
</html>
<%}%>