<%-- 
    Document   : leftContent
    Created on : 19-oct-2012, 19:48:19
    Author     : ISCesarMartinez poseidon24@hotmail.com
--%>



<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.jdbc.EmpresaPermisoAplicacionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.EmpresaPermisoAplicacion"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    EmpresaBO empresaBO = new EmpresaBO(user.getConn());
    EmpresaPermisoAplicacion empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl(user.getConn()).findByPrimaryKey(empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa());

    String verificadorSesionGuiaCerrada = "0";
    try {
        if (session.getAttribute("sesionCerrada") != null) {
            verificadorSesionGuiaCerrada = (String) session.getAttribute("sesionCerrada");
        }
    } catch (Exception e) {
    }
%>
<!-- Begin left panel -->
<a href="javascript:;" id="show_menu">&raquo;</a>
<div id="left_menu">
    <a href="javascript:;" id="hide_menu">&laquo;</a>
    <ul id="main_menu">
        <% if (user.isPermisoVerMenu()) {

        %>
        <li><a href="../../jsp/inicio/main.jsp" id="idInicioLeftContent"><img src="../../images/icon_home.png" alt="Inicio"/>Inicio</a></li>
        <li><a href="../../jsp/catMonitor/monitor.jsp" id="monitor"><img src="../../images/icon_home.png" alt="Inicio"/>Monitor</a></li>


        <li style="position: relative; z-index: 99;">
            <a href="" id="idAdministracionLeftContent"><img src="../../images/icon_admin.png" alt="Administración"/>Administración</a>
            <ul>

                <li><a href="../../jsp/user/perfil.jsp"><img src="../../images/user_male_16.png"/>Mi Perfil</a></li>                                         
                <li><a href="../../jsp/catImagenPersonal/catImagenPersonal_list.jsp"><img src="../../images/icon_imagenPersonal.png"/>Logo</a></li>                        
                <li><a href="../../jsp/catLicencias/catLicencias_list.jsp"><img src="../../images/license.png"/>Licencias</a></li>         
                <li><a href="../../jsp/catUsuarios/catUsuarios_list.jsp"><img src="../../images/icon_users.png"/>Usuarios</a></li>
                <li><a href="../../jsp/catUsuariosMonitor/lista.jsp"><img src="../../images/icon_users.png"/>Usuarios monitor</a></li>
                <li><a href="../../jsp/catSucursales/catSucursales_list.jsp"><img src="../../images/icon_sucursales.png"/>Sucursales</a></li>
                <li><a href="../../jsp/catMonedas/lista.jsp"><img src="../../images/icon_reloj.png"/>Moneda</a></li>
                <li><a href="../../jsp/catZonaHoraria/catZonaHoraria_form.jsp"><img src="../../images/icon_reloj.png"/>Zona Horaria</a></li>
                <li><a href="../../jsp/catCargaManual/catCargaManual_list.jsp"><img src="../../images/icon_excel.png"/>Importar Excel</a></li>
                <li><a href="../../jsp/catConfiguracionCampos/lista.jsp"><img src="../../images/icon_sar_config.png"/>Configuración de campos</a></li>
            </ul>	
        </li>
        
        <li>
            <a href="" id="idAdministracionLeftContent"><img src="../../images/icon_validaXML.png" alt="Proyectos"/>Proyectos</a>
            <ul>
                <li><a href="../../jsp/catProyectos/catProyectos.jsp"><img src="../../images/icon_validaXML.png"/>Ver Proyectos</a></li>
                <li><a href="../../jsp/catCoberturas/catCoberturas_list.jsp"><img src="../../images/camion_icono_16.png"/>Cobertura</a></li>
            </ul>	
        </li>

        <li>
            <a id="idCatalogosLeftContent" href="" ><img src="../../images/icon_pages.png" alt="Catálogos"/>Catálogos</a>
            <ul>                            
                <li><a href="../../jsp/catClientes/catClientes_list.jsp" id="idCatalogosLeftContentCliente" ><img src="../../images/icon_cliente.png"/>Clientes</a></li>                           
                <li><a href="../../jsp/catClientesCategorias/catClientesCategorias_list.jsp" id="idCatalogosLeftContentCategoriaCliente"><img src="../../images/icon_clienteCategoria.png"/>Categoría de Clientes</a></li>                                                                                                                          
                <li><a href="../../jsp/catProspectos/catProspectos_list.jsp" id="idCatalogosLeftContentProspecto"><img src="../../images/icon_prospecto.png"/>Prospectos</a></li>                                                   
                <li><a href="../../jsp/catConceptos/catConceptos_list.jsp" id="idAlmacenLeftContentProductos"><img src="../../images/icon_producto.png"/>Productos</a></li>
                <li><a href="../../jsp/catCategorias/catCategorias_list.jsp" id="idAlmacenLeftContentCategorias"><img src="../../images/icon_categoria.png"/>Categorías</a></li>                               
                <li><a href="../../jsp/catEmbalajes/catEmbalajes_list.jsp" id="idAlmacenLeftContentEmbalaje"><img src="../../images/icon_embalaje.png"/>Embalaje</a></li>                                
                <li><a href="../../jsp/catMarcas/catMarcas_list.jsp" id="idAlmacenLeftContentMarcas"><img src="../../images/icon_marca.png"/>Marcas</a></li>   
                <li><a href="../../jsp/catCompetencias/catCompetencias_list.jsp" id="idCompetenciaLeftContentMarcas"><img src="../../images/icon_proveedor.png"/>Competencia</a></li>   
            </ul>
        </li>                
       <li>
            <a href=""><img src="../../images/icon_ventas.png" alt="Ventas"/>Ventas</a>
            <ul>                            
                <li><a href="../../jsp/pedido/pedido_list.jsp"><img src="../../images/icon_ventas3.png"/>Pedidos</a></li>                            
                <!--<li><a href="../../jsp/catCobranzaAbono/catCobranzaAbono_list.jsp"><img src="../../images/icon_ventas1.png"/>Cobranza</a></li>                           
                <li><a href="../../jsp/catMetasVenta/catMetasVenta_metasActivas_List.jsp"><img src="../../images/proposito.png"/>Metas de Venta</a></li>                           
                <li><a href="../../jsp/catConceptos/catConceptosVendidos_list.jsp"><img src="../../images/icon_producto.png"/>Productos Vendidos</a></li>                            
                <li><a href="../../jsp/cotizacion/cotizacion_list.jsp"><img src="../../images/icon_cotizacion.png"/>Cotizaciones</a></li>                            
                <li><a href="../../jsp/catCobranzaAbono/catCobranzaCorteCaja.jsp"><img src="../../images/corte_caja_icon.png"/>Corte de Caja</a></li>                                                      
                <li><a href="../../jsp/catArqueoCaja/catArqueoCaja_list.jsp"><img src="../../images/coins_icon_16.png"/>Arqueo de Caja</a></li>                            
                <li><a href="../../jsp/catBancos/catDepositosBancarios_list.jsp"><img src="../../images/icon_deposito.png"/>Depósitos Bancarios</a></li>                            
                <li><a href="../../jsp/catDevolucionesCambios/catDevolucionesCambios_list.jsp"><img src="../../images/icon_devCam.png"/>Gestión Devoluciones y Cambios</a></li>                           
                <li><a href="../../jsp/pedido/pedidoVentaDevolucionCambio_list.jsp"><img src="../../images/icon_convert_pedido.png"/>Gestión Ventas, Devoluciones y Cambios</a></li>                            
                <li><a href="../../jsp/catCobranzaAbono/catCobranzaAbono_Referencias_list.jsp"><img src="../../images/Tickets_16.png"/>Referencias</a></li>                            
                <li><a href="../../jsp/catViaEmbarque/catViaEmbarque_list.jsp"><img src="../../images/icon_viaEmbarque.png"/>Vía Embarque</a></li> 
                -->
                <li><a href="../../jsp/catDegustaciones/catDegustaciones_list.jsp"><img src="../../images/cookie_bite.png"/>Degustaciones</a></li>                           
                <!--<li><a href="../../jsp/catEncuestas/catEncustas_list.jsp"><img src="../../images/encuesta.png"/>Encuestas</a></li>-->                           
            </ul>	
        </li>
        
        <!--<li>
            <a id="idAlmacenLeftContent" href=""><img src="../../images/icon_almacen1.png" alt="Almacén"/>Almacén</a>
            <ul>

                <li><a href="../../jsp/catAlmacenes/catAlmacenes_list.jsp" id="idAlmacenLeftContentAlmacenes"><img src="../../images/icon_almacen.png"/>Almacenes</a></li>                               
                <li><a href="../../jsp/catCategorias/catCategorias_list.jsp" id="idAlmacenLeftContentCategorias"><img src="../../images/icon_categoria.png"/>Categorías</a></li>                               
                <li><a href="../../jsp/catEmbalajes/catEmbalajes_list.jsp" id="idAlmacenLeftContentEmbalaje"><img src="../../images/icon_embalaje.png"/>Embalaje</a></li>                                
                <li><a href="../../jsp/catMarcas/catMarcas_list.jsp" id="idAlmacenLeftContentMarcas"><img src="../../images/icon_marca.png"/>Marcas</a></li>                               
                <li><a href="../../jsp/catMovimientos/catMovimientos_list.jsp" id="idAlmacenLeftContentMovimientos"><img src="../../images/icon_movimiento.png"/>Movimientos</a></li>                                
                <li><a href="../../jsp/catConceptos/catConceptos_list.jsp" id="idAlmacenLeftContentProductos"><img src="../../images/icon_producto.png"/>Productos</a></li>                                
                <li><a href="../../jsp/catPaquetes/catPaquetes_list.jsp" id="idAlmacenLeftContentPaquetes"><img src="../../images/icon_paquetes.png"/>Paquetes</a></li>                                
                <li><a href="../../jsp/catServicios/catServicios_list.jsp" id="idAlmacenLeftContentServicios"><img src="../../images/icon_servicio.png"/>Servicios</a></li>                               
                <li><a href="../../jsp/catConceptos/catConceptos_Inventario_list.jsp" id="idAlmacenLeftContentInventario"><img src="../../images/icon_inventario.png"/>Inventario</a></li>
                <li><a href="../../jsp/catConceptosOferta/catConceptos_listCnDscnto.jsp" title="Productos que tienen descuento, solo es reflejado en los dispositivos móviles"><img src="../../images/icon_producto.png"/>Productos con Descuento para Moviles</a></li>                                

            </ul>
        </li> -->


      


        <li>
            <a href="" id="idPretorianoMovilLeftContent"><img src="../../images/icon_phone.png" alt="PretorianoMovil"/>Pretoriano Movil</a>                            
            <ul>
              
                <li><a href="../../jsp/catDispositivosMoviles/catDispositivosMoviles_list.jsp"><img src="../../images/icon_phone.png"/>Dispositivos Moviles</a></li>                                       
                <li><a href="../../jsp/catEmpleados/catEmpleados_list.jsp" id="idPretorianoMovilLeftContentEmpleados"><img src="../../images/icon_users.png"/>Empleados</a></li>                                                                           
                <li><a href="../../jsp/catEmpleados/catEmpleado_Mensajes_form.jsp?acc=mensajeMasivo"><img src="../../images/icon_mensajes.png"/>Mensajes</a></li>                                        
                <li><a href="../../jsp/catEmpleados/catEmpleados_RutaDia.jsp"><img src="../../images/icon_calendar.png"/>Ruta Empleado</a></li>                                                                               
                <li><a href="../../jsp/mapa/mapa_visor.jsp"><img src="../../images/icon_mapa.png"/>Visor de mapa</a></li>   
                <li><a href="../../jsp/mapa/logistica.jsp" id="idPretorianoMovilLeftContentLogistica"><img src="../../images/icon_logistica.png"/>Log&iacute;stica</a></li>
                <li><a href="../../jsp/catSeguimiento/catSeguimiento_list.jsp"><img src="../../images/icon_seguimiento.png"/>Seguimiento</a></li>
                <li><a href="../../jsp/catHorarios/catHorarios_list.jsp"><img src="../../images/clock.png"/>Horarios</a></li>
                <li><a href="../../jsp/catEmpleados/catEmpleados_Registro_list.jsp"><img src="../../images/icon_movimiento.png"/>Bitácora</a></li>
            </ul>	

        <!--<li>
            <a href=""><img src="../../images/clipboard_report_bar_16_ns.png" alt="Reportes"/>Reportes</a>                            
            <ul>                                    
                <li><a href="../../jsp/reporte/reporte_menu.jsp"><img src="../../images/report_gral.png"/>Reportes Generales</a></li> 
            </ul>                            
        </li>-->

        <%}%>
    </ul>

    <br class="clear"/>

    <!-- Begin left panel calendar -->
    <!--<div id="calendar"></div>-->
    <!-- End left panel calendar -->

</div>

<!-- End left panel -->
