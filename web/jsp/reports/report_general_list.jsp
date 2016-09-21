<%-- 
    Document   : report_general_list
    Created on : 9/09/2016, 10:11:08 AM
    Author     : DXN
--%>

<%@page import="com.tsp.gespro.jdbc.RegistroCheckinDaoImpl"%>
<%@page import="com.tsp.gespro.bo.RelacionClienteVendedorBO"%>
<%@page import="com.tsp.gespro.dto.RegistroCheckin"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.dto.RelacionClienteVendedor"%>
<%@page import="com.tsp.gespro.jdbc.ClienteCategoriaDaoImpl"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.bo.ConceptoBO"%>
<%@page import="com.tsp.gespro.dto.Concepto"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.tsp.gespro.bo.EstanteriaBO"%>
<%@page import="com.tsp.gespro.dto.Estanteria"%>
<%@page import="com.tsp.gespro.dto.ClienteCategoria"%>
<%@page import="com.tsp.gespro.bo.ClienteCategoriaBO"%>
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
    String buscar_idpromotor = request.getParameter("q_idpromotor")!=null?request.getParameter("q_idpromotor"):"";
    String buscar_idproducto = request.getParameter("q_idproducto")!=null?request.getParameter("q_idproducto"):"";
    String buscar_idcliente = request.getParameter("q_idcliente")!=null?request.getParameter("q_idcliente"):"";

    
    String filtroBusqueda = "";
    String parametrosPaginacion = ""; 
    
   

   
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
    if (!buscar_idpromotor.trim().equals("")){
        filtroBusqueda += " AND ID_USUARIO='" + buscar_idpromotor +"' ";
        if(!parametrosPaginacion.equals(""))
                        parametrosPaginacion+="&";
        parametrosPaginacion+="q_idpromotor="+buscar_idpromotor;       
    } 
    if (!buscar_idcliente.trim().equals("")){
        filtroBusqueda += " AND ID_CLIENTE='" + buscar_idcliente +"' ";
        if(!parametrosPaginacion.equals(""))
                        parametrosPaginacion+="&";
        parametrosPaginacion+="q_idcliente="+buscar_idcliente;       
    }
    if (!buscar_idproducto.trim().equals("")){
        filtroBusqueda += " AND ID_CONCEPTO='" + buscar_idproducto +"' ";
        if(!parametrosPaginacion.equals(""))
                        parametrosPaginacion+="&";
        parametrosPaginacion+="q_idproducto="+buscar_idproducto;       
    } 
    
    
    
    //Si es vendedor, filtramos para solo mostrar sus pedidos
/*    if (user.getUser().getIdRoles() == RolesBO.ROL_OPERADOR)
        filtroBusqueda += " AND ID_USUARIO_VENDEDOR ='" + user.getUser().getIdUsuarios() + "' ";
*/        
   
    
    int idEstanteria = -1;
    try{ idEstanteria = Integer.parseInt(request.getParameter("idEstanteria")); }catch(NumberFormatException e){}
    
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
    
    List<Estanteria> estanteriaDto = new ArrayList<Estanteria>();
      try{        
        
         EstanteriaBO estanteriaBO = new EstanteriaBO(user.getConn());
         Estanteria[] estanteriaDto2 = new Estanteria[0];
         estanteriaDto2 = estanteriaBO.findEstanterias(idEstanteria, idEmpresa ,-1,-1,-1, 0, 0, filtroBusqueda);
         limiteRegistros = estanteriaDto2.length;
         
         if (!buscar.trim().equals(""))
             registrosPagina = limiteRegistros;
         
         paginasTotales = (int)Math.ceil(limiteRegistros / registrosPagina);

        if(paginaActual<0)
            paginaActual = 1;
        else if(paginaActual>paginasTotales)
            paginaActual = paginasTotales;
        
        //DESENCRIPTAMOS EL NOMBRE:
        //conceptosDto2 = conceptoBO.conceptoDesencriptarNombre(conceptosDto2);            
        //ORDENAMOS LA LISTA:
        //conceptosDto2 = conceptoBO.conceptoOrdenaListaEnBaseNombre(conceptosDto2);
        
        for(int x = ((paginaActual - 1) * (int)registrosPagina); x <= ((paginaActual) * (int)registrosPagina); x++ ){            
            estanteriaDto.add(estanteriaDto2[x]);
        }
     }catch(Exception ex){
         ex.printStackTrace();
     }
     
     
                                         
     
     
     ///
     
     ClienteCategoriaBO clienteCategoriaBO = new ClienteCategoriaBO(user.getConn());
     ClienteCategoria[] clientesCategorias = clienteCategoriaBO.findClienteCategorias(0, idEmpresa, 0, 0, " AND ID_ESTATUS = 1 ");
     
     /*
    * Datos de catálogo
    */
    String urlTo = "../pedido/pedido_form.jsp";
    String paramName = "idPedido";
    //String parametrosPaginacion="";// "idEmpresa="+idEmpresa;
    String filtroBusquedaEncoded = java.net.URLEncoder.encode(filtroBusqueda, "UTF-8");
    
%>
<!DOCTYPE html>
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
                    <h1>Reporte general</h1>
                    
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
                            <form action="report_general_list.jsp" id="search_form_advance" name="search_form_advance" method="post">
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
                                
                                <p>
                                <label>Promotor:</label><br/>
                                <select id="q_idpromotor" name="q_idpromotor" class="flexselect">
                                    <option></option>
                                    <%= new UsuariosBO(user.getConn()).getUsuariosByHTMLCombo(idEmpresa, -1," AND ID_ESTATUS <> 2 " ) %>
                                </select>
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
                                <label>Producto:</label><br/>
                                <select id="q_idproducto" name="q_idproducto" class="flexselect">
                                    <option></option>
                                    <%= new ConceptoBO(user.getConn()).getConceptosByIdHTMLComboReload(idEmpresa,-1,0,0," AND ID_ESTATUS <> 2 ")%>
                                </select>
                                </p>
                                <br/>

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
                                <img src="../../images/clipboard_report_bar_16_ns.png" alt="icon"/>
                                Registros
                            </span>
                            <div class="switch" style="width:650px">
                                <table width="650px" cellpadding="0" cellspacing="0">
                                        <tbody>
                                                <tr>
                                                    <!--<td style="width: 50px">
                                                    <a href="#" id="consultaMapa" title="Grafica" class="modalbox_iframe">                                           
                                                    <img src="../../images/icon_mapa.png" alt="Gráfica" class="help" title="Mapa de Pedidos"/>    
                                                    </td>-->
                                                    <td>
                                                        <!--
                                                        <div id="search">                                                                
                                                        <form action="report_caducidad_list.jsp" id="search_form" name="search_form" method="get">
                                                                <input type="text" id="q" name="q" title="Buscar nombre del producto" class="" style="width: 300px; float: left; "
                                                                       value="<%=buscar%>"/>
                                                                <input type="image" src="../../images/Search-32_2.png" id="buscar" name="buscar"  value="" style="cursor: pointer; width: 30px; height: 25px; float: left"/>
                                                        </form>
                                                        </div>
                                                        -->
                                                    </td>
                                                    <td class="clear">&nbsp;&nbsp;&nbsp;</td>
                                                    <td>
                                                        <!--
                                                        <input type="button" id="nuevo" name="nuevo" class="right_switch" value="Nuevo Pedido" 
                                                               style="float: right; width: 100px;" onclick="location.href='<%=urlTo%>?acc=1'"/>
                                                        -->
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
                                            <th>Fecha registro</th>
                                            <th>Promotor</th>
                                            <th>Cliente</th>
                                            <th>Sucursal</th>   
                                            <!--<th>Hr entrada</th>
                                            <th>Hr salida</th>-->
                                            <th>Clave producto</th>
                                            <th>Nombre producto</th>  
                                            <th>Unidades anaquel</th>
                                            <th>Precio anaquel</th>
                                            <th>Precio oferta</th>
                                            <th>Unidades almacén</th>
                                            <th>Unidades totales</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                        
                                            EstanteriaBO estanteria = new EstanteriaBO(user.getConn());
                                            SimpleDateFormat hora = new SimpleDateFormat("HH:mm:ss" );
                                            ClienteCategoriaDaoImpl categoriaDaoImpl = new ClienteCategoriaDaoImpl(user.getConn());
                                            RelacionClienteVendedor relacionCliente = null;
                                            Usuarios usuario = null;
                                            ClienteCategoria clienteCategoria = null; 
                                            RegistroCheckin registroCheckEntrada = null;
                                            RegistroCheckin registroCheckSalida = null;
                                            for (Estanteria item:estanteriaDto){
                                                try{
                    
                                        %>
                                        <tr>
                                            <!--<td><input type="checkbox"/></td>-->
                                            <td><%=DateManage.formatDateToNormal(item.getFecha()) %></td>
                                            <%
                                               DatosUsuario datosUsuarioVendedor = new UsuarioBO(item.getIdUsuario()).getDatosUsuario();
                                            %>
                                            <td><%=datosUsuarioVendedor!=null? (datosUsuarioVendedor.getNombre() +" " + datosUsuarioVendedor.getApellidoPat()) :"Sin promotor asignado" %></td>
                                            
                                            <%
                                               Cliente cliente = new ClienteBO(item.getIdCliente(),user.getConn()).getCliente();
                                            %>
                                            <td><%=cliente!=null? (cliente.getNombreComercial()) :"Sin cliente" %></td>
                                            
                                            <%
                                              Empresa empresa = new EmpresaBO(user.getConn()).getEmpresaGenericoByEmpresa(item.getIdEmpresa());
                                            %>
                                            
                                            <td><%=empresa!=null? (empresa.getNombreComercial()) :"Sin empresa" %></td>
                                            <!--
                                            <%
                                            
                                            
                                             relacionCliente =  null;
                                                    usuario = null;
                                                    try{relacionCliente = new RelacionClienteVendedorBO(user.getConn()).findRelacionClienteVendedors(item.getIdCliente(),item.getIdUsuario(),0,0,"")[0];}catch(Exception e){}
                                                    try{usuario = new UsuariosBO(relacionCliente.getIdUsuario(), user.getConn()).getUsuario();}catch(Exception e){}
                                                    try{registroCheckEntrada = new RegistroCheckinDaoImpl(user.getConn()).findByDynamicWhere(" ID_CLIENTE = " +item.getIdCliente() +" AND ID_TIPO_CHECK = 1 ORDER BY FECHA_HORA DESC ", null)[0];}catch(Exception e){}
                                                    try{registroCheckSalida = new RegistroCheckinDaoImpl(user.getConn()).findByDynamicWhere(" ID_CLIENTE = " +item.getIdCliente() +" AND ID_TIPO_CHECK = 2 ORDER BY FECHA_HORA DESC ", null)[0];}catch(Exception e){}
                                        %>
                                            <td><%=registroCheckEntrada!=null?hora.format(registroCheckEntrada.getFechaHora()):""%></td>
                                            <td><%=registroCheckSalida!=null?hora.format(registroCheckSalida.getFechaHora()):"" %></td>
                                            -->
                                            <%
                                              ConceptoBO conceptoBO = new ConceptoBO(user.getConn());
                                              Concepto concepto = conceptoBO.findConceptobyId(item.getIdConcepto());
                                              double unidadesTotal = 0;
                                              double unidadesAnaquel = 0;
                                              double unidadesAlmacen = 0;
                                              unidadesAnaquel = item.getCantidad();
                                              unidadesAlmacen = item.getUnidadesAlmacen();
                                              unidadesTotal = unidadesAnaquel + unidadesAlmacen;
                                              

                                              
                                            %>
                                            <td><%=concepto.getClave()%></td>
                                            <td><%=concepto.getNombre() %></td>
                                            <td><%=unidadesAnaquel %></td>
                                            <td><%=item.getPrecio() %></td>
                                            <td><%=item.getPrecioOferta() %></td>
                                            <td><%=unidadesAlmacen %></td>
                                            <td><%=unidadesTotal %></td>
                                                                       
                                        </tr>                                      
                                        
                                                                                
                                       <%      }catch(Exception ex){
                                                    ex.printStackTrace();
                                                }
                                            } 
                                        %>
                                        
                                        <!--<tr>
                                            <td colspan="9" style="text-align: right;"><b>Totales:</b></td>
                                            <td style="color: #0000cc; text-align: left;"><//%=formatMoneda.format(ventasTotales)%></td>
                                            <td style="color: #0000cc; text-align: left;"><//%=formatMoneda.format(pagosTotales)%></td>
                                            <td style="color: #0000cc; text-align: left;"><//%=formatMoneda.format(adeudosTotales)%></td>
                                            <td style="color: #0000cc; text-align: left;"><//%=formatMoneda.format(comisionTotalVendedor)%></td>
                                            <td style="color: #0000cc; text-align: left;"><//%=formatMoneda.format(utilidadTotal)%></td>                                            
                                            <td></td>
                                            <td></td>
                                        </tr>-->
                                        
                                    </tbody>
                                </table>
                            </form>

                            <!-- INCLUDE OPCIONES DE EXPORTACIÓN-->
                            <!--<//jsp:include page="../include/reportExportOptions.jsp" flush="true">
                                <//jsp:param name="idReport" value="<//%= ReportBO.PEDIDO_REPORT %>" />
                                <//jsp:param name="parametrosCustom" value="<//%= filtroBusquedaEncoded %>" />
                            <///jsp:include>-->
                            <!-- FIN INCLUDE OPCIONES DE EXPORTACIÓN-->
                             <jsp:include page="../include/reportExportOptions.jsp" flush="true">
                                <jsp:param name="idReport" value="<%= ReportBO.GENERAL_REPORT %>" />
                                <jsp:param name="parametrosCustom" value="<%= filtroBusquedaEncoded %>" />
                            </jsp:include>                            
                            
                                    
                            <jsp:include page="../include/listPagination.jsp">
                                <jsp:param name="paginaActual" value="<%=paginaActual%>" />
                                <jsp:param name="numeroPaginasAMostrar" value="<%=numeroPaginasAMostrar%>" />
                                <jsp:param name="paginasTotales" value="<%=paginasTotales%>" />
                                <jsp:param name="url" value="<%=request.getRequestURI() %>" />
                                <jsp:param name="parametrosAdicionales" value="<%=parametrosPaginacion%>" />
                            </jsp:include>
                            
                            <input type="button" id="regresar" value="Regresar" onclick="history.back();"/>
                            
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
