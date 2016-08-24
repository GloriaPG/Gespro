<%-- 
    Document   : proyectos_tasks
    Created on : 07/08/2016, 07:55:43 PM
    Author     : Fabian
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
        <title><jsp:include page="../include/titleApp.jsp" /></title>
        <jsp:include page="../include/keyWordSEO.jsp" />
        <jsp:include page="../include/skinCSS.jsp" />
        <jsp:include page="../include/jsFunctions.jsp"/>
    </head>
    <body>
        <!--- Inicialización de variables --->
        <jsp:useBean id="actividad" class="com.tsp.gespro.hibernate.dao.ActividadDAO"/>
        <jsp:useBean id="productoModel" class="com.tsp.gespro.hibernate.dao.ProductoDAO"/>
        <jsp:useBean id="usuariosModel" class="com.tsp.gespro.hibernate.dao.UsuariosDAO"/>
        <jsp:useBean id="puntoModel" class="com.tsp.gespro.hibernate.dao.PuntoDAO"/>
        <jsp:useBean id="services" class="com.tsp.gespro.Services.Allservices"/>
        
        <!--- @lista --->
            <c:set var="where" value="where id_proyecto = ${not empty param.idProyecto ? param.idProyecto : 0}"/>
        <c:set var="lista" value="${services.QueryActividadDAO(where)}"/>
        <!--- @formulario --->
        <c:set var="formulario" value="actividad_form.jsp"/> 
        
        <div class="content_wrapper">
            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>

            <!-- Inicio de Contenido -->
            <div id="content">

                <div class="inner">
                    <h1>Proyecto</h1>
                    
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>
                   
                    <div class="onecolumn">
                  
                    </div>

                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_validaXML.png" alt="icon"/>
                                Actividades
                            </span>
                            <div class="switch" style="width:500px">
                                <table width="500px" cellpadding="0" cellspacing="0">
                                    <tbody>
                                        <tr>
                                            <td>
                                               
                                            </td>
                                            <td class="clear">&nbsp;&nbsp;&nbsp;</td>
                                           
                                            <td>
                                                <input type="button" id="nuevo" name="nuevo" class="right_switch" value="Regresar" 
                                                        style="float: right; width: 100px;" onclick="history.back()"/>&nbsp;&nbsp;
                                                <input type="button" id="nuevo" name="nuevo" class="right_switch" value="Crear Nuevo" 
                                                        style="float: right; width: 100px;" onclick="javascript:window.location.href='${formulario}?idProyecto=${not empty param.idProyecto ? param.idProyecto : 0}'"/>
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
                                            <th>Actividas</th>
                                            <th>descripcion</th>
                                            <th>Usuario</th>
                                            <th>Lugar</th>
                                            <th>Tipo</th>
                                            <th>Realizada</th>
                                            <th>Producto</th>
                                            <th>Cantidad</th>
                                            <th>Recibio</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        
                                       <c:forEach items="${lista}" var="item">
                                         <tr>
                                            <td>${item.actividad}</td>
                                            <td>${item.descripcion}</td>
                                            <c:set var="user" value="${usuariosModel.getById(item.idUser)}"/>
                                            <td>${user.userName}</td>
                                            <c:set var="punto" value="${puntoModel.getById(item.idPunto)}"/>
                                            <td>${punto.lugar}</td>
                                            <td>${item.tipoActividad == 1 ? "Entrega" : "Actividad"}</td>
                                            <td>${item.checkin != null ? item.checkin  :"-"}</td>
                                            <c:set var="producto" value="${productoModel.getById(item.idProducto)}" />
                                            <td>${producto != null ? producto.nombre: "-"}</td>
                                            <td>${item.cantidad != null ? (item.cantidad > 0 ? item.cantidad : "-") :"-"}</td>
                                            <td>${item.recibio != null ? item.recibio  :"-"}</td>
                                            <td>
                                                <a href="${formulario}?idProyecto=${item.idProyecto}&id=${item.idActividad}"><img src="../../images/icon_edit.png" alt="editar" class="help" title="Editar"/></a>
                                                <c:if test="${item.checkin == null}">
                                                    <a href="finish_task.jsp?id=${item.idActividad}&idProyecto=${item.idProyecto}" ><img src="../../images/icon_accept.png" alt="Terminar" class="help" title="Terminar"/></a>
                                                </c:if>
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

    </body>
</html>