<%-- 
    Document   : pedidoDetalleVentaDevCam
    Created on : 24/06/2015, 04:52:29 PM
    Author     : leonardo
--%>

<%@page import="com.tsp.gespro.jdbc.SgfensPedidoProductoDaoImpl"%>
<%@page import="com.tsp.gespro.dto.SgfensPedidoProducto"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.SGPedidoBO"%>
<%@page import="com.tsp.gespro.dto.SgfensPedido"%>
<%@page import="com.tsp.gespro.util.DateManage"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.bo.SGEstatusPedidoBO"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page import="com.tsp.gespro.dto.Concepto"%>
<%@page import="com.tsp.gespro.bo.ConceptoBO"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>

<%@page import="com.tsp.gespro.dto.SgfensPedidoDevolucionCambio"%>
<%@page import="com.tsp.gespro.bo.SgfensPedidoDevolucionCambioBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
//Verifica si el usuario tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
} else {
    
    String buscar = request.getParameter("q")!=null? new String(request.getParameter("q").getBytes("ISO-8859-1"),"UTF-8") :"";
    String parametrosPaginacion = "";
    ///*filtros avanzadas
    String tipoDevCam = request.getParameter("q_tipo")!=null? new String(request.getParameter("q_tipo").getBytes("ISO-8859-1"),"UTF-8") :"";
    String buscar_idvendedor = request.getParameter("q_idvendedor")!=null?request.getParameter("q_idvendedor"):"";
    String buscar_idcliente = request.getParameter("q_idcliente")!=null?request.getParameter("q_idcliente"):"";
    ///*
    
    int idPedido = -1;
    try{ idPedido = Integer.parseInt(request.getParameter("idPedido")); }catch(NumberFormatException e){}
    
    String filtroBusqueda = "";
    if (!buscar.trim().equals(""))
        filtroBusqueda = " ";
    
    ////**
    String buscar_fechamin = "";
    String buscar_fechamax = "";
    Date fechaMin=null;
    Date fechaMax=null;
    String strWhereRangoFechas="";
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
            strWhereRangoFechas="(CAST(FECHA AS DATE) BETWEEN '"+buscar_fechamin+"' AND '"+buscar_fechamax+"')";
            if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
            parametrosPaginacion+="q_fh_max="+DateManage.formatDateToNormal(fechaMax)+"&q_fh_min="+DateManage.formatDateToNormal(fechaMin);
        }
        if (fechaMin!=null && fechaMax==null){
            strWhereRangoFechas="(FECHA  >= '"+buscar_fechamin+"')";
            if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
            parametrosPaginacion+="q_fh_min="+DateManage.formatDateToNormal(fechaMin);
        }
        if (fechaMin==null && fechaMax!=null){
            strWhereRangoFechas="(FECHA  <= '"+buscar_fechamax+"')";
            if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
            parametrosPaginacion+="q_fh_max="+DateManage.formatDateToNormal(fechaMax);
        }
    }
    
    if (!strWhereRangoFechas.trim().equals("")){
        filtroBusqueda += " AND " + strWhereRangoFechas;
    }
    
    
    if (!buscar_idcliente.trim().equals("")){
        filtroBusqueda += " AND ID_PEDIDO IN (SELECT ID_CLIENTE FROM SGFENS_PEDIDO WHERE SGFENS_PEDIDO.ID_CLIENTE ='" + buscar_idcliente +"') ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_idcliente="+buscar_idcliente;
    }
    
    
    if (!buscar_idvendedor.trim().equals("")){
        filtroBusqueda += " AND ID_EMPLEADO = '" + buscar_idvendedor +"' ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_idvendedor="+buscar_idvendedor;
    }
    
    
    if (tipoDevCam.trim().equals("1")){
        System.out.println("ES DEVO");
        filtroBusqueda += " AND ID_TIPO = 1 ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_tipo="+tipoDevCam;
    }else if(tipoDevCam.trim().equals("2")){       
        System.out.println("ES CAMBIO");
        filtroBusqueda += " AND ID_TIPO = 2 ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_tipo="+tipoDevCam;
    }
    ////**
    
    
    int idSgfensPedidoDevolucionCambio = -1;
    try{ idSgfensPedidoDevolucionCambio = Integer.parseInt(request.getParameter("idSgfensPedidoDevolucionCambio")); }catch(NumberFormatException e){}
    
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
    
     SgfensPedidoDevolucionCambioBO sgfensPedidoDevolucionCambioBO = new SgfensPedidoDevolucionCambioBO(user.getConn());
     SgfensPedidoDevolucionCambio[] sgfensPedidoDevolucionCambiosDto = new SgfensPedidoDevolucionCambio[0];
     try{
         limiteRegistros = sgfensPedidoDevolucionCambioBO.findSgfensPedidoDevolucionCambiosAgrupadosTipoFechaPedido(idPedido).length;
         
         if (!buscar.trim().equals(""))
             registrosPagina = limiteRegistros;
         
         paginasTotales = (int)Math.ceil(limiteRegistros / registrosPagina);

        if(paginaActual<0)
            paginaActual = 1;
        else if(paginaActual>paginasTotales)
            paginaActual = paginasTotales;

        sgfensPedidoDevolucionCambiosDto = sgfensPedidoDevolucionCambioBO.findSgfensPedidoDevolucionCambiosAgrupadosTipoFechaPedido(idPedido);

     }catch(Exception ex){
         ex.printStackTrace();
     }
     
     int idComprobanteFiscal = -1;
     try{ idComprobanteFiscal = Integer.parseInt(request.getParameter("idComprobanteFiscal")); }catch(NumberFormatException e){}
     SgfensPedido pedidoDto = null;
     
     SGPedidoBO pedidoBO = null;
     
     String vendedorGralStr ="";
     SgfensPedidoProducto[] sgfensPedidoProductoDto = new SgfensPedidoProducto[0];     
     try{
         if (idPedido>0){
            pedidoBO = new SGPedidoBO(idPedido,user.getConn());
            pedidoDto = pedidoBO.getPedido();
            
            DatosUsuario datosUsuarioVendedorGralDto = new UsuarioBO(pedidoDto.getIdUsuarioVendedor()).getDatosUsuario();
            vendedorGralStr = datosUsuarioVendedorGralDto.getNombre() + " " + datosUsuarioVendedorGralDto.getApellidoPat();
            
            //recuperamos los conceptos del pedido:
            try{sgfensPedidoProductoDto = new SgfensPedidoProductoDaoImpl(user.getConn()).findWhereIdPedidoEquals(idPedido);}catch(Exception ee){}
            
        }
        
     }catch(Exception ex){
         ex.printStackTrace();
     }
     
     /*
    * Datos de catálogo
    */
    String urlTo = "../catSgfensPedidoDevolucionCambios/catSgfensPedidoDevolucionCambios_form.jsp";
    String paramName = "idSgfensPedidoDevolucionCambio";
    //String parametrosPaginacion="";// "idEmpresa="+idEmpresa;
    String filtroBusquedaEncoded = java.net.URLEncoder.encode(filtroBusqueda, "UTF-8");
    
    NumberFormat formatMoneda = new DecimalFormat("$ ###,###,###,##0.00"); 
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
                    <h1>Catálogos</h1>
                    
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
                            <form action="catDevolucionesCambios_list.jsp" id="search_form_advance" name="search_form_advance" method="post">
                                <p>
                                    Por Fecha del Proceso &raquo;&nbsp;&nbsp;
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
                                    <%= new ClienteBO(user.getConn()).getClientesByIdHTMLCombo(idEmpresa, -1," AND ID_ESTATUS<> 2 ") %>
                                </select>
                                </p>
                                <br/>
                                
                                <p>
                                <label>Vendedor:</label><br/>
                                <select id="q_idvendedor" name="q_idvendedor" class="flexselect">
                                    <option></option>
                                    <%= new UsuariosBO(user.getConn()).getUsuariosByHTMLCombo(idEmpresa, -1, "") %> 
                                </select>
                                </p>
                                <br/>
                                
                                
                                
                                <p>
                                    <input type="radio" class="checkbox" id="ambos" name="q_tipo" value="-1" checked> <label for="ambos">Ambos</label>
                                    <input type="radio" class="checkbox" id="devolucion" name="q_tipo" value="1" > <label for="devolucion">Devolución</label>
                                    <input type="radio" class="checkbox" id="cambio" name="q_tipo" value="2" > <label for="cambio">Cambio</label>                                                   
                                </p>    
                                <br/>
                                <div id="action_buttons">
                                    <p>
                                        <input type="button" id="buscar" value="Buscar" onclick="$('#search_form_advance').submit();"/>
                                    </p>
                                </div>
                                
                            </form>
                        </div>
                    </div>
                    
                    <div id="threecolumn" class="threecolumn">
                        <div class="threecolumn_each" style="float: right;">
                                <div class="header">
                                        <span>Datos Financieros de<%=pedidoDto!=null?"l Pedido":""%></span>
                                </div>
                                <br class="clear"/>
                                <div class="content">
                                        <%if (!vendedorGralStr.equals("")){%>
                                            <label>Vendedor: </label>
                                            <%=vendedorGralStr %>
                                            <br/>
                                        <%}%>
                                        <label>Folio de<%=pedidoDto!=null?"l Pedido":"" %>: </label>
                                            <%=pedidoDto!=null?pedidoDto.getFolioPedido():""%>
                                        <br/>
                                        <label>Monto Total: </label>
                                            <%= pedidoDto!=null?(pedidoDto.getBonificacionDevolucion()>0?formatMoneda.format(pedidoDto.getTotal()):formatMoneda.format(pedidoDto.getTotal()+ Math.abs(pedidoDto.getBonificacionDevolucion()))):""%>                                                                                      
                                        <br/>
                                        
                                        <!--<a href="../../jsp/reportesExportar/previewCobranzaEdoCuentaPDF.jsp?idPedido=<%=idPedido %>&idComprobanteFiscal=<%=idComprobanteFiscal %>" id="btn_show_cfdi" title="Edo. Cuenta"
                                                    class="modalbox_iframe" style="float: right;">
                                            <img src="../../images/icon_pdf.png" alt="Mostrar Edo. Cuenta" class="help" title="Edo. Cuenta"/>
                                            Edo. Cuenta (PDF)
                                        </a>-->
                                </div>
                        </div>
                    </div>
                                                    
                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                <img src="../../images/icon_devCam.png" alt="icon"/>
                                Venta
                            </span>
                        </div>
                        <div class="content">                            
                                <table class="data" width="100%" cellpadding="0" cellspacing="0">
                                    <thead>
                                        <tr>
                                            <th>Descripcion</th>                                            
                                            <th>Unidad</th>
                                            <th>Monto</th>                                            
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            for (SgfensPedidoProducto item : sgfensPedidoProductoDto){
                                                try{
                                        %>
                                        <tr>
                                            <td><%=item.getDescripcion()%></td>                                                                                        
                                            <td><%=item.getUnidad()%></td>
                                            <td><%=" $ " +item.getSubtotal()%></td>
                                        </tr>
                                        <%      }catch(Exception ex){
                                                    ex.printStackTrace();
                                                }
                                            } 
                                        %>
                                    </tbody>
                                </table>                            
                        </div>
                        
                        <div class="header">
                            <span>
                                <img src="../../images/icon_devCam.png" alt="icon"/>
                                Devoluciones y Cambios
                            </span>
                           
                        </div>
                        <br class="clear"/>
                        <div class="content">
                            <form id="form_data" name="form_data" action="" method="post">
                                <table class="data" width="100%" cellpadding="0" cellspacing="0">
                                    <thead>
                                        <tr>
                                            <th>Tipo</th>                                            
                                            <th>Motivo Devolución/Cambio</th>
                                            <th>Fecha</th>
                                            <th>Monto Diferencia</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                            for (SgfensPedidoDevolucionCambio item:sgfensPedidoDevolucionCambiosDto){
                                                try{
                                                    Usuarios emp = null;
                                                    //String nombreEmpleado = "";
                                                    try{
                                                    //emp = new EmpleadoBO(item.getIdEmpleado(), user.getConn()).getEmpleado();
                                                    //nombreEmpleado = emp.getNombre() + " " + emp.getApellidoPaterno() + " " + emp.getApellidoMaterno();
                                                    }catch(Exception e){}
                                                    
                                                    Concepto con = null;
                                                    ConceptoBO conBO =  null;
                                                    try{
                                                        conBO = new ConceptoBO(item.getIdConcepto(), user.getConn());
                                                        con = conBO.getConcepto();                                                        
                                                    }catch(Exception e){}
                                                    
                                                    Concepto conEntregado = null;
                                                    try{
                                                        conBO = new ConceptoBO(item.getIdConceptoEntregado(), user.getConn());
                                                        conEntregado = conBO.getConcepto();
                                                    }catch(Exception e){}
                                        %>
                                        <tr <%=(item.getIdEstatus()!=1)?"class='inactive'":""%>>                                                                                   
                                            <!--<td><//%=nombreEmpleado %></td>-->
                                            <!--<td><//%=con!=null?conBO.desencripta(con.getNombre()):""%></td>-->
                                            <td><%=item.getIdTipo()==1?"Devolución":item.getIdTipo()==2?"Cambio":""%></td>                                                                                        
                                            <td><%=(item.getIdClasificacion()==1?"No Solicitado por Cliente":item.getIdClasificacion()==2?"No Vendido":item.getIdClasificacion()==3?(item.getDescripcionClasificacion()!=null?item.getDescripcionClasificacion():""):item.getIdClasificacion()==4?"Producto Caduco":item.getIdClasificacion()==5?"Producto Mal Estado":item.getIdClasificacion()==6?"Solicitado por Cliente":"")%></td>                                            
                                            <td><%=item.getFecha()%></td>
                                            <td><%=(item.getDiferenciaFavor()==1?"-":item.getDiferenciaFavor()==2?"+":"")+" $ " + item.getMontoResultante()%></td>                                             
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