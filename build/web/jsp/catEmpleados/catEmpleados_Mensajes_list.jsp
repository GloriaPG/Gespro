<%-- 
    Document   : catEmpleados_Mensajes_list
    Created on : 13/02/2013, 12:53:47 PM
    Author     : Leonardo
--%>

<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.dto.MovilMensaje"%>
<%@page import="com.tsp.gespro.bo.MovilMensajeBO"%>
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
    
    int idEmpleado = -1;
    try{ 
        idEmpleado = Integer.parseInt(request.getParameter("idUsuario")); }catch(NumberFormatException e){}    
        int idEmpresa = user.getUser().getIdEmpresa();
        
        filtroBusqueda += "  AND ((ID_USUARIO_EMISOR IN (SELECT ID_USUARIOS FROM USUARIOS WHERE ID_EMPRESA =" + idEmpresa + ")) OR "
			+ " (ID_USUARIO_RECEPTOR IN (SELECT ID_USUARIOS FROM USUARIOS WHERE ID_EMPRESA =" + idEmpresa + ")) )";
            
        
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
    
     MovilMensajeBO movilMensajeBO = new MovilMensajeBO(user.getConn());
     MovilMensaje[] movilMensajesDto = new MovilMensaje[0];
     try{
         limiteRegistros = movilMensajeBO.findMovilMensajes(0, idEmpresa , 0, 0, filtroBusqueda,idEmpleado, idEmpleado).length;
         
         if (!buscar.trim().equals(""))
             registrosPagina = limiteRegistros;
         
         paginasTotales = (int)Math.ceil(limiteRegistros / registrosPagina);

        if(paginaActual<0)
            paginaActual = 1;
        else if(paginaActual>paginasTotales)
            paginaActual = paginasTotales;

        movilMensajesDto = movilMensajeBO.findMovilMensajes(0, idEmpresa,
                ((paginaActual - 1) * (int)registrosPagina), (int)registrosPagina,
                filtroBusqueda,idEmpleado, idEmpleado);

     }catch(Exception ex){
         ex.printStackTrace();
     }
     
     /*
    * Datos de catálogo
    */
    String urlTo = "../catEmpleados/catEmpleado_Mensajes_form.jsp";
    String paramName = "idMovilMensaje";
    String paramNameIdEmpleado = "idEmpleado";
    String parametrosPaginacion="";// "idEmpresa="+idEmpresa;
    String filtroBusquedaEncoded = java.net.URLEncoder.encode(filtroBusqueda, "UTF-8");
    String strParamsExtra  =""+idEmpleado ;
    String parametrosExtraEncoded = java.net.URLEncoder.encode(strParamsExtra , "UTF-8");
    
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
            
        </script>

    </head>
    <body>
        <div class="content_wrapper">

            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>

            <!-- Inicio de Contenido -->
            <div id="content">

                <div class="inner">
                    <h1>Mensajes</h1>
                    
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_mensajes.png" alt="icon"/>
                                Movil Mensajes
                            </span>
                            <div class="switch" style="width:410px">
                                <table width="300px" cellpadding="0" cellspacing="0">
                                    <tbody>
                                            <tr>
                                                <td>
                                                    <div id="search">
                                                    <form action="catEmpleados_Mensajes_list.jsp" id="search_form" name="search_form" method="get">
                                                            <input type="text" id="q" name="q" title="Buscar por Nombre / Descripción" class="" style="width: 300px; float: left; "
                                                                    value="<%=buscar%>"/>
                                                            <!--<input title="Buscar" type="submit" id="search" class="right_switch" style="font-size: 9px;"/>-->
                                                    </form>
                                                    </div>
                                                </td>
                                                <td class="clear">&nbsp;&nbsp;&nbsp;</td>
                                                <td>
                                                    <input type="button" id="nuevo" name="nuevo" class="right_switch" value="Nuevo Mensaje" 
                                                            style="float: right; width: 100px;" onclick="location.href='<%=urlTo%>?<%=paramNameIdEmpleado%>=<%=idEmpleado%>'"/>
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
                                            <th>ID</th>
                                            <th>Emisor Tipo</th>
                                            <th>Empleado Emisor</th>
                                            <th>Receptor Tipo</th>
                                            <th>Empleado Receptor</th>
                                            <th>Fecha Emisión</th>
                                            <th>Fecha Recepción</th>
                                            <th>Mensaje</th>
                                            <th>¿Recibido?</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            UsuariosBO ebo = null;
                                            String emisorEmpleado = "";
                                            String receptorEmpleado = "";
                                            Usuarios emplea = null;
                                            for (MovilMensaje item:movilMensajesDto){
                                                try{
                                                    if(item.getEmisorTipo()==1){
                                                        ebo = new UsuariosBO(item.getIdUsuarioEmisor(),user.getConn());
                                                        emplea = ebo.getUsuario();
                                                        emisorEmpleado = emplea.getNumEmpleado();                                                                                                               
                                                    }else
                                                        emisorEmpleado = "";
                                                    if(item.getReceptorTipo()==1){
                                                        ebo = new UsuariosBO(item.getIdUsuarioReceptor(),user.getConn());
                                                        emplea = ebo.getUsuario();
                                                        receptorEmpleado = emplea.getNumEmpleado();
                                                    }else
                                                        receptorEmpleado = "";
                                        %>
                                        <!------<tr <//%=(item.getIdEstatus()!=1)?"class='inactive'":""%>>-->
                                            <!--<td><input type="checkbox"/></td>-->
                                             <td><%=item.getIdMovilMensaje() %></td>
                                            <td><%=(item.getEmisorTipo()==1)? "Empleado" : (item.getEmisorTipo()==2)? "Consola" : "No Identificado"%></td>
                                            <td><%=emisorEmpleado %></td>
                                            <td><%=(item.getReceptorTipo()==1)? "Empleado" : (item.getReceptorTipo()==2)? "Consola" : "No Identificado"%></td>
                                            <td><%=receptorEmpleado %></td>
                                            <td><%=item.getFechaEmision() %></td>
                                            <td><%=(item.getFechaRecepcion()==null)? "" : item.getFechaRecepcion()%></td>
                                            <td><%=item.getMensaje() %></td>
                                            <td><%=(item.getRecibido() == 0)?"No Entregado" : (item.getRecibido() == 1)?"Recibido" : "No Identificado"%></td>                                                                                       
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
                            <!--<///jsp:include page="../include/reportExportOptions.jsp" flush="true">
                                <//jsp:param name="idReport" value="<%//= ReportBO.MENSAJES_REPORT %>" />
                                <//jsp:param name="parametrosCustom" value="<%//= filtroBusquedaEncoded %>" />
                                <//jsp:param name="parametrosExtra" value="<%//=parametrosExtraEncoded%>" />
                            <///jsp:include>-->
                            <!-- FIN INCLUDE OPCIONES DE EXPORTACIÓN-->
                                    
                            <jsp:include page="../include/listPagination.jsp">
                                <jsp:param name="paginaActual" value="<%=paginaActual%>" />
                                <jsp:param name="numeroPaginasAMostrar" value="<%=numeroPaginasAMostrar%>" />
                                <jsp:param name="paginasTotales" value="<%=paginasTotales%>" />
                                <jsp:param name="url" value="<%=request.getRequestURI() %>" />
                                <jsp:param name="parametrosAdicionales" value="<%=parametrosPaginacion%>" />
                            </jsp:include>
                        
                        <div id="action_buttons">
                            <p>                                
                                <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                            </p>
                        </div>
                            
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