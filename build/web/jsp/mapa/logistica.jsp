
<%@page import="com.tsp.gespro.jdbc.UsuariosDaoImpl"%>
<%@page import="com.tsp.gespro.bo.DatosUsuarioBO"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.bo.RutaBO"%>
<%@page import="com.tsp.gespro.dto.Ruta"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el usuario tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
} else {
        
    long idEmpresa = user.getUser().getIdEmpresa();

    String buscar = request.getParameter("q") != null ? new String(request.getParameter("q").getBytes("ISO-8859-1"), "UTF-8") : "";
    String filtroBusqueda = "";
    if (!buscar.trim().equals("")) {
        filtroBusqueda = filtroBusqueda + " AND NOMBRE_RUTA LIKE '%"+buscar+"%'";
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
    
     RutaBO marcaBO = new RutaBO(user.getConn());
     Ruta[] rutasDto = new Ruta[0];
     try{
         limiteRegistros = marcaBO.findRutas(-1, (int)idEmpresa , 0, 0, filtroBusqueda).length;
         
         if (!buscar.trim().equals(""))
             registrosPagina = limiteRegistros;
         
         paginasTotales = (int)Math.ceil(limiteRegistros / registrosPagina);

        if(paginaActual<0)
            paginaActual = 1;
        else if(paginaActual>paginasTotales)
            paginaActual = paginasTotales;

        rutasDto = marcaBO.findRutas(-1, (int)idEmpresa,
                ((paginaActual - 1) * (int)registrosPagina), (int)registrosPagina,
                filtroBusqueda);

     }catch(Exception ex){
         ex.printStackTrace();
     }

    /*
     * Datos de catálogo
     */
    String urlTo = "../mapa/logistica_nuevaRuta.jsp";
    String paramName = "idRuta";
    String parametrosPaginacion = "";// "idEmpresa="+idEmpresa;
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
            function eliminar(id){
                if (id>0){
                    $.ajax({
                        type: "POST",
                        url: "logistica_eliminar_ajax.jsp",
                        data: {id : id},
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                            $("#ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               $("#ajax_message").html(datos);
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").fadeIn("slow");
                               apprise('<center><img src=../../images/info.png> <br/>'+ datos +'</center>',{'animate':true},
                                        function(r){
                                            location.href = "logistica.jsp";
                                        });
                           }else{
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").html(datos);
                               $("#ajax_message").fadeIn("slow");
                               $("#action_buttons").fadeIn("slow");
                               $.scrollTo('#inner',800);
                           }
                        }
                    });
                 }
            }
            
            function eliminarAsignacion(id){
                if (id>0){
                    $.ajax({
                        type: "POST",
                        url: "logistica_eliminar_ajax.jsp",
                        data: {id : id, mode : "eliminarAsignacion"},
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                            $("#ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               $("#ajax_message").html(datos);
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").fadeIn("slow");
                               apprise('<center><img src=../../images/info.png> <br/>'+ datos +'</center>',{'animate':true},
                                        function(r){
                                            location.href = "logistica.jsp";
                                        });
                           }else{
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").html(datos);
                               $("#ajax_message").fadeIn("slow");
                               $("#action_buttons").fadeIn("slow");
                               $.scrollTo('#inner',800);
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
                    <h1>Mapas</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_logistica.png" alt="icon"/>
                                Log&iacute;stica
                            </span>
                            <div class="switch" style="width:500px">
                                <table width="500px" cellpadding="0" cellspacing="0">
                                    <tbody>
                                        <tr>
                                            <td>
                                                <div id="search">
                                                    <form action="logistica.jsp" id="search_form" name="search_form" method="get">
                                                        <input type="text" id="q" name="q" title="Buscar por Nombre" class="" style="width: 300px; float: left; "
                                                               value="<%=buscar%>"/>
                                                        <input type="image" src="../../images/Search-32_2.png" id="buscar" name="buscar"  value="" style="cursor: pointer; width: 30px; height: 25px; float: left"/>
                                                        <!--<input title="Buscar" type="submit" id="search" class="right_switch" style="font-size: 9px;"/>-->
                                                    </form>
                                                </div>
                                            </td>
                                            <td class="clear">&nbsp;&nbsp;&nbsp;</td>
                                            <td>
                                                <input type="button" id="nuevo" name="nuevo" class="right_switch expose" value="Crear Nueva" 
                                                       style="float: right; width: 100px;" onclick="location.href = '<%=urlTo%>'"/>
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
                                            <th>Nombre</th>
                                            <th>Vendedor</th>
                                            <th>Paradas</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            UsuariosDaoImpl usuariosDao = new UsuariosDaoImpl(user.getConn());
                                            for (Ruta item : rutasDto) {
                                                try {
                                                    DatosUsuario datosUsuarioDto = null;
                                                    if(item.getIdUsuario()>0){
                                                        //datosUsuarioDto = usuariosDao.findByPrimaryKey(item.getIdUsuario());
                                                        Usuarios usuariosDto = usuariosDao.findByPrimaryKey(item.getIdUsuario());
                                                        datosUsuarioDto = new DatosUsuarioBO(usuariosDto.getIdDatosUsuario(),user.getConn()).getDatosUsuario();
                                                    }
                                        %>
                                        <tr>
                                            <!--<td><input type="checkbox"/></td>-->
                                            <td><%=item.getIdRuta() %></td>
                                            <td><%=item.getNombreRuta() %></td>
                                            <td><%=(datosUsuarioDto!=null?datosUsuarioDto.getApellidoPat() + " " + datosUsuarioDto.getApellidoMat() + " " + datosUsuarioDto.getNombre():"")%></td>
                                            <td><%=item.getParadasRuta() %></td>              
                                            <td>
                                                <a href="../mapa/logistica_asignar.jsp?<%=paramName%>=<%=item.getIdRuta()%>"><img src="../../images/icon_users.png" alt="asignar" class="help" title="Asignar a vendedor"/></a>
                                                &nbsp;&nbsp;
                                                <!--<a href=""><img src="images/icon_delete.png" alt="delete" class="help" title="Delete"/></a>-->
                                                <a href="#" onclick="eliminar(<%=item.getIdRuta()%>);"><img src="../../images/icon_delete.png" alt="delete" class="help" title="Borrar"/></a>
                                                &nbsp;&nbsp;
                                                <a href="../mapa/logistica_consulta.jsp?<%=paramName%>=<%=item.getIdRuta()%>"><img src="../../images/icon_movimiento.png" alt="consultar" class="help" title="Consultar"/></a>
                                                &nbsp;&nbsp;
                                                <a href="../mapa/logistica_consultaEditar.jsp?<%=paramName%>=<%=item.getIdRuta()%>"><img src="../../images/icon_movimientoSeparado.png" alt="editar" class="help" title="Editar"/></a>
                                                <%if(item.getIdUsuario() > 0){%>
                                                    &nbsp;&nbsp;
                                                    <a href="#" onclick="eliminarAsignacion(<%=item.getIdRuta()%>);"><img src="../../images/icon_users_delete.png" alt="delete" class="help" title="Borrar Asignación"/></a>
                                                <%}%>
                                            </td>
                                        </tr>
                                        <%      } catch (Exception ex) {
                                                    ex.printStackTrace();
                                                }
                                            }
                                        %>
                                    </tbody>
                                </table>
                            </form>

                            <!-- INCLUDE OPCIONES DE EXPORTACIÓN-->
                            <!--
                            < jsp:include page="../include/reportExportOptions.jsp" flush="true">
                                < jsp:param name="idReport" value="<//%= ReportBO.RUTAS_REPORT %>" />
                                < jsp:param name="parametrosCustom" value="<%= filtroBusquedaEncoded %>" />
                            </ jsp:include>
                            -->
                            <!-- FIN INCLUDE OPCIONES DE EXPORTACIÓN-->

                            <jsp:include page="../include/listPagination.jsp">
                                <jsp:param name="paginaActual" value="<%=paginaActual%>" />
                                <jsp:param name="numeroPaginasAMostrar" value="<%=numeroPaginasAMostrar%>" />
                                <jsp:param name="paginasTotales" value="<%=paginasTotales%>" />
                                <jsp:param name="url" value="<%=request.getRequestURI()%>" />
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