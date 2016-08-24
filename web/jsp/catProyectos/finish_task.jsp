<%-- 
    Document   : formulario
    Created on : 07/08/2016, 09:05:02 PM
    Author     : Fabian
--%>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:directive.page import="com.tsp.gespro.hibernate.dao.ActividadDAO"/>
<jsp:directive.page import="com.tsp.gespro.hibernate.pojo.Actividad"/>
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
        <title><jsp:include page="../include/titleApp.jsp" /></title>

        <jsp:include page="../include/keyWordSEO.jsp" />
        <jsp:include page="../include/skinCSS.jsp" />
        <jsp:include page="../include/jsFunctions.jsp"/>
        
        
        <c:if test="${not empty param.idProyecto}">
            <fmt:parseNumber var="idProyecto" integerOnly="true" type="number" value="${param.idProyecto}" />
        </c:if>

        <script type="text/javascript">
            function guardar(){ 
                    $.ajax({
                        type: "POST",
                        url: "changes_ajax.jsp",
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
                                                    javascript:window.location.href = 'proyectos_tasks.jsp?idProyecto=${idProyecto}';
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
        <jsp:useBean id="actividadModel" class="com.tsp.gespro.hibernate.dao.ActividadDAO"/>
        <!--- @obj : Objeto de moneda a editar --->
        <c:set var="obj" value="${Actividad}"/>
        <c:if test="${not empty param.id}">
            <fmt:parseNumber var="id" integerOnly="true" type="number" value="${param.id}" />
            <c:set var="obj" value="${actividadModel.getById(id)}"/>
        </c:if>
        <c:if test="${obj.checkin != null}">
            <script>
                javascript:window.location.href = 'proyectos_tasks.jsp?idProyecto=${idProyecto}';
            </script>
        </c:if>
           <div class="content_wrapper">
            <jsp:include page="../include/header.jsp" flush="true"/>
            <jsp:include page="../include/leftContent.jsp"/>
            <!-- Inicio de Contenido -->
            <div id="content">
                <div class="inner" id="leito">
                    <h1>Proyecto</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <form action="" method="post" id="frm_action">
                    <div class="twocolumn">
                        <div class="column_left">
                            <div class="header">
                                <span>                                    
                                    <img src="../../images/icon_users.png" alt="icon"/>
                                    ${not empty param.id ? "Editar Actividad: " : "Nuevo Actividad"}
                                    ${not empty param.id ? obj.actividad : ""}
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                    <input type="hidden" id="id" name="idActividad" value="${ not empty id ? id :"0"}" />
                                    <input type="hidden" id="id" name="option" value="2" />
                                    <c:if test="${obj.tipoActividad == 1}">
                                    <p>
                                        <label>* ¿Quien Recibio?</label><br/>
                                        <input maxlength="45" type="text" id="recibio" name="recibio" style="width:300px"
                                               data-validation="length"
                                               data-validation-length="1-45"
                                               required
                                               />
                                    </p>
                                    <br/>
                                    </c:if>
                                    <p>
                                        <label>Comentarios</label><br/>
                                        <textarea id="comentarios" name="comentarios" style="width:300px;" required></textarea>
                                    </p>
                                    <br/> 
                                    <div id="action_buttons">
                                        <p>
                                            <input type="submit" id="enviar" value="Terminar" class="btn"/>
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