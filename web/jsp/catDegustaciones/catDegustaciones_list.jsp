<%-- 
    Document   : catDegustaciones_list
    Created on : 3/11/2015, 01:47:44 PM
    Author     : HpPyme
--%>


<%@page import="com.tsp.gespro.report.ReportBO"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.util.DateManage"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.bo.ConceptoBO"%>
<%@page import="com.tsp.gespro.dto.Concepto"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page import="com.tsp.gespro.dto.Degustacion"%>
<%@page import="com.tsp.gespro.dto.Marca"%>
<%@page import="com.tsp.gespro.bo.DegustacionBO"%>
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
    /*if (!buscar.trim().equals(""))
        filtroBusqueda = " AND (NOMBRE LIKE '%" + buscar + "%' OR DESCRIPCION LIKE '%" +buscar+"%')";*/
    
    int idDesgustacion = -1;
    try{ idDesgustacion = Integer.parseInt(request.getParameter("idDesgustacion")); }catch(NumberFormatException e){}
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
    String buscar_idcliente = request.getParameter("q_idcliente")!=null?request.getParameter("q_idcliente"):"";
    String buscar_idvendedor = request.getParameter("q_idvendedor")!=null?request.getParameter("q_idvendedor"):"";
    String buscar_idproducto = request.getParameter("q_idproducto")!=null?request.getParameter("q_idproducto"):"";
    
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
            strWhereRangoFechas="(CAST(FECHA_APERTURA AS DATE) BETWEEN '"+buscar_fechamin+"' AND '"+buscar_fechamax+"')";
            if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
            parametrosPaginacion+="q_fh_max="+DateManage.formatDateToNormal(fechaMax)+"&q_fh_min="+DateManage.formatDateToNormal(fechaMin);
        }
        if (fechaMin!=null && fechaMax==null){
            strWhereRangoFechas="(FECHA_APERTURA  >= '"+buscar_fechamin+"')";
            if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
            parametrosPaginacion+="q_fh_min="+DateManage.formatDateToNormal(fechaMin);
        }
        if (fechaMin==null && fechaMax!=null){
            strWhereRangoFechas="(FECHA_APERTURA  <= '"+buscar_fechamax+"')";
            if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
            parametrosPaginacion+="q_fh_max="+DateManage.formatDateToNormal(fechaMax);
        }
    }
    
    if (!strWhereRangoFechas.trim().equals("")){
        filtroBusqueda += " AND " + strWhereRangoFechas;
    }
    if (!buscar_idcliente.trim().equals("")){
        filtroBusqueda += " AND ID_CLIENTE='" + buscar_idcliente +"' ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_idcliente="+buscar_idcliente;
    } 
    if (!buscar_idvendedor.trim().equals("")){
        filtroBusqueda += " AND ID_USUARIO='" + buscar_idvendedor +"' ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_idvendedor="+buscar_idvendedor;
    }
    if (!buscar_idproducto.trim().equals("")){
        filtroBusqueda += " AND ID_CONCEPTO='" + buscar_idproducto +"' ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="buscar_idproducto="+buscar_idproducto;
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
    
     DegustacionBO degustacionBO = new DegustacionBO(user.getConn());
     Degustacion[] degustacionDto = new Degustacion[0];
     try{
         limiteRegistros = degustacionBO.findDegustaciones(idDesgustacion, idEmpresa , 0, 0, filtroBusqueda).length;
         
         if (!buscar.trim().equals(""))
             registrosPagina = limiteRegistros;
         
         paginasTotales = (int)Math.ceil(limiteRegistros / registrosPagina);

        if(paginaActual<0)
            paginaActual = 1;
        else if(paginaActual>paginasTotales)
            paginaActual = paginasTotales;

        degustacionDto = degustacionBO.findDegustaciones(idDesgustacion, idEmpresa,
                ((paginaActual - 1) * (int)registrosPagina), (int)registrosPagina,
                filtroBusqueda);

     }catch(Exception ex){
         ex.printStackTrace();
     }
     
     /*
    * Datos de catálogo
    */
    String urlTo = "../catMarcas/catMarcas_form.jsp";
    String paramName = "idDesgustacion";
    //String parametrosPaginacion="";// "idEmpresa="+idEmpresa;
    String filtroBusquedaEncoded = java.net.URLEncoder.encode(filtroBusqueda, "UTF-8");    
    
    String urlResponse = "/ServletDegustacionPDF";
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
    <body>
        <div class="content_wrapper">

            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>

            <!-- Inicio de Contenido -->
            <div id="content">

                <div class="inner">
                    <h1>Ventas</h1>
                    
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
                            <form action="catDegustaciones_list.jsp" id="search_form_advance" name="search_form_advance" method="post">
                                <p>
                                    Por Fecha&raquo;&nbsp;&nbsp;
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
                                <label>Cliente:</label><br/>
                                <select id="q_idcliente" name="q_idcliente" class="flexselect">
                                    <option></option>
                                    <%= new ClienteBO(user.getConn()).getClientesByIdHTMLCombo(idEmpresa, -1," AND ID_ESTATUS <> 2 " ) %>
                                </select>
                                </p>
                                <br/>
                                
                                <p>
                                <label>Vendedor:</label><br/>
                                <select id="q_idvendedor" name="q_idvendedor" class="flexselect">
                                    <option></option>
                                    <%= new UsuariosBO().getUsuariosByRolHTMLCombo(idEmpresa, RolesBO.ROL_GESPRO, 0) %>
                                </select>
                                </p>
                                <br/>
                                
                                <p>
                                <label>Producto:</label><br/>
                                <select id="q_idproducto" name="q_idproducto" class="flexselect">
                                    <option></option>
                                    <%= new ConceptoBO(user.getConn()).getConceptosByIdHTMLCombo(idEmpresa) %>
                                </select>
                                </p>
                                <br/>
                                
<!--                                <p>
                                    <input type="radio" class="checkbox" id="sinAdeudo" name="q_adeudo" value="0" > <label for="sinAdeudo">Sin Adeudo</label>
                                    <input type="radio" class="checkbox" id="conAdeudo" name="q_adeudo" value="1" > <label for="conAdeudo">Con Adeudo</label>                                                   
                                </p>    
                                <br/>
                                <p>
                                    <input type="radio" class="checkbox" id="noConsigna" name="q_consigna" value="0" > <label for="noConsigna">Clientes Normales</label>
                                    <input type="radio" class="checkbox" id="siConsigna" name="q_consigna" value="1" > <label for="siConsigna">En Consigna</label>                                                   
                                </p>    
                                <br/>
-->
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
                                <img src="../../images/cookie_bite.png" alt="icon"/>
                                Degustaciones
                            </span>
                            <div class="switch" style="width:500px">
                                <table width="500px" cellpadding="0" cellspacing="0">
                                    <tbody>
                                            <tr>
                                                
                                                
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
                                            <th>Promotor</th>
                                            <th>Cliente</th>  
                                            <th>Hr inicio</th>
                                            <th>Hr Termino</th>
                                            <th>Tiempo Degusatción (min) </th>
                                            <th>Piezas Degustadas</th>
                                            <th>Ver</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                             SimpleDateFormat fecha = new SimpleDateFormat("dd/MM/yyyy" );
                                             SimpleDateFormat hora = new SimpleDateFormat("HH:mm:ss" );
                                            for (Degustacion item:degustacionDto){
                                                try{
                                                    
                                                    String nombreProm = "";
                                                    try{
                                                        DatosUsuario datosUsuario = new UsuarioBO(item.getIdUsuario()).getDatosUsuario();
                                                        
                                                        if(datosUsuario!=null){
                                                            nombreProm += datosUsuario.getNombre()!=null?datosUsuario.getNombre():"";
                                                            nombreProm += " " +(datosUsuario.getApellidoPat()!=null?datosUsuario.getApellidoPat():"");
                                                            nombreProm += " " +(datosUsuario.getApellidoMat()!=null?datosUsuario.getApellidoMat():"");
                                                        }
                                                                
                                                    }catch(Exception e){}
                                                    
                                                    
                                                    Cliente cliente = null;
                                                    try{ cliente = new ClienteBO(item.getIdCliente(),user.getConn()).getCliente(); }catch(Exception ex){}
                                                    
                                                    /*Concepto conceptoDto = null;
                                                   
                                                    try{
                                                        ConceptoBO conceptoBO = new ConceptoBO(item.getIdConcepto(),user.getConn());
                                                        conceptoDto = conceptoBO.getConcepto();
                                                    }catch(Exception e){}*/
                                                    
                                                    
                                                    long inicio = item.getFechaApertura().getTime();
                                                    long fin = item.getFechaCierre().getTime(); 

                                                    long diff = fin - inicio;
                                                    long diffMinutes = diff / (60 * 1000);
                                                    
                                                    
    
                                        %>
                                        <tr <%=(item.getIdEstatus()==2)?"class='inactive'":""%>>                                           
                                            <td><%=item.getIdDegustacion()%></td>
                                            <td><%=fecha.format(item.getFechaApertura())%></td>
                                            <td><%=nombreProm%></td>
                                            <td><%=cliente!=null?cliente.getNombreComercial():"Desconocido"%> 
                                            <!--<td><%//=conceptoDto.getNombreDesencriptado()%></td> -->
                                            <td><%=hora.format(item.getFechaApertura())%></td>
                                            <td><%=hora.format(item.getFechaCierre())%></td>                
                                            <td><%=diffMinutes<0?0:diffMinutes%></td>
                                            <td><%=item.getCantidad()-item.getCantidadCierre()%></td>
                                            <td>
                                                <a href="<%=request.getContextPath()+urlResponse+"?idDegustacion="+item.getIdDegustacion()%>" id="btn_show_cfdi" title="Previsualizar"
                                                class="">
                                                    <img src="../../images/icon_consultar.png" alt="Mostrar Pedido" class="help" title="Descarga Reporte"/><br/>
                                                </a>
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
                            <jsp:include page="../include/reportExportOptions.jsp" flush="true">
                                <jsp:param name="idReport" value="<%= ReportBO.DEGUSTACION_REPORT %>" />
                                <jsp:param name="parametrosCustom" value="<%= filtroBusquedaEncoded %>" />
                            </jsp:include>         
                            
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