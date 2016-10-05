<%-- 
    Document   : catEmpleado_Relacion_Prospecto
    Created on : 30/09/2016, 11:45:25 AM
    Author     : DXN
--%>

<%@page import="com.tsp.gespro.dto.RelacionProspectoVendedor"%>
<%@page import="com.tsp.gespro.bo.RelacionProspectoVendedorBO"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
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
        int idProspecto = -1;
        try{ idProspecto = Integer.parseInt(request.getParameter("idProspecto")); }catch(NumberFormatException e){}

        int idUsuarioEmpleado = -1;
        try{ idUsuarioEmpleado = Integer.parseInt(request.getParameter("idUsuarioEmpleado")); }catch(NumberFormatException e){}
        
        int asignado = -1;
        try{ asignado = Integer.parseInt(request.getParameter("asignado")); }catch(NumberFormatException e){}

        /*
         *   0/"" = nuevo
         *   1 = editar/consultar
         *   2 = eliminar  
         */
        String mode = request.getParameter("acc") != null ? request.getParameter("acc") : "";
        String newRandomPass = "";
        
        RelacionProspectoVendedorBO relacionProspectoVendedorBO = new RelacionProspectoVendedorBO(user.getConn());
        RelacionProspectoVendedor relacionProspectoVendedorsDto = null;
        if (idProspecto > 0 && idUsuarioEmpleado > 0){
            relacionProspectoVendedorsDto = relacionProspectoVendedorBO.findRelacionProspectoVendedors(idProspecto, idUsuarioEmpleado, 0, 0, "")[0];
        }
%>
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
                        url: "catEmpleado_Relacion_Prospecto_ajax.jsp",
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
                                            location.href = "../catProspectos/catProspectos_list.jsp";
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
                    <h1>Prospecto - Promotor</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                    <div class="twocolumn">
                        <div class="column_left">
                            <div class="header">
                                <span>
                                    <img src="../../images/icon_users.png" alt="icon"/>
                                    <% if(asignado==0){%>
                                    Relación Prospecto - Promotor
                                    <%}else{%>
                                    Relación Prospecto - Promotor (Reasignación)
                                    <%}%>
                                    
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                    <input type="hidden" id="idProspecto" name="idProspecto" value="<%= idProspecto %>"/>
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>"/>
                                    <input type="hidden" id="asignacionPrevia" name="asignacionPrevia" value="0"/>
                                    <p>
                                        <label>Promotor:</label><br/>
                                        <select id="idUsuarioEmpleado" name="idUsuarioEmpleado" class="flexselect">
                                            <option value="-1"></option>
                                            <%= new UsuariosBO(user.getConn()).getUsuariosByRolHTMLCombo(idEmpresa, RolesBO.ROL_GESPRO, relacionProspectoVendedorsDto!=null?relacionProspectoVendedorsDto.getIdUsuario():idUsuarioEmpleado)%>
                                        </select>
                                    </p>
                                    <br/>
                                    
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