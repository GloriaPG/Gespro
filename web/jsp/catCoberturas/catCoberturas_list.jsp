<%-- 
    Document   : catCoberturas_list
    Created on : 07/08/2016, 07:55:43 PM
    Author     : Jefecito
--%>

<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Cobertura"%>
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
    String buscar = request.getParameter("q") != null ? new String(request.getParameter("q").getBytes("ISO-8859-1"), "UTF-8") : "";    //

// crear consulta de filtro
    String filtroBusqueda = ""; //"AND ID_ESTATUS=1 ";
    if (!buscar.trim().equals("")) {
        filtroBusqueda += " WHERE (NOMBRE LIKE '%" + buscar + "%')";
    }
    String filtroBusquedaEncoded = java.net.URLEncoder.encode(filtroBusqueda, "UTF-8");
    Allservices allservices = new Allservices();
    
    EmpresaBO empresaBO = new EmpresaBO(user.getConn());
    int idEmpresaMatriz = empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa();
    
    List<Cobertura> coberturas = allservices.queryCobertura(filtroBusqueda);
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title><jsp:include page="../include/titleApp.jsp" /></title>
        <jsp:include page="../include/keyWordSEO.jsp" />
        <jsp:include page="../include/skinCSS.jsp" />
        <jsp:include page="../include/jsFunctions.jsp"/>
        <script type="text/javascript">
            function eliminarCobertura(coberturaId) {
                $.ajax({
                    type: "POST",
                    url: "ajax.jsp?accion=eliminar&id=" + coberturaId,
                    data: $("#frm_action").serialize(),
                    beforeSend: function(objeto) {
                        $("#action_buttons").fadeOut("slow");
                        $("#ajax_loading").html('<div style=""><center>Procesando...<br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /></center></div>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function(datos) {
                        console.log("Datos");
                        console.log(datos);
                        if (datos.indexOf("--EXITO-->", 0) > 0) {
                            $("#ajax_message").html("La cobertura se eliminó correctamente.");
                            $("#ajax_loading").fadeOut("slow");
                            $("#ajax_message").fadeIn("slow");
                            apprise('<center><img src=../../images/info.png> <br/>Los datos se guardaron correctamente.</center>', {'animate': true},
                            function(r) {
                                javascript:window.location.href = "catCoberturas_list.jsp";
                                parent.$.fancybox.close();
                            });
                        } else {
                            $("#ajax_loading").fadeOut("slow");
                            $("#ajax_message").html("Ocurrió un error al intentar eliminar la cobertura.");
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
    <jsp:useBean id="productos" class="com.tsp.gespro.hibernate.dao.ProductoDAO"/>
    <jsp:useBean id="proyectoModel" class="com.tsp.gespro.hibernate.dao.ProyectoDAO"/>
    <!--- @formulario --->
    <c:set var="formulario" value="formulario.jsp"/> 

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
                            <img src="../../images/camion_icono_16.png" alt="icon"/>
                            Coberturas
                        </span>
                        <div class="switch" style="width:500px">
                            <table width="500px" cellpadding="0" cellspacing="0">
                                <tbody>
                                    <tr>
                                        <td>
                                            <div id="search">
                                                <form action="catCoberturas_list.jsp" id="search_form" name="search_form" method="get">                                                                                                                                                

                                                    <input type="text" id="q" name="q" title="Buscar por nombre" class="" style="width: 70%; float: left; "
                                                           value="<%=buscar%>"/>
                                                    <input type="image" src="../../images/Search-32_2.png" id="buscar" name="buscar"  value="" style="cursor: pointer; width: 30px; height: 25px; float: left"/>

                                                </form>
                                            </div>
                                        </td>
                                        <td class="clear">&nbsp;&nbsp;&nbsp;</td>

                                        <td>
                                            <input type="button" id="nuevo" name="nuevo" class="right_switch" value="Crear Nuevo" 
                                                   style="float: right; width: 100px;" onclick="javascript:window.location.href = '${formulario}'"/>
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
                                        <th>ID Cobertura</th>
                                        <th>Nombre</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        for(Cobertura cobertura:coberturas) {
                                            if (cobertura.getActivo() == 1 && Integer.parseInt(cobertura.getIdEmpresa().toString()) == idEmpresaMatriz ) {
                                                %><tr>
                                                <td><%=cobertura.getIdCobertura()%></td>
                                                <td><%=cobertura.getNombre()%></td>
                                                <td>
                                                <a href="./formulario.jsp?id=<%=cobertura.getIdCobertura()%>">
                                                   <img src="../../images/icon_edit.png" alt="editar" class="help" title="Editar"/>
                                                </a>
                                                    &nbsp;&nbsp;
                                                    <a class="accion-eliminar" href="#" cobertura-id="<%=cobertura.getIdCobertura()%>"><img src="../../images/icon_delete.png" alt="editar" class="help" title="Editar"/></a>
                                                    &nbsp;&nbsp;
                                                </td>
                                            </tr>
                                            <%
                                            }
                                        }
                                    %>
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
    <script type="text/javascript">
        $('.accion-eliminar').click(function() {
            var coberturaId = $(this).attr("cobertura-id");
            apprise('¿Estas seguro de eliminar la cobertura?', {'verify': true, 'animate': true, 'textYes': 'Si', 'textNo': 'Cancelar'}, function(r)
            {
                if (r) {
                    eliminarCobertura(coberturaId);
                }
            });
        });
    </script>
</body>
</html>