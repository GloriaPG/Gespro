<%-- 
    Document   : lista
    Created on : 16/07/2016, 04:42:43 PM
    Author     : gloria
--%>

<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:directive.page import="com.tsp.gespro.hibernate.dao.*"/>
<jsp:directive.page import="java.util.List"/>
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
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
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
           
        </script>
    </head>
    <body>
        <!--- Inicialización de variables --->
        <jsp:useBean id="helper" class="com.tsp.gespro.hibernate.dao.UsuarioMonitorDAO"/>
        <!--- @lista --->
        <c:set var="lista" value="${helper.lista}"/>
        <!--- @formulario --->
        <c:set var="formulario" value="../catUsuariosMonitor/formulario.jsp"/>
        
        <div class="content_wrapper">

            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>

            <!-- Inicio de Contenido -->
            <div id="content">

                <div class="inner" id="leito">
                    <h1>Administración</h1>
                    
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>
                   
                    <div class="onecolumn">
                  
                    </div>

                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_users.png" alt="icon"/>
                                Usuarios monitor
                            </span>
                            <div class="switch" style="width:500px">
                                <table width="500px" cellpadding="0" cellspacing="0">
                                    <tbody>
                                        <tr>
                                            <td>
                                               
                                            </td>
                                            <td class="clear">&nbsp;&nbsp;&nbsp;</td>
                                           
                                            <td>
                                                <input type="button" id="nuevo" name="nuevo" class="right_switch" value="Crear Nuevo" 
                                                        style="float: right; width: 100px;" onclick="location.href='${formulario}'"/>
                                            </td>                                           
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <br class="clear"/>
                        
                        <div class="content">
                            <form id="form_data" name="form_data" action="" method="post">
                                <table class="data" width="100%" cellpadding="0" cellspacing="0">
                                    <thead>
                                        <tr>
                                            <th>Nombre</th>
                                            <th>Apellido Paterno</th>
                                            <th>Apellido Materno</th>
                                            <th>email</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                       <c:forEach items="${lista}" var="item">
                                         <tr class="${ item.activo ? "" : "inactive"}">
                                            <td>${item.nombre}</td>
                                            <td>${item.apellidoPaterno}</td>
                                            <td>${item.apellidoMaterno}</td>
                                            <td>${item.email}</td>
                                            <td>
                                               <a href="${formulario}?id=${item.id}"><img src="../../images/icon_edit.png" alt="editar" class="help" title="Editar"/></a>
                                                &nbsp;&nbsp;
                                                <a href="#" onclick="guardar(this);" id="${item.id}">
                                                    <img src="../../images/icon_email.png" alt="reestablecer" class="help" title="Generar nueva credencial"/></a>
                                            </td>
                                          </tr>
                                       </c:forEach>
                                    </tbody>
                                </table>
                            </form>
                        </div>
                    </div>

                </div>

                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>
    <script>
        function guardar(obj){
                var id=$(obj).attr("id");
                var contrasenia=crearPassword(10);
                $.ajax({
                    type: "POST",
                    url: "crearCredenciales.jsp",
                    data: { id: id, password:contrasenia },
                    beforeSend: function(objeto){
                        $("#ajax_loading").html('<center><img src="../../images/ajax_loader.gif" alt="Cargando.." /><h2>Generando...</h2></center>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("EXITO") != -1){
                           $("#ajax_message").html("Credenciales generadas.");
                           $("#ajax_loading").fadeOut("slow");
                           $("#ajax_message").fadeIn("slow");
                           var appriseString='<center><img src=../../images/info.png> <br/> Credenciales generadas.</center>';
                           var appriseArgs={'animate':true};
                           var appriseCallback=function(){
                               location.href = "lista.jsp";
                               parent.$.fancybox.close();
                           };
                           apprise(appriseString,appriseArgs,appriseCallback);
                        }else{
                           $("#ajax_loading").fadeOut("slow");
                           $("#ajax_message").html("Ocurrió un error al intentar generar las crendeciales.");
                           $("#ajax_message").fadeIn("slow");
                        }
                    }
               });
            }
    </script>
    </body>
</html>
