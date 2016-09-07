<%-- 
    Document   : catEmpleado_Relacion_Cliente_list
    Created on : 10/03/2016, 01:39:16 PM
    Author     : leonardo
--%>

<%@page import="com.tsp.gespro.jdbc.DatosUsuarioDaoImpl"%>
<%@page import="com.tsp.gespro.jdbc.UsuariosDaoImpl"%>
<%@page import="com.tsp.gespro.jdbc.ClienteDaoImpl"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page import="com.tsp.gespro.dto.RelacionClienteVendedor"%>
<%@page import="com.tsp.gespro.bo.RelacionClienteVendedorBO"%>
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
    
    int idCliente = -1;
    try{ idCliente = Integer.parseInt(request.getParameter("idCliente")); }catch(NumberFormatException e){}
    
    int idUsuarioEmpleado = -1;
    try{ idUsuarioEmpleado = Integer.parseInt(request.getParameter("idUsuarioEmpleado")); }catch(NumberFormatException e){}
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
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
    
     RelacionClienteVendedorBO relacionClienteVendedorBO = new RelacionClienteVendedorBO(user.getConn());
     RelacionClienteVendedor[] relacionClienteVendedorsDto = new RelacionClienteVendedor[0];
     try{
         limiteRegistros = relacionClienteVendedorBO.findRelacionClienteVendedors(idCliente, idUsuarioEmpleado , 0, 0, filtroBusqueda).length;
         
         if (!buscar.trim().equals(""))
             registrosPagina = limiteRegistros;
         
         paginasTotales = (int)Math.ceil(limiteRegistros / registrosPagina);

        if(paginaActual<0)
            paginaActual = 1;
        else if(paginaActual>paginasTotales)
            paginaActual = paginasTotales;

        relacionClienteVendedorsDto = relacionClienteVendedorBO.findRelacionClienteVendedors(idCliente, idUsuarioEmpleado,
                ((paginaActual - 1) * (int)registrosPagina), (int)registrosPagina,
                filtroBusqueda);

     }catch(Exception ex){
         ex.printStackTrace();
     }
     
     /*
    * Datos de catálogo
    */
    String urlTo = "../catEmpleados/catEmpleado_Relacion_Cliente_form.jsp";
    String paramNameCliente = "idCliente";
    String paramNameUsuario = "idUsuarioEmpleado";
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
            
            function confirmarEliminarRelacion(idCliente, idUsuarioEmpleado){
                apprise('¿Esta seguro que desea eliminar la relación?', {'verify':true, 'animate':true, 'textYes':'Si', 'textNo':'No'}, 
                    function(r){
                        if(r){
                            // Usuario dio click 'Yes'
                            confirmarEliminar(idCliente, idUsuarioEmpleado);
                        }
                });
                
            }
            
            function confirmarEliminar(idCliente, idUsuarioEmpleado){
                if(idCliente>0 && idUsuarioEmpleado>0){
                    $.ajax({
                        type: "POST",
                        url: "catEmpleado_Relacion_Cliente_ajax.jsp",
                        data: { mode: 'eliminar', idCliente : idCliente, idUsuarioEmpleado : idUsuarioEmpleado },
                        beforeSend: function(objeto){
                            //$("#action_buttons").fadeOut("slow");
                            $("#ajax_loading").html('<div style="">ESPERE, procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></div>');
                            $("#ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").html(datos);
                               $("#ajax_message").fadeIn("slow");
                               apprise('<center><img src=../../images/info.png> <br/>'+ datos +'</center>',{'animate':true},
                                    function(r){
                                        location.href = "catEmpleado_Relacion_Cliente_list.jsp?idUsuarioEmpleado="+idUsuarioEmpleado;
                                });
                           }else{
                               $("#ajax_loading").fadeOut("slow");
                               //$("#ajax_message").html(datos);
                               //$("#ajax_message").fadeIn("slow");
                               apprise('<center><img src=../../images/warning.png> <br/>'+ datos +'</center>',{'animate':true});
                           }
                        }
                    });
                }
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
                    <h1>Relación</h1>
                    
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_cliente.png" alt="icon"/>
                                Relación Cliente - Vendedor
                            </span>
                            <div class="switch" style="width:500px">
                                <table width="500px" cellpadding="0" cellspacing="0">
                                    <tbody>
                                            <tr>
                                                <td>
                                                    <div id="search">
                                                    <form action="catEmpleado_Relacion_Cliente_list.jsp" id="search_form" name="search_form" method="get">
                                                            <input type="text" id="q" name="q" title="Buscar por Nombre / Descripción" class="" style="width: 300px; float: left; "
                                                                    value="<%=buscar%>"/>
                                                            <input type="image" src="../../images/Search-32_2.png" id="buscar" name="buscar"  value="" style="cursor: pointer; width: 30px; height: 25px; float: left"/>
                                                    </form>
                                                    </div>
                                                </td>
                                                <td class="clear">&nbsp;&nbsp;&nbsp;</td>
                                                
                                                <td>
                                                    <input type="button" id="nuevo" name="nuevo" class="right_switch" value="Crear Nuevo" 
                                                            style="float: right; width: 100px;" onclick="location.href='<%=urlTo%>?acc=relacion&idUsuarioEmpleado=<%=idUsuarioEmpleado%>'"/>
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
                                            <th>Empleado</th>
                                            <th>Cliente</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            Cliente cliente = null;
                                            Usuarios usuarios = null;
                                            DatosUsuario datosUsuario = null;
                                            ClienteDaoImpl clienteDaoImpl = new ClienteDaoImpl(user.getConn());
                                            UsuariosDaoImpl usuariosDaoImpl = new UsuariosDaoImpl(user.getConn());
                                            DatosUsuarioDaoImpl datosUsuarioDaoImpl = new DatosUsuarioDaoImpl(user.getConn());
                                            for (RelacionClienteVendedor item:relacionClienteVendedorsDto){
                                                cliente = null;
                                                usuarios = null;
                                                datosUsuario = null;
                                                try{
                                                    cliente = clienteDaoImpl.findByPrimaryKey(item.getIdCliente());
                                                }catch(Exception e){}
                                                try{
                                                    usuarios = usuariosDaoImpl.findByPrimaryKey(item.getIdUsuario());
                                                    datosUsuario = datosUsuarioDaoImpl.findByPrimaryKey(usuarios.getIdDatosUsuario());
                                                }catch(Exception e){}
                                                                                                
                                                try{
                                        %>
                                        <tr>
                                            <!--<td><input type="checkbox"/></td>-->
                                            <td><%=datosUsuario!=null?(datosUsuario.getNombre() + " " + datosUsuario.getApellidoPat() + " " + datosUsuario.getApellidoMat()):"" %></td>
                                            <td><%=cliente!=null?cliente.getNombreComercial():"" %></td>
                                            <td>
                                                <a href="#" onclick="confirmarEliminarRelacion(<%=item.getIdCliente()%>, <%=item.getIdUsuario()%>);"><img src="../../images/icon_delete.png" alt="delete" class="help" title="Delete"/></a>
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
                            
                            <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                            
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