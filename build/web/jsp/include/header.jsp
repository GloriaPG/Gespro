<%-- 
    Document   : header
    Created on : 19-oct-2012, 19:30:39
    Author     : ISCesarMartinez poseidon24@hotmail.com
--%>

<%@page import="com.tsp.gespro.jdbc.EmpresaPermisoAplicacionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.EmpresaPermisoAplicacion"%>
<%@page import="java.util.Locale"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
/*
* Revisamos si se inicio la sesión
* Si no se inicio sesión redirigimos a la pantalla de login
* incluyendo la url actual para en cuanto se de un login válido se rediriga aquí mismo,
* ademas se incluyen los parametros GET
*/
if (user == null || user.getUser() == null) {
    //Redirección por javascript (cliente)
    out.print("<script>document.location.href='../../jsp/inicio/login.jsp?action=loginRequired&urlSource="+request.getRequestURI()+"?"+request.getQueryString()+"'</script>");
    //Redirección por java (servidor) ***No Funciona correctamente
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource="+request.getRequestURI()+"?"+request.getQueryString());
    response.flushBuffer();
}else{
    
    Date fecha=new Date(); 
    SimpleDateFormat sdf=new SimpleDateFormat("dd 'de' MMMM 'de' yyyy", new Locale("es","MX")); 
        
    EmpresaBO ebo = new EmpresaBO(user.getUser().getIdEmpresa(),user.getConn());
    Empresa empresa = ebo.getEmpresa();
    Empresa empresaMatriz =  null;
    try{ empresaMatriz = ebo.getEmpresaMatriz(empresa.getIdEmpresa()); }catch(Exception ex){}
    
 %>
<jsp:include page="../../jsp/include/registraNavegacionBitacora.jsp"/>
<script type="text/javascript">
    var urlLogout = '../inicio/login.jsp?action=logout';

    function salir(){
        apprise('Estas seguro que deseas cerrar sesión y salir?', {'verify':true, 'animate':true, 'textYes':'Si, salir', 'textNo':'Cancelar'}, function(r)
        {
            if(r){
                // Usuario dio click 'Yes'
                document.location.href=urlLogout;
            }
            else {
                // Usuario dio click 'Cancel'
                //apprise('Gracias por continuar!');
            }
        });
    }

    /* Idle TimeOut Session / Función JavaScript para controlar actividad
     * del usuario y en caso de inactividad cerrar sesión
     */
      $(document).ready(function(){
        $(document).idleTimeout({
			inactivity: (30 * 60 * 1000),//15 Minutes //Periodo de inactividad antes de mostrar el alert
			noconfirm: (30 * 1000), //10 Seconds //Tiempo maximo de espera para que el usuario confirme
			sessionAlive: false, //(5*1000)//5 Minutes //Tiempo para enviar un request y Mantener sesion viva
			redirect_url: '../../jsp/inicio/login.jsp?action=logoutInactiveSession',
                        activityEvents: 'click keypress scroll wheel mousewheel mousemove', 
			click_reset: true,
			alive_url: '../../jsp/inicio/mantenerSesionViva.jsp',
			logout_url: '../../jsp/inicio/login.jsp?action=logoutInactiveSession'
        });
        
        //Secuencia repetitiva de consulta de mensajes recibidos
        //Cada 10 segundos = 10*1000
        var id = setInterval("consultarMensajesRecibidos()",30*1000);
        
        //validamos las geocercas y la posicion de los empleados
        //var geoposicion = setInterval("consultarGeoposicionEmpleadoGeocerca()", 30*1000);
        
      });
      
      function consultarMensajesRecibidos(){
         $.get("../include/include_check_messages_ajax.jsp", {param1: "Nada"}, function(respuesta){
            $("#div_mensajes_recibidos").html(respuesta);
        });
      }
      
      /*function consultarGeoposicionEmpleadoGeocerca(){
         $.get("../catGeocerca/include_check_geoposicion_EmpleadoGeocerca_ajax.jsp", {param1: "Nada"}, function(respuesta){
            $("#div_mensajes_recibidos").html(respuesta);
        });
      }*/
        /*function consultarGeoposicionEmpleadoGeocerca(){
        
           
            $.post("../catGeocerca/mapaGeocercasCron.jsp", {param1: "Nada", idGeocerca : "1", forma : "1"}, function(respuesta){             
            
        });
      }*/
      
      

      
</script>

<!-- Begin header -->
<div id="header">
        <!--<div id="logo">
                <img src="../../images/logo.png" alt="logo"/>
        </div>
        <div id="search">
                <form action="../../jsp/inicio/main.jsp" id="search_form" name="search_form" method="get">
                        <input type="text" id="q" name="q" title="Buscar" class="search noshadow"/>
                </form>
        </div>-->
        <div id="account_info">
            <a href=""><%=empresa.getNombreComercial().length() < 25?empresa.getNombreComercial():empresa.getNombreComercial().substring(0, 25)%></a>
        </div>
        <div id="account_info">
                <img src="../../images/icon_online.png" alt="Online" class="mid_align"/>
                Bienvenido <a href=""><%=user.getUser().getUserName()%></a> | <a href="#" onclick="salir();">Cerrar Sesión</a>
        </div>
        <div id="div_mensajes_recibidos">            
        </div>        
        
        
        <div id="account_info" style="float: right;">
            <a href="#"><%=sdf.format(fecha)%></a>
        </div>
        
        
        <!--<div id="juanGuiaDinamica" style="position: absolute;left: 0px;top: 0px;z-index: 100; ">            
            <//%@include file="guiaDinamica.jsp" %>
        </div>-->
        
</div>
        
        <div id='chkcomments'></div>
<!-- End header -->

<%}%>
