
<%@page import="com.tsp.gespro.bo.DatosUsuarioBO"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.tsp.gespro.factory.ProspectoDaoFactory"%>
<%@page import="com.tsp.gespro.dto.Prospecto"%>
<%@page import="com.tsp.gespro.util.StringManage"%>
<%@page import="com.tsp.gespro.factory.ClienteDaoFactory"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page import="com.tsp.gespro.factory.RutaMarcadorDaoFactory"%>
<%@page import="com.tsp.gespro.dto.RutaMarcador"%>
<%@page import="com.tsp.gespro.jdbc.UsuariosDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.factory.RutaDaoFactory"%>
<%@page import="com.tsp.gespro.dto.Ruta"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el cliente tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
} else {

    int idEmpresa = user.getUser().getIdEmpresa();

    /*
     * Parámetros
     */
    int idRuta = 0;
    try {
        idRuta = Integer.parseInt(request.getParameter("idRuta"));
    } catch (NumberFormatException e) {
    }

    Ruta rutaDto = RutaDaoFactory.create(user.getConn()).findByPrimaryKey(idRuta);
    Usuarios promotorDto = null;
    DatosUsuario datosUsuarioDto = null;
    try{            
        promotorDto = new UsuariosDaoImpl(user.getConn()).findByPrimaryKey(rutaDto.getIdUsuario());
        datosUsuarioDto = new DatosUsuarioBO(promotorDto.getIdDatosUsuario(),user.getConn()).getDatosUsuario();
    }catch(Exception e){
        promotorDto = new Usuarios();
        datosUsuarioDto = new DatosUsuario();
    }
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
        
        <script type="text/javascript">
            
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
                
        
                //solo para centrar mapa en primer punto
                <%
                RutaMarcador[] centraMapa = RutaMarcadorDaoFactory.create(user.getConn()).findByDynamicWhere("ID_RUTA = " + rutaDto.getIdRuta() + " ORDER BY ID_RUTA_MARCADOR ASC", new Object[0]);
                    for(RutaMarcador pCentral : centraMapa){
                %>
                        var mapOptions = {
                                zoom: 13,
                                center: creaLatLng(<%=pCentral.getLatitudMarcador() %>,<%=pCentral.getLongitudMarcador() %>),
                                mapTypeId: google.maps.MapTypeId.ROADMAP
                         };
                    <%
                        break;
                    }                    
                    %>
                            
                //          

                map = new google.maps.Map(document.getElementById('map_canvas'),
                    mapOptions);
                    
                map.controls[google.maps.ControlPosition.TOP_RIGHT].push(
                FullScreenControl(map, 'Pantalla Completa',
                'Salir Pantalla Completa'));
                
                showRoute();
                
                directionsDisplay.setMap(map);
                                
            }
        
            function loadScript() {
                var script = document.createElement('script');
                script.type = 'text/javascript';
                script.src = 'https://maps.googleapis.com/maps/api/js?libraries=geometry&sensor=false&' +
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
                }
                var poly = new google.maps.Polyline(polyOptions);
                poly.setMap(map);
                
                <%
                    String lineaRuta = rutaDto.getRecorridoRuta();
                    lineaRuta =  lineaRuta.replaceAll("\\),\\(", "|");
                    lineaRuta =  lineaRuta.replaceAll("\\)", "");
                    lineaRuta =  lineaRuta.replaceAll("\\(", "");

                    String[] puntosRuta = lineaRuta.split("\\|");
                    
                    for(String datosPunto : puntosRuta){

                        String[] latLng = datosPunto.split(",");
                        out.print("poly.getPath().push(creaLatLng("+latLng[0]+", "+latLng[1]+"));");                        
                    }
                    
                    RutaMarcador[] rutaMarcadores = RutaMarcadorDaoFactory.create(user.getConn()).findByDynamicWhere("ID_RUTA = " + rutaDto.getIdRuta() + " ORDER BY ID_RUTA_MARCADOR ASC", new Object[0]);
                    boolean primero = true;
                    int index = 0;
                    for(RutaMarcador rutaMarcador:rutaMarcadores){
                       index++;
                       System.out.println(" **************" + rutaMarcador.getIdCliente());
                        
                        String info = "";
                        String title = "";
                        String img = "";
                        if(rutaMarcador.getIdCliente()>0){
                            try{
                                Cliente clienteDto = ClienteDaoFactory.create(user.getConn()).findByPrimaryKey(rutaMarcador.getIdCliente());
                                title = StringManage.getValidString(clienteDto.getNombreComercial());
                                info = ""
                                    + "<div class='map_dialog'>"
                                    + "    Cliente:<br/>" + StringManage.getValidString(clienteDto.getNombreComercial()) + "<br/><br/>"
                                    + "</div>";
                                img = "../../images/maps/map_marker_cte.png";
                            }catch(Exception e){}
                        }
                        
                        if(rutaMarcador.getIdProspecto()>0){
                            try{
                                Prospecto prospectoDto = ProspectoDaoFactory.create(user.getConn()).findByPrimaryKey(rutaMarcador.getIdProspecto());
                                title = prospectoDto.getContacto()!=null?prospectoDto.getContacto():"Desconocido";
                                info = ""
                                    + "<div class='map_dialog'>"
                                    + "    Prospecto:<br/>" + prospectoDto.getContacto()!=null?prospectoDto.getContacto():"Desconocido" + "<br/><br/>"
                                    + "</div>";
                                img = "../../images/maps/map_marker_pros.png";
                            }catch(Exception e){}
                        }
                        
                        if(info.equals("")){
                            info = "<div class='map_dialog'>"+(rutaMarcador.getInformacionMarcador()!=null?rutaMarcador.getInformacionMarcador():"")+"</div>";
                        }
                        
                        if(img.equals("")){
                            img = "../../images/maps/numbers_red/number_" + index + ".png";
                        }
                        
                        if(title.equals("")){
                            title = "Marcador";
                        }
                        
                        %>
                        creaMarcador(
                             <%=rutaMarcador.getLatitudMarcador() %>,
                             <%=rutaMarcador.getLongitudMarcador() %>,
                             "<%=title %>",
                             "<%=img%>",
                             "<%=info %>"
                         )
                        <%
                    
                    }
                    
                %>
                
            }
            
            function creaLatLng(lat, lng){
                return new google.maps.LatLng(lat,lng);
            }
        
            function creaMarcador(lat,lng,title,img,content){
                var marcador = new google.maps.Marker({
                        position: new google.maps.LatLng(lat,lng), 
                        title:title,
                        animation: google.maps.Animation.DROP,
                        icon: img
                    });
                var infowindow = new google.maps.InfoWindow({
                    content: content
                });
                google.maps.event.addListener(marcador, 'click', function() {
                    //infowindow.open(map,marcador);
                });
                marcador.setMap(map);
            }
        </script>
    </head>
    <body>
        <div class="content_wrapper">

            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>

            <!-- Inicio de Contenido -->
            <div id="content">

                <div class="inner">
                    <h1>Logística</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                    <div class="twocolumn">
                        <div class="column_left">
                            <div class="header">
                                <span>
                                    <img src="../../images/icon_logistica.png" alt="icon"/>
                                    Datos
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                    <input type="hidden" id="idRuta" name="idRuta" value="<%=rutaDto!=null?rutaDto.getIdRuta():"" %>" />
                                    <p>
                                        <label>Nombre:</label><br/>
                                        <%=rutaDto.getNombreRuta() %>
                                    </p>
                                    <br/>
                                    <p>
                                        <label>Comentarios:</label><br/>
                                        <%=rutaDto.getComentarioRuta().replaceAll("\n", "<br/>") %>
                                    </p>
                                    <br/>
                                    <p>
                                        <label>Fecha de registro:</label><br/>
                                        <%=new SimpleDateFormat("dd/MM/yyyy HH:mm").format(rutaDto.getFhRegRuta()) %>
                                    </p>
                                    <br/>
                                    <p>
                                        <label>Vendedor:</label><br/>
                                        <%
                                        try{
                                            out.print(datosUsuarioDto.getApellidoPat() + " " + datosUsuarioDto.getApellidoMat() + " " + datosUsuarioDto.getNombre());
                                        }catch(Exception e){
                                            out.print("No Asignado");
                                        }
                                        
                                            
                                        %>
                                    </p>
                                    <br/>
                                    <p>
                                        <label>Repetir Semanalmente:</label><br/>
                                        <%= StringManage.getValidString(rutaDto.getDiasSemanaRuta()) %>
                                    </p>
                                    <br/>
                                    <br/>
                                    <div id="action_buttons">
                                        <p>
                                            <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                                        </p>
                                    </div>
                                    
                            </div>
                        </div>
                        <!-- End left column window -->
                        <div class="column_right">
                            <div class="header">
                                <span>
                                    <img src="../../images/icon_logistica.png" alt="icon"/>
                                    Ruta
                                </span>
                                <div class="switch" style="width:410px">

                                </div>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                <div id="map_canvas" style="height: 400px;width: auto">
                                    <img src="../../images/maps/ajax-loader.gif" alt="Cargando" style="margin: auto;"/>
                                </div>
                            </div>
                        </div>
                        
                    </div>
                    </form>
                    <!--TODO EL CONTENIDO VA AQUÍ-->

                </div>

                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>


    </body>
</html>
<%}%>