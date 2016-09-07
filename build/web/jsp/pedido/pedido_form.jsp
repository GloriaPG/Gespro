<%-- 
    Document   : pedido_form
    Created on : 13-dic-2012, 19:18:28
    Author     : ISCesarMartinez
--%>

<%@page import="com.tsp.gespro.util.StringManage"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.SGEstatusPedidoBO"%>
<%@page import="com.tsp.gespro.util.DateManage"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page import="com.tsp.gespro.bo.ConceptoBO"%>
<%@page import="com.tsp.gespro.dto.SgfensPedido"%>
<%@page import="com.tsp.gespro.bo.SGPedidoBO"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<jsp:useBean id="pedidoSesion" scope="session" class="com.tsp.gespro.sesion.PedidoSesion"/>
<%
//Verifica si el proveedor tiene acceso a este topico
if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
    response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
    response.flushBuffer();
} else {
    
        int paginaActual = 1;
        try{
            paginaActual = Integer.parseInt(request.getParameter("pagina"));
        }catch(Exception e){}

        int idEmpresa = user.getUser().getIdEmpresa();
        
        /*
         * Parámetros
         */
        int idPedido = 0;
        try {
            idPedido = Integer.parseInt(request.getParameter("idPedido"));
        } catch (NumberFormatException e) {
        }

        /*
         *   1 = nuevo
         *   2 = editar/consultar
         *   
         */
        String mode = request.getParameter("acc") != null ? request.getParameter("acc") : "";
        
        SGPedidoBO pedidoBO = new SGPedidoBO(user.getConn());
        SgfensPedido pedidoDto = null;
        
        Cliente clienteDto = null;
        UsuarioBO usuario_vendedorBO = null;
        DatosUsuario usuario_vendedorDatos =  null;
        if (idPedido > 0){
            pedidoBO = new SGPedidoBO(idPedido,user.getConn());
            pedidoDto = pedidoBO.getPedido();
            
            clienteDto = new ClienteBO(pedidoDto!=null?pedidoDto.getIdCliente():-1,user.getConn()).getCliente();
            usuario_vendedorBO = new UsuarioBO(pedidoDto.getIdUsuarioVendedor());
            usuario_vendedorDatos = usuario_vendedorBO.getDatosUsuario();
        }
        
        ConceptoBO conceptoBO = new ConceptoBO(user.getConn());
        
        boolean isPedidoEditable = true;
        if (pedidoDto!=null){
            if (pedidoDto.getIdComprobanteFiscal()>0 || pedidoDto.getIdEstatusPedido()==SGEstatusPedidoBO.ESTATUS_ENTREGADO 
                || pedidoDto.getIdEstatusPedido()==SGEstatusPedidoBO.ESTATUS_CANCELADO ){
                isPedidoEditable= false;
            }
        }

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
            
            //Usar en caso de que los select usen libreria jquery flexselect para poder usar los eventos focus,etc.. 
            var postnameFlexSelect='_flexselect';
            var sugerenciaPrecio = 0;
            
            function iniciarFlexSelect(){
                $("#id_cliente").flexselect({
                    jsFunction:  function(id) { selectCliente(id); }
                });

                $("#producto_select").flexselect({
                    jsFunction:  function(id) { selectProducto(id); }
                });

                $("#servicio_select").flexselect({
                    jsFunction:  function(id) { selectServicio(id); }
                });

                $("select.flexselect").flexselect();
            }
            
            //****---------------------------------------INICIALIZACION
            
            $(document).ready(function() {
                recargarSelectClientes();
                
                recuperarListados();
                <%=(mode.equals("1")?"nuevaPedido();":"")%>
            });
            
            function recuperarListados(){
                recargarListaProducto();
                recargarListaServicio();
                //recargarListaImpuestos();
            }
            
            function recalcularTotales(){
                recargarListaImpuestos();
                calculaDescuento();
                //calculaTotal();
            }
            
            function activarFancyBox(){
                $('.modalbox_iframe').fancybox({
                        padding: 0, 
                        titleShow: false, 
                        overlayColor: '#333333', 
                        overlayOpacity: .5,
                        'type': 'iframe',
                        'autoScale':   true
                });
            }
            
            function nuevaPedido(){
                $.ajax({
                    type: "POST",
                    url: "pedido_ajax.jsp",
                    data: { mode: '6' },
                    beforeSend: function(objeto){
                        $("#action_buttons").fadeOut("slow");
                        $("#ajax_loading").html('<center><img src="../../images/ajax_loader2.gif" alt="Cargando.." /><br/>Procesando...</center>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("--EXITO-->", 0)>0){
                           //$("#ajax_loading").html(datos);
                           $("#ajax_loading").fadeOut("slow");
                           $("#action_buttons").fadeIn("slow");
                           recuperarListados();
                           $('#descuento_tasa').val(0);
                       }else{
                           $("#ajax_loading").html(datos);
                           $("#action_buttons").fadeIn("slow");
                       }
                    }
                });
            }
            
            //****--------------------------------------- FIN INICIALIZACION
            
            //****---------------------------------GUARDAR
            function enviarYgrabar(){
                if(validar(0)){
                    var correoCliente = $("#cliente_correo").val();
                    var correos = correoCliente;
                    
                    apprise("¿Correos electrónicos a los que se enviará el pedido (separar por coma ,)?", 
                        {'input':correos, 'animate':true}, function(r){
                            
                            if(r) {
                                //alert (r);
                                 grabar(r);
                            }
                            
                    });
                }
            }
            
            function grabar(listaCorreos){
                
                idCliente = $("#id_cliente").val();
                descuentoMotivo = $("#descuento_motivo").val();
                coment = $("#comentarios").val();
                tipoMoneda = $("#tipo_moneda").val();
                
                idEstatus = $("#id_estatus").val();
                pedidoIdCFD = $("#pedido_id_cfd").val();
                pedidoAdelanto = $("#pedido_adelanto").val();
                saldoPagado = $("#pedido_saldo_pagado").val();
                fechaEntrega = $("#pedido_fecha_entrega").val();
                fechaTentativaPago = $("#pedido_fecha_pago").val();
                ventaConsigna = $("#ventaConsigna").val();
                idViaEmbarquePedido = $("#idViaEmbarquePedido").val();
                tipo_pedido = $("#tipo_pedido").val();
                
                
                if(validar(0)){
                    $.ajax({
                        type: "POST",
                        url: "pedido_ajax.jsp",
                        data: { mode: '19' , id_cliente : idCliente, descuento_motivo : descuentoMotivo,
                                comentarios : coment, tipo_moneda : tipoMoneda , 
                                lista_correos : listaCorreos ,
                                id_estatus : idEstatus, pedido_id_cfd : pedidoIdCFD, pedido_adelanto : pedidoAdelanto,
                                pedido_saldo_pagado : saldoPagado, pedido_fecha_entrega: fechaEntrega,
                                pedido_fecha_tentativa_pago : fechaTentativaPago , ventaConsigna: ventaConsigna, idViaEmbarquePedido : idViaEmbarquePedido, tipo_pedido : tipo_pedido},
                            //$("#frm_action").serialize(),
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#ajax_loading").html('<center><img src="../../images/ajax_loader2.gif" alt="Cargando.." /><br/>Procesando...</center>');
                            $("#ajax_loading").fadeIn("slow");
                            $.scrollTo('#inner',800);
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               $("#ajax_message").html(datos);
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").fadeIn("slow");
                               apprise('<center><img src=../../images/info.png> <br/>'+ datos +'</center>',{'animate':true},
                                    function(r){
                                        location.href="../pedido/pedido_list.jsp?pagina="+"<%=paginaActual%>";
                                });
                           }else{
                               $("#ajax_loading").fadeOut("slow");
                               $("#ajax_message").html(datos);
                               $("#ajax_message").fadeIn("slow");
                               $("#action_buttons").fadeIn("slow");
                               apprise('<center><img src=../../images/warning.png> <br/>'+ datos +'</center>',{'animate':true});
                           }
                        }
                    });
                }
                
            }
            
            function validar(mode){
                if(jQuery.trim($("#id_cliente").val())<=0 ){
                    apprise('<center><img src=../../images/warning.png> <br/>El dato "Cliente"  es requerido</center>',{'animate':true});
                    return false;
                }
                return true;
            }
            
            //****---------------------------------FIN GUARDAR
            
            
            //****---------------------------------PRODUCTOS
            
            function selectProductoFromPopupCategoria(idProducto, nombreProducto){
                //alert('Producto seleccionado de categorias: ' + idProducto + " " + nombreProducto);
                selectProducto(idProducto);
                
                //Como se usa flexselect se usan las siguientes 2 opciones
                $("#producto_select").val(idProducto);
                $('#producto_select'+postnameFlexSelect).val(nombreProducto);
                //En caso de no usa flexselect, y ser un select básico se usa la siguiente opción
                //$("#producto_select option[value="+idProducto+"]").attr("selected",true);
            }
            
            function selectProducto(idProducto){
                //alert("idProducto: " + idProducto);
                if(idProducto>0){
                    idCliente = $("#id_cliente").val();
                    if(idCliente>=-1){
                    
                        $.ajax({
                            type: "POST",
                            url: "pedido_ajax.jsp",
                            data: { mode: '1', id_producto_select: idProducto,idCliente : idCliente },
                                //$("#frm_action").serialize(),
                            beforeSend: function(objeto){
                                $("#action_buttons").fadeOut("slow");
                                $("#div_producto_ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                                $("#div_producto_ajax_loading").fadeIn("slow");
                            },
                            success: function(datos){
                                if(datos.indexOf("--EXITO-->", 0)>0){
                                   strJSON = $.trim(datos.replace('<!--EXITO-->',''));

                                   arrayRespuesta=eval('(' + strJSON + ')');
                                   //$('#producto_unidad').val(arrayRespuesta["unidadProductoCompra"]);
                                   //$('#producto_precio').val(arrayRespuesta["precio"]);
                                   $('#producto_descripcion').val(arrayRespuesta["descripcion"]);

                                   var options_precio = '';

                                   //creamos opciones para combo de precios
                                   //options_precio += '<option value="0"></option>';
                                   if($("#ventaConsigna").is(":checked")){
                                       options_precio += '<option value="0">0 [Consigna]</option>';
                                    }else{
                                       options_precio += '<option value="' + arrayRespuesta["precio"] + '">' + arrayRespuesta["precio"] + ' [Unitario/Menudeo]</option>';
                                       options_precio += '<option value="' + arrayRespuesta["precioMedioMayoreo"] + '">' + arrayRespuesta["precioMedioMayoreo"] + ' [Medio Mayoreo]</option>';
                                       options_precio += '<option value="' + arrayRespuesta["precioMayoreo"] + '">' + arrayRespuesta["precioMayoreo"] + ' [Mayoreo]</option>';
                                       options_precio += '<option value="' + arrayRespuesta["precioDocena"] + '">' + arrayRespuesta["precioDocena"] + ' [Docena]</option>';
                                       options_precio += '<option value="' + arrayRespuesta["precioEspecial"] + '">' + arrayRespuesta["precioEspecial"] + ' [Especial]</option>';
                                    }




                                   //alert('-->' + options_precio);

                                   $("#producto_precio").html(options_precio);

                                   selectProductoLimpiar();
                                   $("#div_producto_ajax_loading").fadeOut("slow");
                                   $("#action_buttons").fadeIn("slow");
                               }else{
                                   $("#div_producto_ajax_loading").html(datos);
                                   $("#action_buttons").fadeIn("slow");
                               }
                            }
                        });
                    
                        //obtenemos existencia de alamcenes
                        //$('#almacen_ref').attr('href','../../jsp/includeProductoSelect/almacen_select_form.jsp?mode=1&idProducto='+idProducto);
                        
                    }else{
                         apprise('<center><img src=../../images/warning.png> <br/>'+ "Selecciona primero un Cliente" +'</center>',{'animate':true});
                         $('#producto_select'+postnameFlexSelect).val('');
                    }
                        
                }
            }
            function selectProductoLimpiar(){                
                $('#producto_cantidad').val('');
                $('#producto_monto').val('');
                $('#unidad_select'+postnameFlexSelect).val('');
                //$('#unidad_select'+postnameFlexSelect).focus();
            }
            function selectProductoCalcularMonto(){   
                
                    productoId = $('#labelSugerido').empty();
                              
                    var cantidad = getFloatFromInput($('#producto_cantidad'));
                    var precio = getFloatFromInput($('#producto_precio'));
                    var monto = (precio * cantidad).toFixed(2);
                    //alert('precio: ' + precio + ' cantidad: ' + cantidad + ' monto: ' + monto);
                    $('#producto_monto').val(monto);
                   
            }
            
            function sugerirPrecio(){
                if(sugerenciaPrecio <= 0 ){
                    productoId = $('#producto_select').val();
                    productoCantidad = $('#producto_cantidad').val();

                    if(productoId > 0){                     
                        $.ajax({
                            type: "POST",
                            url: "pedido_ajax.jsp",
                            data: { mode: '25', producto_id : productoId, 
                                producto_cantidad : productoCantidad},
                                //$("#frm_action").serialize(),
                            beforeSend: function(objeto){
                                $("#action_buttons").fadeOut("slow");
                                $("#div_producto_ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                                $("#div_producto_ajax_loading").fadeIn("slow");
                            },
                            success: function(datos){

                                if(datos.indexOf("--EXITO-->", 0)>0){                                              
                                   var indexLlave = datos.trim().indexOf(">");
                                   var indexPto = datos.trim().indexOf("<",1);                               
                                   var precioSugerido = datos.trim().substr(indexLlave + 1 ,indexPto - (indexLlave + 3));                               
                                   $('#producto_precio').val(precioSugerido);
                                   selectProductoCalcularMonto();
                                   $('#producto_precio').val(precioSugerido);
                                   $("#div_producto_ajax_loading").fadeOut("slow");

                                   $("#labelSugerido").empty();
                                   $("#labelSugerido").append("Precio Sugerido");
                                   $("#labelSugerido").fadeIn("slow");

                               }else{
                                   $("#div_producto_ajax_loading").html(datos);
                                   $("#action_buttons").fadeIn("slow");
                                   
                               }
                            }
                        });                 
                    }
                }else{
                    selectProductoCalcularMonto();
                }
                
            }
            
            function addProducto(){
                productoId = $('#labelSugerido').empty();                
                sugerenciaPrecio = 0;
                productoId = $('#producto_select').val();
                unidadId = $('#unidad_select').val();
                unidadText = $('#unidad_select'+postnameFlexSelect).val();
                //unidadText = $('#unidad_select option:selected').text();
                    //alert('unidad ' + unidadText);
                productoPrecio = $('#producto_precio').val();
                productoCantidad = $('#producto_cantidad').val();
                productoMonto = $('#producto_monto').val();
                //almacenId = $('#almacen_select').val();
                almacenId = 0;
               
                if (validarAddProducto(productoId,productoCantidad,productoMonto,unidadId,almacenId)){
                    if(productoId>0){
                        $.ajax({
                            type: "POST",
                            url: "pedido_ajax.jsp",
                            data: { mode: '2', producto_id : productoId, 
                                producto_cantidad : productoCantidad, producto_monto : productoMonto,
                                producto_precio : productoPrecio, producto_unidad: "No Definido", 
                                unidad_id: unidadId },
                                //$("#frm_action").serialize(),
                            beforeSend: function(objeto){
                                $("#action_buttons").fadeOut("slow");
                                $("#div_producto_ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                                $("#div_producto_ajax_loading").fadeIn("slow");
                            },
                            success: function(datos){
                                if(datos.indexOf("--EXITO-->", 0)>0){
                                   $("#div_ajax_productos").html(datos);
                                   selectProductoLimpiar();
                                   $("#div_producto_ajax_loading").fadeOut("slow");
                                   $("#action_buttons").fadeIn("slow");
                                   recalcularTotales();
                               }else{
                                   $("#div_producto_ajax_loading").html(datos);
                                   $("#action_buttons").fadeIn("slow");
                               }
                            }
                        });
                    }
                }
            }
            function validarAddProducto(idProducto,cantidad,monto, idUnidad,almacenId){
                if(idProducto<=0 || cantidad<0 || monto<0 || idUnidad<=0 //|| almacenId <=0
                    || cantidad=="" || monto==""){
                    apprise('<center><img src=../../images/warning.png> <br/>Llene todos los datos requeridos para agregar el producto. Valores mayores a 0</center>',{'animate':true});
                    return false;
                }
                return true;
            }
            
            function subProducto(indexListaProductosSesion){
                if(indexListaProductosSesion>=0){
                    $.ajax({
                        type: "POST",
                        url: "pedido_ajax.jsp",
                        data: { mode: '4', index_lista_producto : indexListaProductosSesion },
                            //$("#frm_action").serialize(),
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#div_producto_ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                            $("#div_producto_ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               $("#div_ajax_productos").html(datos);
                               //selectProductoLimpiar();
                               $("#div_producto_ajax_loading").fadeOut("slow");
                               $("#action_buttons").fadeIn("slow");
                               recalcularTotales();
                           }else{
                               $("#div_producto_ajax_loading").html(datos);
                               $("#action_buttons").fadeIn("slow");
                           }
                        }
                    });
                }
            }
            
            function reiniciarListaProducto(){
                $.ajax({
                    type: "POST",
                    url: "pedido_ajax.jsp",
                    data: { mode: '3' },
                    beforeSend: function(objeto){
                        $("#action_buttons").fadeOut("slow");
                        $("#div_producto_ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                        $("#div_producto_ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("--EXITO-->", 0)>0){
                           $("#div_ajax_productos").html(datos);
                           selectProductoLimpiar();
                           $("#div_producto_ajax_loading").fadeOut("slow");
                           $("#action_buttons").fadeIn("slow");
                           recalcularTotales();
                       }else{
                           $("#div_producto_ajax_loading").html(datos);
                           $("#action_buttons").fadeIn("slow");
                       }
                    }
                });
            }
            
            function recargarListaProducto(){
                $.ajax({
                    type: "POST",
                    url: "pedido_ajax.jsp",
                    data: { mode: '5' },
                    beforeSend: function(objeto){
                        $("#action_buttons").fadeOut("slow");
                        $("#div_producto_ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                        $("#div_producto_ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("--EXITO-->", 0)>0){
                           $("#div_ajax_productos").html(datos);
                           selectProductoLimpiar();
                           $("#div_producto_ajax_loading").fadeOut("slow");
                           $("#action_buttons").fadeIn("slow");
                           recalcularTotales();
                       }else{
                           $("#div_producto_ajax_loading").html(datos);
                           $("#action_buttons").fadeIn("slow");
                       }
                    }
                });
            }
            //****---------------------------------FIN PRODUCTOS
            
            //****---------------------------------SERVICIOS
            function selectServicio(idServicio){
                //alert("idServicio: " + idServicio);
                if(idServicio>0){
                    $.ajax({
                        type: "POST",
                        url: "pedido_ajax.jsp",
                        data: { mode: '13', id_servicio_select: idServicio },
                            //$("#frm_action").serialize(),
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#div_servicio_ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                            $("#div_servicio_ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               strJSONServicio = $.trim(datos.replace('<!--EXITO-->',''));
                               
                               arrayRespuestaServicio=eval('(' + strJSONServicio + ')');
                               //$('#servicio_unidad').val(arrayRespuesta["unidadServicioCompra"]);
                               //$('#servicio_precio').val(arrayRespuesta["precio"]);
                               
                               $('#servicio_descripcion').val(arrayRespuestaServicio["descripcion"]);
                               
                               var options_precio = '';
                               
                               //creamos opciones para combo de precios
                               //options_precio += '<option value="0"></option>';
                               options_precio += '<option selected value="' + arrayRespuestaServicio["precio"] + '">' + arrayRespuestaServicio["precio"] + ' </option>';
                               //options_precio += '<option value="' + arrayRespuesta["precioMayoreo"] + '">' + arrayRespuesta["precioMayoreo"] + ' [may.]</option>';
                               //options_precio += '<option value="' + arrayRespuesta["precioDocena"] + '">' + arrayRespuesta["precioDocena"] + ' [docena]</option>';
                               //options_precio += '<option value="' + arrayRespuesta["precioEspecial"] + '">' + arrayRespuesta["precioEspecial"] + ' [especial]</option>';
                               
                               //alert('-->' + options_precio);
                               
                               $("#servicio_precio").html(options_precio);
                               
                               selectServicioLimpiar();
                               $("#div_servicio_ajax_loading").fadeOut("slow");
                               $("#action_buttons").fadeIn("slow");
                           }else{
                               $("#div_servicio_ajax_loading").html(datos);
                               $("#action_buttons").fadeIn("slow");
                           }
                        }
                    });
                }
            }
            function selectServicioLimpiar(){
                $('#servicio_cantidad').val('');
                $('#servicio_monto').val('');
                //$('#unidad_select'+postnameFlexSelect).val('');
            }
            function selectServicioCalcularMonto(){
                var cantidad = getFloatFromInput($('#servicio_cantidad'));
                var precio = getFloatFromInput($('#servicio_precio'));
                var monto = (precio * cantidad).toFixed(2);
                //alert('precio: ' + precio + ' cantidad: ' + cantidad + ' monto: ' + monto);
                $('#servicio_monto').val(monto);
            }
            
            function addServicio(){
                servicioId = $('#servicio_select').val();
                //unidadId = $('#unidad_select').val();
                //unidadText = $('#unidad_select'+postnameFlexSelect).val();
                //unidadText = $('#unidad_select option:selected').text();
                    //alert('unidad ' + unidadText);
                servicioPrecio = $('#servicio_precio').val();
                servicioCantidad = $('#servicio_cantidad').val();
                servicioMonto = $('#servicio_monto').val();
                if (validarAddServicio(servicioId,servicioCantidad,servicioMonto)){
                    if(servicioId>0){
                        $.ajax({
                            type: "POST",
                            url: "pedido_ajax.jsp",
                            data: { mode: '14', servicio_id : servicioId, 
                                servicio_cantidad : servicioCantidad, servicio_monto : servicioMonto,
                                servicio_precio : servicioPrecio},
                                //$("#frm_action").serialize(),
                            beforeSend: function(objeto){
                                $("#action_buttons").fadeOut("slow");
                                $("#div_servicio_ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                                $("#div_servicio_ajax_loading").fadeIn("slow");
                            },
                            success: function(datos){
                                if(datos.indexOf("--EXITO-->", 0)>0){
                                   $("#div_ajax_servicios").html(datos);
                                   selectServicioLimpiar();
                                   $("#div_servicio_ajax_loading").fadeOut("slow");
                                   $("#action_buttons").fadeIn("slow");
                                   recalcularTotales();
                               }else{
                                   $("#div_servicio_ajax_loading").html(datos);
                                   $("#action_buttons").fadeIn("slow");
                               }
                            }
                        });
                    }
                }
            }
            function validarAddServicio(idServicio,cantidad,monto){
                if(idServicio<=0 || cantidad<0 || monto<0
                    || cantidad=="" || monto==""){
                    apprise('<center><img src=../../images/warning.png> <br/>Llene todos los datos requeridos para agregar el servicio. Valores mayores a 0</center>',{'animate':true});
                    return false;
                }
                return true;
            }
            
            function subServicio(indexListaServiciosSesion){
                if(indexListaServiciosSesion>=0){
                    $.ajax({
                        type: "POST",
                        url: "pedido_ajax.jsp",
                        data: { mode: '16', index_lista_servicio : indexListaServiciosSesion },
                            //$("#frm_action").serialize(),
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#div_servicio_ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                            $("#div_servicio_ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               $("#div_ajax_servicios").html(datos);
                               //selectServicioLimpiar();
                               $("#div_servicio_ajax_loading").fadeOut("slow");
                               $("#action_buttons").fadeIn("slow");
                               recalcularTotales();
                           }else{
                               $("#div_servicio_ajax_loading").html(datos);
                               $("#action_buttons").fadeIn("slow");
                           }
                        }
                    });
                }
            }
            
            function reiniciarListaServicio(){
                $.ajax({
                    type: "POST",
                    url: "pedido_ajax.jsp",
                    data: { mode: '15' },
                    beforeSend: function(objeto){
                        $("#action_buttons").fadeOut("slow");
                        $("#div_servicio_ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                        $("#div_servicio_ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("--EXITO-->", 0)>0){
                           $("#div_ajax_servicios").html(datos);
                           selectServicioLimpiar();
                           $("#div_servicio_ajax_loading").fadeOut("slow");
                           $("#action_buttons").fadeIn("slow");
                           recalcularTotales();
                       }else{
                           $("#div_servicio_ajax_loading").html(datos);
                           $("#action_buttons").fadeIn("slow");
                       }
                    }
                });
            }
            
            function recargarListaServicio(){
                $.ajax({
                    type: "POST",
                    url: "pedido_ajax.jsp",
                    data: { mode: '17' },
                    beforeSend: function(objeto){
                        $("#action_buttons").fadeOut("slow");
                        $("#div_servicio_ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                        $("#div_servicio_ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("--EXITO-->", 0)>0){
                           $("#div_ajax_servicios").html(datos);
                           selectServicioLimpiar();
                           $("#div_servicio_ajax_loading").fadeOut("slow");
                           $("#action_buttons").fadeIn("slow");
                           recalcularTotales();
                       }else{
                           $("#div_servicio_ajax_loading").html(datos);
                           $("#action_buttons").fadeIn("slow");
                       }
                    }
                });
            }
            //****---------------------------------FIN SERVICIOS
            
            
            //****----------------------------------IMPUESTOS
            function addImpuesto(){
                impuestoId = $('#impuesto_select').val();
                
                if (validarAddImpuesto(impuestoId)){
                    if(impuestoId>0){
                        $.ajax({
                            type: "POST",
                            url: "pedido_ajax.jsp",
                            data: { mode: '9', impuesto_id : impuestoId},
                            beforeSend: function(objeto){
                                $("#action_buttons").fadeOut("slow");
                                $("#div_impuesto_ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                                $("#div_impuesto_ajax_loading").fadeIn("slow");
                            },
                            success: function(datos){
                                if(datos.indexOf("--EXITO-->", 0)>0){
                                   $("#div_ajax_impuesto").html(datos);
                                   $("#div_impuesto_ajax_loading").fadeOut("slow");
                                   $("#action_buttons").fadeIn("slow");
                                   calculaTotal();
                               }else{
                                   $("#div_impuesto_ajax_loading").html(datos);
                                   $("#action_buttons").fadeIn("slow");
                               }
                            }
                        });
                    }
                }
            }
            function validarAddImpuesto(idImpuesto){
                if(idImpuesto<=0){
                    apprise('<center><img src=../../images/warning.png> <br/>Seleccione un impuesto válido.</center>',{'animate':true});
                    return false;
                }
                return true;
            }
            
            function subImpuesto(indexListaImpuestosSesion){
                if(indexListaImpuestosSesion>=0){
                    $.ajax({
                        type: "POST",
                        url: "pedido_ajax.jsp",
                        data: { mode: '10', index_lista_impuesto : indexListaImpuestosSesion },
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#div_impuesto_ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                            $("#div_impuesto_ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               $("#div_ajax_impuesto").html(datos);
                               $("#div_impuesto_ajax_loading").fadeOut("slow");
                               $("#action_buttons").fadeIn("slow");
                               calculaTotal();
                           }else{
                               $("#div_impuesto_ajax_loading").html(datos);
                               $("#action_buttons").fadeIn("slow");
                           }
                        }
                    });
                }
            }            
            
            function recargarListaImpuestos(){
                $.ajax({
                    type: "POST",
                    url: "pedido_ajax.jsp",
                    data: { mode: '11' },
                    beforeSend: function(objeto){
                        $("#action_buttons").fadeOut("slow");
                        $("#div_impuesto_ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                        $("#div_impuesto_ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("--EXITO-->", 0)>0){
                           $("#div_ajax_impuesto").html(datos);
                           $("#div_impuesto_ajax_loading").fadeOut("slow");
                           $("#action_buttons").fadeIn("slow");
                           calculaTotal();
                       }else{
                           $("#div_impuesto_ajax_loading").html(datos);
                           $("#action_buttons").fadeIn("slow");
                       }
                    }
                });
            }
            
            //****----------------------------------FIN IMPUESTOS
            
            function calculaDescuento(){
                var tasaDescuento = getFloatFromInput($('#descuento_tasa'));
                if (tasaDescuento>100){
                    tasaDescuento = 0;
                    $('#descuento_tasa').val(tasaDescuento);
                    alert('La tasa de descuento no puede ser mayor a 100%');
                }
                
                if(tasaDescuento>=0){
                    $.ajax({
                        type: "POST",
                        url: "pedido_ajax.jsp",
                        data: { mode: '12', descuento_tasa : tasaDescuento },
                            //$("#frm_action").serialize(),
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#div_descuento_ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                            $("#div_descuento_ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               datos = $.trim(datos.replace('<!--EXITO-->',''));
                               //alert(datos);
                               $('#descuento_importe').val(datos);
                               //selectProductoLimpiar();
                               $("#div_descuento_ajax_loading").fadeOut("slow");
                               $("#action_buttons").fadeIn("slow");
                               recargarListaImpuestos();
                               calculaTotal();
                           }else{
                               $("#div_descuento_ajax_loading").html(datos);
                               $("#action_buttons").fadeIn("slow");
                           }
                        }
                    });
                }
            }
            
            
            function calculaTotal(){
                var total=0;             
                //var subtotalServicios = parseFloat(0);
                
                //Calculamos subtotal (productos + servicios)
                var subtotalProductos = getFloatFromInput($('#producto_subtotal'));
                var subtotalServicios = getFloatFromInput($('#servicio_subtotal'));
                
                var subtotal = (parseFloat(subtotalProductos) + parseFloat(subtotalServicios)).toFixed(2);
                
                var importeDescuento = getFloatFromInput($('#descuento_importe'));
                var subtotalImpuestos_traslados = getFloatFromInput($('#subtotalImpuestos_traslados'));
                var subtotalImpuestos_retenciones = getFloatFromInput($('#subtotalImpuestos_retenciones'));
                //alert('subtotal prod ' + subtotalProductos);
                
                //Total = Subtotal – Descuentos + Impuestos Trasladados – Impuestos Retenidos.
                total = ((subtotal) 
                    - parseFloat(importeDescuento) 
                    + parseFloat(subtotalImpuestos_traslados) 
                    - parseFloat(subtotalImpuestos_retenciones) ).toFixed(2);
                //alert('total ' + total);
                $('#total').val(total);
                
                calculaSaldoConAdelanto();
            }
            
            
            
            //****-----------------ACCIONES DE SELECCION CLIENTE
            
            //Recarga de BD dinámicamente el listado de clientes de la empresa
            function recargarSelectClientes(){
                var tipoClientes; // 1 - Normales  2 - Consigna
                if($("#ventaConsigna").is(":checked")){
                    
                    $("#ventaConsigna").val(1);                    
                    tipoClientes =  2;
                    selectProducto($("#producto_select").val());
                    $("#producto_precio").eComboBox({
                            'allowNewElements' : false,		// default : true
                            'editableElements' : true		// default : true
                    });
                    $("#producto_precio").css("cursor","pointer");
                    selPrecio();
                }else{
                   $("#ventaConsigna").val(0);  
                   tipoClientes =  1;
                   selectProducto($("#producto_select").val());                   
                }
                    
                
                $.ajax({
                    type: "POST",
                    url: "pedido_ajax.jsp",
                    data: { mode: '20', id_cliente : <%= pedidoDto!=null?pedidoDto.getIdCliente():-1 %> , tipoClientes : tipoClientes},
                    beforeSend: function(objeto){
                        $("#action_buttons").fadeOut("slow");
                        $("#ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                        $("#ajax_loading").fadeIn("slow");
                    },
                    success: function(datos){
                        if(datos.indexOf("--EXITO-->", 0)>0){
                            $("#div_select_cliente").html(datos);
                            //selectProductoLimpiar();
                            $("#ajax_loading").fadeOut("slow");
                            $("#action_buttons").fadeIn("slow");
                            iniciarFlexSelect();
                        }else{
                            $("#ajax_loading").html(datos);
                            $("#action_buttons").fadeIn("slow");
                        }
                    }
                });
            }
            
            
            function selectCliente(idCliente){
                //alert('ID cliente elegido: ' + idCliente);
                if(idCliente>0){
                    $.ajax({
                        type: "POST",
                        url: "pedido_ajax.jsp",
                        data: { mode: '21', id_cliente : idCliente },
                            //$("#frm_action").serialize(),
                        beforeSend: function(objeto){
                            $("#action_buttons").fadeOut("slow");
                            $("#ajax_loading").html('<div style=""><img src="../../images/ajax_loader4.gif" alt="Cargando.." /><br/><img src="../../images/ajax_loader.gif" alt="Cargando.." /><br/>Procesando... </div>');
                            $("#ajax_loading").fadeIn("slow");
                        },
                        success: function(datos){
                            if(datos.indexOf("--EXITO-->", 0)>0){
                               strJSONCliente = $.trim(datos.replace('<!--EXITO-->',''));
                               
                               arrayRespuestaCliente=eval('(' + strJSONCliente + ')');
                               
                               $('#cliente_correo').val(arrayRespuestaCliente["correo"]);
                               
                               $("#ajax_loading").fadeOut("slow");
                               $("#action_buttons").fadeIn("slow");
                           }else{
                               $("#ajax_loading").html(datos);
                               $("#action_buttons").fadeIn("slow");
                           }
                        }
                    });
                }else{
                    $('#cliente_correo').val('');
                }
            }
            
            //****-----------------FIN ACCIONES DE SELECCION CLIENTE
            
            //***------------------CALCULO DE ADELANTO Y SALDOS
            
            function calculaSaldoConAdelanto(){
                var total = getFloatFromInput($('#total'));
                var adelanto = getFloatFromInput($('#pedido_adelanto'));
                var saldo = total;
                
                <% 
                    //Si es un pedido nuevo
                    if (pedidoDto==null && mode.equals("1")){ 
                %>
                    //Adelanto no puede ser mayor a total
                    if (parseFloat(adelanto) > parseFloat(total)){
                        $('#pedido_adelanto').val(0);
                        adelanto = 0;
                        alert('El adelanto no puede ser mayor al total.');
                    }
                
                    saldo = (parseFloat(total) - parseFloat(adelanto)).toFixed(2);
                    
                    //Pedido nuevo, el saldo se calcula solo utilizando el adelanto
                    $('#pedido_saldo_pagado').val(adelanto);
                <% 
                    } else {
                    //Si es la edición de un pedido
                %>
                    //Pedido editdo, el saldo se calcula utilizando el dato "saldo pagado"
                    var saldo_pagado = getFloatFromInput($('#pedido_saldo_pagado'));
                    saldo = (parseFloat(total) - parseFloat(saldo_pagado)).toFixed(2);    
                <%
                    }
                %>
                 $('#pedido_saldo_pendiente').val(saldo);
                
            }
            
            //**--------------------FIN CALCULO DE ADELANTO Y SALDOS
            
            function mostrarCalendario(){
                $( "#pedido_fecha_pago" ).datepicker({
                        minDate: 0,
                        gotoCurrent: true,
                        changeMonth: true,
                        beforeShow: function(input, datepicker) {
                            setTimeout(function() {
                                    $(datepicker.dpDiv).css('zIndex', 100);
                            }, 500)}
                });
                
                $( "#pedido_fecha_entrega" ).datepicker({
                        minDate: 0,
                        gotoCurrent: true,
                        changeMonth: true,
                        beforeShow: function(input, datepicker) {
                            setTimeout(function() {
                                    $(datepicker.dpDiv).css('zIndex', 100);
                            }, 500)}
                });
            }
            
            
            function selPrecio(){ //funcion para saber si selecciono primero el precio, para no sugerirle uno.
                sugerenciaPrecio += 1;
            }
                       
                       
           /* function selectAlmacenFromPopup(idAlmacen, nombreAlmacen){
                
                $("#almacen_select").val(idAlmacen);
                $('#almacen_select'+postnameFlexSelect).val(nombreAlmacen);
                
            } */          
                       
        </script>
    </head>
    <body>
        <div class="content_wrapper">

            <jsp:include page="../include/header.jsp" flush="true"/>

            <jsp:include page="../include/leftContent.jsp"/>

            <!-- Inicio de Contenido -->
            <div id="content">

                <div class="inner">
                    <h1>Pedido</h1>

                    <div id="ajax_loading" class="alert_info" style="display: none;"></div>
                    <div id="ajax_message" class="alert_warning" style="display: none;"></div>

                    <!--TODO EL CONTENIDO VA AQUÍ-->
                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                Datos Generales
                            </span>
                        </div>
                        <br class="clear"/>
                        <div class="content">
                            <form action="pedido_form.jsp" id="select_cliente" name="select_cliente" method="post">
                                <p>
                                    <label>ID Pedido: &nbsp;</label>
                                    <input type="text" name="pedido_id" id="pedido_id" readonly disabled
                                           value="<%= pedidoDto!=null?pedidoDto.getIdPedido():"0" %>"
                                           style="width: 80px;"/>
                                    &nbsp;&nbsp;&nbsp;
                                    <label>Folio: &nbsp;</label>
                                    <input type="text" name="pedido_folio" id="pedido_folio" readonly disabled
                                           value="<%= pedidoDto!=null?pedidoDto.getFolioPedido():"P-///" %>"
                                           style="width: 80px;"/>
                                    &nbsp;&nbsp;&nbsp;
                                    <!--<label>Fecha Pago: &nbsp;</label>
                                    <input type="text" name="pedido_fecha_pago" id="pedido_fecha_pago" readonly
                                           value="<//%= pedidoDto!=null?DateManage.formatDateToNormal(pedidoDto.getFechaTentativaPago()):"" %>"
                                           style="width: 80px;"/>
                                    &nbsp;&nbsp;&nbsp;
                                    <label>Fecha Entrega: &nbsp;</label>
                                    <input type="text" name="pedido_fecha_entrega" id="pedido_fecha_entrega" readonly
                                           value="<//%= pedidoDto!=null?DateManage.formatDateToNormal(pedidoDto.getFechaEntrega()):"" %>"
                                           style="width: 80px;"/>-->
                                    
                                    <label>Tipo de Pedido: &nbsp;</label>                                                   
                                                    <select id="tipo_pedido" name="tipo_pedido">
                                                        <option value="1" selected>Faltante a Cliente</option>
                                                        <option value="2">Degustación</option>
                                                        <option value="3">Registro de Venta</option>
                                                    </select>
                                                
                                    
                                </p>
                                <br/>
                                
                                <% if (pedidoDto!=null){
                                        if (!StringManage.getValidString(pedidoDto.getFolioPedidoMovil()).equals("")) {%>
                                            <label>Folio M&oacute;vil &nbsp;</label>
                                            <input type="text" name="pedido_folio_movil" id="pedido_folio_movil" readonly disabled
                                                   value="<%= pedidoDto.getFolioPedidoMovil() %>"
                                                   style="width: 250px;"/>
                                            <br/>
                                <% 
                                        }
                                    }
                                %>
                                    <!--<p>
                                        <input type="checkbox" class="checkbox" id="ventaConsigna" name="ventaConsigna" onchange="recargarSelectClientes();" <%=pedidoDto!=null?(pedidoDto.getConsigna()==1?"checked readonly disabled":""):"" %>> <label for="ventaConsigna">Venta en Consigna</label>
                                    </p>-->
                                    <br/>
                                    <p>
                                    <label>Cliente:</label>
                                    <div id="div_select_cliente" name="div_select_cliente" style="display: inline;" >
                                        
                                    </div>
                                    &nbsp;&nbsp;&nbsp;
                                    <a href="../../jsp/catClientes/catClientes_form.jsp?acc=3" id="btn_nuevo_cliente" title="Nuevo Cliente"
                                    class="modalbox_iframe">
                                        <img src="../../images/icon_agregar.png" alt="nuevo cliente" class="help" title="Nuevo Cliente"/><br/>
                                    </a>
                                
                                    <input type="hidden" id="cliente_correo" name="cliente_correo" value="<%= clienteDto!=null?clienteDto.getCorreo():"" %>"/>
                                </p>
                                <br/>
                                <% if (pedidoDto!=null && !mode.equals("1")) {  %>
                                <p>
                                    <label>Vendedor:</label>
                                    <input type="text" name="vendedor" id="vendedor" readonly disabled
                                           value="<%= (pedidoDto!=null && usuario_vendedorDatos!=null)?usuario_vendedorDatos.getNombre() + " " + usuario_vendedorDatos.getApellidoPat() :"Sin datos del vendedor" %>"
                                           style="width: 250px;"/>
                                </p>
                                <br/>
                                <%}%>
<!--                                <p>
                                    <label>Estatus Pedido: &nbsp;</label>
                                    <select size="1" id="id_estatus" name="id_estatus">
                                        <option value="<//%= SGEstatusPedidoBO.ESTATUS_PENDIENTE %>"
                                                <//%= pedidoDto!=null?(pedidoDto.getIdEstatusPedido()==SGEstatusPedidoBO.ESTATUS_PENDIENTE?"selected":""):"selected"%> > 
                                            <//%= SGEstatusPedidoBO.ESTATUS_PENDIENTE_NAME %>
                                        </option>
                                        <//%  
                                            //Si es un nuevo pedido entonces no se muestran los siguientes estatus
                                            if (pedidoDto!=null && !mode.equals("1")){ 
                                        %>
                                        <option value="<//%= SGEstatusPedidoBO.ESTATUS_ENTREGADO %>"
                                                <//%= pedidoDto!=null?(pedidoDto.getIdEstatusPedido()==SGEstatusPedidoBO.ESTATUS_ENTREGADO?"selected":""):"selected"%> >
                                            <//%= SGEstatusPedidoBO.ESTATUS_ENTREGADO_NAME %>
                                        </option>
                                        <option value="<//%= SGEstatusPedidoBO.ESTATUS_CANCELADO %>"
                                                <//%= pedidoDto!=null?(pedidoDto.getIdEstatusPedido()==SGEstatusPedidoBO.ESTATUS_CANCELADO?"selected":""):"selected"%> >
                                            <//%= SGEstatusPedidoBO.ESTATUS_CANCELADO_NAME %>
                                        </option>
                                        <//% } %>
                                    </select>
                                    &nbsp;&nbsp;&nbsp;
                                    
                                    <!--<label>ID Comprobante Fiscal: &nbsp;</label>
                                    <input type="text" name="pedido_id_cfd" id="pedido_id_cfd" readonly disabled
                                           value="<//%= pedidoDto!=null?pedidoDto.getIdComprobanteFiscal():"No se genero" %>"
                                           style="width: 80px;"/>
                                    &nbsp;&nbsp;&nbsp;
                                    <//% if (pedidoDto!=null){
                                        if (pedidoDto.getIdComprobanteFiscal()>0){
                                    %>
                                    <a href="../../jsp/reportesExportar/previewCfdPdf.jsp?idComprobanteFiscal=<//%=pedidoDto.getIdComprobanteFiscal() %>&versionCfd=3.2" id="btn_show_cfdi" title="Previsualizar CFDI"
                                        class="modalbox_iframe">
                                        <img src="../../images/icon_consultar.png" alt="Mostrar CFDI" class="help" title="Previsualizar CFDI"/><br/>
                                    </a>
                                    <//%
                                            }
                                        }
                                    %>-->
<!--                                </p>
-->
                                <br/>
                                <!--<p>
                                    <label>Vía de Embarque:</label><br/>
                                    <select size="1" id="idViaEmbarquePedido" name="idViaEmbarquePedido" >
                                        <option value="-1" >Selecciona una vía de embarque</option>
                                            <//%
                                                out.print(new ViaEmbarqueBO(user.getConn()).getViaEmbarquesByIdHTMLCombo(idEmpresa, (pedidoDto!=null?pedidoDto.getIdViaEmbarque():-1) ));                                                     
                                            %>
                                    </select>                                        
                                </p>  
                                <br/>-->
                                
                            </form>
                        </div>
                    </div>
                    
                    <div class="onecolumn">
                        <div class="header">
                            <span>
                                Productos
                            </span>
                        </div>
                        <br class="clear"/>
                        <div class="content">
                            <form action="pedido_form.jsp" method="post" id="form_productos" name="form_productos">
                                                               
                                <table class="data" width="100%" cellpadding="0" cellspacing="0" style="vertical-align: top;">
                                    <thead>
                                        <tr>
                                            <td>Producto</td>
                                            <td>Descripción</td>
                                            <!--<td>Unidad</td>-->
                                            <td>Precio ($)</td>
                                            
                                            <td>Cantidad</td>
                                            <td>Monto ($)</td>
                                            <td>Acciones</td>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>
                                                <select size="1" name="producto_select" id="producto_select"  style="width:120px;"
                                                                onchange="selectProducto(this.value);"
                                                                class="flexselect">
                                                    <option value="-1"></option>
                                                    <%out.print(conceptoBO.getConceptosByIdHTMLCombo(idEmpresa, -1,0,250,"")); %>
                                                </select>
                                                
                                                &nbsp;
                                                <a href="../../jsp/includeProductoSelect/producto_by_categoria_select_form.jsp?mode=pedido" id="btn_select_producto_by_categoria" title="Busqueda Avanzada"
                                                    class="modalbox_iframe">
                                                    <img src="../../images/Search_16.png" alt="Busqueda Avanzada" class="help" title="Busqueda Avanzada"/><br/>
                                                </a>   
                                            </td>
                                            <td>
                                                <textarea name="producto_descripcion" id="producto_descripcion" 
                                                rows="3" cols="35" readonly disabled>Seleccione un producto...</textarea>
                                            </td>
                                            <!--<td>
                                                <select size="1" name="unidad_select" id="unidad_select"  style="width:150px;"
                                                                class="flexselect">
                                                    <option value="-1"></option>
                                                    <//%out.print(new UnidadBO(user.getConn()).getUnidadesHTMLCombo(-1)); %>
                                                </select>
                                            </td>-->
                                            <td>
                                                <div id="labelSugerido"></div>
                                                <select id="producto_precio" name="producto_precio" onchange="selPrecio();selectProductoCalcularMonto();" onkeypress="selectProductoCalcularMonto();"
                                                        style="width: 90px;">
                                                    <option value="0">0</option>
                                                </select>
                                            </td>
                                            
                                            <td>
                                                <input type="text" maxlength="8" name="producto_cantidad" id="producto_cantidad" 
                                                        style="text-align: right;" size="8" onchange="sugerirPrecio();"
                                                        onkeypress="return validateNumber(event);"/>                                                
                                            </td>                                            
                                            <td>
                                                <input type="text" maxlength="12" name="producto_monto" id="producto_monto" 
                                                    readonly style="text-align: right;" size="10" onkeypress="return validateNumber(event);"/>
                                            </td>
                                            <td>
                                                <a href="javascript:void(0);" name="add_producto_action" onclick="addProducto();" id="add_producto_action">
                                                    <img src="../../images/icon_agregar.png" alt="Agregar Producto" height="20" width="20" class="help" title="Agregar Producto"/>
                                                </a>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                                
                                <center><div id="div_producto_ajax_loading" class="alert_warning noshadow" style="display: none;"></div></center>
                                <div id="div_ajax_productos" class="ajax_selected_box"></div>
                                
                            </form>
                        </div>
                    </div>
                                                            
                    <div class="twocolumn">
                        
                        <!--Columna izquierda: Descuentos-->
                        <div class="column_left">
                            <div class="header">
                                <span>
                                    Descuentos
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content" style="display: none;">
                                    <table class="data" width="100%" cellpadding="0" cellspacing="0">
                                        <thead>
                                            <tr>
                                                <td>Descuento (%)</td>
                                                <td>Importe Descuento</td>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>
                                                    <input type="text" maxlength="5" name="descuento_tasa" id="descuento_tasa"
                                                            style="text-align: right;" size="12" value="<%=pedidoSesion!=null?pedidoSesion.getDescuento_tasa():"0"%>"
                                                            onkeypress="return validateNumber(event);"
                                                            onchange="calculaDescuento();"/>
                                                </td>
                                                <td>
                                                    <h3>- 
                                                    <input type="text" name="descuento_importe" id="descuento_importe"
                                                            style="text-align: right;" size="12" value="0"
                                                            onkeypress="return validateNumber(event);"
                                                            readonly />
                                                    </h3>
                                                </td>
                                            </tr>
                                            
                                            <tr>
                                                <td colspan="2">
                                                    <br/>
                                                    Motivo Descuento:
                                                    <br/>
                                                    <input type="text" name="descuento_motivo" id="descuento_motivo"
                                                           style="width: 100%;" value="<%= pedidoDto!=null?pedidoDto.getDescuentoMotivo():"" %>" maxlength="100"/>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                    <center><div id="div_descuento_ajax_loading" class="alert_warning noshadow" style="display: none;"></div></center>
                            </div>
                        </div>
                        <!--Fin columna izquierda: Descuentos-->
                         
                        <!--Columna derecha: Impuestos-->
                        
                        <!--Fin Columna derecha: Impuestos-->                         
                    </div>
                    <br class="clear"/>
                    
                    
                    <div class="twocolumn">
                        <div class="column_left" id="div_comentarios">
                            <div class="header">
                                <span>
                                    Comentarios
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                    <textarea cols="60" rows="5" id="comentarios" name="comentarios"><%= pedidoDto!=null?pedidoDto.getComentarios():pedidoSesion.getIdCotizacionOrigen()>0?pedidoSesion.getComentarios():"" %></textarea>
                            </div>
                        </div>
                        
                        <div class="column_right" id="div_totales">
                            <div class="header">
                                <span>
                                    Totales
                                </span>
                            </div>
                            <br class="clear"/>
                            <div class="content">
                                <form action="pedido_form.jsp" id="form_acciones" name="form_acciones" method="post">                            
                                    <table class="data" width="100%" cellpadding="0" cellspacing="0">
                                        <tbody style="text-align: right;">                                      
                                            <tr>
                                                <td>
                                                    <h2>
                                                    Total:
                                                    <input type="text" maxlength="16" name="total" id="total"
                                                            style="text-align: right;" size="12" value="0" readonly
                                                            onkeypress="return validateNumber(event);"/>
                                                    </h2>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    Tipo de Moneda:
                                                    <select id="tipo_moneda" name="tipo_moneda">
                                                        <option value="MXN" selected>PESOS (M.N.)</option>
                                                        <option value="USD">DOLAR (USD)</option>
                                                        <option value="EUR">EUROS (EUR)</option>
                                                    </select>
                                                </td>
                                            </tr>
<!--                                            <tr>
                                                <td>
                                                    Adelanto:
                                                    <input type="text" maxlength="16" name="pedido_adelanto" id="pedido_adelanto"
                                                            style="text-align: right;" size="12"
                                                            onkeypress="return validateNumber(event);"
                                                            value="<%= pedidoDto!=null?pedidoDto.getAdelanto():"0" %>"
                                                            <%= pedidoDto!=null?" readonly ":"" %>
                                                            onchange="calculaSaldoConAdelanto();"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    Saldo Pagado:
                                                    <input type="text" maxlength="16" name="pedido_saldo_pagado" id="pedido_saldo_pagado"
                                                            style="text-align: right;" size="12" readonly
                                                            onkeypress="return validateNumber(event);"
                                                            value="<%= pedidoDto!=null?pedidoDto.getSaldoPagado():"0"%>"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    Saldo Pendiente: 
                                                    <input type="text" maxlength="16" name="pedido_saldo_pendiente" id="pedido_saldo_pendiente"
                                                            style="text-align: right;" size="12" value="0" readonly
                                                            onkeypress="return validateNumber(event);"
                                                            value="0"/>
                                                </td>
                                            </tr>
-->                                        </tbody>
                                    </table>
                                </form>
                            </div>
                        </div>
                    </div>
                    <br class="clear"/>
                                
                   <div class="onecolumn" id="action_buttons">
                        <div class="header">
                            <span>
                                Acciones
                            </span>
                        </div>
                        <br class="clear"/>
                        <div class="content">
                            <form action="pedido_form.jsp" id="form_acciones" name="form_acciones" method="post">                            
                                <div>
                                    <p>
                                        <input type="button" id="regresar" value="Cancelar y Regresar" onclick="history.back();"/>
                                        &nbsp;&nbsp;&nbsp;
                                        <% if (pedidoDto!=null) {
                                            //Solo se puede modificar el pedido si no ha sido facturado o entregado
                                                if (isPedidoEditable){
                                        %>
                                        <input type="button" id="guardar" value="Guardar Cambios" onclick="grabar('');"/>
                                        &nbsp;&nbsp;&nbsp;
                                        <!--<input type="button" id="guardar_enviar" value="Guardar Cambios y Enviar" onclick="enviarYgrabar();"/>-->
                                        <%
                                                }
                                            }else{
                                        %>
                                        <input type="button" id="guardar" value="Guardar" onclick="grabar('');"/>
                                        &nbsp;&nbsp;&nbsp;
                                        <input type="button" id="guardar_enviar" value="Guardar y Enviar" onclick="enviarYgrabar();"/>
                                        <%
                                            }
                                        %>
                                    </p>
                                </div>
                            </form>
                        </div>
                    </div>
                                
                    <!--TODO EL CONTENIDO VA AQUÍ-->

                </div>

                <jsp:include page="../include/footer.jsp"/>
            </div>
            <!-- Fin de Contenido-->
        </div>

        <script>
            mostrarCalendario();
           iniciarFlexSelect();
        </script>
    </body>
</html>
<%}%>