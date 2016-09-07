<%-- 
    Document   : catEmpleados_list
    Created on : 9/01/2013, 11:12:43 AM
    Author     : Leonardo Montes de Oca, leonarzeta@hotmail.com
    

    Funciona historico checs in registrados,si no se registro no hace ninguna validacion, aparecera sin registro.
    

--%>


<%@page import="com.tsp.gespro.report.ReportBO"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page import="com.tsp.gespro.jdbc.DetalleHorarioDaoImpl"%>
<%@page import="com.tsp.gespro.dto.DetalleHorario"%>
<%@page import="com.tsp.gespro.jdbc.HorarioUsuarioDaoImpl"%>
<%@page import="com.tsp.gespro.dto.HorarioUsuario"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.tsp.gespro.util.DateManage"%>
<%@page import="com.tsp.gespro.util.StringManage"%>
<%@page import="com.tsp.gespro.bo.EstadoEmpleadoBO"%>
<%@page import="com.tsp.gespro.dto.RegistroCheckin"%>
<%@page import="com.tsp.gespro.bo.RegistroCheckInBO"%>
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
    
    
     
    String buscar = request.getParameter("q")!=null? new String(request.getParameter("q").getBytes("ISO-8859-1"),"UTF-8") :"";    
    String buscar_q_detalleCheck = request.getParameter("q_detalleCheck")!=null?request.getParameter("q_detalleCheck"):"";
    String buscar_q_idIncidencia = request.getParameter("q_idIncidencia")!=null?request.getParameter("q_idIncidencia"):"";
    String buscar_idcliente = request.getParameter("q_idcliente")!=null?request.getParameter("q_idcliente"):"";

    
    String filtroBusqueda = " AND ID_USUARIO IN (SELECT ID_USUARIOS FROM USUARIOS WHERE ID_EMPRESA IN (SELECT ID_EMPRESA FROM EMPRESA WHERE ID_EMPRESA_PADRE = " + user.getUser().getIdEmpresa() + " OR ID_EMPRESA= " + user.getUser().getIdEmpresa() + ") )"; //"AND ID_ESTATUS=1 ";
    if (!buscar.trim().equals(""))
        filtroBusqueda += " AND ID_DATOS_USUARIO IN (SELECT ID_DATOS_USUARIO FROM datos_usuario WHERE NOMBRE LIKE '%" + buscar + 
                            "%' OR APELLIDO_PAT LIKE '%" + buscar +
                            "%' OR APELLIDO_MAT LIKE '%"+buscar+
                            "%') OR NUM_EMPLEADO LIKE '%"+buscar+                                                       
                            "%' OR (ID_ROLES IN (SELECT ID_ROLES FROM ROLES WHERE ROLES.NOMBRE LIKE '%"+buscar+
                            "%')) OR (ID_EMPRESA IN (SELECT ID_EMPRESA FROM EMPRESA WHERE EMPRESA.NOMBRE_COMERCIAL LIKE '%"+buscar+                           
                            "%')) OR (ID_ESTATUS IN (SELECT ID_ESTATUS FROM ESTATUS WHERE NOMBRE LIKE '"+buscar+"')) ";
    
                 
    
    String buscar_fechamin = "";
    String buscar_fechamax = "";
    Date fechaMin=null;
    Date fechaMax=null;
    String strWhereRangoFechas="";  
    String parametrosPaginacion = "";
    
    {
        try{
            fechaMin = new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("q_fh_min"));
            buscar_fechamin = DateManage.formatDateToSQL(fechaMin);
        }catch(Exception e){}
        try{
            fechaMax = new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("q_fh_max"));
            buscar_fechamax = DateManage.formatDateToSQL(fechaMax);
        }catch(Exception e){}

        /*Filtro por rango de fechas*/
        if (fechaMin!=null && fechaMax!=null){
            strWhereRangoFechas="(CAST(FECHA_HORA AS DATE) BETWEEN '"+buscar_fechamin+"' AND '"+buscar_fechamax+"')";
            if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
            parametrosPaginacion+="q_fh_max="+DateManage.formatDateToNormal(fechaMax)+"&q_fh_min="+DateManage.formatDateToNormal(fechaMin);
        }
        if (fechaMin!=null && fechaMax==null){
            strWhereRangoFechas="(FECHA_HORA  >= '"+buscar_fechamin+"')";
            if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
            parametrosPaginacion+="q_fh_min="+DateManage.formatDateToNormal(fechaMin);
        }
        if (fechaMin==null && fechaMax!=null){
            strWhereRangoFechas="(FECHA_HORA  <= '"+buscar_fechamax+"')";
            if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
            parametrosPaginacion+="q_fh_max="+DateManage.formatDateToNormal(fechaMax);
        }
    }
    
    if (!strWhereRangoFechas.trim().equals("")){
        filtroBusqueda += " AND " + strWhereRangoFechas;
    }
           
    
    if (!buscar_q_detalleCheck.trim().equals("")){
        
        filtroBusqueda += " AND ID_DETALLE_CHECK=" + buscar_q_detalleCheck +" ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_idestatusUsuario="+buscar_q_detalleCheck;
    }
    
    
    if (!buscar_q_idIncidencia.trim().equals("")){
        
        filtroBusqueda += " AND INCIDENCIA = "+  buscar_q_idIncidencia +"  ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_idIncidencia="+buscar_q_idIncidencia;
    }
    
   
    
    int idUsuario = 0;
    try {
        idUsuario = Integer.parseInt(request.getParameter("idUsuario"));        
    } catch (NumberFormatException e) {
    }

    
    if (idUsuario>0){
        
        filtroBusqueda += " AND ID_USUARIO = "+  idUsuario +"  ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="idUsuario="+idUsuario;
        
    }
    
    
    if (!buscar_idcliente.trim().equals("")){
        filtroBusqueda += " AND ID_CLIENTE='" + buscar_idcliente +"' ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_idcliente="+buscar_idcliente;
    }else{
        filtroBusqueda += " AND ID_CLIENTE>=0 ";
    }
    
   Usuarios empleadoConsultado = null;
   UsuariosBO empleadoBO = new UsuariosBO(user.getConn());
   DatosUsuario datosUsuarioDto = null;
   String nombreEmpleado="" ;
   
    
   try {      
        
        UsuarioBO usuarioBO = new UsuarioBO(user.getConn(),idUsuario);
        empleadoConsultado = usuarioBO.getUser();
        datosUsuarioDto =  usuarioBO.getDatosUsuario();      
        
        
        nombreEmpleado = (datosUsuarioDto.getNombre()!=null?datosUsuarioDto.getNombre():"") + " " + (datosUsuarioDto.getApellidoPat()!=null?" " + datosUsuarioDto.getApellidoPat():"") + " " +(datosUsuarioDto.getApellidoMat()!=null?" " + datosUsuarioDto.getApellidoMat():"");
    } catch (Exception e) {
    }
   
   
    
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
    
     RegistroCheckInBO registroCheckInBO = new RegistroCheckInBO(user.getConn());
     RegistroCheckin[] checksDto = new RegistroCheckin[0];
             
     try{
         limiteRegistros = registroCheckInBO.findRegistroCheckins(-1,-1,0, 0, filtroBusqueda).length;
         
         if (!buscar.trim().equals(""))
             registrosPagina = limiteRegistros;
         
         paginasTotales = (int)Math.ceil(limiteRegistros / registrosPagina);

        if(paginaActual<0)
            paginaActual = 1;
        else if(paginaActual>paginasTotales)
            paginaActual = paginasTotales;

        checksDto = registroCheckInBO.findRegistroCheckins(-1,-1, 
                ((paginaActual - 1) * (int)registrosPagina), (int)registrosPagina,
                filtroBusqueda);

     }catch(Exception ex){
         ex.printStackTrace();
     }
     
     /*
    * Datos de catálogo
    */
    String urlTo = "../catEmpleados/catEmpleados_checkLocalizacion.jsp";
    String paramName = "checkIn";
    
    parametrosPaginacion+="&idUsuario="+idUsuario;// "idEmpresa="+idEmpresa;
    String filtroBusquedaEncoded = java.net.URLEncoder.encode(filtroBusqueda, "UTF-8");
    
  
    
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
            
                       
            
            
            function mostrarCalendario(){
                //fh_min
                //fh_max

                var dates = $('#q_fh_min, #q_fh_max').datepicker({
                        //minDate: 0,
			changeMonth: true,
			//numberOfMonths: 2,
                        //beforeShow: function() {$('#fh_min').css("z-index", 9999); },
                        beforeShow: function(input, datepicker) {
                            setTimeout(function() {
                                    $(datepicker.dpDiv).css('zIndex', 998);
                            }, 500)},
			onSelect: function( selectedDate ) {
				var option = this.id == "q_fh_min" ? "minDate" : "maxDate",
					instance = $( this ).data( "datepicker" ),
					date = $.datepicker.parseDate(
						instance.settings.dateFormat ||
						$.datepicker._defaults.dateFormat,
						selectedDate, instance.settings );
				dates.not( this ).datepicker( "option", option, date );
			}
		});

            }
            
            
        </script>

    </head>
    <body class="nobg">
        <div class="content_wrapper">         

            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>
            
            <!-- Inicio de Contenido -->
             <div id="content">

                <div class="inner">                          
                    
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>
                                        
                      
                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                Búsqueda Avanzada &dArr;
                            </span>
                        </div>
                        <br class="clear"/>
                        <div class="content" style="display: none;">
                            <form action="catEmpleados_Registro_list.jsp" id="search_form_advance" name="search_form_advance" method="post">
                              
                                <p>                                   
                                    <label>Desde:</label>
                                    <input maxlength="15" type="text" id="q_fh_min" name="q_fh_min" style="width:100px"
                                            value="" readonly/>
                                    &nbsp; &laquo; &mdash; &raquo; &nbsp;
                                    <label>Hasta:</label>
                                    <input maxlength="15" type="text" id="q_fh_max" name="q_fh_max" style="width:100px"
                                        value="" readonly/>
                                </p>
                                <br/>     
                                <p>
                                <label>Promotor:</label><br>
                                <select id="idUsuario" name="idUsuario" class="flexselect">
                                    <option></option>
                                    <%= new UsuariosBO().getUsuariosByRolHTMLCombo(idEmpresa, RolesBO.ROL_GESPRO, idUsuario) %>                                                        
                                </select>
                                </p> 
                                <br>
                                <p>
                                <label>Cliente:</label><br/>
                                <select id="q_idcliente" name="q_idcliente" class="flexselect">
                                    <option></option>
                                    <%= new ClienteBO(user.getConn()).getClientesByIdHTMLCombo(idEmpresa, -1," AND ID_ESTATUS <> 2 " + (user.getUser().getIdRoles() == RolesBO.ROL_GESPRO ? " AND ID_CLIENTE IN (SELECT ID_CLIENTE FROM relacion_cliente_vendedor WHERE ID_USUARIO="+user.getUser().getIdUsuarios()+")" : "") ) %>
                                </select>
                                </p>  
                                 <br>
                                <p>
                                <label>Detalle:</label><br/>
                                <select id="q_detalleCheck" name="q_detalleCheck" class="flexselect">
                                    <option></option>      
                                    <%= new EstadoEmpleadoBO(user.getConn()).getEstadosByIdHTMLCombo(idEmpresa, 0) %>                                    
                                </select>
                                </p>
                                 <br/>  
                                <p>
                                <label>Incidencia:</label><br/>
                                <select id="q_idIncidencia" name="q_idIncidencia" class="flexselect">
                                    <option></option>      
                                    <option value="0">SIN COMENTARIO</option> 
                                    <option value="1">RETARDO</option> 
                                    <option value="2">FALTA</option> 
                                </select>
                                </p>
                               
                                <br/>                                    
                                <br/>
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
                               
                                <% if(datosUsuarioDto!=null){%>
                                Promotor&nbsp;&nbsp;&nbsp;&nbsp;<%=nombreEmpleado%>
                                <%}else{%>
                                Promotor 
                                <%}%>
                            </span>
                            <div class="switch" style="width:750px">
                                <table width="750px" cellpadding="0" cellspacing="0">
						<tbody>
							<tr>
                                                            <td>
                                                                <div id="search">
                                                                   <!-- <form action="../inicio/main.jsp" id="search_form" name="search_form" method="get"> 
                                                                                                                                    
                                                                        
                                                                        <input type="text" id="q" name="q" title="Buscar por # Empleado/Nombre/Apellido Paterno/Materno/Rol/Sucursal/Estatus" class="" style="width: 300px; float: left; "
                                                                               value="<%//=buscar%>"/>                                                                        
                                                                        
                                                                        <input type="image" src="../../images/Search-32_2.png" id="buscar" name="buscar"  value="" style="width: 30px; height: 25px; float: left"/>
                                                                </form>-->
                                                                </div>
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
                                            <th>Fecha</th>
                                            <th>Tipo</th>    
                                            <th>Detalle</th>
                                            <th>Cliente</th>
                                            <th>Incidencia</th>
                                            <th>Comentarios</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                            <% 
                                        
                                            ClienteBO clienteBO = new ClienteBO(user.getConn());
                                            String imagenIncidencia = "";
                                            String titleIncidencia = "";
                                            for (RegistroCheckin item:checksDto){
                                                try{
                                                    
                                                  
                                                    String nombreEstatus  = "SIN DETALLE";
                                                    try{

                                                        EstadoEmpleadoBO estadoEmpleadoBO =  new EstadoEmpleadoBO(item.getIdDetalleCheck(),user.getConn());

                                                        nombreEstatus = estadoEmpleadoBO.getEstado().getNombre();
                                                    }catch(Exception e){
                                                        System.out.println("No se encontraron registros con los datos especificado");
                                                    }
                                                    
                                                    
                                                    Cliente clientesDto = null;
                                                    if (item.getIdCliente() > 0){
                                                        clienteBO = new ClienteBO(item.getIdCliente(), user.getConn());
                                                        clientesDto = clienteBO.getCliente();
                                                    }
                                                    
                                                    
                                                    
                                                    
                                        %>
                                        <tr <%=(item.getIdEstatus()==2)?"style='background: #B0B1B1'":""%> >
                                          
                                            <td><%=item.getIdCheck()%></td>
                                            <td><%=item.getFechaHora()%></td>
                                            <td><%=item.getIdTipoCheck()==1?"ENTRADA":item.getIdTipoCheck()==2?"SALIDA":"DESCONOCIDO"%></td>                                                                                     
                                            <td><%=nombreEstatus%></td>
                                            <td><%=clientesDto!=null?clientesDto.getNombreComercial():"NA"%></td>
                                            <% if(item.getIdTipoCheck() == 1  && item.getIdDetalleCheck() == 6){
                                                   if(item.getIncidencia()== 0){
                                                        imagenIncidencia = "../../images/gespro_verde.png";
                                                        titleIncidencia = "SIN COMENTARIO";
                                                    }else if(item.getIncidencia() == 1){
                                                        imagenIncidencia = "../../images/gespro_amarillo.png";
                                                        titleIncidencia = "RETARDO";
                                                    }else if(item.getIncidencia() == 2){
                                                        imagenIncidencia = "../../images/gespro_rojo.png";  
                                                        titleIncidencia = "FALTA";
                                                    } 
                                            %>
                                                <td><img title="<%=titleIncidencia%>"  class="help" src="<%=imagenIncidencia%>"/></td>
                                            <%}else{%>
                                                <td>NA</td>
                                             <%}%>
                                            <td><%=item.getComentarios() %></td>                                              
                                            <td>                                  
                                                <a href="<%=urlTo%>?<%=paramName%>=<%=item.getIdCheck()%>" id="consultaGeoLocalizacion"><img src="../../images/icon_movimiento.png" alt="localización" class="help" title="Localización"/></a>                                                                    
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
                            <jsp:include page="../include/reportExportOptions.jsp" flush="true">
                                <jsp:param name="idReport" value="<%= ReportBO.BITACORA_REPORT %>" />
                                <jsp:param name="parametrosCustom" value="<%= filtroBusquedaEncoded %>" />
                            </jsp:include>
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
      <script>
            mostrarCalendario();
            $("select.flexselect").flexselect();
     </script>                           

    </body>
</html>
<%}%>
