<%-- 
    Document   : catConceptoEstanteria_list
    Created on : 30/10/2015, 06:19:40 PM
    Author     : leonardo
--%>

<%@page import="com.tsp.gespro.util.DateManage"%>
<%@page import="com.tsp.gespro.bo.ConceptoBO"%>
<%@page import="com.tsp.gespro.dto.Concepto"%>
<%@page import="com.tsp.gespro.dto.Estanteria"%>
<%@page import="com.tsp.gespro.bo.EstanteriaBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el usuario tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
} else {
    
    String buscar = request.getParameter("q")!=null? new String(request.getParameter("q").getBytes("ISO-8859-1"),"UTF-8") :"";
    String filtroBusqueda = "";
    if (!buscar.trim().equals(""))
        filtroBusqueda = " AND (NOMBRE LIKE '%" + buscar + "%' OR DESCRIPCION LIKE '%" +buscar+"%')";
    
    int idEstanteria = -1;
    try{ idEstanteria = Integer.parseInt(request.getParameter("idEstanteria")); }catch(NumberFormatException e){}
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
    int idCliente = -1;
    try{ idCliente = Integer.parseInt(request.getParameter("idCliente")); }catch(NumberFormatException e){}
    int idConcepto = -1;
    try{ idConcepto = Integer.parseInt(request.getParameter("idConcepto")); }catch(NumberFormatException e){}
    int idUsuario = -1;//id del usuario promotor
    try{ idUsuario = Integer.parseInt(request.getParameter("idUsuario")); }catch(NumberFormatException e){}
    
    if(!buscar.trim().equals("")){
        filtroBusqueda = " AND ID_CONCEPTO IN (SELECT ID_CONCEPTO FROM CONCEPTO WHERE NOMBRE LIKE '%" + buscar + "%')";
    }
    
    /*
    * Paginación
    */
    int paginaActual = 1;
    double registrosPagina = 10;
    double limiteRegistros = 0;
    int paginasTotales = 0;
    int numeroPaginasAMostrar = 5;

    try{
        paginaActual = Integer.parseInt(request.getParameter("pagina"));
    }catch(Exception e){}

    try{
        registrosPagina = Integer.parseInt(request.getParameter("registros_pagina"));
    }catch(Exception e){}
    
     EstanteriaBO estanteriaBO = new EstanteriaBO(user.getConn());
     Estanteria[] estanteriasDto = new Estanteria[0];
     try{
         limiteRegistros = estanteriaBO.findEstanterias(idEstanteria, idEmpresa ,idCliente, idConcepto, idUsuario, 0, 0, filtroBusqueda).length;
         
         if (!buscar.trim().equals(""))
             registrosPagina = limiteRegistros;
         
         paginasTotales = (int)Math.ceil(limiteRegistros / registrosPagina);

        if(paginaActual<0)
            paginaActual = 1;
        else if(paginaActual>paginasTotales)
            paginaActual = paginasTotales;

        estanteriasDto = estanteriaBO.findEstanterias(idEstanteria, idEmpresa, idCliente, idConcepto, idUsuario,
                ((paginaActual - 1) * (int)registrosPagina), (int)registrosPagina,
                filtroBusqueda);

     }catch(Exception ex){
         ex.printStackTrace();
     }
     
     /*
    * Datos de catálogo
    */
    String urlTo = "../catEstanteria/catConceptoEstanteria_form.jsp";
    String paramName = "idEstanteria";
    String parametrosPaginacion="";// "idEmpresa="+idEmpresa;
    String filtroBusquedaEncoded = java.net.URLEncoder.encode(filtroBusqueda, "UTF-8");
    
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <jsp:include page="../include/keyWordSEO.jsp" />

        <title><jsp:include page="../include/titleApp.jsp" /></title>

        <jsp:include page="../include/skinCSS.jsp" />

        <jsp:include page="../include/jsFunctions.jsp"/>
        
        <script type="text/javascript">
            
        </script>

    </head>
    <body>
        <div class="content_wrapper">

            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>

            <!-- Inicio de Contenido -->
            <div id="content">

                <div class="inner">
                    <h1>Catálogos</h1>
                    
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_estanteria.png" alt="icon"/>
                                Catálogo de Estanterias
                            </span>
                            <div class="switch" style="width:500px">
                                <table width="500px" cellpadding="0" cellspacing="0">
                                    <tbody>
                                            <tr>
                                                <td>
                                                    <div id="search">
                                                    <form action="catConceptoEstanteria_list.jsp" id="search_form" name="search_form" method="get">
                                                            <input type="hidden" id="idEstanteria" name="idEstanteria" value="<%=idEstanteria%>" />
                                                            <input type="hidden" id="idCliente" name="idCliente" value="<%=idCliente%>" />
                                                            <input type="hidden" id="idConcepto" name="idConcepto" value="<%=idConcepto%>" />
                                                            <input type="hidden" id="idUsuario" name="idUsuario" value="<%=idUsuario%>" />
                                                            <input type="text" id="q" name="q" title="Buscar por Nombre" class="" style="width: 300px; float: left; "
                                                                    value="<%=buscar%>"/>
                                                            <input type="image" src="../../images/Search-32_2.png" id="buscar" name="buscar"  value="" style="cursor: pointer; width: 30px; height: 25px; float: left"/>
                                                    </form>
                                                    </div>
                                                </td>
                                                <td class="clear">&nbsp;&nbsp;&nbsp;</td>
                                                <!--
                                                <td>
                                                    <input type="button" id="nuevo" name="nuevo" class="right_switch" value="Crear Nuevo" 
                                                            style="float: right; width: 100px;" onclick="location.href='<%=urlTo%>'"/>
                                                </td>-->
                                                
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
                                            <th>ID</th>
                                            <th>Producto</th>
                                            <th>Cantidad</th>
                                            <th>Precio</th>
                                            <th>Fecha</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            Concepto concepto = null;
                                            for (Estanteria item:estanteriasDto){
                                                try{concepto = new ConceptoBO(item.getIdConcepto(), user.getConn()).getConcepto();}catch(Exception e){}
                                                try{
                                        %>
                                        <tr <%=(item.getIdEstatus()!=1)?"class='inactive'":""%>>
                                            <!--<td><input type="checkbox"/></td>-->
                                            <td><%=item.getIdEstanteria() %></td>
                                            <td><%=concepto!=null?concepto.getNombre():"" %></td>
                                            <td><%=item.getCantidad()%></td>
                                            <td><%=item.getPrecio()%></td>
                                            <td><%=DateManage.formatDateToNormal(item.getFecha())%></td>
                                            <td>
                                                
                                                <a href="<%=urlTo%>?<%=paramName%>=<%=item.getIdEstanteria()%>&acc=1&pagina=<%=paginaActual%>&idConcepto=<%=item.getIdConcepto()%>&idCliente=<%=item.getIdCliente()%>"><img src="../../images/icon_consultar.png" alt="ver" class="help" title="Ver"/></a>
                                                &nbsp;&nbsp;
                                                
                                                <!--<a href=""><img src="images/icon_delete.png" alt="delete" class="help" title="Delete"/></a>-->
                                            </td>
                                        </tr>
                                        <%      }catch(Exception ex){
                                                    ex.printStackTrace();
                                                }
                                            } 
                                        %>
                                    </tbody>
                                </table>
                            </form>

                            <!-- INCLUDE OPCIONES DE EXPORTACIÓN-->
                            <!--<//jsp:include page="../include/reportExportOptions.jsp" flush="true">
                                <//jsp:param name="idReport" value="<//%= ReportBO.MARCA_REPORT %>" />
                                <//jsp:param name="parametrosCustom" value="<//%= filtroBusquedaEncoded %>" />
                            <///jsp:include>-->
                            <!-- FIN INCLUDE OPCIONES DE EXPORTACIÓN-->
                                    
                            <jsp:include page="../include/listPagination.jsp">
                                <jsp:param name="paginaActual" value="<%=paginaActual%>" />
                                <jsp:param name="numeroPaginasAMostrar" value="<%=numeroPaginasAMostrar%>" />
                                <jsp:param name="paginasTotales" value="<%=paginasTotales%>" />
                                <jsp:param name="url" value="<%=request.getRequestURI() %>" />
                                <jsp:param name="parametrosAdicionales" value="<%=parametrosPaginacion%>" />
                            </jsp:include>
                            
                        </div>
                    </div>

                </div>

                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>


    </body>
</html>
<%}%>