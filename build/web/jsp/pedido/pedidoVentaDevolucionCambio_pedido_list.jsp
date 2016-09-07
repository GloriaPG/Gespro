<%-- 
    Document   : pedidoVentaDevolucionCambio_pedido_list
    Created on : 26/06/2015, 11:21:19 AM
    Author     : leonardo
--%>

<%@page import="java.lang.Math.*"%>
<%@page import="com.tsp.gespro.jdbc.SgfensPedidoProductoDaoImpl"%>
<%@page import="com.tsp.gespro.dto.SgfensPedidoProducto"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="com.tsp.gespro.report.ReportBO"%>
<%@page import="com.tsp.gespro.bo.SGEstatusPedidoBO"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.util.DateManage"%>
<%@page import="com.tsp.gespro.dto.SgfensPedido"%>
<%@page import="com.tsp.gespro.bo.SGPedidoBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
//Verifica si el usuario tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
} else {
    
    NumberFormat formatMoneda = new DecimalFormat("###,###,###,##0.00");
    
    String buscar = request.getParameter("q")!=null? new String(request.getParameter("q").getBytes("ISO-8859-1"),"UTF-8") :"";
    String buscar_idcliente = request.getParameter("q_idcliente")!=null?request.getParameter("q_idcliente"):"";
    String buscar_idvendedor = request.getParameter("q_idvendedor")!=null?request.getParameter("q_idvendedor"):"";
    String buscar_idestatuspedido = request.getParameter("q_idestatuspedido")!=null?request.getParameter("q_idestatuspedido"):"";
    
    ////--
    String buscar_idestatus = request.getParameter("q_idestatus")!=null?request.getParameter("q_idestatus"):"";//viene del list de "pedidoVentaDevolucionCambio_list"
    if(!buscar_idestatus.trim().equals("")){
        if(buscar_idestatus.equals("1"))
            buscar_idestatuspedido = "1";
        else if(buscar_idestatus.equals("2"))
            buscar_idestatuspedido = "2";
        else if(buscar_idestatus.equals("3"))
            buscar_idestatuspedido = "3";
        else if(buscar_idestatus.equals("4"))
            buscar_idestatuspedido = "4";
    }
    ////--
    
    String buscar_adeudo = request.getParameter("q_adeudo")!=null? new String(request.getParameter("q_adeudo").getBytes("ISO-8859-1"),"UTF-8") :""; 
    String buscar_consigna = request.getParameter("q_consigna")!=null? new String(request.getParameter("q_consigna").getBytes("ISO-8859-1"),"UTF-8") :""; 
    
    String buscar_folio = request.getParameter("q_folio")!=null? new String(request.getParameter("q_folio").getBytes("ISO-8859-1"),"UTF-8") :"";
    
    String buscar_fechamin = "";
    String buscar_fechamax = "";
    Date fechaMin=null;
    Date fechaMax=null;
    String strWhereRangoFechas="";
    String filtroBusqueda = "";
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
            strWhereRangoFechas="(CAST(FECHA_ENTREGA AS DATE) BETWEEN '"+buscar_fechamin+"' AND '"+buscar_fechamax+"')";
            if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
            parametrosPaginacion+="q_fh_max="+DateManage.formatDateToNormal(fechaMax)+"&q_fh_min="+DateManage.formatDateToNormal(fechaMin);
        }
        if (fechaMin!=null && fechaMax==null){
            strWhereRangoFechas="(FECHA_ENTREGA  >= '"+buscar_fechamin+"')";
            if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
            parametrosPaginacion+="q_fh_min="+DateManage.formatDateToNormal(fechaMin);
        }
        if (fechaMin==null && fechaMax!=null){
            strWhereRangoFechas="(FECHA_ENTREGA  <= '"+buscar_fechamax+"')";
            if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
            parametrosPaginacion+="q_fh_max="+DateManage.formatDateToNormal(fechaMax);
        }
    }
    
    if(!buscar_folio.trim().equals("")){
        filtroBusqueda += " AND (FOLIO_PEDIDO_MOVIL ='" + buscar_folio + "' OR FOLIO_PEDIDO = '"+ buscar_folio.trim() + "') ";
    }
    
    //Si es vendedor, filtramos para solo mostrar sus pedidos
/*    if (user.getUser().getIdRoles() == RolesBO.ROL_OPERADOR)
        filtroBusqueda += " AND ID_USUARIO_VENDEDOR ='" + user.getUser().getIdUsuarios() + "' ";
*/        
    if (!buscar.trim().equals("")){
        filtroBusqueda += " AND (FOLIO_PEDIDO LIKE '%" + buscar + "%' OR FOLIO_PEDIDO_MOVIL LIKE '%" + buscar + "%')";
        if(!parametrosPaginacion.equals(""))
                        parametrosPaginacion+="&";
        parametrosPaginacion+="q="+buscar;
    }
    
    if (!buscar_idcliente.trim().equals("")){
        filtroBusqueda += " AND ID_CLIENTE='" + buscar_idcliente +"' ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_idcliente="+buscar_idcliente;
    }else{
        filtroBusqueda += " AND ID_CLIENTE>=0 ";
    }
    
    if (!buscar_idvendedor.trim().equals("")){
        filtroBusqueda += " AND ID_USUARIO_VENDEDOR='" + buscar_idvendedor +"' ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_idvendedor="+buscar_idvendedor;
    }
    
    if (!buscar_idestatuspedido.trim().equals("")){
        filtroBusqueda += " AND ID_ESTATUS_PEDIDO='" + buscar_idestatuspedido +"' ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_idestatuspedido="+buscar_idestatuspedido;
    }
        
    if(buscar_idestatus.trim().equals("5")){
        filtroBusqueda += " AND ID_PEDIDO IN (SELECT ID_PEDIDO FROM sgfens_pedido_devolucion_cambio WHERE ID_TIPO = 1)";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_idestatus="+buscar_idestatus;
        
    }else if(buscar_idestatus.trim().equals("6")){
        filtroBusqueda += " AND ID_PEDIDO IN (SELECT ID_PEDIDO FROM sgfens_pedido_devolucion_cambio WHERE ID_TIPO = 2)";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_idestatus="+buscar_idestatus;
    }
    
    if (!strWhereRangoFechas.trim().equals("")){
        filtroBusqueda += " AND " + strWhereRangoFechas;
    }
    
        
    if (buscar_adeudo.trim().equals("0")){       
        filtroBusqueda += " AND (TOTAL - SALDO_PAGADO) <= 0 ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_adeudo="+buscar_adeudo;
    }else if(buscar_adeudo.trim().equals("1")){       
        //filtroBusqueda += " AND (TOTAL - SALDO_PAGADO) > 0 ";
        filtroBusqueda += " AND (saldo_pagado + (CASE WHEN  BONIFICACION_DEVOLUCION<0 THEN BONIFICACION_DEVOLUCION ELSE 0 END)) < total ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_adeudo="+buscar_adeudo;
    }
    
    if (buscar_consigna.trim().equals("0")){        
        filtroBusqueda += " AND CONSIGNA = 0 ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_consigna="+buscar_consigna;
    }else if(buscar_consigna.trim().equals("1")){       
        //filtroBusqueda += " AND (TOTAL - SALDO_PAGADO) > 0 ";
        filtroBusqueda += " AND CONSIGNA = 1 ";
        if(!parametrosPaginacion.equals(""))
                    parametrosPaginacion+="&";
        parametrosPaginacion+="q_consigna="+buscar_consigna;
    }
       
       
    
    int idPedido = -1;
    try{ idPedido = Integer.parseInt(request.getParameter("idPedido")); }catch(NumberFormatException e){}
    
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
    
     SGPedidoBO pedidoBO = new SGPedidoBO(user.getConn());
     SgfensPedido[] pedidoDto = new SgfensPedido[0];
     try{
         limiteRegistros = pedidoBO.findCantidadPedido(idPedido, idEmpresa , 0, 0, filtroBusqueda);
         
          if (!buscar.trim().equals(""))
             registrosPagina = limiteRegistros;
         
         paginasTotales = (int)Math.ceil(limiteRegistros / registrosPagina);

        if(paginaActual<0)
            paginaActual = 1;
        else if(paginaActual>paginasTotales)
            paginaActual = paginasTotales;

        pedidoDto = pedidoBO.findPedido(idPedido, idEmpresa,
                ((paginaActual - 1) * (int)registrosPagina), (int)registrosPagina,
                filtroBusqueda);

     }catch(Exception ex){
         ex.printStackTrace();
     }
     
     
     // Totales 
            double ventasTotales = 0;
            double pagosTotales = 0;
            double adeudosTotales  = 0;
            double comisionTotalVendedor = 0;
            double utilidadTotal = 0;
            SgfensPedido[] pedidoDtoTotales = new SgfensPedido[0];
            pedidoDtoTotales = pedidoBO.findPedido(idPedido, idEmpresa , 0, 0, filtroBusqueda);
                                        
            for (SgfensPedido item:pedidoDtoTotales){
                
                int cantidadProductos = 0;
                double comisionVendedor = 0;
                double utilidadNeta = 0;                                                   
                double ventaTotal = 0;
                double adeudo = 0;
                
                
                if(item.getIdEstatusPedido()!=3 || buscar_idestatuspedido.equals("3")){
                    
                
                    ventasTotales += item.getTotal();
                    pagosTotales += item.getSaldoPagado();
                    adeudosTotales  += (item.getTotal()- item.getSaldoPagado());



                    double costoVentaProducto = 0;
                    if(item.getBonificacionDevolucion()<0){
                        ventasTotales += Math.abs(item.getBonificacionDevolucion());
                        adeudosTotales  += Math.abs(item.getBonificacionDevolucion());
                    }


                    try{                                  
                        SgfensPedidoProducto[] spp = new SgfensPedidoProductoDaoImpl(user.getConn()).findWhereIdPedidoEquals(item.getIdPedido());
                        cantidadProductos = spp.length;
                        for(SgfensPedidoProducto product : spp){
                            comisionVendedor += ( product.getPorcentajeComisionEmpleado() * 0.01 * product.getSubtotal() );
                            costoVentaProducto += (product.getCostoUnitario() * product.getCantidad() );// + comisionVendedor);
                        }
                        comisionTotalVendedor += comisionVendedor;
                    }catch(Exception e){}

                    if(item.getBonificacionDevolucion()>0){
                       utilidadNeta = (item.getTotal() - costoVentaProducto - comisionVendedor);
                       ventaTotal = item.getTotal();
                       adeudo = item.getTotal() - item.getSaldoPagado();
                    }else{
                       utilidadNeta = ((item.getTotal() + Math.abs(item.getBonificacionDevolucion())) - costoVentaProducto - comisionVendedor);
                       ventaTotal = item.getTotal() + Math.abs(item.getBonificacionDevolucion());
                       adeudo = (item.getTotal() + Math.abs(item.getBonificacionDevolucion())) - item.getSaldoPagado();
                    }



                    utilidadTotal += utilidadNeta;
                    
                }
                
            }
     
     
     ///
     
     
     
     /*
    * Datos de catálogo
    */
    String urlTo = "../pedido/pedido_form.jsp";
    String paramName = "idPedido";
    //String parametrosPaginacion="";// "idEmpresa="+idEmpresa;
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
            
            function editarPedido(idPedido){
                if(idPedido>=0){
                    $.ajax({
                        type: "POST",
                        url: "pedido_ajax.jsp",
                        data: { mode: '7', id_pedido : idPedido },
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
                               location.href = "pedido_form.jsp?acc=2&idPedido="+idPedido+"&pagina="+"<%=paginaActual%>";
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
            
            
            function facturar(idPedido){
                if(idPedido>=0){
                    $.ajax({
                        type: "POST",
                        url: "pedido_ajax.jsp",
                        data: { mode: '22', id_pedido : idPedido },
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
                               location.href = "../cfdi_factura/cfdi_factura_form.jsp";
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
            
            function confirmarCancelarPedido(idPedido, folioPedido){
                apprise('¿Esta seguro que desea cancelar el pedido con Folio '+folioPedido+'?', {'verify':true, 'animate':true, 'textYes':'Si', 'textNo':'No'}, 
                    function(r){
                        if(r){
                            // Usuario dio click 'Yes'
                            cancelarPedido(idPedido);
                        }
                });
                
            }
            
            function cancelarPedido(idPedido){
                if(idPedido>=0){
                    $.ajax({
                        type: "POST",
                        url: "pedido_ajax.jsp",
                        data: { mode: '23', id_pedido : idPedido },
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
                               location.href = "pedido_list.jsp?idPedido="+idPedido;
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
            
            function confirmarEntregaPedido(idPedido, folioPedido){
                apprise('¿Esta seguro que desea marcar como entregado el pedido con Folio '+folioPedido+'?', {'verify':true, 'animate':true, 'textYes':'Si', 'textNo':'No'}, 
                    function(r){
                        if(r){
                            // Usuario dio click 'Yes'
                            marcarEntregaPedido(idPedido);
                        }
                });
                
            }
            
            function marcarEntregaPedido(idPedido){
                if(idPedido>=0){
                    $.ajax({
                        type: "POST",
                        url: "pedido_ajax.jsp",
                        data: { mode: '24', id_pedido : idPedido },
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
                               location.href = "pedido_list.jsp?idPedido="+idPedido;
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
    <body class="nobg">
        <div class="content_wrapper" style="width: 99%;">

            <!-- Inicio de Contenido -->
            <div>

                <div class="inner">
                    <!--<h1>Cuentas por Cobrar (Comprobantes Fiscales)</h1>-->
                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>
                    
                    <!--<br class="clear"/>-->
                    
                    <div class="onecolumn">
                        <!--
                        <div class="header">
                            <span>
                                <img src="../../images/icon_cxc.png" alt="icon"/>
                                CxC Comprobantes Fiscales (Facturas)
                            </span>                            
                        </div>
                        <br class="clear"/>
                        -->
                        <div class="content">
                            <form id="form_data" name="form_data" action="" method="post">
                                <table class="data" width="100%" cellpadding="0" cellspacing="0">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Folio</th>
                                            <th>Ver</th>
                                            <th>Vendedor</th>                    
                                            <th>Cliente</th>
                                            <th>Fecha Entrega</th>
                                            <th>Estado</th>
                                            <th>Cantidad Productos</th>
                                            <th>Días Crédito</th>
                                            <th>Venta Total</th>
                                            <th>Pagado</th>
                                            <th>Adeudo</th>
                                            <th>Comisión Vendedor</th>
                                            <th>Utilidad</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                        
                                            
                                            Date hoy = new Date();//fecha de hoy
                                            final long MILLSECS_POR_DAY = 24 * 60 * 60 * 1000; //Milisegundos al día 
                                            for (SgfensPedido item:pedidoDto){
                                                
                                                try{
                                                    DatosUsuario datosUsuarioVendedor = new UsuarioBO(item.getIdUsuarioVendedor()).getDatosUsuario();
                                                    Cliente cliente = null;
                                                    try{ cliente = new ClienteBO(item.getIdCliente(),user.getConn()).getCliente(); }catch(Exception ex){}
                                                    
                                                    //recuperamos el ultimo abono del pedido para ver cuantos dias han transcurrido del ultimo pago que se considera como días de crédito.
                                                    long diasDeCredito = 0;
                                                    /*if(item.getTotal() > (item.getAdelanto() + item.getSaldoPagado()) ){//validamos si aun existe monto por pagar, para calcular los dias de crédito
                                                        //obtenemos el ultimo abono del pedido:
                                                        try{
                                                            SgfensCobranzaAbono abono = new SGCobranzaAbonoBO(user.getConn()).findCobranzaAbono(0, 0, 0, 1, " AND ID_PEDIDO = " + item.getIdPedido())[0];
                                                            diasDeCredito = (hoy.getTime() - abono.getFechaAbono().getTime())/MILLSECS_POR_DAY;
                                                        }catch(Exception e){//si no hay un abono aun, calculamos los dias transcurridos de la fecha realizada del pedido al día de hoy
                                                            diasDeCredito = (hoy.getTime() - item.getFechaPedido().getTime())/MILLSECS_POR_DAY;
                                                        }
                                                    }*/
                                                    
                                                    //Verificamos la cantidad de productos que tiene el pedido
                                                    int cantidadProductos = 0;
                                                    double comisionVendedor = 0;
                                                    double utilidadNeta = 0;
                                                    double costoVentaProducto = 0;
                                                    double ventaTotal = 0;
                                                    double adeudo = 0;
                                                    
                                                    try{
                                                        SgfensPedidoProducto[] spp = new SgfensPedidoProductoDaoImpl(user.getConn()).findWhereIdPedidoEquals(item.getIdPedido());
                                                        cantidadProductos = spp.length;
                                                        for(SgfensPedidoProducto product : spp){
                                                            comisionVendedor += ( product.getPorcentajeComisionEmpleado() * 0.01 * product.getSubtotal() );
                                                            costoVentaProducto += (product.getCostoUnitario() * product.getCantidad() );// + comisionVendedor);
                                                        }
                                                        //comisionTotalVendedor += comisionVendedor;
                                                    }catch(Exception e){}
                                                    
                                                    
                                                    if(item.getBonificacionDevolucion()>0){
                                                       utilidadNeta = (item.getTotal() - costoVentaProducto - comisionVendedor);
                                                       ventaTotal = item.getTotal();
                                                       adeudo = item.getTotal() - item.getSaldoPagado();
                                                    }else{
                                                       utilidadNeta = ((item.getTotal() + Math.abs(item.getBonificacionDevolucion())) - costoVentaProducto - comisionVendedor);
                                                       ventaTotal = item.getTotal() + Math.abs(item.getBonificacionDevolucion());
                                                       adeudo = (item.getTotal() + Math.abs(item.getBonificacionDevolucion())) - item.getSaldoPagado();
                                                    }
                                                    
                                                    
                                                    
                                                    //utilidadNeta = (item.getTotal() - costoVentaProducto - comisionVendedor);
                                                    //utilidadTotal += utilidadNeta;
                                                    
                                        %>
                                        <tr>
                                            <!--<td><input type="checkbox"/></td>-->
                                            <td><%=item.getIdPedido() %></td>
                                            <td><%=item.getFolioPedido() %></td>
                                            <td>
                                                <a href="../../jsp/reportesExportar/previewPedidoPDF.jsp?idPedido=<%=item.getIdPedido() %>" id="btn_show_cfdi" title="Previsualizar Pedido"
                                                class="modalbox_iframe">
                                                    <img src="../../images/icon_consultar.png" alt="Mostrar Pedido" class="help" title="Previsualizar Pedido"/><br/>
                                                </a>
                                            </td>
                                            <td><%= datosUsuarioVendedor!=null? (datosUsuarioVendedor.getNombre() +" " + datosUsuarioVendedor.getApellidoPat()) :"Sin vendedor asignado" %></td>                                            
                                            <td>
                                                <%
                                                    if (item.getIdCliente()>0 && cliente!=null){
                                                        if(item.getConsigna()==1){
                                                            //Cliente consigna
                                                            out.print(cliente.getNombreComercial()+ " <i>[Cliente Consigna]</i>");
                                                        }else{
                                                            //Cliente
                                                            out.print(cliente.getNombreComercial() + " <i>[Cliente]</i>");
                                                        }
                                                    }else{
                                                        out.print("Sin cliente asignado.");
                                                    }
                                                %>
                                            </td>
                                            <td><%= DateManage.formatDateToNormal(item.getFechaEntrega()) %></td>
                                            <td><%= item.getIdEstatusPedido()==1?"Venta":item.getIdEstatusPedido()==2?"Venta":item.getIdEstatusPedido()==3?"Cancelación":item.getIdEstatusPedido()==4?"Venta":"" %></td>
                                            
                                            <td><%=cantidadProductos%></td>
                                            
                                            <td><%=diasDeCredito%></td>
                                            
                                            <td><%=formatMoneda.format(ventaTotal)%></td>
                                            <td><%=formatMoneda.format(item.getSaldoPagado())%></td>
                                            <td><%=formatMoneda.format(adeudo)%></td>
                                            <td><%=formatMoneda.format(comisionVendedor)%></td>
                                            <td><%=formatMoneda.format(utilidadNeta)%></td>
                                            <td>
                                                
                                                <%if (item.getIdEstatusPedido()!=SGEstatusPedidoBO.ESTATUS_CANCELADO){%>
                                                    <a href="#" onclick="editarPedido(<%=item.getIdPedido()%>);"><img src="../../images/icon_edit.png" alt="editar" class="help" title="Editar" /></a>
                                                    
                                                    &nbsp;&nbsp;
                                                    <% if (item.getIdEstatusPedido()==SGEstatusPedidoBO.ESTATUS_PENDIENTE || item.getIdEstatusPedido()==SGEstatusPedidoBO.ESTATUS_ENTREGADO ) {%>
                                                        <a href="#" onclick="confirmarCancelarPedido(<%=item.getIdPedido()%>,'<%=item.getFolioPedido() %>');"><img src="../../images/icon_delete.png" alt="cancelar" class="help" title="Cancelar" /></a>
                                                    <%}%>
                                                    &nbsp;&nbsp;
                                                    <% if (item.getIdEstatusPedido()==SGEstatusPedidoBO.ESTATUS_PENDIENTE  || item.getIdEstatusPedido()==SGEstatusPedidoBO.ESTATUS_ENTREGADO_PARCIAL ) {%>
                                                        <a href="#" onclick="confirmarEntregaPedido(<%=item.getIdPedido()%>,'<%=item.getFolioPedido() %>');"><img src="../../images/icon_ok.png" alt="entregar" class="help" title="Marcar como Entregado" /></a>
                                                        <%if (item.getConsigna()==0){ %>
                                                        &nbsp;&nbsp;
                                                        <a href="pedido_AsignarPedido_form.jsp?idPedido=<%=item.getIdPedido() %>" id="asignarPedido" title="Asignar Pedido" class="modalbox_iframe">
                                                        <img src="../../images/icon_prospecto.png" alt="Asignar Pedido" class="help" title="Asignar Pedido"/>
                                                        </a>  
                                                    <%  }
                                                    }%>
                                                    <%if (item.getConsigna()==0){ %>
                                                    &nbsp;&nbsp;
                                                    <a href="../pedido/pedido_pedidoLocalizacion.jsp?idPedido=<%=item.getIdPedido() %>"><img src="../../images/icon_movimiento.png" alt="Localización" class="help" title="Localización" /></a>
                                                    <%}%>                                                     
                                                <%}%>
                                                
                                                <!--<a href=""><img src="images/icon_delete.png" alt="delete" class="help" title="Delete"/></a>-->
                                            </td>
                                        </tr>                                      
                                        
                                                                                
                                        <%      }catch(Exception ex){
                                                    ex.printStackTrace();
                                                }
                                            } 
                                        %>
                                        
                                        <tr>
                                            <td colspan="9" style="text-align: right;"><b>Totales:</b></td>
                                            <td style="color: #0000cc; text-align: left;"><%=formatMoneda.format(ventasTotales)%></td>
                                            <td style="color: #0000cc; text-align: left;"><%=formatMoneda.format(pagosTotales)%></td>
                                            <td style="color: #0000cc; text-align: left;"><%=formatMoneda.format(adeudosTotales)%></td>
                                            <td style="color: #0000cc; text-align: left;"><%=formatMoneda.format(comisionTotalVendedor)%></td>
                                            <td style="color: #0000cc; text-align: left;"><%=formatMoneda.format(utilidadTotal)%></td>                                            
                                            <td></td>
                                            <td></td>
                                        </tr>
                                        
                                    </tbody>
                                </table>
                            </form>

                            <!-- INCLUDE OPCIONES DE EXPORTACIÓN-->
                            <!--<//jsp:include page="../include/reportExportOptions.jsp" flush="true">
                                <//jsp:param name="idReport" value="<//%= ReportBO.PEDIDO_REPORT %>" />
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
                            
                        </div>
                    </div>

                </div>

            </div>
            <!-- Fin de Contenido-->
        </div>

        <script>
            $("select.flexselect").flexselect();
        </script>
    </body>
</html>
<%}%>