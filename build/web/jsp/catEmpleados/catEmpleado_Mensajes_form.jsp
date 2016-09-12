<%-- 
    Document   : catEmpleado_Mensajes_form
    Created on : 13/02/2013, 03:58:33 PM
    Author     : Leonardo
--%>

<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.PasswordBO"%>
<%@page import="com.tsp.gespro.bo.MovilMensajeBO"%>
<%@page import="com.tsp.gespro.jdbc.MovilMensajeDaoImpl"%>
<%@page import="com.tsp.gespro.dto.MovilMensaje"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el cliente tiene acceso a este topico
    if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
        response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
        response.flushBuffer();
    } else {

        long idEmpresa = user.getUser().getIdEmpresa();
        
        /*
         * Parámetros
         */
        int idMovilMensaje = 0;
        try {
            idMovilMensaje = Integer.parseInt(request.getParameter("idMovilMensaje"));
        } catch (NumberFormatException e) {
        }
        
         int idEmpleado = -1;
        try{ 
            idEmpleado = Integer.parseInt(request.getParameter("idEmpleado")); 
        }catch(NumberFormatException e){}

        /*
         *   0/"" = nuevo
         *   1 = editar/consultar
         *   2 = eliminar  
         */
        String mode = request.getParameter("acc") != null ? request.getParameter("acc") : "";
        String newRandomPass = "";
        
        MovilMensajeBO movilMensajeBO = new MovilMensajeBO(user.getConn());
        MovilMensaje movilMensajesDto = null;
        if (idMovilMensaje > 0){
            movilMensajeBO = new MovilMensajeBO(idMovilMensaje,user.getConn());
            movilMensajesDto = movilMensajeBO.getMovilMensaje();
        }else{
            newRandomPass = new PasswordBO().generateValidPassword();
        }
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
            
            function grabar(){
                if(validar()){
                    $.ajax({
                        type: "POST",
                        url: "catEmpleado_Mensajes_ajax.jsp",
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
                                            location.href = "catEmpleados_list.jsp";
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
                    <%if(mode.equals("mensajeMasivo")){%>
                        <h1>Mensaje a Empleados</h1>
                    <%}else{%>
                        <h1>Mensaje a Empleado</h1>
                    <%}%>
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                    <div class="twocolumn">
                        <div class="column_left">
                            <div class="header">
                                <span>
                                    <img src="../../images/icon_marca.png" alt="icon"/>
                                    <% if(movilMensajesDto!=null){%>
                                    Editar Mensaje ID <%=movilMensajesDto!=null?movilMensajesDto.getIdMovilMensaje():"" %>
                                    <%}else{%>
                                    Mensaje
                                    <%}%>
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                    <input type="hidden" id="idMovilMensaje" name="idMovilMensaje" value="<%=movilMensajesDto!=null?movilMensajesDto.getIdMovilMensaje():"" %>" />
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>" />
                                    <p>
                                        <label>Empleado que recibe el mensaje:</label><br/>
                                        <select size="1" id="idEmpleado" name="idEmpleado" >
                                            <%if(mode.equals("mensajeMasivo")){%>
                                            <option value="-1" >Todos los Empleados</option>
                                            <%
                                                    
                                                out.print(new UsuariosBO(user.getConn()).getUsuariosByHTMLCombo((int)idEmpresa, idEmpleado," AND ID_ROLES = 4 AND ID_ESTATUS = 1 " ));                                                
                                            %>
                                            <%}else{%>
                                            <option value="-1" >Selecciona un Receptor</option>                                            
                                                <%
                                                   
                                                out.print(new UsuariosBO(user.getConn()).getUsuariosByHTMLCombo((int)idEmpresa, idEmpleado,"" ));                                                
                                            }%>
                                        </select>                                        
                                    </p>  
                                    <br/>
                                    <p>
                                        <label>*Mensaje:</label><br/>
                                        <input maxlength="160" type="text" id="mensajeMovil" name="mensajeMovil" style="width:350px;"
                                               value="<%=movilMensajesDto!=null?movilMensajeBO.getMovilMensaje().getMensaje():"" %>"/>
                                    </p>
                                    <br/>                                                                        
                                    
                                    <!--<p>
                                        <input type="checkbox" class="checkbox" <//%=movilMensajesDto!=null?(movilMensajesDto.getIdEstatus()==1?"checked":""):"checked" %> id="estatus" name="estatus" value="1"> <label for="estatus">Activo</label>
                                    </p>-->
                                    <br/><br/>
                                    
                                    <% if (!mode.equals("3")) {%>
                                        <div id="action_buttons">
                                            <p>
                                                <input type="button" id="enviar" value="Enviar" onclick="grabar();"/>
                                                <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                                            </p>
                                        </div>
                                    <%}else{
                                        //En caso de ser Formulario en modo PopUp
                                    %>
                                        <div id="action_buttons">
                                            <p>
                                                <input type="button" id="enviar" value="Enviar" onclick="grabar();"/>
                                                <input type="button" id="regresar" value="Cerrar" onclick="parent.$.fancybox.close();"/>
                                            </p>
                                        </div>
                                    <%}%>
                                    
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


    </body>
</html>
<%}%>