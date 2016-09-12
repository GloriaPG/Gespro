<%-- 
    Document   : perfil
    Created on : 19-dic-2012, 13:11:41
    Author     : ISCesarMartinez
--%>

<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.dto.Ldap"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el usuario tiene acceso a este topico
if (user==null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
}else{
    
    String mode = request.getParameter("mode") != null ? request.getParameter("mode") : "";
    
    
    Usuarios usuarios = user.getUser();
    Ldap ldap = user.getLdap();
    DatosUsuario datosUsuario = user.getDatosUsuario();
    /**
     * No es obligatorio que todos los usuarios tengan estos datos,
     * por lo tanto puede tener valor NULO
     */
    
    
    
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <jsp:include page="../include/keyWordSEO.jsp" />

        <title><jsp:include page="../../jsp/include/titleApp.jsp" /></title>
        
        <jsp:include page="../../jsp/include/skinCSS.jsp" />

        <jsp:include page="../../jsp/include/jsFunctions.jsp"/>
        
        <script type="text/javascript">
            
            <% if (user.requirePasswordChange()) {%>
            function msgCambioPasswordRequerido(){
                    $("#ldap_pass").focus();
                    apprise('<center><img src=../../images/info.png> <br/>Debido al reestablecimiento de tu contraseña<br/>es necesario que la cambies para asegurar tu privacidad</center>',{'animate':true});
            }
            <%}%>
                
            function grabar(){
                if(validar()){
                    $.ajax({
                        type: "POST",
                        url: "perfil_ajax.jsp",
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
                                            location.href = "../inicio/main.jsp";
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
                <% if (user.requirePasswordChange()){ %>
                    if(jQuery.trim($("#ldap_pass").val())==""){
                        apprise('<center><img src=../../images/warning.png> <br/>El dato "contraseña" es requerido</center>',{'animate':true});
                        $("#ldap_pass").focus();
                        return false;
                    }
                    if(jQuery.trim($("#ldap_pass_confirm").val())==""){
                        apprise('<center><img src=../../images/warning.png> <br/>El dato "confirmar contraseña" es requerido</center>',{'animate':true});
                        $("#ldap_pass_confirm").focus();
                        return false;
                    }
                <%}%>
                    
                if(jQuery.trim($("#ldap_pass").val())!="" && (jQuery.trim($("#ldap_pass").val())!=jQuery.trim($("#ldap_pass_confirm").val()))){
                    apprise('<center><img src=../../images/warning.png> <br/>El dato "contraseña" y su confirmación no coinciden</center>',{'animate':true});
                    $("#ldap_pass").focus();
                    return false;
                }
                
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
                    <h1>Mi Perfil</h1>
                    
                    <!--<//jsp:include page="../include/menu.jsp"/>-->
                    
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>
                    
                    <form action="" method="post" id="frm_action">
                    <div class="twocolumn">
                        <div class="column_left">
                        
                            <div class="header">
                                <span>Mis Datos</span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                    <!--<input type="hidden" id="idUsuarios" name="idUsuarios" value="<%=user.getUser()!=null?user.getUser().getIdUsuarios():"" %>" />-->
                                    <input type="hidden" id="mode" name="mode" value="<%=mode%>" />
                                    
                                    <p>
                                        <label>ID: </label><br/>
                                        <input type="text" id="idUsuarios" name="idUsuarios" style="width:300px"
                                               value="<%= usuarios!=null?usuarios.getIdUsuarios():"" %>"
                                               readonly disabled/>
                                    </p>
                                    <br/>
                                    
                                    <p>
                                        <label>Username: </label><br/>
                                        <input type="text" id="usuarios_username" name="usuarios_username" style="width:300px"
                                               value="<%= usuarios!=null?usuarios.getUserName():"" %>"
                                               readonly disabled/>
                                    </p>
                                    <br/>
                                    
                                    <p>
                                        <label>Contraseña: </label><br/>
                                        <input type="password" id="ldap_pass" name="ldap_pass" style="width:300px"
                                               maxlength="20" value=""/>
                                    </p>
                                    <br/>
                                    
                                    <p>
                                        <label>Confirmar Contraseña: </label><br/>
                                        <input type="password" id="ldap_pass_confirm" name="ldap_pass_confirm" style="width:300px"
                                               maxlength="20" value=""/>
                                    </p>
                                    <br/>
                                    
                                    <p>
                                        <label>Rol: </label><br/>
                                        <input type="text" id="usuarios_rol" name="usuarios_rol" style="width:300px"
                                               value="<%= RolesBO.getRolName(usuarios!=null?usuarios.getIdRoles():0) %>"
                                               readonly disabled/>
                                    </p>
                                    <br/>
                                    
                                    <p>
                                        <label>Correo electrónico de contacto: </label><br/>
                                        <input type="text" id="ldap_email" name="ldap_email" style="width:300px"
                                               value="<%= datosUsuario!=null?datosUsuario.getCorreo():"" %>"
                                               maxlength="90"/>
                                    </p>
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
                        
                        <!--Columna derecha-->
                        <div class="column_right">
                            <div class="header">
                                <span>
                                    Información Personal
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                <p>
                                    <label>Nombre: </label><br/>
                                    <input type="text" id="datosUsuario_nombre" name="datosUsuario_nombre" style="width:300px"
                                            value="<%= datosUsuario!=null?datosUsuario.getNombre():"" %>"
                                            maxlength="50"/>
                                </p>
                                <br/>
                                
                                <p>
                                    <label>Apellido Paterno: </label><br/>
                                    <input type="text" id="datosUsuario_apaterno" name="datosUsuario_apaterno" style="width:300px"
                                            value="<%= datosUsuario!=null?datosUsuario.getApellidoPat():"" %>"
                                            maxlength="50"/>
                                </p>
                                <br/>
                                
                                <p>
                                    <label>Apellido Materno: </label><br/>
                                    <input type="text" id="datosUsuario_amaterno" name="datosUsuario_amaterno" style="width:300px"
                                            value="<%= datosUsuario!=null?datosUsuario.getApellidoMat():"" %>"
                                            maxlength="50"/>
                                </p>
                                <br/>
                                
                                <p>
                                    <label>Dirección: </label><br/>
                                    <input type="text" id="datosUsuario_direccion" name="datosUsuario_direccion" style="width:300px"
                                            value="<%= datosUsuario!=null?datosUsuario.getDireccion():"" %>"
                                            maxlength="100"/>
                                </p>
                                <br/>
                                
                                <p>
                                    <label>*Teléfono:</label><br/>  
                                    <input maxlength="8" type="text" id="datosUsuario_telefono" name="datosUsuario_telefono" style="width:255px"
                                            value="<%=datosUsuario!=null?datosUsuario.getTelefono():"" %>"
                                            onkeypress="return validateNumber(event);"/>
                                </p>
                                <br/>
                                
                                <p>
                                    <label>Celular: </label><br/>
                                    <input type="text" id="datosUsuario_celular" name="datosUsuario_celular" style="width:300px"
                                            value="<%= datosUsuario!=null?datosUsuario.getCelular():"" %>"
                                            maxlength="50" onkeypress="return validateNumber(event);"/>
                                </p>
                                <br/>
                                
                            </div>
                        </div>
                        <!--Fin Columna derecha-->
                    </div>
                    </form>
                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    
                </div>
                
                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>

        <script>
            <% if (user.requirePasswordChange()) {%>
                msgCambioPasswordRequerido();
            <%}%>
        </script>
    </body>
</html>
<%}%>