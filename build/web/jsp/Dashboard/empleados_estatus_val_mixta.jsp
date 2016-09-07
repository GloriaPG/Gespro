<%-- 
   validacion mixta
es decir,
los checks in si funcionara historico,
pero si no registraron check in tomara el actual,
casa confusion.
--%>


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
    
    
    String buscar_isMostrarSoloActivos = request.getParameter("inactivos")!=null?request.getParameter("inactivos"):"1";
    String buscar_idvendedor = request.getParameter("q_idvendedor")!=null?request.getParameter("q_idvendedor"):"";
    String buscar = request.getParameter("q")!=null? new String(request.getParameter("q").getBytes("ISO-8859-1"),"UTF-8") :"";    
    String buscar_q_idestatusUsuario = request.getParameter("q_idestatusUsuario")!=null?request.getParameter("q_idestatusUsuario"):"";
    String buscar_q_idIncidencia = request.getParameter("q_idIncidencia")!=null?request.getParameter("q_idIncidencia"):"";
    
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
    
    
    
    
    String buscar_fechamin = "";    
    Date fechaMin=null;
  
    String strWhereRangoFechas="";    
    String parametrosPaginacion = "";
    DateManage fmt = new DateManage();
    Date fechaChecks = new Date();
    
    
    {
        try{
            fechaMin = new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("q_fh_min"));
           
        }catch(Exception e){
        
            fechaMin = new Date();
        }       

        /*Filtro por rango de fechas*/
        if (fechaMin!=null){           
            if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
            parametrosPaginacion+="q_fh_min="+DateManage.formatDateToNormal(fechaMin);
            
            fechaChecks = fechaMin;
        }
        
    }
    
    
       
    
    //filtro promotor
    if (!buscar_idvendedor.equals("")){
        filtroBusqueda += " AND ID_USUARIOS ='" + buscar_idvendedor + "' ";
    }
    
    
    
    if (!buscar_q_idestatusUsuario.trim().equals("")){
        
        filtroBusqueda += " AND ID_ESTADO_EMPLEADO=" + buscar_q_idestatusUsuario +" ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_idestatusUsuario="+buscar_q_idestatusUsuario;
    }
    
    
    if (!buscar_q_idIncidencia.trim().equals("")){
        
        filtroBusqueda += " AND ID_USUARIOS IN (SELECT ID_USUARIO FROM registro_checkin WHERE DATE(FECHA_HORA) = DATE('"+fmt.formatDateToSQL(fechaChecks)+"') AND INCIDENCIA = "+  buscar_q_idIncidencia +" ) ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_idIncidencia="+buscar_q_idIncidencia;
    }
    
    //Para Obtener solo promotores
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
    String urlTo6 = "../catGeocerca/mapaFiguras.jsp";  
    String urlTo8 = "../mapa/cobranzaPromotor_ComparaRutas.jsp";
    String urlToAgenda = "../catEmpleados/catEmpleado_Agenda_list.jsp";
    String urlToCuentaEfe = "../catEmpleados/catEmpleado_CuentaEfectivo_list.jsp";

    String paramName = "idUsuario";
    String paramName2 = "idGeocerca";
    parametrosPaginacion+="&inactivos="+buscar_isMostrarSoloActivos;// "idEmpresa="+idEmpresa;
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
                        url: "../catEmpleados/catEmpleados_ajax.jsp",
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
                                            location.href = "../inicio/main.jsp";
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

            <!-- Inicio de Contenido -->
             <div id="">

                <div class="inner">                          
                    
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>
                                        
                      
                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_users.png" alt="icon"/>
                                Promotores 
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                               <%=fmt.dateToStringEspanol(fechaMin)%>
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
                                            <th>Número de Empleado</th>
                                            <th>Nombre Promotor</th>    
                                            <th>Estatus Actual</th>
                                            <th>Incidencia</th>                                            
                                            <th>Check In</th>  
                                            <th>Check Out</th>  
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                        
                                            RegistroCheckInBO registroCheckInBO = new RegistroCheckInBO(user.getConn());
                                            for (Usuarios item:usuariosDto){
                                                try{
                                                    
                                                    DatosUsuario datosUsuario = new DatosUsuarioBO(item.getIdDatosUsuario(),user.getConn()).getDatosUsuario();
                                                    
                                                    //Obtenemos ultimo estatus registrado                                                   
                                                    String nombreEstatus  = "SIN DETALLE";
                                                    try{
                                                                                                                
                                                        EstadoEmpleadoBO estadoEmpleadoBO =  new EstadoEmpleadoBO(item.getIdEstadoEmpleado(),user.getConn());
                                                                                                                                                                      
                                                        nombreEstatus = estadoEmpleadoBO.getEstado().getNombre();
                                                    }catch(Exception e){
                                                        System.out.println("No se encontraron registros con los datos especificado");
                                                    }
                                                    
                                        %>
                                        <tr <%=(item.getIdEstatus()==2)?"style='background: #B0B1B1'":""%> >
                                          
                                            <td><%=item.getIdUsuarios()%></td>
                                            <td><%=item.getNumEmpleado()%></td>
                                            <td><%=datosUsuario.getNombre() + " " + datosUsuario.getApellidoPat() +" "+ datosUsuario.getApellidoMat()%></td>                                                                                     
                                            <td><%=nombreEstatus%></td>
                                            
                                            <%                 
                                                String imagenIncidencia = "";
                                                String titleIncidencia = "";
                                                
                                                RegistroCheckin checkEntradaDto =  null;
                                                RegistroCheckin checkSalidaDto =  null;
                                                try{//cehck in
                                                    checkEntradaDto = registroCheckInBO.findRegistroCheckins(-1, item.getIdUsuarios(), -1, -1," AND ID_TIPO_CHECK = 1 AND DATE(FECHA_HORA) = '" + fmt.formatDateToSQL(fechaChecks)  + "' AND ID_DETALLE_CHECK = 6 " )[0];
                                                            
                                                                                                        
                                                        if(item.getIdHorarioAsignado()>0){


                                                            HorarioUsuario horarioUsuario = null;
                                                            horarioUsuario = new HorarioUsuarioDaoImpl().findByPrimaryKey(item.getIdHorarioAsignado());


                                                            DateManage utilDate =  new DateManage();
                                                            String diaSemanaCheck ="";
                                                            try{
                                                                diaSemanaCheck = utilDate.getDiaSemana(new Date());
                                                            }catch(Exception e){}

                                                            String filtroSem = "  DIA = '"+diaSemanaCheck+"' AND ID_HORARIO = " + item.getIdHorarioAsignado() + " ";

                                                            DetalleHorario[] detalleHorario  = new DetalleHorario[0];                        
                                                            detalleHorario = new DetalleHorarioDaoImpl().findByDynamicWhere(filtroSem , null);

                                                            if(detalleHorario.length>0){//si no tiene horario es sin detalle
                                                                if(detalleHorario[0].getDiaDescanso()==1){//del dia actual
                                                                    imagenIncidencia = "../../images/gespro-asist-03.png";
                                                                    titleIncidencia = "SIN COMENTARIO";
                                                                }else{                                                                
                                                                    if(checkEntradaDto.getIncidencia()== 0){
                                                                        imagenIncidencia = "../../images/gespro-asist-03.png";
                                                                        titleIncidencia = "SIN COMENTARIO";
                                                                    }else if(checkEntradaDto.getIncidencia() == 1){
                                                                        imagenIncidencia = "../../images/gespro-asist-04.png";
                                                                        titleIncidencia = "RETARDO";
                                                                    }else if(checkEntradaDto.getIncidencia() == 2){
                                                                        imagenIncidencia = "../../images/gespro-asist-05.png";  
                                                                        titleIncidencia = "FALTA";
                                                                    }                                                                                                                                
                                                                }                                                               
                                                            }


                                                        }
                                                    
                                                    
                                                }catch(Exception e){
                                                    
                                                    // no ha registrado entrada despues de 3 horas
                                                    
                                                    
                                                    try{
                                                    
                                                        if(item.getIdHorarioAsignado()>0){

                                                            HorarioUsuario horarioUsuario = null;
                                                            horarioUsuario = new HorarioUsuarioDaoImpl().findByPrimaryKey(item.getIdHorarioAsignado());


                                                            DateManage utilDate =  new DateManage();
                                                            String diaSemanaCheck ="";
                                                            try{
                                                                diaSemanaCheck = utilDate.getDiaSemana(new Date());
                                                            }catch(Exception ess){}

                                                            String filtroSem = "  DIA = '"+diaSemanaCheck+"' AND ID_HORARIO = " + item.getIdHorarioAsignado() + " ";

                                                            DetalleHorario[] detalleHorario  = new DetalleHorario[0];                        
                                                            detalleHorario = new DetalleHorarioDaoImpl().findByDynamicWhere(filtroSem , null);

                                                            if(detalleHorario.length>0){//si no tiene horario es sin detalle
                                                                if(detalleHorario[0].getDiaDescanso()==1){
                                                                    imagenIncidencia = "../../images/gespro-asist-03.png";
                                                                    titleIncidencia = "SIN COMENTARIO";
                                                                }else{                                                                
                                                                    
                                                                    SimpleDateFormat printFormat = new SimpleDateFormat("HH:mm:ss");       
                                    
                                                                    String dateCheck = printFormat.format(new Date());
                                                                    String datehorario = printFormat.format(detalleHorario[0].getHoraEntrada());


                                                                    long nowHorario = printFormat.parse(datehorario).getTime();
                                                                    long horaCheck = printFormat.parse(dateCheck).getTime(); 

                                                                    long diff = nowHorario - horaCheck;
                                                                    long diffMinutes = diff / (60 * 1000);
                                                                    System.out.println("dif-----jsp---------> " + diffMinutes);
                                                                    long tiempoTolerancia = detalleHorario[0].getTolerancia();
                                                                    
                                                                    if(diffMinutes<0){//obtener abs
                                                                        diffMinutes = diffMinutes * -1;
                                                                    }
                                                                    
                                                                    if((diffMinutes) > 180){// 3 horas despues de la entrada para considerarse falta //del dia actual
                                                                        imagenIncidencia = "../../images/gespro-asist-05.png";  
                                                                        titleIncidencia = "FALTA";
                                                                    }
                                                                    
                                                                }                                                               
                                                            }


                                                        }                                                        
                                                        
                                                    }catch(Exception es){
                                                        
                                                    }
                                                    System.out.println("No se encontraron registros con los datos especificados check in");
                                                    
                                                }
                                                
                                                try{//check out                                                    
                                                    checkSalidaDto = registroCheckInBO.findRegistroCheckins(-1, item.getIdUsuarios(), -1, -1," AND ID_TIPO_CHECK = 2 AND DATE(FECHA_HORA) = '" + fmt.formatDateToSQL(fechaChecks) + "' AND ID_DETALLE_CHECK = 4 " )[0];
                                                                                                       
                                                }catch(Exception e){
                                                    System.out.println("No se encontraron registros con los datos especificados check out");
                                                }
                                                                                    
                                                
                                                 %>                                           
                                                 <td><img title="<%=titleIncidencia%>"  class="help" src="<%=imagenIncidencia%>"/></td>
                                                
                                            <td><%=checkEntradaDto!=null?checkEntradaDto.getFechaHora():"SIN REGISTRO"%></td>
                                            <td><%=checkSalidaDto!=null?checkSalidaDto.getFechaHora():"SIN REGISTRO"%></td>
                                            
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
                                                    
                                                    <%
                                                      
                                                       //Revisamos si el pomotor tiene asignada al menos una ruta 
                                                        RutaDaoImpl rutasDaoImpl = new RutaDaoImpl(user.getConn());
                                                        Ruta[] rutas = rutasDaoImpl.findWhereIdUsuarioEquals(item.getIdUsuarios());

                                                    if(rutas.length>=1){
                                                    %>
                                                        &nbsp;&nbsp;
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
                                    
                           
                            
                        </div>
                    </div>

                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                Búsqueda Avanzada &dArr;
                            </span>
                        </div>
                        <br class="clear"/>
                        <div class="content" style="display: block;">
                            <form action="../inicio/main.jsp" id="search_form_advance" name="search_form_advance" method="post">
                                <p>                                    
                                    <label>Día:</label>
                                    <input maxlength="15" type="text" id="q_fh_min" name="q_fh_min" style="width:100px"
                                            value="" readonly/>
                                    <!--&nbsp; &laquo; &mdash; &raquo; &nbsp;
                                    <label>Hasta:</label>
                                    <input maxlength="15" type="text" id="q_fh_max" name="q_fh_max" style="width:100px"
                                        value="" readonly/>-->
                                </p>
                                <br/>                      
                               
                                
                             
                                <p>
                                <label>Promotor:</label><br/>
                                <select id="q_idvendedor" name="q_idvendedor" class="flexselect">
                                    <option></option>
                                    <%= new UsuariosBO().getUsuariosByRolHTMLCombo(idEmpresa, RolesBO.ROL_GESPRO, 0) %>                                     
                                </select>
                                </p>
                                <br/>
                                                             
                                <p>
                                <label>Estado:</label><br/>
                                <select id="q_idestatusUsuario" name="q_idestatusUsuario" class="flexselect">
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
                                    
                                    
                                    
                                    
                </div>

                
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
