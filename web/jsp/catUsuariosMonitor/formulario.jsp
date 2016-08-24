<%-- 
    Document   : formulario
    Created on : 16/07/2016, 04:43:02 PM
    Author     : gloria
--%>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:directive.page import="com.tsp.gespro.hibernate.dao.UsuarioMonitorDAO"/>
<jsp:directive.page import="com.tsp.gespro.hibernate.pojo.UsuarioMonitor"/>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
//Verifica si el usuario tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
}
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link rel="shortcut icon" href="../../images/favicon.ico">
        <jsp:include page="../include/keyWordSEO.jsp" />
        <title><jsp:include page="../include/titleApp.jsp" /></title>
        <jsp:include page="../include/skinCSS.jsp" />
        <jsp:include page="../include/jsFunctions.jsp"/>
        
        <script type="text/javascript">
        function crearPassword(length, special) {
             var iteration = 0;
             var password = "";
             var randomNumber;
             if(special == undefined){
                 var special = false;
             }
             while(iteration < length){
               randomNumber = (Math.floor((Math.random() * 100)) % 94) + 33;
               if(!special){

                 if ((randomNumber >=33) && (randomNumber <=47)) { continue; }

                 if ((randomNumber >=58) && (randomNumber <=64)) { continue; }

                 if ((randomNumber >=91) && (randomNumber <=96)) { continue; }

                 if ((randomNumber >=123) && (randomNumber <=126)) { continue; }

               }

               iteration++;
               password += String.fromCharCode(randomNumber);
             }

             $('#password').val(password);                      
             return password;
           }
            
            function guardar(){ 
                    $.ajax({
                        type: "POST",
                        url: "ajax.jsp",
                        data: $("#frm_action").serialize(),
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                            $("#ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            console.log("Datos");
                            console.log(datos);
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               $("#ajax_message").html("Los datos se guardaron correctamente.");
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").fadeIn("slow");
                               apprise('<center><img src=../../images/info.png> <br/>Los datos se guardaron correctamente.</center>',{'animate':true},
                                        function(r){
                                                javascript:window.location.href = "lista.jsp";
                                                parent.$.fancybox.close();  
                                        });
                           }else{
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").html("Ocurrió un error al intentar guardar los datos.");
                               $("#ajax_message").fadeIn("slow");
                               $("#action_buttons").fadeIn("slow");
                           }
                        }
                    });   
                }                               
        </script>
    </head>
    <body>
        <!--- Inicialización de variables --->
        <jsp:useBean id="helper" class="com.tsp.gespro.hibernate.dao.UsuarioMonitorDAO"/>
        <!--- @obj : Objeto de usuario a editar --->
        <c:set var="obj" value="${UsuarioMonitor}"/>
        <c:if test="${not empty param.id}">
            <fmt:parseNumber var="id" integerOnly="true" type="number" value="${param.id}" />
            <c:set var="obj" value="${helper.getById(id)}"/>
        </c:if>
            
           <div class="content_wrapper">
            <jsp:include page="../include/header.jsp" flush="true"/>
            <jsp:include page="../include/leftContent.jsp"/>
            <!-- Inicio de Contenido -->
            <div id="content">
                <div class="inner"id="leito">
                    <h1>Usuario monitor</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                    <div class="twocolumn">
                        <div class="column_left">
                            <div class="header">
                                <span>                                    
                                    <img src="../../images/icon_users.png" alt="icon"/>
                                    ${not empty param.id ? "Editar usuario:" : "Usuario"}
                                    ${not empty param.id ? param.id : ""}
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                    <input type="hidden" id="id" name="id" value="${ not empty obj.id ? obj.id :"0"}" />
                                    <p>
                                        <label>Nombre:</label><br/>
                                        <input maxlength="50" type="text" id="nombre" name="nombre" style="width:300px"
                                               value="${not empty obj.nombre ? obj.nombre : ""}"
                                               data-validation="length"
                                               data-validation-length="1-50"
                                               data-validation-error-msg="El nombre debe tener de 1 a 50 caracteres."
                                               />
                                    </p>
                                    <br/>
                                    <p>
                                        <label>Apellido Paterno:</label><br/>
                                        <input maxlength="70" type="text" id="apellidoPaterno" name="apellidoPaterno" style="width:300px;"
                                               value="${not empty obj.apellidoPaterno ? obj.apellidoPaterno : ""}"
                                               data-validation="length"
                                               data-validation-length="1-50"
                                               data-validation-error-msg="El apellido paterno debe tener de 1 a 50 caracteres."
                                               />
                                    </p>
                                    <br/>                                    
                                    <p>
                                        <label>Apellido Materno:</label><br/>
                                        <input maxlength="70" type="text" id="apellidoMaterno" name="apellidoMaterno" style="width:300px;"
                                               value="${not empty obj.apellidoMaterno ? obj.apellidoMaterno : ""}"
                                               />
                                    </p>
                                    <br/> 
                                    <p>
                                        <label>*email:</label><br/>
                                        <input maxlength="100" type="text" id="email" name="email" style="width:300px"
                                               value="${not empty obj.email ? obj.email : ""}"
                                               class="required"
                                               data-validation="email"
                                               data-validation-error-msg="Formato de email incorrecto."
                                               required/>
                                    </p>  
                                    <br/>                                                                                                                                            
                                    <p>
                                       <label>* Contraseña:</label><br/>
                                       <input type="text" id="password" name="password" value="${ not empty obj.password ? obj.password :""}" required/>
                                       <br/><br/>
                                       <input type="button" id="generarPassword" value="Generar contraseña" onClick="crearPassword(10);"/>
                                    </p>
                                    <br>
                                    <p>
                                        <input type="checkbox" class="checkbox" ${ obj.activo ? "checked":""} 
                                               id="checkActivo" name="checkActivo">
                                        <label for="activo">Activo</label>
                                        <input type="hidden" id="activo" name="activo" value="${not empty obj.activo ? obj.activo : "true" }"/>
                                    </p>
                                    <br/>
                                    <div id="action_buttons">
                                        <p>
                                            <input type="submit" id="enviar" value="Guardar" class="btn"/>
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
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
        <script src="http://cdnjs.cloudflare.com/ajax/libs/jquery-form-validator/2.3.26/jquery.form-validator.min.js"></script>
        <script>

         $(document).ready(function() {
            $.validate({
                 lang: 'en',
                 modules : 'toggleDisabled',
                 disabledFormFilter : 'form.toggle-disabled',
                 showErrorDialogs : true
             });
            $("#frm_action").submit(function(e){
               e.preventDefault();
               guardar();
            });
            $('#checkActivo').change(function() {
                if($(this).is(":checked")) {
                   $("#activo").val("true");
                }else{
                   $("#activo").val("false");
                }      
            });
        });
        </script>
    </body>
</html>
