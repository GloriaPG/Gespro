<%-- 
    Document   : catCargaManual_list
    Created on : 28/08/2015, 03:47:16 PM
    Author     : HpPyme
--%>


<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.config.Configuration"%>
<%@page import="com.tsp.gespro.bo.CargaExcelBO"%>
<%@page import="com.tsp.gespro.dto.CargaXls"%>
<%@page import="java.util.StringTokenizer"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el usuario tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
} else {
    
    String buscar = request.getParameter("q")!=null? new String(request.getParameter("q").getBytes("ISO-8859-1"),"UTF-8") :"";
    
    
    
    String FechaInicioHisto = request.getParameter("fechaInicioHistoria")!=null? new String(request.getParameter("fechaInicioHistoria").getBytes("ISO-8859-1"),"UTF-8") :"";
    String FechaFinHisto = request.getParameter("fechaFinHistoria")!=null? new String(request.getParameter("fechaFinHistoria").getBytes("ISO-8859-1"),"UTF-8") :"";
    
    String dia = "";
    String mes = "";
    String ano = "";
    String FechaInicioHisto2 = "";
    String FechaFinHisto2 = "";
    StringTokenizer tokens = null;
    try{
        if(!FechaInicioHisto.equals("")){
                    tokens = new StringTokenizer(FechaInicioHisto,"/");
                            dia = tokens.nextToken().intern();
                            mes = tokens.nextToken().intern();
                            ano = tokens.nextToken().intern();
                            FechaInicioHisto2 = ano+"-"+mes+"-"+dia;

        }
    }catch(Exception e){
        FechaInicioHisto = "";
    }
    try{
        if(!FechaFinHisto.equals("")){
            tokens = new StringTokenizer(FechaFinHisto,"/");
                            dia = tokens.nextToken().intern();
                            mes = tokens.nextToken().intern();
                            ano = tokens.nextToken().intern();
                            FechaFinHisto2 = ano+"-"+mes+"-"+dia;
        }
    }catch(Exception e){
        FechaFinHisto = "";
    }    
    ////
    
    String cadenaParametrosPaginacion = "";

    
    String filtroBusqueda = "";
    if (!buscar.trim().equals("")){
        filtroBusqueda = " AND (PLACAS LIKE '%" + buscar + "%' OR MARCA LIKE '%" +buscar+"%' OR MODELO LIKE '%" +buscar+"%' OR CODIGO LIKE '%" +buscar+"%')";
         cadenaParametrosPaginacion+="buscar="+buscar;
    }
    
    //FILTRO POR FECHA
    if (!FechaInicioHisto.trim().equals("")&&!FechaFinHisto.trim().equals("")){
        filtroBusqueda += " AND (FECHA BETWEEN '"+ FechaInicioHisto2 + "' AND '" + FechaFinHisto2 + " 23:59:59.99')";
        if(!cadenaParametrosPaginacion.equals(""))
                cadenaParametrosPaginacion+="&";
        cadenaParametrosPaginacion+="fechaInicioHistoria="+FechaInicioHisto+"&fechaFinHistoria="+FechaFinHisto;
    }else if (!FechaInicioHisto.trim().equals("")&&FechaFinHisto.trim().equals("")){
        filtroBusqueda += " AND FECHA > '"+ FechaInicioHisto2 + "'";
        if(!cadenaParametrosPaginacion.equals(""))
                cadenaParametrosPaginacion+="&";
        cadenaParametrosPaginacion+="fechaInicioHistoria="+FechaInicioHisto;
    }else if (FechaInicioHisto.trim().equals("")&&!FechaFinHisto.trim().equals("")){
        filtroBusqueda += " AND FECHA < '"+ FechaFinHisto2 + " 23:59:59.99'";
        if(!cadenaParametrosPaginacion.equals(""))
                cadenaParametrosPaginacion+="&";
        cadenaParametrosPaginacion+="fechaFinHistoria="+FechaFinHisto;
    }else{
        filtroBusqueda = filtroBusqueda; 
    }
    //////
    
    
    long idEmpresa = user.getUser().getIdEmpresa();
    
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
    
     CargaExcelBO cargaExcelBO = new CargaExcelBO(user.getConn());
     CargaXls[] cargaExcelDto = new CargaXls[0];
     try{
         limiteRegistros = cargaExcelBO.findCargasExcel(-1, idEmpresa , 0, 0, filtroBusqueda).length;
         
         if (!buscar.trim().equals(""))
             registrosPagina = limiteRegistros;
         
         paginasTotales = (int)Math.ceil(limiteRegistros / registrosPagina);

        if(paginaActual<0)
            paginaActual = 1;
        else if(paginaActual>paginasTotales)
            paginaActual = paginasTotales;

        cargaExcelDto = cargaExcelBO.findCargasExcel(-1, idEmpresa,
                ((paginaActual - 1) * (int)registrosPagina), (int)registrosPagina,
                filtroBusqueda);

     }catch(Exception ex){
         ex.printStackTrace();
     }                                               
     
     
     /*
    * Datos de catálogo
    */
    String urlTo = "../catCargaManual/catCargaManual_form.jsp";    
    String urlTo2 = "catCargaManual_logDescripcion.jsp";
    String paramName = "idCargaManual";
    String parametrosPaginacion=cadenaParametrosPaginacion;// "idEmpresa="+idEmpresa;
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
            
            function muestraLog(icon,log){
                apprise( "<center><img src='../../images/"+icon+ "' alt='icon' /></center><br>"+log,{'animate':true}, function(r){ });
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
                            <p>
                            <form action="catCargaManual_list.jsp" id="search_form_advance" name="search_form_advance" method="post">                                                            
                                    <p>
                                    Por Fecha &raquo;&nbsp;&nbsp;
                                    <label>Desde:</label>
                                    <input maxlength="15" type="text" id="q_fh_min" name="q_fh_min" style="width:100px"
                                            value="" readonly/>
                                    &nbsp; &laquo; &mdash; &raquo; &nbsp;
                                    <label>Hasta:</label>
                                    <input maxlength="15" type="text" id="q_fh_max" name="q_fh_max" style="width:100px"
                                        value="" readonly/>
                                </p>
                                <br/>                                  
                                <div id="action_buttons">
                                    <p>
                                        <input type="button" id="buscar" value="Buscar" onclick="$('#search_form_advance').submit();"/>
                                    </p>
                                </div>
                            </form>
                            </p>  
                            <br/>
                        </div>
                   </div>
                    

                    <div class="onecolumn">  
                        <div class="header">
                            <span>
                                <img src="../../images/icon_excel.png" alt="icon"/>
                                Importa Datos
                            </span>
                            <div class="switch" style="width:70%">                                
                            
                                <table width="100%" cellpadding="0" cellspacing="0">
                                        <tbody>
                                                <tr>  
                                                    <td>
                                                        <input type="button" id="nuevo" name="nuevo" class="right_switch" value="Subir Archivo" 
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
                                            <th>Fecha</th>
                                            <th>Archivo</th> 
                                            <th>Tipo</th>
                                            <th>Usuario</th>
                                            <th>Estatus Carga</th>
                                            <th>Acciones</th>                                           
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                        
                                            UsuarioBO usuBO;
                                            DatosUsuario usuDto =  new DatosUsuario();
                                           
                                            for (CargaXls item:cargaExcelDto){
                                                try{
                                            
                                                    String icon ="";     
                                                    String logAnimate ="";  
                                                  

                                                    if(item.getLogText()!=null){
                                                            if(item.getLogText().equals("Carga realizada sin errores.")){  
                                                                icon = "correcto.png";
                                                                logAnimate="<center><h4>"+item.getLogText()+"</h4></center>";
                                                            }else{ 
                                                                icon = "error.png";   
                                                                logAnimate+="<center><h4>Carga realizada con errores.</h4></center>";
                                                                logAnimate+=item.getLogText().replace("'","-");
                                                            }
                                                    }
                                                    
                                                    
                                                    usuDto = new UsuarioBO(item.getIdUsuario()).getDatosUsuario();
                                                    String nombreUser = "";
                                                    nombreUser += usuDto.getNombre()!=null?usuDto.getNombre():"";
                                                    nombreUser += " " + (usuDto.getApellidoPat()!=null?usuDto.getApellidoPat():"");
                                                    nombreUser += " " + (usuDto.getApellidoMat()!=null?usuDto.getApellidoMat():"");
                                        %>
                                        <tr>                                           
                                            <td><%=item.getIdCarga()%></td>
                                            <td><%=item.getFecha()%></td>
                                            <td><%=item.getNombreArchivo()%></td>
                                            <td><%=item.getIdTipoCarga()==1?"PRODUCTOS":item.getIdTipoCarga()==2?"CLIENTES":"OTRO"%></td>
                                            <td><%=nombreUser%></td>                                            
                                            <td><%=item.getIdEstatusCarga()==1?"CARGA COMPLETA":item.getIdEstatusCarga()==2?"CARGA INCOMPLETA (CON ERRORES)":item.getIdEstatusCarga()==3?"OTRO":""%></td>
                                            <td> 
                                                <a onclick="muestraLog('<%=icon%>','<%=logAnimate%>')" ><img src="../../images/log_error.png" alt="Log Errores" class="help" title="Log Errores"/></a>
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
        <script>
            mostrarCalendario();
            $("select.flexselect").flexselect();
        </script>    

    </body>
</html>
<%}%>
