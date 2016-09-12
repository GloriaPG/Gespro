<%-- 
    Document   : plantillaSGFENS
    Created on : 25-oct-2012, 12:13:49
    Author     : ISCesarMartinez poseidon24@hotmail.com
--%>

<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.report.ReportBO"%>
<%@page import="com.tsp.gespro.jdbc.DatosUsuarioDaoImpl"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el usuario tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
} else {
    
    String buscar_isMostrarSoloActivos = request.getParameter("inactivos")!=null?request.getParameter("inactivos"):"1";
    String buscar = request.getParameter("q")!=null?new String(request.getParameter("q").getBytes("ISO-8859-1"),"UTF-8"):"";
    String filtroBusqueda = "";
    if (!buscar.trim().equals(""))
        filtroBusqueda = " AND (USER_NAME LIKE '%" + buscar + "%')";
    
    int idUsuarios = -1;
    try{ idUsuarios = Integer.parseInt(request.getParameter("idUsuarios")); }catch(NumberFormatException e){}
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
    
    
    if (buscar_isMostrarSoloActivos.trim().equals("1")){
       
        filtroBusqueda += " AND (ID_ESTATUS = 1) ";
    }
    
    
    filtroBusqueda += " AND (ID_ROLES <> 1 AND ID_ROLES <> 4) ";
    
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
    
     UsuariosBO usuariosBO = new UsuariosBO();
     Usuarios[] usuariosDto = new Usuarios[0];
     try{
         limiteRegistros = usuariosBO.findUsuarios(idUsuarios, idEmpresa , 0, 0, filtroBusqueda).length;
         
         if (!buscar.trim().equals(""))
             registrosPagina = limiteRegistros;
         
         paginasTotales = (int)Math.ceil(limiteRegistros / registrosPagina);

        if(paginaActual<0)
            paginaActual = 1;
        else if(paginaActual>paginasTotales)
            paginaActual = paginasTotales;

        usuariosDto = usuariosBO.findUsuarios(idUsuarios, idEmpresa,
                ((paginaActual - 1) * (int)registrosPagina), (int)registrosPagina, 
                filtroBusqueda);

     }catch(Exception ex){
         ex.printStackTrace();
     }
     
     /*
    * Datos de catálogo
    */
    String urlTo = "../catUsuarios/catUsuarios_form.jsp";
    String paramName = "idUsuario";
    String parametrosPaginacion="inactivos="+buscar_isMostrarSoloActivos;// "idEmpresa="+idEmpresa;
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
            function reestablecer(user){              
                apprise('¿Estas seguro de hacer el reestablecimiento de password?', {'verify':true, 'animate':true, 'textYes':'Si', 'textNo':'Cancelar'}, function(r)
                {
                    if(r){
                        ajaxReestablecer(user);
                    }
                });
            }

            function ajaxReestablecer(user){
                $.ajax({
                    type: "POST",
                    url: "../catUsuarios/catUsuarios_reestablecerPass_ajax.jsp",
                    data: { username: user },
                    beforeSend: function(objeto){
                        $("#ajax_loading").html('<center><img src="../../images/ajax_loader.gif" alt="Cargando.." /><h2>Reestableciendo...</h2></center>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("--EXITO-->", 0)>0){
                           $("#ajax_message").html(datos);
                           $("#ajax_loading").fadeOut("slow");
                           $("#ajax_message").fadeIn("slow");
                           apprise(datos,{'info':true, 'animate':true});
                       }else{
                           $("#ajax_loading").fadeOut("slow");
                           $("#ajax_message").html(datos);
                           $("#ajax_message").fadeIn("slow");
                           apprise(datos,{'info':true, 'animate':true});
                       }
                    }
                });
            }
            
            
            function cambiarContrasena(user, pass){              
                apprise('<center>Indique el password que desea asignar al usuario <b>'+user+'</b> <br/><br/><i>En esta modalidad, NO se enviará un correo informando el cambio al usuario.</i></center>', {'input':true, 'animate':true, 'textYes':'Asignar', 'textNo':'Cancelar'}, function(r)
                {
                    if(r){
                        var pass = r;
                        ajaxCambiarContrasena(user, pass);
                    }
                });
            }

            function ajaxCambiarContrasena(user, pass){
                $.ajax({
                    type: "POST",
                    url: "../catUsuarios/catUsuarios_reestablecerPass_ajax.jsp",
                    data: { username: user, password_default: pass },
                    beforeSend: function(objeto){
                        $("#ajax_loading").html('<center><img src="../../images/ajax_loader.gif" alt="Cargando.." /><h2>Reestableciendo...</h2></center>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("--EXITO-->", 0)>0){
                           $("#ajax_message").html(datos);
                           $("#ajax_loading").fadeOut("slow");
                           $("#ajax_message").fadeIn("slow");
                           apprise(datos,{'info':true, 'animate':true});
                       }else{
                           $("#ajax_loading").fadeOut("slow");
                           $("#ajax_message").html(datos);
                           $("#ajax_message").fadeIn("slow");
                           apprise(datos,{'info':true, 'animate':true});
                       }
                    }
                });
            }
            
            
            function inactiv(){               
                if($("#inactivos").attr("checked")){
                    $("#inactivos").val("2");
                }else{
                     $("#inactivos").val("1");
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
                    <h1>Administración</h1>
                    
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>
                    
                    
                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                Busqueda Avanzada &dArr;
                            </span>
                        </div>
                        <br class="clear"/>
                        <div class="content" style="display: none;">
                            <form action="catUsuarios_list.jsp" id="search_form_advance" name="search_form_advance" method="post">
                                
                                 
                                <p>
                                    <input type="checkbox" class="checkbox" id="inactivos" name="inactivos" value="1"  onchange="inactiv();" > <label for="inactivos">Mostrar Inactivos</label>                                   
                                </p>
                                <br/><br/>  
                            
                                <div id="action_buttons">
                                    <p>
                                        <input type="button" id="buscar" value="Buscar" onclick="$('#search_form_advance').submit();"/>
                                    </p>
                                </div>
                                
                            </form>
                        </div>
                    </div>

                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_users.png" alt="icon"/>
                                Usuarios
                            </span>
                            
                            <!--Panel busqueda-->
                            <div class="switch" style="width:500px">
                                <table width="500px" cellpadding="0" cellspacing="0">
                                    <tbody>
                                            <tr>
                                                <td>
                                                    <div id="search">
                                                    <form action="catUsuarios_list.jsp" id="search_form" name="search_form" method="get">
                                                            <input type="text" id="q" name="q" title="Buscar por Usuario" class="" style="width: 300px; float: left; "
                                                                    value="<%=buscar%>"/>
                                                            <input type="image" src="../../images/Search-32_2.png" id="buscar" name="buscar"  value="" style="cursor: pointer; width: 30px; height: 25px; float: left"/>
                                                    </form>
                                                    </div>
                                                </td>
                                                <td class="clear">&nbsp;&nbsp;&nbsp;</td>
                                                
                                                <td>
                                                    <input type="button" id="nuevo" name="nuevo" class="right_switch" value="Crear Nuevo" 
                                                            style="float: right; width: 100px;" onclick="location.href='<%=urlTo%>'"/>
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
                                            <th>Sucursal</th>
                                            <th>Usuario</th>
                                            <th>Rol</th>
                                            <th>Nombre</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            for (Usuarios item:usuariosDto){
                                                try{
                                                    DatosUsuario datosUsuarioDto = new DatosUsuarioDaoImpl(user.getConn()).findByPrimaryKey(item.getIdDatosUsuario());
                                                    Empresa empresaDto = new EmpresaBO(item.getIdEmpresa(),user.getConn()).getEmpresa();
                                        %>
                                        <tr <%=(item.getIdEstatus()!=1)?"class='inactive'":""%>>
                                            <!--<td><input type="checkbox"/></td>-->
                                            <td><%=item.getIdUsuarios() %></td>
                                            <td><i><%=empresaDto.getNombreComercial() %></i></td>
                                            <td><b><%=item.getUserName() %></b></td>
                                            <td><%=RolesBO.getRolName(item.getIdRoles()) %></td>
                                            <td><%=datosUsuarioDto.getNombre()+" "+ datosUsuarioDto.getApellidoPat() + " " +datosUsuarioDto.getApellidoMat()  %></td>
                                            <td>
                                                
                                                <a href="<%=urlTo%>?<%=paramName%>=<%=item.getIdUsuarios()%>&acc=1&pagina=<%=paginaActual%>"><img src="../../images/icon_edit.png" alt="editar" class="help" title="Editar"/></a>
                                                &nbsp;&nbsp;
                                                <a href="#" onclick="reestablecer('<%=item.getUserName() %>');"><img src="../../images/icon_email.png" alt="reestablecer" class="help" title="Reestablecer Contraseña"/></a>
                                                &nbsp;&nbsp;
                                                <a href="#" onclick="cambiarContrasena('<%=item.getUserName() %>');"><img src="../../images/Change-Password-16.png" alt="Cambiar Password" class="help" title="Cambiar Password"/></a>
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
                           <!--<//jsp:include page="../include/reportExportOptions.jsp">
                                <//jsp:param name="idReport" value="<%//= ReportBO.USER_REPORT %>" />
                                <//jsp:param name="parametrosCustom" value="<%//=filtroBusquedaEncoded %>" />
                            <//jsp:include> -->
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