<%-- 
    Document   : catProyectos
    Created on : 07/08/2016, 07:55:43 PM
    Author     : Fabian
--%>

<%@page import="com.tsp.gespro.hibernate.pojo.LoginCliente"%>
<%@page import="com.tsp.gespro.dto.Roles"%>
<%@page import="com.tsp.gespro.jdbc.RolesDaoImpl"%>
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
 RolesDaoImpl rolesDaoImpl=new RolesDaoImpl(user.getConn());
 Roles rol=rolesDaoImpl.findByPrimaryKey(user.getUser().getIdRoles());
 int idCliente=0;
 if(rol.getNombre().equals("CLIENTE")){
     LoginClienteDAO loginClienteDAO=new LoginClienteDAO(user.getConn());
     LoginCliente lc=loginClienteDAO.getByIdUsuario(user.getUser().getIdUsuarios());
     idCliente=lc.getIdCliente();
 }
// crear consulta de filtro
String filtroBusqueda = ""; //"AND ID_ESTATUS=1 ";
if (!buscar.trim().equals("")) {
    if(idCliente != 0){
        filtroBusqueda += "(NOMBRE LIKE '%" + buscar + "%') AND status=1 AND ID_CLIENTE="+ String.valueOf(idCliente);
    }else{
        filtroBusqueda += " (NOMBRE LIKE '%" + buscar + "%') AND status=1";
    }
}
String filtroBusquedaEncoded = java.net.URLEncoder.encode(filtroBusqueda, "UTF-8");
Allservices allservices = new Allservices();
List<Proyecto> proyectos = allservices.queryProyectoDAO(filtroBusqueda);
if(filtroBusqueda.equals("")){
    if(idCliente != 0){
        String where="WHERE status=1 AND ID_CLIENTE="+String.valueOf(idCliente);
        proyectos = allservices.queryProyectoDAO(where);
    }else{
        String where="WHERE status=1";
        proyectos = allservices.queryProyectoDAO(where);
    }
}

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
                    <h1>Log de Monitor</h1>
                    
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>
                   
                    <div class="onecolumn">
                  
                    </div>

                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_validaXML.png" alt="icon"/>
                                Lista de Proyectos
                            </span>
                            <div class="switch" style="width:500px">
                                <table width="500px" cellpadding="0" cellspacing="0">
                                    <tbody>
                                        <tr>
                                            <td>
                                                <div id="search">
                                                <form action="monitor_log.jsp" id="search_form" name="search_form" method="get">                                                                                                                                                

                                                        <input type="text" id="q" name="q" title="Buscar por nombre" class="" style="width: 70%; float: left; "
                                                               value="<%=buscar%>"/>
                                                        <input type="image" src="../../images/Search-32_2.png" id="buscar" name="buscar"  style="cursor: pointer; width: 30px; height: 25px; float: left"/>

                                                </form>
                                                </div>
                                            </td>
                                            <td class="clear">&nbsp;&nbsp;&nbsp;</td>
                                                                                     
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
                                            <th>Fecha de Inicio</th>
                                            <th>Fecha Programada</th>
                                            <th>Cliente</th>
                                            <th>Avance %</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            for(Proyecto proyecto : proyectos){
                                               
                                        %> 
                                        <tr>
                                            <td><% out.print(proyecto.getNombre()); %></td>
                                            <td><% out.print(proyecto.getFechaInicio()); %></td>
                                            <td><% out.print(proyecto.getFechaProgramada()); %></td>
                                            <% Cliente client = clienteModel.getById(proyecto.getIdCliente());
                                            %>
                                            <td><% out.print(client.getNombreComercial()); %></td>
                                            <td><% out.print(proyecto.getAvance()); %></td>
                                            <td>

                                                <a href="monitor_log_report.jsp?idProyecto=<% out.print(proyecto.getIdProyecto()); %>"><img src="../../images/icon_reporte.png" alt="Ver Reporte" class="help" title="Ver Reporte"/></a>

                                                <a class="imprimir_excel" idProyecto="<% out.print(proyecto.getIdProyecto()); %>"><img src="../../images/icon_excel.png" alt="Excel Resumen" class="help" title="Excel Resumen"/></a>
                                                <a class="imprimir_pdf" idProyecto="<% out.print(proyecto.getIdProyecto()); %>"><img src="../../images/icon_pdf.png" alt="PDF Resumen" class="help" title="PDF Resumen"/></a>
                                            </td>
                                          </tr>        
                                         
                                        <%        
                                                
                                            }
                                        %>
                                    </tbody>
                                </table>
                            </form>
                            <form action="../reportesExportar/exportarXLS.jsp" method="post" id="imprimir_reporte" target="_blank">
                                <input type="hidden" id="i" name="i" value="7">
                                <input type="hidden" id="parametrosCustom" name="parametrosCustom" value="">
                            </form>
                        </div>
                    </div>

                </div>

                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>
            <script>
                $(document).ready(function(){
                    $(".imprimir_excel").click(function(){
                        var idProyecto = $(this).attr("idProyecto");
                        var where = "WHERE idProyecto = "+idProyecto;
                        $("#parametrosCustom").val(where);
                        $("#imprimir_reporte").attr({"action":"../reportesExportar/exportarXLS.jsp"});
                        $("#imprimir_reporte").submit();
                    });
                    $(".imprimir_pdf").click(function(){
                        var idProyecto = $(this).attr("idProyecto");
                        var where = "WHERE idProyecto = "+idProyecto;
                        $("#parametrosCustom").val(where);
                        $("#imprimir_reporte").attr({"action":"../reportesExportar/exportarPDF.jsp"});
                        $("#imprimir_reporte").submit();
                    });
                });
            </script>
        
    </body>
</html>