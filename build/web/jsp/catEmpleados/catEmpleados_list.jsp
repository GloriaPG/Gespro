<%-- 
    Document   : catEmpleados_list
    Created on : 9/01/2013, 11:12:43 AM
    Author     : Leonardo Montes de Oca, leonarzeta@hotmail.com
--%>

<%@page import="com.tsp.gespro.bo.EstadoEmpleadoBO"%>
<%@page import="com.tsp.gespro.bo.DatosUsuarioBO"%>
<%@page import="com.tsp.gespro.dto.Ruta"%>
<%@page import="com.tsp.gespro.jdbc.RutaDaoImpl"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.jdbc.DatosUsuarioDaoImpl"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.dto.EmpleadoBitacoraPosicion"%>
<%@page import="com.tsp.gespro.jdbc.EmpleadoBitacoraPosicionDaoImpl"%>
<%@page import="com.tsp.gespro.jdbc.EmpresaPermisoAplicacionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.EmpresaPermisoAplicacion"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="java.util.Date"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el usuario tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
} else {
    
    
    String buscar_isMostrarSoloActivos = request.getParameter("inactivos")!=null?request.getParameter("inactivos"):"1";
    
    String buscar = request.getParameter("q")!=null? new String(request.getParameter("q").getBytes("ISO-8859-1"),"UTF-8") :"";    
    
    String filtroBusqueda = ""; //"AND ID_ESTATUS=1 ";
    if (!buscar.trim().equals(""))
        filtroBusqueda += " AND ID_DATOS_USUARIO IN (SELECT ID_DATOS_USUARIO FROM datos_usuario WHERE NOMBRE LIKE '%" + buscar + 
                            "%' OR APELLIDO_PAT LIKE '%" + buscar +
                            "%' OR APELLIDO_MAT LIKE '%"+buscar+
                            "%') OR NUM_EMPLEADO LIKE '%"+buscar+                                                       
                            "%' OR (ID_ROLES IN (SELECT ID_ROLES FROM ROLES WHERE ROLES.NOMBRE LIKE '%"+buscar+
                            "%')) OR (ID_EMPRESA IN (SELECT ID_EMPRESA FROM EMPRESA WHERE EMPRESA.NOMBRE_COMERCIAL LIKE '%"+buscar+                           
                            "%')) OR (ID_ESTATUS IN (SELECT ID_ESTATUS FROM ESTATUS WHERE NOMBRE LIKE '"+buscar+"')) ";
                            
    if (buscar_isMostrarSoloActivos.trim().equals("1")){
        
        filtroBusqueda += " AND (ID_ESTATUS = 1) ";
    }
    
    
    
    filtroBusqueda += " AND (ID_ROLES = 4) ";
    
    int idEmpleado = -1;
    try{ idEmpleado = Integer.parseInt(request.getParameter("idEmpleado")); }catch(NumberFormatException e){}
    
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
    
     UsuariosBO usuariosBO = new UsuariosBO(user.getConn());
     Usuarios[] usuariosDto = new Usuarios[0];
     try{
         limiteRegistros = usuariosBO.findUsuarios(idEmpleado, idEmpresa , 0, 0, filtroBusqueda).length;
         
         if (!buscar.trim().equals(""))
             registrosPagina = limiteRegistros;
         
         paginasTotales = (int)Math.ceil(limiteRegistros / registrosPagina);

        if(paginaActual<0)
            paginaActual = 1;
        else if(paginaActual>paginasTotales)
            paginaActual = paginasTotales;

        usuariosDto = usuariosBO.findUsuarios(idEmpleado, idEmpresa,
                ((paginaActual - 1) * (int)registrosPagina), (int)registrosPagina,
                filtroBusqueda);

     }catch(Exception ex){
         ex.printStackTrace();
     }
     
     /*
    * Datos de catálogo
    */
    String urlTo = "../catEmpleados/catEmpleados_form.jsp";
    String urlTo2 = "../catEmpleados/catEmpleados_formEstado.jsp";
    String urlTo3 = "../catEmpleados/catEmpleados_formMapa.jsp";
    String urlTo4 = "../catEmpleados/catEmpleados_RutaDia.jsp";//../catEmpleados/catEmpleados_formHistorial.jsp
    String urlTo5 = "../catEmpleados/catEmpleados_Mensajes_list.jsp"; 
    String urlTo6 = "../catEmpleados/catEmpleados_Registro_list.jsp";  
    String urlTo8 = "../mapa/cobranzaPromotor_ComparaRutas.jsp";
    String urlToCliEmpl = "../catEmpleados/catEmpleado_Relacion_Cliente_list.jsp";
    String urlToAgenda = "../catEmpleados/catEmpleado_Agenda_list.jsp";
    String urlToCuentaEfe = "../catEmpleados/catEmpleado_CuentaEfectivo_list.jsp";

    String paramName = "idUsuario";
    String paramName2 = "idGeocerca";
    String parametrosPaginacion="inactivos="+buscar_isMostrarSoloActivos;// "idEmpresa="+idEmpresa;
    String filtroBusquedaEncoded = java.net.URLEncoder.encode(filtroBusqueda, "UTF-8");
    
    
    EmpresaBO empresaBO = new EmpresaBO(user.getConn());
    EmpresaPermisoAplicacion empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl(user.getConn()).findByPrimaryKey(empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa());

    String verificadorSesionGuiaCerrada = "0";
    String cssDatosObligatorios = "border:3px solid red;";//variable para colocar el css del recuadro que encierra al input para la guia interactiva
    try{
        if(session.getAttribute("sesionCerrada")!= null){
            verificadorSesionGuiaCerrada = (String)session.getAttribute("sesionCerrada");
        }
    }catch(Exception e){}
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
            function eliminarEmpleado(idUsuario){
                if (idUsuario>0){
                    $.ajax({
                        type: "POST",
                        url: "catEmpleados_ajax.jsp",
                        data: {mode: '2', idUsuario : idUsuario},
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
                                            location.href = "catEmpleados_list.jsp";
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
            
            
            
            function eliminar(idEmpleado){              
                apprise('¿Estas seguro de eliminar (cambiar de estatus) el registro del empleado?', {'verify':true, 'animate':true, 'textYes':'Si', 'textNo':'Cancelar'}, function(r)
                {
                    if(r){
                        ajaxReestablecer(idEmpleado);
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
                            <form action="catEmpleados_list.jsp" id="search_form_advance" name="search_form_advance" method="post">
                                                                    
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
                                Administración Empleados
                            </span>
                            <div class="switch" style="width:750px">
                                <table width="750px" cellpadding="0" cellspacing="0">
						<tbody>
							<tr>
                                                            <td>
                                                                <div id="search">
                                                                    <form action="catEmpleados_list.jsp" id="search_form" name="search_form" method="get"> 
                                                                                                                                    
                                                                        
                                                                        <input type="text" id="q" name="q" title="Buscar por # Empleado/Nombre/Apellido Paterno/Materno/Rol/Sucursal/Estatus" class="" style="width: 300px; float: left; "
                                                                               value="<%=buscar%>"/>                                                                        
                                                                        <!--<li> <a title="Buscar" type="submit" id="search" class="right_switch" onclick="search_form.submit(); q.value=''">Buscar </a> </li>-->
                                                                        <!--<input title="Buscar" type="submit" id="search" class="right_switch" style="font-size: 9px;"/>-->
                                                                        <input type="image" src="../../images/Search-32_2.png" id="buscar" name="buscar"  value="" style="width: 30px; height: 25px; float: left"/>
                                                                </form>
                                                                </div>
                                                            </td>
                                                            <td class="clear">&nbsp;&nbsp;&nbsp;</td>
                                                            
                                                            <td>
                                                                <input type="button" id="nuevo" name="nuevo" class="right_switch expose" value="Crear Nuevo" 
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
                                            <th>Número de Empleado</th>
                                            <th>Nombre</th>
                                            <th>Apellido Paterno</th>
                                            <th>Apellido Materno</th>
                                            <th>Rol</th>
                                            <th>Estado</th>                                            
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            for (Usuarios item:usuariosDto){
                                                try{
                                                    
                                                    DatosUsuario datosUsuario = new DatosUsuarioBO(item.getIdDatosUsuario(),user.getConn()).getDatosUsuario();
                                        %>
                                        <tr <%=(item.getIdEstatus()==2)?"style='background: #B0B1B1'":""%> >
                                          
                                            <td><%=item.getIdUsuarios()%></td>
                                            <td><%=item.getNumEmpleado()%></td>
                                            <td><%=datosUsuario.getNombre()%></td>
                                            <td><%=datosUsuario.getApellidoPat()%></td>
                                            <td><%=datosUsuario.getApellidoMat()%></td>                                           
                                            <td><%=RolesBO.getRolName(item.getIdRoles()) %></td>
                                            
                                                <%                                            
                                               
                                                //Obtenemos ultimo estatus registrado                                                   
                                                    String nombreEstatus  = "SIN DETALLE";
                                                    try{
                                                                                                                
                                                        EstadoEmpleadoBO estadoEmpleadoBO =  new EstadoEmpleadoBO(item.getIdEstadoEmpleado(),user.getConn());
                                                                                                                                                                      
                                                        nombreEstatus = estadoEmpleadoBO.getEstado().getNombre();
                                                    }catch(Exception e){
                                                        System.out.println("No se encontraron registros con los datos especificado");
                                                    }
                                                %>
                                                <td><%=nombreEstatus%></td>                                            
                                            <td>     
                                                
                                                    <a href="<%=urlTo%>?<%=paramName%>=<%=item.getIdUsuarios()%>&acc=1&pagina=<%=paginaActual%>"><img src="../../images/icon_edit.png" alt="editar" class="help" title="Editar"/></a>
                                                    &nbsp;&nbsp;                                                    
                                                    <a href="#" onclick="eliminarEmpleado(<%=item.getIdUsuarios()%>);"><img src="../../images/icon_delete.png" alt="delete" class="help" title="Borrar"/></a>
                                                    &nbsp;&nbsp;
                                                    <a href="<%=urlTo3%>?<%=paramName%>=<%=item.getIdUsuarios()%>&acc=Mapa" id="consultaGeoLocalizacionEmpleado"><img src="../../images/icon_movimiento.png" alt="localización" class="help" title="Localización"/></a>
                                                    &nbsp;&nbsp;
                                                    <a href="<%=urlTo4%>?<%=paramName%>=<%=item.getIdUsuarios()%>&acc=Historial&menu=1"><img src="../../images/icon_calendar.png" alt="historial" class="help" title="Historial"/></a>                                                
                                                    &nbsp;&nbsp;
                                                    <a href="<%=urlTo5%>?<%=paramName%>=<%=item.getIdUsuarios()%>&acc=Mensaje"><img src="../../images/icon_mensajes.png" alt="mensaje" class="help" title="Mensaje"/></a>
                                                    &nbsp;&nbsp; 
                                                    <a href="<%=urlTo6%>?<%=paramName%>=<%=item.getIdUsuarios()%>&acc=Mensaje"><img src="../../images/clock.png" alt="Bitácora" class="help" title="Bitácora"/></a>
                                                    &nbsp;&nbsp;
                                                    <a href="<%=urlToCliEmpl%>?<%="idUsuarioEmpleado"%>=<%=item.getIdUsuarios()%>&acc=relacionEmpleadoCliente"><img src="../../images/icon_cliente.png" alt="cliente" class="help" title="Relación de Clientes"/></a>
                                                    &nbsp;&nbsp;
                                                    
                                                    <%
                                                      
                                                       //Revisamos si el pomotor tiene asignada al menos una ruta 
                                                        RutaDaoImpl rutasDaoImpl = new RutaDaoImpl(user.getConn());
                                                        Ruta[] rutas = rutasDaoImpl.findWhereIdUsuarioEquals(item.getIdUsuarios());

                                                    if(rutas.length>=1){
                                                    %>
                                                        <a href="<%=urlTo8%>?<%=paramName%>=<%=item.getIdUsuarios()%>&acc=CompararRutas"><img src="../../images/icon_logistica_antes.png" alt="CompararRutas" class="help" title="Comparar Rutas"/></a>
                                                        &nbsp;&nbsp;
                                                    <% } %>                                                   
                                                    
                                                   
                                            
                                                
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
                                <//jsp:param name="idReport" value="<//%= ReportBO.CLIENTE_REPORT %>" />
                                <//jsp:param name="parametrosCustom" value="<%= filtroBusquedaEncoded %>" />
                            <//jsp:include>-->
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
