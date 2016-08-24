<%-- 
    Document   : reparto
    Created on : 07/08/2016, 07:55:43 PM
    Author     : Fabian
--%>

<%@page import="com.tsp.gespro.hibernate.pojo.Proyecto"%>
<%@page import="com.tsp.gespro.Services.Allservices"%>
<%@page import="com.tsp.gespro.report.ReportBO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Cobertura"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Coberturaproyecto"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Punto"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Producto"%>
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
// Obtener parametros
String buscar = request.getParameter("q")!=null? new String(request.getParameter("q").getBytes("ISO-8859-1"),"UTF-8") :"";    //
String idProyecto = request.getParameter("idProyecto")!=null? new String(request.getParameter("idProyecto").getBytes("ISO-8859-1"),"UTF-8") :"";
// crear consulta de filtro
String filtroBusqueda = ""; //"AND ID_ESTATUS=1 ";
if (!buscar.trim().equals("")) {
    filtroBusqueda += " WHERE (NOMBRE LIKE '%" + buscar + "%')";
}
String filtroBusquedaEncoded = java.net.URLEncoder.encode(filtroBusqueda, "UTF-8");
Allservices allservices = new Allservices();
List<Proyecto> proyectos = allservices.queryProyectoDAO(filtroBusqueda);
List<Cobertura> coberturas = allservices.queryCobertura("where idCobertura in (select idCobertura from Coberturaproyecto where idProyecto = "+idProyecto+")");

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
        <jsp:useBean id="productos" class="com.tsp.gespro.hibernate.dao.ProductoDAO"/>
        <jsp:useBean id="clienteModel" class="com.tsp.gespro.hibernate.dao.ClienteDAO"/>
        <jsp:useBean id="coberturaModel" class="com.tsp.gespro.hibernate.dao.CoberturaDAO"/>
        <jsp:useBean id="puntoModel" class="com.tsp.gespro.hibernate.dao.PuntoDAO"/>
        <jsp:useBean id="repartoModel" class="com.tsp.gespro.hibernate.dao.RepartoDAO"/>
        <jsp:useBean id="Services" class="com.tsp.gespro.Services.Allservices"/>
        <!--- @formulario --->
        <c:set var="formulario" value="formulario.jsp"/>        
<script type="text/javascript">
            function guardar(){ 
                    $.ajax({
                        type: "POST",
                        url: "reparto_ajax.jsp",
                        data: $("#form_data").serialize(),
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
                                                javascript:window.location.href = "catProyectos.jsp";
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
        
        <div class="content_wrapper">

            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>

            <!-- Inicio de Contenido -->
            <div id="content">

                <div class="inner">
                    <h1>Proyectos</h1>
                    
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>
                   
                    <div class="onecolumn">
                  
                    </div>

                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_validaXML.png" alt="icon"/>
                                Reparto
                            </span>
                        </div>
                        <br class="clear"/>
                        
                        <div class="content">
                            <form id="form_data" name="form_data" action="" method="post">
                                <c:set var="where" value="where idProyecto = ${not empty param.idProyecto ? param.idProyecto : 0}"/>
                                <c:set var="reparto" value="${Services.queryRepartoDAO(where)}"/>
                                <c:if test="${empty reparto}">
                                    <% 
                                        if(coberturas.size() > 0){
                                    %>
                                    <input type="hidden" name="id_proyecto" value="${param.idProyecto}"/>
                                        <table class="data" width="100%" cellpadding="0" cellspacing="0" style="text-align: center">
                                            <thead>
                                                <tr>
                                                    <th></th>
                                                    <% 
                                                        for(Cobertura itemsCob : coberturas){
                                                            List<Punto> puntos = allservices.queryPuntoDAO("where idCobertura = "+itemsCob.getIdCobertura());
                                                            out.print("<th colspan='"+puntos.size()+"'>"+itemsCob.getNombre()+"</th>");
                                                        }
                                                    %>

                                                </tr>
                                                <tr>
                                                    <th></th>
                                                    <% 
                                                        for(Cobertura itemsCob : coberturas){
                                                            List<Punto> puntos = allservices.queryPuntoDAO("where idCobertura = "+itemsCob.getIdCobertura());
                                                            for(Punto itemsPun : puntos){
                                                                out.print("<th>"+itemsPun.getLugar()+"</th>");
                                                            }
                                                        }
                                                    %>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <%int conPro = 1;%>
                                                <c:set var="where" value="where id_proyecto = ${param.idProyecto}"/>
                                                <c:set var="productosProyecto" value="${Services.QueryProductosDAO(where)}"/>
                                                <c:forEach items="${productosProyecto}" var="productoProyecto">
                                                    <tr>
                                                <th>${productoProyecto.nombre}</th>
                                                 <% 
                                                        for(Cobertura itemsCob : coberturas){
                                                            List<Punto> puntos = allservices.queryPuntoDAO("where idCobertura = "+itemsCob.getIdCobertura());
                                                            for(Punto itemsPun : puntos){
                                                                out.print("<td>");%>
                                                                <input type="text" name="cantidad[]" value="0"/>
                                                                <input type="hidden" name="id_producto[]" value="${productoProyecto.idProducto}"/>
                                                                <input type="hidden" name="id_lugar[]"value="<%=itemsPun.getIdPunto()%>"/>
                                                                <%out.print("</td>");
                                                                conPro++;
                                                            }
                                                        }
                                                %>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                                <input type="submit" value="Guardar"/>
                                    <% } %>
                                    <c:if test="${empty coberturas}">
                                    </c:if>
                                </c:if>
                                <c:if test="${not empty reparto}">
                                    <% 
                                        if(coberturas.size() > 0){
                                    %>
                                    <input type="hidden" name="id_proyecto" value="${param.idProyecto}"/>
                                        <table class="data" width="100%" cellpadding="0" cellspacing="0" style="text-align: center">
                                            <thead>
                                                <tr>
                                                    <th></th>
                                                    <% 
                                                        for(Cobertura itemsCob : coberturas){
                                                            List<Punto> puntos = allservices.queryPuntoDAO("where id_cobertura = "+itemsCob.getIdCobertura());
                                                            out.print("<th colspan='"+puntos.size()+"'>"+itemsCob.getNombre()+"</th>");
                                                        }
                                                    %>

                                                </tr>
                                                <tr>
                                                    <th></th>
                                                    <% 
                                                        for(Cobertura itemsCob : coberturas){
                                                            List<Punto> puntos = allservices.queryPuntoDAO("where id_cobertura = "+itemsCob.getIdCobertura());
                                                            for(Punto itemsPun : puntos){
                                                                out.print("<th>"+itemsPun.getLugar()+"</th>");
                                                            }
                                                        }
                                                    %>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <%int conPro = 1;%>
                                                <c:set var="where" value="where id_proyecto = ${param.idProyecto}"/>
                                                <c:set var="productosProyecto" value="${Services.QueryProductosDAO(where)}"/>
                                                <c:forEach items="${productosProyecto}" var="productoProyecto">
                                                    <tr>
                                                <th>${productoProyecto.nombre}</th>
                                                 <% 
                                                        for(Cobertura itemsCob : coberturas){
                                                            List<Punto> puntos = allservices.queryPuntoDAO("where id_cobertura = "+itemsCob.getIdCobertura());
                                                            for(Punto itemsPun : puntos){
                                                                out.print("<td>");%>
                                                                <c:set var="punto" value="<%=itemsPun.getIdPunto()%>"/>
                                                                <c:set var="wherereparto" value="where idProyecto = ${param.idProyecto} and idLugar = ${punto} and idProducto = ${productoProyecto.idProducto}"/>
                                                                <c:set var="repartopunto" value="${Services.queryRepartoDAO(wherereparto)}"/>
                                                                <c:forEach var="reparto" items="${repartopunto}">
                                                                    <input type="hidden" name="idreparto[]" value="${reparto.idreparto}"/>
                                                                    <input type="text" name="cantidad[]" value="${reparto.cantidad}"/>
                                                                    <input type="hidden" name="id_producto[]" value="${productoProyecto.idProducto}"/>
                                                                    <input type="hidden" name="id_lugar[]"value="<%=itemsPun.getIdPunto()%>"/>
                                                                </c:forEach>
                                                                <%out.print("</td>");
                                                                conPro++;
                                                            }
                                                        }
                                                %>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                                <br>
                                                <br>
                                                <div style="text-align: right">
                                                <input type="submit" value="Guardar"/>
                                                <input type="button" value="Regresar" onclick="history.back()"/>
                                                </div>
                                    <% } %>
                                    <c:if test="${empty coberturas}">
                                    </c:if>
                                </c:if>

                            </form>
                             <!-- INCLUDE OPCIONES DE EXPORTACIÓN-->
           
                            <!-- FIN INCLUDE OPCIONES DE EXPORTACIÓN-->
                        </div>
                    </div>

                </div>

                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>
                <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
        <script src="http://cdnjs.cloudflare.com/ajax/libs/jquery-form-validator/2.3.26/jquery.form-validator.min.js"></script>
        <script>

         $(document).ready(function() {
            $("#form_data").submit(function(e){
               e.preventDefault();
               guardar();
            });
        });
        </script>
    </body>
</html>