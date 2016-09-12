<%-- 
    Document   : catEmpleados_form.jsp
    Created on : 08-01-2013, 12:13:49
    Author     : Leonardo 
--%>

<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.jdbc.EmpresaPermisoAplicacionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.EmpresaPermisoAplicacion"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.dto.EmpleadoBitacoraPosicion"%>
<%@page import="com.tsp.gespro.jdbc.EmpleadoBitacoraPosicionDaoImpl"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.bo.DispositivoMovilBO"%>
<%@page import="com.tsp.gespro.dto.DispositivoMovil"%>
<%@page import="com.tsp.gespro.bo.EmpleadoRolBO"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.PasswordBO"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el Empleado tiene acceso a este topico
    if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
        response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
        response.flushBuffer();
    } else {

        long idEmpresa = user.getUser().getIdEmpresa();
        
        /*
         * Parámetros
         */
        int idEmpleado = 0;
        try {
            idEmpleado = Integer.parseInt(request.getParameter("idUsuario"));
        } catch (NumberFormatException e) {
        }
        
        

        /*
         *   0/"" = nuevo
         *   1 = editar/consultar
         *   2 = eliminar  
         *   3 = nuevo (modalidad PopUp [cotizaciones, pedidos, facturas]) 
         */
        String mode = request.getParameter("acc") != null ? request.getParameter("acc") : "";
        String newRandomPass = "";
        
        UsuarioBO usuarioBO = new UsuarioBO(user.getConn());
        Usuarios empleadosDto = null;
        DatosUsuario datosUsuarioDto = null;
        
        if (idEmpleado > 0){
            usuarioBO = new UsuarioBO(user.getConn(),idEmpleado);
            empleadosDto = usuarioBO.getUser();
            
             datosUsuarioDto =  usuarioBO.getDatosUsuario();
        }
        
        EmpresaBO empresaBO = new EmpresaBO(user.getConn());
        EmpresaPermisoAplicacion empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl(user.getConn()).findByPrimaryKey(empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa());
        
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
        <link rel="shortcut icon" href="../../images/favicon.ico">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <jsp:include page="../include/keyWordSEO.jsp" />

        <title><jsp:include page="../include/titleApp.jsp" /></title>

        <jsp:include page="../include/skinCSS.jsp" />

        <jsp:include page="../include/jsFunctions.jsp"/>
        
        <script type="text/javascript">
            
            var global = [];
            
            
            function grabar(){
              
                    $.ajax({
                        type: "POST",
                        url: "catEmpleados_ajax.jsp",
                        data: $("#frm_action").serialize(),
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                            $("#ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               $("#ajax_message").html(datos);
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").fadeIn("slow");
                               apprise('<center><img src=../../images/info.png> <br/>'+ datos +'</center>',{'animate':true},
                                        function(r){
                                            <% if (!mode.equals("3")) {%>
                                                location.href = "catEmpleados_list.jsp";
                                            <%}else{%>
                                                parent.recargarSelectEmpleados();
                                                parent.$.fancybox.close();
                                            <%}%>
                                            
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

         
            
            $(document).ready(function() {
                //Si se recibio el parametro para que el modo sea en forma de popup
                <%= mode.equals("3")? "mostrarFormPopUpMode();":""%>
            });
            
            function mostrarFormPopUpMode(){
		$('#left_menu').hide();
                $('#header').hide();
		//$('#show_menu').show();
		$('body').addClass('nobg');
		$('#content').css('marginLeft', 30);
		$('#wysiwyg').css('width', '97%');
		setNotifications();
            }
            
            function apareceAutomovil(){   
                var seleccionadoRol = document.getElementById("idRolEmpleado").value;
                if(seleccionadoRol==2){                    
                    document.getElementById("automovilDisplay").style.display="block";
                }else{                    
                    document.getElementById("automovilDisplay").style.display="none";                    
                }
            }
            
            
            function muestraDetallesPromotor(id, tipo){
                var url = "";
                switch(tipo){
                    case 1:
                        url = "../mapa/detallesPromotor_ajax.jsp";
                        break;
                    case 2:
                        url = "../mapa/historicoPromotor_ajax.jsp";
                        break;
                    case 3:
                        url = "../mapa/cobrosPromotor_ajax.jsp";
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
                        url = "../mapa/rutasPromotor_ajax.jsp";
                        break;
                    case 6:
                    url = "../mapa/pedidosPromotor_ajax.jsp";
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
          
          
          function actualizarHistorico(id){
                $.ajax({
                    type: "GET",
                    url: "../mapa/historicoPromotor_ajax.jsp",
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
            
            
            
            function reproducirHistorico(i){
                apprise('<center>No Aplica</center>',{'animate':true},function(r){ });
                
            }
            function cambiaRuta(idRuta){
                location.href = "../mapa/logistica_consulta.jsp?idRuta="+idRuta;
                
            }
            
            function creaMarcadorBasico(lat,lng,title){
                var marcador = new google.maps.Marker({
                        position: new google.maps.LatLng(lat,lng), 
                        title:title,
                        animation: google.maps.Animation.DROP
                    });
                return marcador;
            }
            
            function enviarMensaje(){
              $.ajax({
                    type: "POST",
                    url: "../mapa/envioMensajePromotor_ajax.jsp",
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
            
            
        </script>
    </head>
    <body>
        <div class="content_wrapper">

            <% if (!mode.equals("3")) {%>
                <jsp:include page="../include/header.jsp" flush="true"/>
                <jsp:include page="../include/leftContent.jsp"/>
            <% } %>

            <!-- Inicio de Contenido -->
            <div id="content">

                <div class="inner" id="leito">
                    <h1>Localización</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                    <div class="twocolumn">
                        <div class="column_left">
                            <div class="header">
                                <span>
                                    <%
                                    long s = (new Date()).getTime();
                                    long d = 0; 
                                    EmpleadoBitacoraPosicion bitEmp = null;
                                    try{
                                        EmpleadoBitacoraPosicionDaoImpl bitacoraDao = new EmpleadoBitacoraPosicionDaoImpl();
                                        String filtro = " ID_USUARIO = "+ empleadosDto.getIdUsuarios()+ " ORDER BY ID_BITACORA_POSICION DESC LIMIT 0,1";
                                        bitEmp = bitacoraDao.findByDynamicWhere(filtro,null)[0];

                                        d = bitEmp.getFecha().getTime();
                                        //d = empleadosDto.getFechaHora().getTime();
                                    }catch(Exception e){}
                                    long diferencia = s - d;                                
                                    if(diferencia < 300000){
                                    %>
                                        <img src="../../images/estatusEmpleado/icon_activoTrabajando.png" alt="icon"/>
                                    <%}else{%>
                                        <img src="../../images/estatusEmpleado/icon_desactivado.png"  alt="icon"/>
                                    <%}%>
                                    
                                    <% if(empleadosDto!=null){%>
                                    Localización de Empleado ID <%=empleadosDto!=null?empleadosDto.getIdUsuarios():"" %>
                                    <%}else{%>
                                    Empleado  Localización
                                    <%}%>
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content" style="height:520px;">
                                    <input type="hidden" id="idEmpleado" name="idEmpleado" value="<%=empleadosDto!=null?empleadosDto.getIdUsuarios():"" %>" />
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>" />
                                    <p>
                                        <label>Número de Empleado:</label><br/>
                                        <%=empleadosDto!=null?empleadosDto.getNumEmpleado():"" %>
                                    </p>
                                    <br/>
                                    <p>
                                        <label>Nombre:</label><br/>
                                        <%=datosUsuarioDto!=null?datosUsuarioDto.getNombre():"" %>
                                    </p>
                                    <br/>
                                    <p>
                                        <label>Apellido Paterno:</label><br/>
                                        <%=datosUsuarioDto!=null?datosUsuarioDto.getApellidoPat():"" %>
                                    </p>
                                    <br/>                                    
                                    <p>
                                        <label>Apellido Materno:</label><br/>
                                        <%=datosUsuarioDto!=null?datosUsuarioDto.getApellidoMat():"" %>
                                    </p>
                                    <br/>  
                                    <p>
                                        <label>Latitud:</label><br/>
                                        <%=bitEmp!=null?bitEmp.getLatitud():"0" %>
                                    </p>
                                    <br/>  
                                    <p>
                                        <label>Longitud:</label><br/>
                                        <%=bitEmp!=null?bitEmp.getLongitud():"0"%>
                                    </p>
                                    <br/>  
                                    <div id="div_map_resultado_buscar" style="height: 210px;overflow: scroll;"></div>                                   
                                    <br/>
                                    
                                    <% if (!mode.equals("3")) {%>
                                        <div id="action_buttons">
                                            <p>
                                                <!--<input type="button" id="enviar" value="Guardar" onclick="grabar();"/>-->
                                                <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                                            </p>
                                        </div>
                                    <%}else{
                                        //En caso de ser Formulario en modo PopUp
                                    %>
                                        <div id="action_buttons">
                                            <p>
                                                <input type="button" id="enviar" value="Guardar" onclick="grabar();"/>
                                                <input type="button" id="regresar" value="Cerrar" onclick="parent.$.fancybox.close();"/>
                                            </p>
                                        </div>
                                    <%}%>
                                    
                            </div>
                        </div>
                        <!-- End left column window -->
                        <!-- contenido de columna derecha Mapa-->
                        <div class="column_left">
                            <div class="header">
                                <span>
                                    <img src="../../images/icon_movimiento.png" alt="icon"/>                                    
                                    Mapa                                     
                                </span>
                            </div>
                            <br class="clear"/>
                            
                            <div class="content" style="height:520px;">                                                 
                                <jsp:include page="../include/Mapa_EmpleadoLocalizacion.jsp"/>     
                            </div>
                        </div>
                        <!-- fin de contenido de columna derecha Mapa-->
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