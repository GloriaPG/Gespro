<%-- 
    Document   : catProyectos
    Created on : 07/08/2016, 07:55:43 PM
    Author     : Fabian
--%>

<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Proyecto"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Cliente"%>
<%@page import="com.tsp.gespro.hibernate.dao.ClienteDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Usuarios"%>
<%@page import="com.tsp.gespro.hibernate.dao.UsuariosDAO"%>
<%@page import="com.tsp.gespro.Services.Allservices"%>
<%@page import="com.tsp.gespro.report.ReportBO"%>
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

// crear consulta de filtro
String filtroBusqueda = ""; //"AND ID_ESTATUS=1 ";
if (!buscar.trim().equals("")) {
    filtroBusqueda += " WHERE (NOMBRE LIKE '%" + buscar + "%')";
}
String filtroBusquedaEncoded = java.net.URLEncoder.encode(filtroBusqueda, "UTF-8");
Allservices allservices = new Allservices();
List<Proyecto> proyectos = allservices.queryProyectoDAO(filtroBusqueda);

EmpresaBO empresaBO = new EmpresaBO(user.getConn());
int idEmpresaMatriz = empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa();
ClienteDAO clienteModel = new ClienteDAO();
UsuariosDAO usuarioModel = new UsuariosDAO();
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
        <!--- @formulario --->
        <c:set var="formulario" value="formulario.jsp"/> 
        
        <div class="content_wrapper">

            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>

            <!-- Inicio de Contenido -->
            <div id="content">

                <div class="inner">
                    <h1>Administración</h1>
                    
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>
                   
                    <div class="onecolumn">
                  
                    </div>

                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_validaXML.png" alt="icon"/>
                                Proyectos
                            </span>
                            <div class="switch" style="width:500px">
                                <table width="500px" cellpadding="0" cellspacing="0">
                                    <tbody>
                                        <tr>
                                            <td>
                                                <div id="search">
                                                <form action="catProyectos.jsp" id="search_form" name="search_form" method="get">                                                                                                                                                

                                                        <input type="text" id="q" name="q" title="Buscar por nombre" class="" style="width: 70%; float: left; "
                                                               value="<%=buscar%>"/>
                                                        <input type="image" src="../../images/Search-32_2.png" id="buscar" name="buscar"  style="cursor: pointer; width: 30px; height: 25px; float: left"/>

                                                </form>
                                                </div>
                                            </td>
                                            <td class="clear">&nbsp;&nbsp;&nbsp;</td>
                                           
                                            <td>
                                                <input type="button" id="nuevo" name="nuevo" class="right_switch" value="Crear Nuevo" 
                                                        style="float: right; width: 100px;" onclick="javascript:window.location.href='${formulario}'"/>
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
                                            <th>ID Proyecto</th>
                                            <th>Nombre</th>
                                            <th>Fecha de Inicio</th>
                                            <th>Fecha Programada</th>
                                            <th>Fecha de Creación</th>
                                            <th>Cliente</th>
                                            <th>Avance %</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            for(Proyecto proyecto : proyectos){
                                                Usuarios userproyecto = null;
                                                boolean isSameEmpresa = false;
                                                if(proyecto.getIdPromotor()!=null){
                                                    userproyecto = usuarioModel.getById(proyecto.getIdPromotor());
                                                    int idEmpresaMatrizProyecto = empresaBO.getEmpresaMatriz(userproyecto.getIdEmpresa()).getIdEmpresa();
                                                    if(idEmpresaMatrizProyecto==idEmpresaMatriz)
                                                        isSameEmpresa = true;
                                                    
                                                }
                                                if(proyecto.getStatus() == 1 && isSameEmpresa){
                                        %> 
                                        <tr>
                                            <td><% out.print(proyecto.getIdProyecto()); %></td>
                                            <td><% out.print(proyecto.getNombre()); %></td>
                                            <td><% out.print(proyecto.getFechaInicio()); %></td>
                                            <td><% out.print(proyecto.getFechaProgramada()); %></td>
                                            <td><% out.print(proyecto.getFechaReal()); %></td>
                                            <% Cliente client = clienteModel.getById(proyecto.getIdCliente());
                                            %>
                                            <td><% out.print(client.getNombreComercial()); %></td>
                                            <td><% out.print(proyecto.getAvance()); %></td>
                                            <td>
                                                <a href="${formulario}?id=<% out.print(proyecto.getIdProyecto()); %><% if(isSameEmpresa){out.print("&idEmpresa="+idEmpresaMatriz);} %>"><img src="../../images/icon_edit.png" alt="editar" class="help" title="Editar"/></a>
                                                <a href="proyectos_tasks.jsp?idProyecto=<% out.print(proyecto.getIdProyecto()); %>"><img src="../../images/icon_logistica.png" alt="editar" class="help" title="Ver Actividades"/></a>
                                                <a href="reparto.jsp?idProyecto=<% out.print(proyecto.getIdProyecto()); %>"><img src="../../images/clipboard_report_bar_16_ns.png" alt="editar" class="help" title="Ver Reparto"/></a>
                                                <% if(proyecto.getStatus() == 1) { %>
                                                <a href="changes_proyecto_ajax.jsp?idProyecto=<% out.print(proyecto.getIdProyecto()); %>"><img src="../../images/icon_delete.png" alt="editar" class="help" title="Ver Reparto"/></a>
                                                <% } %>
                                                </td>
                                          </tr>        
                                         
                                        <%        
                                                }
                                            }
                                        %>
                                    </tbody>
                                </table>
                            </form>
                             <!-- INCLUDE OPCIONES DE EXPORTACIÓN-->
                            <jsp:include page="../include/reportExportOptions.jsp" flush="true">
                                <jsp:param name="idReport" value="<%= ReportBO.PROYECTO_REPORT %>" />
                                <jsp:param name="parametrosCustom" value="<%= filtroBusquedaEncoded %>" />
                            </jsp:include>
                            <!-- FIN INCLUDE OPCIONES DE EXPORTACIÓN-->
                        </div>
                    </div>

                </div>

                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>
        
    </body>
</html>