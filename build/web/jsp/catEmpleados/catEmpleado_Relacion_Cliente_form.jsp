<%-- 
    Document   : catEmpleado_Relacion_Cliente_form
    Created on : 10/03/2016, 01:39:25 PM
    Author     : leonardo
--%>

<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.RelacionClienteVendedorBO"%>
<%@page import="com.tsp.gespro.jdbc.RelacionClienteVendedorDaoImpl"%>
<%@page import="com.tsp.gespro.dto.RelacionClienteVendedor"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el cliente tiene acceso a este topico
    if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
        response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
        response.flushBuffer();
    } else {
        
        int paginaActual = 1;
        try{
            paginaActual = Integer.parseInt(request.getParameter("pagina"));
        }catch(Exception e){}

        int idEmpresa = user.getUser().getIdEmpresa();
        
        /*
         * Parámetros
         */
        int idCliente = -1;
        try{ idCliente = Integer.parseInt(request.getParameter("idCliente")); }catch(NumberFormatException e){}

        int idUsuarioEmpleado = -1;
        try{ idUsuarioEmpleado = Integer.parseInt(request.getParameter("idUsuarioEmpleado")); }catch(NumberFormatException e){}

        /*
         *   0/"" = nuevo
         *   1 = editar/consultar
         *   2 = eliminar  
         */
        String mode = request.getParameter("acc") != null ? request.getParameter("acc") : "";
        String newRandomPass = "";
        
        RelacionClienteVendedorBO relacionClienteVendedorBO = new RelacionClienteVendedorBO(user.getConn());
        RelacionClienteVendedor relacionClienteVendedorsDto = null;
        if (idCliente > 0 && idUsuarioEmpleado > 0){
            relacionClienteVendedorsDto = relacionClienteVendedorBO.findRelacionClienteVendedors(idCliente, idUsuarioEmpleado, 0, 0, "")[0];
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
            
            function grabar(){
                var idUsuarioSeleccionado = $('#idUsuarioEmpleado').val();
                
                if(validar()){
                    $.ajax({
                        type: "POST",
                        url: "catEmpleado_Relacion_Cliente_ajax.jsp",
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
                                            location.href = "catEmpleado_Relacion_Cliente_list.jsp?pagina=<%=paginaActual%>&idUsuarioEmpleado="+idUsuarioSeleccionado;
                                        });
                           }else if(datos.indexOf("--CONFIRMACION-->", 0)>0){
                               $("#ajax_message").html(datos);
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").fadeIn("slow");
                               apprise('<img src=../../images/info.png>'+ datos + ' <br/> ¿Desea conservar las asignaciones previas?', {'verify':true, 'animate':true, 'textYes':'Si', 'textNo':'No'}, 
                                    function(r){
                                        if(r){
                                            // Usuario dio click 'Yes'
                                            $('#asignacionPrevia').val("1");//conservar la asignación previa del cliente
                                            grabar();
                                        }else{
                                            $('#asignacionPrevia').val("2");//no conservar la asignacion previa del cliente
                                            grabar();
                                        }
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
            }

            function validar(){
                /*
                if(jQuery.trim($("#nombre").val())==""){
                    apprise('<center><img src=../../images/warning.png> <br/>El dato "nombre de contacto" es requerido</center>',{'animate':true});
                    $("#nombre_contacto").focus();
                    return false;
                }
                */
                return true;
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
                    <h1>Cliente - Empleado</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                    <div class="twocolumn">
                        <div class="column_left">
                            <div class="header">
                                <span>
                                    <img src="../../images/icon_cliente.png" alt="icon"/>
                                    <% if(relacionClienteVendedorsDto!=null){%>
                                    Relación Cliente - Vendedor
                                    <%}else{%>
                                    Relación Cliente - Vendedor
                                    <%}%>
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                    
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>"/>
                                    <input type="hidden" id="asignacionPrevia" name="asignacionPrevia" value="0"/>
                                    
                                    <p>
                                        <label>Empleado:</label><br/>
                                        <select id="idUsuarioEmpleado" name="idUsuarioEmpleado" class="flexselect">
                                            <option value="-1"></option>
                                            <%= new UsuariosBO(user.getConn()).getUsuariosByRolHTMLCombo(idEmpresa, RolesBO.ROL_GESPRO, relacionClienteVendedorsDto!=null?relacionClienteVendedorsDto.getIdUsuario():idUsuarioEmpleado)%>
                                        </select>
                                    </p>
                                    <br/>
                                    <p>
                                        <label>Cliente:</label><br/>
                                        <select id="idCliente" name="idCliente" class="flexselect">
                                            <option value="-1" ></option>
                                            <%= new ClienteBO(user.getConn()).getClientesByIdHTMLCombo(idEmpresa, relacionClienteVendedorsDto!=null?relacionClienteVendedorsDto.getIdCliente():idCliente," AND ID_ESTATUS <> 2 " ) %>
                                        </select>
                                    </p>
                                    <br/>
                                    
                                    <br/><br/>
                                    
                                    <div id="action_buttons">
                                        <p>
                                            <input type="button" id="enviar" value="Guardar" onclick="grabar();"/>
                                            <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                                        </p>
                                    </div>
                                    
                            </div>
                        </div>
                        <!-- End left column window -->
                        
                        
                    </div>
                    </form>
                    <!--TODO EL CONTENIDO VA AQUÍ-->

                </div>

                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>

        <script>
            $("select.flexselect").flexselect();
        </script>
    </body>
</html>
<%}%>