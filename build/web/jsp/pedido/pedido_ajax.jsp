<%-- 
    Document   : pedido_ajax
    Created on : 13-dic-2012, 16:27:45
    Author     : ISCesarMartinez
--%>

<%@page import="com.tsp.gespro.bo.ZonaHorariaBO"%>
<%@page import="com.tsp.gespro.bo.ExistenciaAlmacenBO"%>
<%@page import="com.tsp.gespro.dto.ExistenciaAlmacen"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.jdbc.SgfensPedidoProductoDaoImpl"%>

<%@page import="com.tsp.gespro.jdbc.EmpresaPermisoAplicacionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.EmpresaPermisoAplicacion"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.dto.SgfensPedidoProducto"%>
<%@page import="com.tsp.gespro.bo.SGPedidoProductoBO"%>
<%@page import="com.tsp.gespro.jdbc.SgfensPedidoDaoImpl"%>
<%@page import="com.tsp.gespro.bo.SGEstatusPedidoBO"%>
<%@page import="java.io.File"%>
<%@page import="com.tsp.gespro.sesion.FormatoSesion"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page import="com.tsp.gespro.util.GenericUtil"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page import="com.tsp.gespro.dto.SgfensPedido"%>
<%@page import="com.tsp.gespro.sesion.ServicioSesion"%>
<%@page import="java.math.RoundingMode"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="com.tsp.gespro.sesion.ImpuestoSesion"%>
<%@page import="com.tsp.gespro.bo.ConceptoBO"%>
<%@page import="com.tsp.gespro.bo.SGPedidoBO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.tsp.gespro.sesion.ProductoSesion"%>
<%@page import="com.tsp.gespro.jdbc.ConceptoDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Concepto"%>
<%@page import="com.google.gson.Gson"%>
<%@page import="com.tsp.gespro.sesion.PedidoSesion"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<jsp:useBean id="pedidoSesion" scope="session" class="com.tsp.gespro.sesion.PedidoSesion"/>
<%
    String msgError="";
    /*
    *   Modos:
    *       -1  =  No se eligio (ERROR)
    *        1  =  Seleccionar y Recuperar datos de Producto (recuperar info de 1 producto)
    *        2  =  Agregar Producto
    *        3  =  Reiniciar lista Productos (borrar todos)
    *        4  =  Quitar producto de lista (borrar 1)
    *        5  =  Recargar Lista de Productos
    *        6  =  Reiniciar Pedido (Borrar todo)
    *        7  =  Reconstruir Sesion desde BD (Sesion <- BD)
    *        8  =  Modificar Producto
    *
    *        9  =  Agregar Impuesto
    *        10 =  Quitar Impuesto de lista (borrar 1)
    *        11 =  Recargar Lista de Impuestos
    * 
    *        12 =  Calcular/Aplicar Descuento
    * 
    *        13 =  Seleccionar y Recuperar datos de Servicio
    *        14 =  Agregar Servicio
    *        15 =  Reiniciar lista Servicio (borrar todos)
    *        16 =  Quitar Servicio de lista (borrar 1)
    *        17 =  Recargar lista de Servicios
    *        18 =  Modificar Servicio 
    *        
    *        19 =  Guardar Pedido (Sesion -> BD)  
    * 
    *        20 =  Recargar Select Clientes
    *        21 =  Seleccionar Cliente (obtener datos)
    * 
    *        22 =  Facturar (sesion pedido -> sesion comprobante fiscal)
    *        23 =  Cancelar Pedido
    *        24 =  Marcar como entregado el pedido
    *        25 =  Sugerir Precio en base a la cantidad tecleada
    *        26 =  Asignar vendedor  y repartidor al pedido
    */
    int mode=-1;
    try{
        mode = Integer.parseInt(request.getParameter("mode"));
    }catch(NumberFormatException e){}
    boolean recargarListaProductos=false;
    boolean recargarListaServicios=false;
    boolean recargarListaImpuestos=false;
    
    boolean recargarSelectClientes=false;
    int idCliente = -1;
    int tipoClientes = -1;
    
    PedidoSesion pedidoAux = pedidoSesion;
    
    Gson gson = new Gson();
    
    GenericValidator genericValidator = new GenericValidator();
    
    /*
     * Procesamiento
     */
    if (mode==-1){
        msgError = "No se eligio una acción correcta. Reintente el llenado de los datos.";
    }else if (mode==1){
        //MODO  1  =  Seleccionar y Recuperar datos de Producto
        
        //Parametros
        int idProducto = -1;
        try{
            idProducto = Integer.parseInt(request.getParameter("id_producto_select"));
        }catch(NumberFormatException e){}
        
        idCliente = -1;
        try{
            idCliente = Integer.parseInt(request.getParameter("idCliente"));
        }catch(NumberFormatException e){}
        
        //Validacion
/*        if (idCliente>0){
*/            if (idProducto>0){
                Concepto producto = new Concepto();
                ConceptoDaoImpl conceptoDaoImpl = new ConceptoDaoImpl(user.getConn());

                try{
                   producto = conceptoDaoImpl.findByPrimaryKey(idProducto);

/*                   //Revisamos si tiene precios especiales
                   ClientePrecioConceptoBO clientePrecioBO = new ClientePrecioConceptoBO(user.getConn());
                   ClientePrecioConcepto[] clientePrecioDto = clientePrecioBO.findClientePrecioEspecial(idCliente, idProducto, -1, -1, "");

                   if(clientePrecioDto.length>0){
                       if(clientePrecioDto[0].getPrecioUnitarioCliente()>0){
                           producto.setPrecio((float)clientePrecioDto[0].getPrecioUnitarioCliente());
                       }
                       if(clientePrecioDto[0].getPrecioMedioCliente()>0){
                           producto.setPrecioMedioMayoreo(clientePrecioDto[0].getPrecioMedioCliente());
                       }
                       if(clientePrecioDto[0].getPrecioMayoreoCliente()>0){
                           producto.setPrecioMayoreo(clientePrecioDto[0].getPrecioMayoreoCliente());
                       }
                       if(clientePrecioDto[0].getPrecioDocenaCliente()>0){
                           producto.setPrecioDocena(clientePrecioDto[0].getPrecioDocenaCliente());
                       }
                       if(clientePrecioDto[0].getPrecioEspecialCliente()>0){
                           producto.setPrecioEspecial(clientePrecioDto[0].getPrecioEspecialCliente());
                       }
                           
                   }
*/
                }catch(Exception ex){
                    msgError = "Ocurrio un error al consultar el producto elegido. " + ex.toString();
                }

                if (msgError.equals("")){
                    //Usamos JSON para retornar el objeto respuesta
                    String jsonOutput = gson.toJson(producto);
                    out.print("<!--EXITO-->"+jsonOutput);
                }
            }else{
                msgError="No se selecciono un producto válido.";
            }
/*        }else{
            msgError="No se selecciono un cliente válido.";
        }
*/        
    }else if (mode==2){
        //Modo 2 = agregar producto
        
        //Parametros
        int idProducto = -1;
        double cantidad =-1;
        double precio =-1;
        double monto=-1;
        int idAlmacen = 0;
        String unidad = request.getParameter("producto_unidad") != null ? request.getParameter("producto_unidad") : "No aplica";
        try{ idProducto = Integer.parseInt(request.getParameter("producto_id")); }catch(Exception e){}
        try{ cantidad = Double.parseDouble(request.getParameter("producto_cantidad")); }catch(Exception e){}
        try{ precio = Double.parseDouble(request.getParameter("producto_precio")); }catch(Exception e){}
        try{ monto = Double.parseDouble(request.getParameter("producto_monto")); }catch(Exception e){}
        try{ idAlmacen = Integer.parseInt(request.getParameter("almacen_id")); }catch(Exception e){}
        
        //Validaciones
        if (idProducto<=0)
            msgError = "<ul>Producto no específicado o incorrecto";
        if (cantidad<0)
            msgError = "<ul>Cantidad invalida";
        if (monto<0)
            msgError = "<ul>Monto invalido";
        if (precio<0)
            msgError = "<ul>Precio invalido";
        if (unidad.trim().length()<=0)
            msgError = "<ul>Seleccione Unidad valida";
        
        //Si no valida existencia
        EmpresaPermisoAplicacion empresaPermisoAplicacionDto = null;
        try{
            EmpresaBO empresaBO = new EmpresaBO(user.getConn());
            empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl(user.getConn()).findByPrimaryKey(empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa());     
                       
        }catch(Exception ex){ex.printStackTrace();}
        
/*        if (empresaPermisoAplicacionDto != null) {
             if (empresaPermisoAplicacionDto.getRevisionCantidadProducto() == 1) {
                if (idAlmacen<=0)
                    msgError = "<ul>Almacén no especificado o incorrecto";
             }
        }        
*/        
        if (msgError.equals("")){
            Concepto productoCompra = null;
            ConceptoDaoImpl conceptoDaoImpl = new ConceptoDaoImpl(user.getConn());
            
            ExistenciaAlmacen almPrincipal = null;
            ExistenciaAlmacenBO exisAlmBO = new ExistenciaAlmacenBO(user.getConn());

            try{
               productoCompra = conceptoDaoImpl.findByPrimaryKey(idProducto);
            }catch(Exception ex){
                msgError = "Ocurrio un error al consultar el producto elegido. " + ex.toString();
            }
            
            
                
/*            if (empresaPermisoAplicacionDto != null) {
                if (empresaPermisoAplicacionDto.getRevisionCantidadProducto() == 1) {
                    
                    if (productoCompra!=null){
                
                        almPrincipal = exisAlmBO.getExistenciaProductoAlmacen(idAlmacen, productoCompra.getIdConcepto());

                        BigDecimal numArticulosDisponibles = (new BigDecimal(almPrincipal!=null?almPrincipal.getExistencia():0)).setScale(2, RoundingMode.HALF_UP);
                        BigDecimal cantidad2 = (new BigDecimal(cantidad)).setScale(2, RoundingMode.HALF_UP);
                        BigDecimal stockTotal = numArticulosDisponibles.subtract(cantidad2);

                        double nuevoStock = stockTotal.doubleValue();                
                        if (nuevoStock<0){
                            msgError+="<ul>El stock en Almacen del articulo es insuficiente para cubrir la operación.<br/>No. de Articulos disponibles: " + (almPrincipal!=null?almPrincipal.getExistencia():0);
                        }
                    }
                }
            }
*/            
            if (msgError.equals("")){
                try{
                    if (pedidoSesion==null){
                        pedidoSesion = new PedidoSesion();
                    }

                    ProductoSesion nuevoProductoCompraSesion = new ProductoSesion();
                    nuevoProductoCompraSesion.setCantidad(cantidad);
                    nuevoProductoCompraSesion.setIdProducto(idProducto);
                    nuevoProductoCompraSesion.setMonto(monto);
                    nuevoProductoCompraSesion.setPrecio(precio);
                    nuevoProductoCompraSesion.setUnidad(unidad);
                    nuevoProductoCompraSesion.setIdAlmacen(idAlmacen);

                    if (productoCompra!=null){

                        boolean coincidenciaPrevia=false;
                        for (ProductoSesion itemProducto:pedidoSesion.getListaProducto()){
                            if (itemProducto.getIdProducto()==productoCompra.getIdConcepto()){
                                //Ya se había seleccionado este producto
                                coincidenciaPrevia=true;
                                break;
                            }
                        }
                        if (!coincidenciaPrevia){
                            pedidoSesion.getListaProducto().add(nuevoProductoCompraSesion);
                        }else{
                            msgError +="<ul> El producto ya fue seleccionado previamente. Modifique los valores o elimine el producto del listado.";
                        }

                    }

                    request.getSession().setAttribute("pedidoSesion", pedidoSesion);

                }catch(Exception ex){
                    msgError += "Ocurrio un error al recuperar los productos elegidos previamente en la sesion. " + ex.toString();
                }
            }
            
            recargarListaProductos=true;
        }
        
    }else if (mode==3){
        //Reiniciar lista de productos
        if (pedidoSesion==null)
            pedidoSesion = new PedidoSesion();
        pedidoSesion.setListaProducto(new ArrayList<ProductoSesion>());
        request.getSession().setAttribute("pedidoSesion", pedidoSesion);
        
        recargarListaProductos=true;
    }else if (mode==4){
        //Quitar producto de lista
        if (pedidoSesion==null)
            pedidoSesion = new PedidoSesion();
        int index_lista_producto=-1;
        try{ index_lista_producto = Integer.parseInt(request.getParameter("index_lista_producto")); }catch(Exception e){}
        if (index_lista_producto<0)
            msgError = "<ul>Producto inválido. Si persiste el problema intente recargar esta página.";
        
        if (msgError.equals("")){
            try{
                pedidoSesion.getListaProducto().remove(index_lista_producto);
            }catch(Exception ex){
                msgError+="El producto especificado no se encontro en el listado en sesion. Intente de nuevo.";
            }
            request.getSession().setAttribute("pedidoSesion", pedidoSesion);

            recargarListaProductos=true;
        }
    }else if (mode==5){
        //Recargar Lista de Productos
        if (pedidoSesion==null)
            pedidoSesion = new PedidoSesion();
        request.getSession().setAttribute("pedidoSesion", pedidoSesion);
        recargarListaProductos=true;
    }else if (mode==6){
        //6 = Reiniciar Pedido (Borrar todo)
        pedidoSesion = new PedidoSesion();
        request.getSession().setAttribute("pedidoSesion", pedidoSesion);
    }else if (mode==7){
        //Reconstruir Sesion desde BD
        
        //Parametros
        int id_pedido = -1;
        try{ id_pedido = Integer.parseInt(request.getParameter("id_pedido")); }catch(Exception e){}
        
        //Procesamiento
        if (id_pedido>=0){
            SGPedidoBO pedidoSesionBO = new SGPedidoBO(id_pedido,user.getConn());
            pedidoSesion = pedidoSesionBO.getSessionFromPedidoDB();
            request.getSession().setAttribute("pedidoSesion", pedidoSesion);
        }else{
            msgError += "<ul> No se específico el identificador (ID) de la Pedido a recuperar. Intente de nuevo.";
        }
        
    }else if(mode==8){
        //Modo 8 = Modificar Producto
        if (pedidoSesion==null)
            pedidoSesion = new PedidoSesion();
        
        //Parametros
        int idProducto = -1;
        double cantidad =-1;
        double monto=-1;
        double precio = -1;
        int index_lista_producto=-1;
        int idAlmacen=0; 
        String almacenNombre = "";
        try{ idProducto = Integer.parseInt(request.getParameter("producto_id")); }catch(Exception e){}
        try{ cantidad = Double.parseDouble(request.getParameter("producto_cantidad")); }catch(Exception e){}
        try{ monto = Double.parseDouble(request.getParameter("producto_monto")); }catch(Exception e){}
        try{ precio = Double.parseDouble(request.getParameter("producto_precio")); }catch(Exception e){}
        try{ index_lista_producto = Integer.parseInt(request.getParameter("index_lista_producto")); }catch(Exception e){}
        String unidad = request.getParameter("producto_unidad") != null ? request.getParameter("producto_unidad") : "No Aplica";
        try{ idAlmacen = Integer.parseInt(request.getParameter("almacen_id")); }catch(Exception e){}
        almacenNombre = request.getParameter("almacenNombre") != null ? request.getParameter("almacenNombre") : "";
        
        
        //Validaciones
        if (idProducto<=0)
            msgError = "<ul>Producto no específicado o incorrecto";
        if (cantidad<0)
            msgError = "<ul>Cantidad invalida";
        if (monto<0)
            msgError = "<ul>Monto invalido";
        if (precio<0)
            msgError = "<ul>Precio no específicado o incorrecto";
        if (index_lista_producto<0)
            msgError = "<ul>Producto inválido. Si persiste el problema intente recargar esta página.";
        
        
         //Si no valida existencia
        EmpresaPermisoAplicacion empresaPermisoAplicacionDto = null;
        try{
            EmpresaBO empresaBO = new EmpresaBO(user.getConn());
            empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl().findByPrimaryKey(user.getUser().getIdEmpresa());   
                       
        }catch(Exception ex){ex.printStackTrace();}
        
/*        if (empresaPermisoAplicacionDto != null) {
            if (empresaPermisoAplicacionDto.getRevisionCantidadProducto() == 1) {
                if (idAlmacen<=0 && !almacenNombre.equals("Almacen Movil") )
                  msgError = "<ul>Almacén no específicado o incorrecto";
            }
        }
*/        
        if (msgError.equals("")){
            
            // valida existencia
            Concepto productoCompra = null;
            ConceptoDaoImpl conceptoDaoImpl = new ConceptoDaoImpl(user.getConn());

            ExistenciaAlmacen almPrincipal = null;
            ExistenciaAlmacenBO exisAlmBO = new ExistenciaAlmacenBO(user.getConn());

            try{
               productoCompra = conceptoDaoImpl.findByPrimaryKey(idProducto);
            }catch(Exception ex){
                msgError = "Ocurrio un error al consultar el producto elegido. " + ex.toString();
            }
            
/*            if (empresaPermisoAplicacionDto != null) {
                if (empresaPermisoAplicacionDto.getRevisionCantidadProducto() == 1) {

                    if (productoCompra!=null && !almacenNombre.equals("Almacen Movil")){                

                        almPrincipal = exisAlmBO.getExistenciaProductoAlmacen(idAlmacen, productoCompra.getIdConcepto());

                        BigDecimal numArticulosDisponibles = (new BigDecimal(almPrincipal!=null?almPrincipal.getExistencia():0)).setScale(2, RoundingMode.HALF_UP);
                        BigDecimal cantidad2 = (new BigDecimal(cantidad)).setScale(2, RoundingMode.HALF_UP);
                        BigDecimal stockTotal = numArticulosDisponibles.subtract(cantidad2);

                        double nuevoStock = stockTotal.doubleValue();                
                        if (nuevoStock<0){
                            msgError+="<ul>El stock del articulo es insuficiente para cubrir la operación.<br/>No. de Articulos disponibles: " + (almPrincipal!=null?almPrincipal.getExistencia():0);
                        }
                    }// fin valida existencia
                }
            }
*/            
            
            if (msgError.equals("")){
            
                monto = precio * cantidad;

                try{            

                    ProductoSesion nuevoProductoSesion = new ProductoSesion();
                    nuevoProductoSesion.setCantidad(cantidad);
                    nuevoProductoSesion.setPrecio(precio);
                    nuevoProductoSesion.setIdProducto(idProducto);
                    nuevoProductoSesion.setMonto(monto);
                    nuevoProductoSesion.setUnidad(unidad);
                    nuevoProductoSesion.setIdAlmacen(idAlmacen);

                    pedidoSesion.getListaProducto().set(index_lista_producto, nuevoProductoSesion);
                }catch(Exception ex){
                    msgError+="El producto especificado no se pudo actualizar. Intente de nuevo.";
                }
                request.getSession().setAttribute("pedidoSesion", pedidoSesion);

                if (msgError.equals("")){
                    out.print("Producto actualizado exitosamente");
                }

            }
        }
    }else if(mode==9){
        //Modo 9 = Agregar Impuesto
        
        //Parametros
        int idImpuesto = -1;
        try{ idImpuesto = Integer.parseInt(request.getParameter("impuesto_id")); }catch(Exception e){}
        
        //Validaciones
/*        if (idImpuesto<=0)
            msgError = "<ul>Impuesto no específicado o incorrecto";
        
/*        if (msgError.equals("")){
            Impuesto impuestoDto = null;
            ImpuestoDaoImpl impuestoDaoImpl = new ImpuestoDaoImpl(user.getConn());

            try{
               impuestoDto = impuestoDaoImpl.findByPrimaryKey(idImpuesto);
            }catch(Exception ex){
                msgError = "Ocurrio un error al consultar el impuesto elegido. " + ex.toString();
            }
            
            try{
                if (pedidoSesion==null){
                    pedidoSesion = new PedidoSesion();
                }

                ImpuestoSesion nuevoImpuestoCompraSesion = new ImpuestoSesion();
                nuevoImpuestoCompraSesion.setIdImpuesto(idImpuesto);
                nuevoImpuestoCompraSesion.setNombre(impuestoDto.getNombre());
                nuevoImpuestoCompraSesion.setDescripcion(impuestoDto.getDescripcion());
                nuevoImpuestoCompraSesion.setPorcentaje(impuestoDto.getPorcentaje());
                nuevoImpuestoCompraSesion.setTrasladado(impuestoDto.getTrasladado()==(short)1?true:false);
                nuevoImpuestoCompraSesion.setImplocal(impuestoDto.getImpuestoLocal()==(short)1?true:false);
                
                if (impuestoDto!=null){
                    boolean coincidenciaPrevia=false;
                    for (ImpuestoSesion itemImpuesto:pedidoSesion.getListaImpuesto()){
                        if (itemImpuesto.getIdImpuesto()==impuestoDto.getIdImpuesto()){
                            //Ya se había seleccionado este impuesto
                            coincidenciaPrevia=true;
                            break;
                        }
                    }
                    if (!coincidenciaPrevia){
                        pedidoSesion.getListaImpuesto().add(nuevoImpuestoCompraSesion);
                    }else{
                        msgError +="<ul> El impuesto ya fue seleccionado previamente.";
                    }
                        
                }
                
                request.getSession().setAttribute("pedidoSesion", pedidoSesion);
            }catch(Exception ex){
                msgError += "Ocurrio un error al recuperar los impuestos elegidos previamente en la sesion. " + ex.toString();
            }
            
            recargarListaImpuestos=true;
        }
*/        
    }else if(mode==10){
        //Modo 10 = Quitar Impuesto
        if (pedidoSesion==null)
            pedidoSesion = new PedidoSesion();
        int index_lista_impuesto=-1;
        try{ index_lista_impuesto = Integer.parseInt(request.getParameter("index_lista_impuesto")); }catch(Exception e){}
        if (index_lista_impuesto<0)
            msgError = "<ul>Impuesto inválido. Si persiste el problema intente recargar esta página.";
        
        if (msgError.equals("")){
            try{
                pedidoSesion.getListaImpuesto().remove(index_lista_impuesto);
            }catch(Exception ex){
                msgError+="El impuesto especificado no se encontro en el listado en sesion. Intente de nuevo.";
            }
            request.getSession().setAttribute("pedidoSesion", pedidoSesion);

            recargarListaImpuestos=true;
        }
        
    }else if(mode==11){
        //Modo 11 = Recargar Lista Impuestos
        if (pedidoSesion==null)
            pedidoSesion = new PedidoSesion();
        request.getSession().setAttribute("pedidoSesion", pedidoSesion);
        recargarListaImpuestos=true;
    }else if(mode==12){
        //Modo 12 = Calcular/Aplicar Descuento
        if (pedidoSesion==null)
            pedidoSesion = new PedidoSesion();
        String descuento_tasa = request.getParameter("descuento_tasa") != null ? request.getParameter("descuento_tasa") : "0";
        
        BigDecimal descuento_tasa_bigd = new BigDecimal(descuento_tasa).setScale(2, RoundingMode.HALF_UP);
        if (descuento_tasa_bigd.doubleValue()<0)
            msgError = "<ul>Descuento inválido. El descuento debe ser mayor o igual a 0 en porcentaje;";
        
        if (msgError.equals("")){
            try{
                pedidoSesion.setDescuento_tasa(descuento_tasa_bigd.doubleValue());
            }catch(Exception ex){
                msgError+="Ocurrio un error al aplicar el descuento. Intente de nuevo.";
            }
            request.getSession().setAttribute("pedidoSesion", pedidoSesion);
        }
        
        if (msgError.equals("")){
            out.print("<!--EXITO-->"+pedidoSesion.getDescuentoImporte());
        }
    }else if(mode==13){
        //Modo 13 = Seleccionar y Recuperar datos de Servicio
        
        //Parametros
        int idServicio = -1;
        try{
            idServicio = Integer.parseInt(request.getParameter("id_servicio_select"));
        }catch(NumberFormatException e){}
        
        //Validacion
/*        if (idServicio>0){
            Servicio servicio = new Servicio();
            ServicioDaoImpl servicioDaoImpl = new ServicioDaoImpl(user.getConn());

            try{
               servicio = servicioDaoImpl.findByPrimaryKey(idServicio);
            }catch(Exception ex){
                msgError = "Ocurrio un error al consultar el servicio elegido. " + ex.toString();
            }

            if (msgError.equals("")){
                //Usamos JSON para retornar el objeto respuesta
                String jsonOutput = gson.toJson(servicio);
                out.print("<!--EXITO-->"+jsonOutput);
                //System.out.println("\n\n"+jsonOutput);
            }
        }else{
            msgError="No se selecciono un servicio válido.";
        }
*/        
    }else if(mode==14){
        //Modo 14 = Agregar Servicio
        
        //Parametros
        int idServicio = -1;
        double cantidad =-1;
        double precio =-1;
        double monto=-1;
        String unidad = request.getParameter("servicio_unidad") != null ? request.getParameter("servicio_unidad") : "No Aplica";
        try{ idServicio = Integer.parseInt(request.getParameter("servicio_id")); }catch(Exception e){}
        try{ cantidad = Double.parseDouble(request.getParameter("servicio_cantidad")); }catch(Exception e){}
        try{ precio = Double.parseDouble(request.getParameter("servicio_precio")); }catch(Exception e){}
        try{ monto = Double.parseDouble(request.getParameter("servicio_monto")); }catch(Exception e){}
        
        //Validaciones
        if (idServicio<=0)
            msgError = "<ul>Servicio no específicado o incorrecto";
        if (cantidad<0)
            msgError = "<ul>Cantidad invalida";
        if (monto<0)
            msgError = "<ul>Monto invalido";
        if (precio<0)
            msgError = "<ul>Precio invalido";
        
/*        if (msgError.equals("")){
            Servicio servicioCompra = null;
            ServicioDaoImpl servicioDaoImpl = new ServicioDaoImpl(user.getConn());

            try{
               servicioCompra = servicioDaoImpl.findByPrimaryKey(idServicio);
            }catch(Exception ex){
                msgError = "Ocurrio un error al consultar el servicio elegido. " + ex.toString();
            }
            
            try{
                if (pedidoSesion==null){
                    pedidoSesion = new PedidoSesion();
                }

                ServicioSesion nuevoServicioCompraSesion = new ServicioSesion();
                nuevoServicioCompraSesion.setCantidad(cantidad);
                nuevoServicioCompraSesion.setIdServicio(idServicio);
                nuevoServicioCompraSesion.setMonto(monto);
                nuevoServicioCompraSesion.setPrecio(precio);
                nuevoServicioCompraSesion.setUnidad(unidad);
                
                if (servicioCompra!=null){
                    boolean coincidenciaPrevia=false;
                    for (ServicioSesion itemServicio:pedidoSesion.getListaServicio()){
                        if (itemServicio.getIdServicio()==servicioCompra.getIdServicio()){
                            //Ya se había seleccionado este servicio
                            coincidenciaPrevia=true;
                            break;
                        }
                    }
                    if (!coincidenciaPrevia){
                        pedidoSesion.getListaServicio().add(nuevoServicioCompraSesion);
                    }else{
                        msgError +="<ul> El servicio ya fue seleccionado previamente. Modifique los valores o elimine el servicio del listado.";
                    }
                        
                }
                
                request.getSession().setAttribute("pedidoSesion", pedidoSesion);
            }catch(Exception ex){
                msgError += "Ocurrio un error al recuperar los servicios elegidos previamente en la sesion. " + ex.toString();
            }
            
            recargarListaServicios=true;
        }
*/        
    }else if(mode==15){
        //Modo 15 = Reiniciar lista Servicio (borrar todos)
        if (pedidoSesion==null)
            pedidoSesion = new PedidoSesion();
        pedidoSesion.setListaServicio(new ArrayList<ServicioSesion>());
        request.getSession().setAttribute("pedidoSesion", pedidoSesion);
        
        recargarListaServicios=true;
    }else if(mode==16){
        //Modo 16 = Quitar Servicio de lista (borrar 1)
        
        if (pedidoSesion==null)
            pedidoSesion = new PedidoSesion();
        int index_lista_servicio=-1;
        try{ index_lista_servicio = Integer.parseInt(request.getParameter("index_lista_servicio")); }catch(Exception e){}
        if (index_lista_servicio<0)
            msgError = "<ul>Servicio inválido. Si persiste el problema intente recargar esta página.";
        
        if (msgError.equals("")){
            try{
                pedidoSesion.getListaServicio().remove(index_lista_servicio);
            }catch(Exception ex){
                msgError+="El servicio especificado no se encontro en el listado en sesion. Intente de nuevo.";
            }
            request.getSession().setAttribute("pedidoSesion", pedidoSesion);

            recargarListaServicios=true;
        }
        
    }else if(mode==17){
        //Modo 17 = Recargar lista de Servicios
        
        if (pedidoSesion==null)
            pedidoSesion = new PedidoSesion();
        request.getSession().setAttribute("pedidoSesion", pedidoSesion);
        recargarListaServicios=true;
        
    }else if(mode==18){
        //Modo 18 = Modificar Servicio
        
        if (pedidoSesion==null)
            pedidoSesion = new PedidoSesion();
        
        //Parametros
        int idServicio = -1;
        double cantidad =-1;
        double monto=-1;
        double precio = -1;
        int index_lista_servicio=-1;
        
        try{ idServicio = Integer.parseInt(request.getParameter("servicio_id")); }catch(Exception e){}
        try{ cantidad = Double.parseDouble(request.getParameter("servicio_cantidad")); }catch(Exception e){}
        try{ monto = Double.parseDouble(request.getParameter("servicio_monto")); }catch(Exception e){}
        try{ precio = Double.parseDouble(request.getParameter("servicio_precio")); }catch(Exception e){}
        try{ index_lista_servicio = Integer.parseInt(request.getParameter("index_lista_servicio")); }catch(Exception e){}
        String unidad = request.getParameter("servicio_unidad") != null ? request.getParameter("servicio_unidad") : "No Aplica";
        
        
        //Validaciones
        if (idServicio<=0)
            msgError = "<ul>Servicio no específicado o incorrecto";
        if (cantidad<0)
            msgError = "<ul>Cantidad invalida";
        if (monto<0)
            msgError = "<ul>Monto invalido";
        if (precio<0)
            msgError = "<ul>Precio no específicado o incorrecto";
        if (index_lista_servicio<0)
            msgError = "<ul>Servicio inválido. Si persiste el problema intente recargar esta página.";
        
        if (msgError.equals("")){
            
            monto = precio * cantidad;
            
            try{
                ServicioSesion nuevoServicioSesion = new ServicioSesion();
                nuevoServicioSesion.setCantidad(cantidad);
                nuevoServicioSesion.setPrecio(precio);
                nuevoServicioSesion.setIdServicio(idServicio);
                nuevoServicioSesion.setMonto(monto);
                nuevoServicioSesion.setUnidad(unidad);
                
                pedidoSesion.getListaServicio().set(index_lista_servicio, nuevoServicioSesion);
            }catch(Exception ex){
                msgError+="El servicio especificado no se pudo actualizar. Intente de nuevo.";
            }
            request.getSession().setAttribute("pedidoSesion", pedidoSesion);
            
            if (msgError.equals(""))
                out.print("Servicio actualizado exitosamente");
        }
        
    }else if (mode==19){
        //19 =  Guardar Pedido (Sesion -> BD)  
        
        boolean enviarCorreo = false;
        
        //Parametros
        String comentarios = request.getParameter("comentarios")!=null?new String(request.getParameter("comentarios").getBytes("ISO-8859-1"),"UTF-8"):"";
        String tipo_moneda = request.getParameter("tipo_moneda")!=null?new String(request.getParameter("tipo_moneda").getBytes("ISO-8859-1"),"UTF-8"):"MXN";
        String descuento_motivo = request.getParameter("descuento_motivo")!=null?new String(request.getParameter("descuento_motivo").getBytes("ISO-8859-1"),"UTF-8"):"";
        String lista_correos = request.getParameter("lista_correos")!=null?new String(request.getParameter("lista_correos").getBytes("ISO-8859-1"),"UTF-8"):"";
        int idComprobanteFiscal = 0;
        double adelanto = 0;
        double saldo_pagado = 0;
        Date fecha_entrega = null;
        Date fecha_tentativa_pago = null;  
        int idEstatus = -1;
        idCliente = -1;
        int ventaConsigna = 0;
        
        try{ idCliente = Integer.parseInt(request.getParameter("id_cliente")); }catch(Exception e){}
        try{ idEstatus = Integer.parseInt(request.getParameter("id_estatus")); }catch(Exception e){}        
        try{ idComprobanteFiscal = Integer.parseInt(request.getParameter("pedido_id_cfd")); }catch(Exception e){}
        try{ adelanto = Double.parseDouble(request.getParameter("pedido_adelanto")); }catch(Exception e){}
        try{ saldo_pagado = Double.parseDouble(request.getParameter("pedido_saldo_pagado")); }catch(Exception e){}
        try{ fecha_entrega = new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("pedido_fecha_entrega"));}catch(Exception e){}
        try{ fecha_tentativa_pago = new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("pedido_fecha_tentativa_pago"));}catch(Exception e){}
        try{ ventaConsigna = Integer.parseInt(request.getParameter("ventaConsigna")); }catch(Exception e){}
        int idViaEmbarquePedido = 0;
        try{ idViaEmbarquePedido = Integer.parseInt(request.getParameter("idViaEmbarquePedido")); }catch(Exception e){}
        
        int tipo_pedido = 0;
        try{ tipo_pedido = Integer.parseInt(request.getParameter("tipo_pedido")); }catch(Exception e){}
        
        String[] correos = new String[0];
        ArrayList<String> listCorreosValidos = new ArrayList<String>();
        if (!lista_correos.trim().equals("")){
            correos = lista_correos.split(",");
            
            for (String itemCorreo: correos){
                try { itemCorreo = itemCorreo.trim(); } catch(Exception ex){}
                if (genericValidator.isEmail(itemCorreo)){
                    listCorreosValidos.add(itemCorreo);
                }
            }
            
            if (listCorreosValidos.size()<=0)
                msgError += "Ninguno de los correos proporcionados es válido";
                
            if (listCorreosValidos.size()>0)
                enviarCorreo = true;
        }
            
        //Validaciones
/*        if (!genericValidator.isValidString(comentarios, 1, 500))
            msgError = "<ul>El campo comentarios del pedido es obligatorio. Máximo 500 caracteres. ";
*/        
        if (idCliente<=0)
            msgError+="<ul> Debe seleccionar un cliente para generar el pedido. ";
        
        /*if (idEstatus<=0)
            msgError+="<ul> Debe seleccionar un estatus válido para generar el pedido. ";*/
        
/*        if (fecha_entrega==null)
            msgError+="<ul> Debe seleccionar una fecha de entrega. ";
        
        if (fecha_tentativa_pago==null)
            msgError+="<ul> Debe seleccionar una fecha tentativa de pago. ";
*/        
        
        if (msgError.equals("")){
            if (pedidoSesion==null){
                msgError += "<ul>No se ha inicializado el Pedido, esta vacía. ";
            }else{
                
                //Validaciones de la Solicitud de Compra
                if (pedidoSesion.getListaProducto().size()<=0 && pedidoSesion.getListaServicio().size()<=0)
                    msgError+="<ul> Debe seleccionar al menos un producto o servicio para generar el pedido. Lista de Productos y Servicios vacia. ";
                
                if (pedidoSesion.getDescuento_tasa()>0 && !genericValidator.isValidString(descuento_motivo, 1, 200))
                    msgError+="<ul> Debe expresar el/los motivo(s) del descuento. Máximo 200 caracteres.";
                
                //Verificamos que los productos
                //  tengan el stock necesario para dar salida de almacen.
                if (pedidoSesion.getIdPedido()<=0){
                    //Se hace solo en caso de que el pedido sea nuevo y no si se esta editando
                    try{
                        if(pedidoSesion.getIdCotizacionOrigen()<=0){
                            pedidoSesion.verificaExistenciaProductos();
                        }
                    }catch(Exception ex){
                        msgError += ex.getMessage();
                    }
                }
                
                //Se da salida de almacen
                // a todos los productos seleccionados en el pedido (restar stock)
               /*if (msgError.trim().equals("") && pedidoSesion.getIdPedido()<=0){
                    if (pedidoSesion.getIdPedido()<=0){
                        try{
                            pedidoSesion.salidaAlmacenProductos();
                        }catch(Exception ex){
                            msgError += ex.getMessage();
                        }
                    }
                }*/
                
                SgfensPedido pedidoDto = null;
                File[] adjuntos = new File[0];
                if (msgError.equals("")){
                    pedidoSesion.setComentarios(comentarios);
                    pedidoSesion.setTipo_moneda(tipo_moneda);
                    pedidoSesion.setDescuento_motivo(descuento_motivo);
                    
                    pedidoSesion.setAdelanto(adelanto);
                    pedidoSesion.setSaldoPagado(saldo_pagado);
                    pedidoSesion.setFechaEntrega(fecha_entrega);
                    pedidoSesion.setFechaTentativaPago(fecha_tentativa_pago);
                    pedidoSesion.setIdComprobanteFiscal(idComprobanteFiscal);
                    pedidoSesion.setIdEstatus(idEstatus);
                    pedidoSesion.setConsigna(ventaConsigna);
                    
                    try{
                        if (idCliente>0){
                            pedidoSesion.setCliente(new ClienteBO(idCliente,user.getConn()).getCliente());
                        }
                    }catch(Exception ex){ ex.printStackTrace();}
                    
                    //Para generar un nuevo pedido en cada Guardar
                    //Deshabilitar en caso de querer actualizar en lugar de generar una nueva
                    //pedidoSesion.setIdPedido(0);
                    
                    request.getSession().setAttribute("pedidoSesion", pedidoSesion);
                    pedidoAux = pedidoSesion;
                    
                    SGPedidoBO pedidoBO = new SGPedidoBO(user.getConn());
                    pedidoBO.idViaEmbarquePedido = idViaEmbarquePedido;
                    pedidoSesion.setIdTipoPedido(tipo_pedido);
                    try{
                        try{
                            pedidoDto = pedidoBO.creaActualizaPedido(pedidoSesion, user, ( ZonaHorariaBO.DateZonaHorariaByIdEmpresa(user.getConn(), new Date(), (int)user.getUser().getIdEmpresa()).getTime() ), true);
                        }catch(Exception e){
                            pedidoDto = pedidoBO.creaActualizaPedido(pedidoSesion, user, new Date(), true);
                        }
                    }catch(Exception ex){
                        msgError+= "<ul>Ocurrio un error al almacenar el pedido: <br/>" + ex.toString();
                    }
                    
                    if (enviarCorreo){
                        pedidoBO = new SGPedidoBO(pedidoDto,user.getConn());
                        try{
                            File pedidoPDF = pedidoBO.guardarRepresentacionImpresa(user);
                            adjuntos = new File[1];
                            adjuntos[0] = pedidoPDF;
                        }catch(Exception ex){
                            out.print("<ul> No se pudo crear y adjuntar la representación impresa de la cotización.");
                            ex.printStackTrace();
                        }
                    }

                }
                
                if (msgError.equals("")){
                    out.print("Pedido almacenado satisfactoriamente. <br/><br/><b> Folio de Pedido: " + pedidoDto.getFolioPedido() + "</b>");
                    
                    pedidoSesion = new PedidoSesion();
                    request.getSession().setAttribute("pedidoSesion", pedidoSesion);
                }
                
                if (msgError.equals("")){
                    try{
                        if (enviarCorreo){
                            SGPedidoBO pedidoBO = new SGPedidoBO(pedidoDto.getIdPedido(),user.getConn());
                            out.print("<ul>"+ pedidoBO.enviaNotificacionNuevaPedido(listCorreosValidos,adjuntos,user.getUser().getIdEmpresa()));
                        }
                    }catch(Exception ex){
                        out.print("<ul> No se pudo enviar el correo de notificación.");
                    }
                }
                
            }
        }
        
    }else if (mode==20){
        //20 =  Recargar Select Clientes
        
        idCliente = -1;
        try{ idCliente = Integer.parseInt(request.getParameter("id_cliente")); }catch(Exception e){}
        
        
        // tipoClientes 1 - Normales  2 - Consigna
        tipoClientes = -1;
        try{ tipoClientes = Integer.parseInt(request.getParameter("tipoClientes")); }catch(Exception e){}
        
        recargarSelectClientes = true;
        
    }else if (mode==21){
        //21 = Seleccionar Cliente (obtener datos)
        
        idCliente = -1;
        try{ idCliente = Integer.parseInt(request.getParameter("id_cliente")); }catch(Exception e){}
        
        Cliente clienteDto = new ClienteBO(idCliente,user.getConn()).getCliente();
        
        String jsonOutput = gson.toJson(clienteDto);
        out.print("<!--EXITO-->"+jsonOutput);
        
    }else if (mode==22){
        //Facturar Pedido
        
        //Parametros
        int id_pedido = -1;
        try{ id_pedido = Integer.parseInt(request.getParameter("id_pedido")); }catch(Exception e){}
        int tipoFactura = -1; //1 Normal , 2 Impuestos
        try{ tipoFactura = Integer.parseInt(request.getParameter("tipoFactura")); }catch(Exception e){}
        
        //Procesamiento
        if (id_pedido>=0){
            SGPedidoBO pedidoSesionBO = new SGPedidoBO(id_pedido,user.getConn());
            pedidoSesion = pedidoSesionBO.getSessionFromPedidoDB();
            if (pedidoSesion.getIdComprobanteFiscal()>0){
                msgError+= "<ul> Este pedido ya fue facturado, el ID de la factura es: " + pedidoSesion.getIdComprobanteFiscal();
            }
            if (msgError.equals("")){
                
                
/*                if(tipoFactura==1){//Fact normal
                    ComprobanteFiscalSesion comprobanteFiscalSesion = pedidoSesionBO.convertirAComprobanteFiscalSesion(pedidoSesion);

                    request.getSession().setAttribute("cfdiSesion", comprobanteFiscalSesion);
                }else if(tipoFactura==2){//fact con impuestos
                    SGPedidoProductoBO pedidoProductoBO = new SGPedidoProductoBO(user.getConn());                        
                    SgfensPedidoProducto[] productosPedido = pedidoProductoBO.findByIdPedido(id_pedido, -1, -1, -1, "");

                    boolean factImp = false;
                    for(SgfensPedidoProducto itemConcepto:productosPedido){

                        ImpuestoPorConceptoBO porConceptoBO = new ImpuestoPorConceptoBO(user.getConn());            
                        ImpuestoPorConcepto[] impuestos = porConceptoBO.findImpuestoPorConceptos(0, 0, 0, 0, " AND ID_CONCEPTO = " + itemConcepto.getIdConcepto() + " AND ID_ESTATUS != 2 ");

                        if(impuestos.length>0){//Si algún producto tiene impuestos, se puede generar la factura
                            factImp = true;
                        }                
                    }
                    
                    if(factImp){
                        ComprobanteFiscalSesion comprobanteFiscalSesion = pedidoSesionBO.convertirAComprobanteFiscalSesion(pedidoSesion);
                        request.getSession().setAttribute("cfdiSesion", comprobanteFiscalSesion);
                        out.print("<!--EXITO-->El pedido se puede facturar con impuestos.");
                    }else{
                         msgError += "<ul> Los conceptos del pedido no tienen<br/>impuestos relacionados.";
                    }
                    
                    
                }
*/               
            }
        }else{
            msgError += "<ul> No se específico el identificador (ID) del Pedido a recuperar. Intente de nuevo.";
        }
        
    }else if (mode==23){
        //23 = Cancelar Pedido (Pedido + CFDI)
        
        //Parametros
        int id_pedido = -1;
        try{ id_pedido = Integer.parseInt(request.getParameter("id_pedido")); }catch(Exception e){}
        
        //Procesamiento
        if (id_pedido>=0){
            SGPedidoBO pedidoSesionBO = new SGPedidoBO(id_pedido,user.getConn());           
            SgfensPedido pedidoDto = pedidoSesionBO.getPedido();
            
            //si es en consigna obtenemos idEmpleado-Cliente
            Cliente clienteDto = null;
            Usuarios empCliente = null;                     
                    
/*            if(pedidoDto.getConsigna()==1){
                //Buscamos empleado correspondiente al cliente
                clienteDto = new ClienteBO(pedidoDto.getIdCliente(),user.getConn()).getCliente();
                empCliente = new UsuariosBO(clienteDto.getIdVendedorConsigna(),user.getConn()).getEmpleado();
                
            }
*/            
            
            /*
            SgfensPedido pedidoDto = pedidoSesionBO.getPedido();
            if (pedidoDto.getIdComprobanteFiscal()>0){
                //Existe un CFDI relacionado al pedido
                ComprobanteFiscalBO comprobanteFiscalBO = new ComprobanteFiscalBO(pedidoDto.getIdComprobanteFiscal());
                try{
                    comprobanteFiscalBO.cancelaComprobanteFiscal();
                }catch(Exception ex){
                    msgError+="<ul>El pedido tiene una factura relacionada. Ocurrio un error al cancelar la factura (CFDI).<br/>" + ex.toString();
                }
            }
            
            if (msgError.equals("")){
            try{                
                    pedidoDto.setIdEstatusPedido((short)SGEstatusPedidoBO.ESTATUS_CANCELADO);
                
                    new SgfensPedidoDaoImpl(user.getConn()).update(pedidoDto.createPk(), pedidoDto);
                }catch(Exception ex){
                    msgError += "<ul>Error al actualizar estatus de pedido a cancelado. " +ex.toString();
                }
                
                if (msgError.equals(""))
                    out.print("<!--EXITO-->El pedido ha sido cancelado satisfactoriamente.");
            }
            */
            
            try{                
                
                SGPedidoProductoBO pedidoProductoBO = new SGPedidoProductoBO(user.getConn());                        
                SgfensPedidoProducto[] productosPedido = pedidoProductoBO.findByIdPedido(id_pedido, -1, -1, -1, "");
                ConceptoBO conceptoBO;
                Concepto conceptoDto;      
                
                
               //regresa prods a inventario
                if (productosPedido!=null){
                    
                    EmpresaBO empresaBO = new EmpresaBO(user.getConn());
                    EmpresaPermisoAplicacion empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl().findByPrimaryKey(empresaBO.getEmpresaMatriz(pedidoDto.getIdEmpresa()).getIdEmpresa());     
                    
                    //Recorremos por primera vez para asegurar integridad
                    //Solo en caso de que todos los productos tengan stock suficiente se daran de baja TODOS
                    //  de lo contrario, no se dara de baja ninguno.  
                    boolean regresaInv = true;
                    for (SgfensPedidoProducto productoDto : productosPedido){
                          
                        conceptoBO = new ConceptoBO(productoDto.getIdConcepto(),user.getConn());
                        conceptoDto = conceptoBO.getConcepto();
                       
                        if (conceptoDto!=null){
                            if (empresaPermisoAplicacionDto != null) {
/*                                if (empresaPermisoAplicacionDto.getRevisionCantidadProducto() == 1) {
                                    if(pedidoDto.getIdEstatusPedido()== 2 ){ //Verificamo que el pedido ya se ha entregado
                                        
                                        if(pedidoDto.getConsigna()==1){
                                            EmpleadoInventarioRepartidor[] inventarios = new EmpleadoInventarioRepartidorDaoImpl(user.getConn()).findByDynamicWhere("ID_EMPLEADO = " + empCliente.getIdEmpleado() +" AND ID_CONCEPTO = "+conceptoDto.getIdConcepto() + " AND ID_ESTATUS = 1 " , null);
                                           /* validamos que el vendedor aun tenga la existencia de los productos entregados
                                            para que pueda regresar todo el pedido, si no la tiene no se puede cancelar
                                            es decir se regresan todos los productos o ninguno */
                                            
/*                                            if(inventarios != null){
                                                if(inventarios.length > 0){
                                                    for(EmpleadoInventarioRepartidor inventarioVal:inventarios){
                                                        
                                                        BigDecimal numArticulosDisponibles = (new BigDecimal(inventarioVal.getCantidad())).setScale(2, RoundingMode.HALF_UP);
                                                        BigDecimal prodSesionCantidad = (new BigDecimal(productoDto.getCantidad())).setScale(2, RoundingMode.HALF_UP);
                                                        BigDecimal stockTotal = numArticulosDisponibles.subtract(prodSesionCantidad);
                                                        System.out.println("Stock disp.." + numArticulosDisponibles + "quitar..." + prodSesionCantidad  + " total .. " + stockTotal );
                                                        double nuevoStock = stockTotal.doubleValue();
                                                       
                                                        if (nuevoStock < 0) {
                                                            
                                                            msgError += "<ul>El stock del articulo '" + conceptoDto.getNombreDesencriptado() + "' del Vendedor es insuficiente para cubrir la operación.<br/>No. de Articulos disponibles: " + inventarioVal.getCantidad();                                            
                                                            
                                                        }
                                                       
                                                    }
                                                      
                                                }else{
                                                    msgError += "<ul>El stock del articulo '" + conceptoDto.getNombreDesencriptado() + "' del Vendedor es insuficiente para cubrir la operación.<br/>";                                            
                                                  
                                                }
                                            }else{
                                                msgError += "<ul>El stock del articulo '" + conceptoDto.getNombreDesencriptado() + "' del Vendedor es insuficiente para cubrir la operación.<br/>";                                                                                            
                                                
                                            }
                                            
                                            
                                        }
                                        
                                        
                                    }else{
                                        pedidoSesionBO.cancelarPedido(true, true);
                                        regresaInv = false;                                                                                       
                                    }                 
                                }
*/                            }
                        }

                      }
                    
                   
                 //Verificamos si se consulta el stock o no
                
                if (empresaPermisoAplicacionDto != null) {
/*                    if (empresaPermisoAplicacionDto.getRevisionCantidadProducto() == 1) {        

                        //recorremo segunda vez para regresar inventario del vendedor al almacen general, una vez validada la existencia     
                        if(msgError.equals("") && regresaInv){                   
                            for (SgfensPedidoProducto productoDto : productosPedido){
                                conceptoBO = new ConceptoBO(productoDto.getIdConcepto(),user.getConn());
                                conceptoDto = conceptoBO.getConcepto();

                                if (conceptoDto!=null){

                                    //Verificamos si se consulta el stock o no
                                    //EmpresaBO empresaBO = new EmpresaBO(user.getConn());
                                    //EmpresaPermisoAplicacion empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl().findByPrimaryKey(empresaBO.getEmpresaMatriz(conceptoBO.getConcepto().getIdEmpresa()).getIdEmpresa());     
                                    if (empresaPermisoAplicacionDto != null) {
                                        if (empresaPermisoAplicacionDto.getRevisionCantidadProducto() == 1) {
                                            //if(pedidoDto.getIdEstatusPedido()== 2 ){ //Verificamo que el pedido ya se ha entregado


                                                regresaInv = true;//si no es en consigna, lo regresa directo a inventario sin validar stock vendedor                                        

                                                if(pedidoDto.getConsigna()==1){                                            


                                                    EmpleadoInventarioRepartidor[] inventarios = new EmpleadoInventarioRepartidorDaoImpl(user.getConn()).findByDynamicWhere("ID_EMPLEADO = " + empCliente.getIdEmpleado() +" AND ID_CONCEPTO = "+conceptoDto.getIdConcepto() + " AND ID_ESTATUS = 1 " , null);
                                                    EmpleadoInventarioRepartidor inventario = null;


                                                    //Recorremos segunda vez damos de baja todos los prods
                                                    if(inventarios != null){
                                                        if(inventarios.length > 0){
                                                            inventario = inventarios[0]; 

                                                             //Verificamos si se consulta el stock o no
                                                            empresaBO = new EmpresaBO(user.getConn());
                                                            empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl().findByPrimaryKey(empresaBO.getEmpresaMatriz(conceptoBO.getConcepto().getIdEmpresa()).getIdEmpresa());     
                                                            if (empresaPermisoAplicacionDto != null) {
                                                                if (empresaPermisoAplicacionDto.getRevisionCantidadProducto() == 1) {

                                                                    BigDecimal numArticulosDisponibles = (new BigDecimal(inventario.getCantidad())).setScale(2, RoundingMode.HALF_UP);
                                                                    BigDecimal prodSesionCantidad = (new BigDecimal(productoDto.getCantidad())).setScale(2, RoundingMode.HALF_UP);
                                                                    BigDecimal stockTotal = numArticulosDisponibles.subtract(prodSesionCantidad);
                                                                    System.out.println("Stock disp.." + numArticulosDisponibles + "quitar..." + prodSesionCantidad  + " total .. " + stockTotal );
                                                                    double nuevoStock = stockTotal.doubleValue();
                                                                    if (nuevoStock < 0) {

                                                                        msgError += "<ul>El stock del articulo '" + conceptoDto.getNombreDesencriptado() + "' del Vendedor es insuficiente para cubrir la operación.<br/>No. de Articulos disponibles: " + inventario.getCantidad();                                            
                                                                        regresaInv = false;

                                                                    }else{

                                                                         inventario.setCantidad(stockTotal.doubleValue());               
                                                                        new EmpleadoInventarioRepartidorDaoImpl(user.getConn()).update(inventario.createPk(), inventario);
                                                                    }
                                                                }
                                                            }
                                                        }else{
                                                            msgError += "<ul>El stock del articulo '" + conceptoDto.getNombreDesencriptado() + "' del Vendedor es insuficiente para cubrir la operación.<br/>No. de Articulos disponibles: " + inventario.getCantidad();                                            
                                                            regresaInv = false;

                                                        }
                                                    }else{

                                                        msgError += "<ul>El stock del articulo '" + conceptoDto.getNombreDesencriptado() + "' del Vendedor es insuficiente para cubrir la operación.<br/>No. de Articulos disponibles: " + inventario.getCantidad();                                            
                                                        regresaInv = false;
                                                    }

                                                }
                                                ////////////////////


                                                if(regresaInv){
                                                    ExistenciaAlmacen almPrincipal = null;
                                                    ExistenciaAlmacenBO exisAlmBO = new ExistenciaAlmacenBO(user.getConn());
                                                    almPrincipal = exisAlmBO.getExistenciaProductoAlmacen(productoDto.getIdAlmacenOrigen(), conceptoDto.getIdConcepto());

                                                    BigDecimal numArticulosDisponibles = (new BigDecimal(almPrincipal!=null?almPrincipal.getExistencia():0)).setScale(2, RoundingMode.HALF_UP);
                                                    BigDecimal prodSesionCantidad = (new BigDecimal(productoDto.getCantidad())).setScale(2, RoundingMode.HALF_UP);
                                                    BigDecimal stockTotal = numArticulosDisponibles.add(prodSesionCantidad);

                                                    double nuevoStock = stockTotal.doubleValue();  

                                                    //Creamos registro de movimiento de almacen
                                                    Movimiento movimientoDto = new Movimiento();
                                                    MovimientoDaoImpl movimientosDaoImpl = new MovimientoDaoImpl();
                                                    int idEmpresa = conceptoDto.getIdEmpresa();

                                                    movimientoDto.setIdEmpresa(idEmpresa);
                                                    movimientoDto.setTipoMovimiento("ENTRADA");
                                                    movimientoDto.setNombreProducto(conceptoBO.getNombreConceptoLegible());
                                                    movimientoDto.setContabilidad(productoDto.getCantidad());
                                                    movimientoDto.setIdProveedor(-1);
                                                    movimientoDto.setOrdenCompra("");
                                                    movimientoDto.setNumeroGuia("");
                                                    //movimientoDto.setIdAlmacen(alamacenMovimiento);
                                                    movimientoDto.setIdAlmacen(productoDto.getIdAlmacenOrigen());
                                                    movimientoDto.setConceptoMovimiento("Cancelación de Venta (Pedido/Factura)");                
                                                    movimientoDto.setFechaRegistro(new Date());
                                                    movimientoDto.setIdConcepto(conceptoDto.getIdConcepto());

                                                    /**
                                                    * Realizamos el insert
                                                    */
/*                                                    if(pedidoDto.getFolioPedidoMovil()==null){
                                                        movimientosDaoImpl.insert(movimientoDto);
                                                    }

                                                    //Actualizamos registro único de concepto                                            


                                                    almPrincipal.setExistencia(nuevoStock);
                                                    new ExistenciaAlmacenBO(user.getConn()).updateBD(almPrincipal);
                                                    /*Antes de alamcenes
                                                    conceptoDto.setNumArticulosDisponibles(nuevoStock);
                                                    conceptoBO.updateBD(conceptoDto);*/

                                                    //Ponemos pedido como cancelado
/*                                                    pedidoSesionBO.cancelarPedido(true, true);
                                                    /*pedidoDto.setIdEstatusPedido((short)SGEstatusPedidoBO.ESTATUS_CANCELADO);
                                                    pedidoDto.setIsModificadoConsola((short)1);
                                                    new SgfensPedidoDaoImpl(user.getConn()).update(pedidoDto.createPk(), pedidoDto);*/

/*                                                }else{
                                                   msgError += "<ul>El vendedor no cuenta con la existencia suficiente para regresar los productos."; 
                                                }


                                            /*}else{
                                                pedidoSesionBO.cancelarPedido(true, true);
                                            }*/
/*                                        }
                                    }


                                }else{
                                    msgError += "<ul>El producto con id " + conceptoDto.getIdConcepto() + "no existe en la base de datos, probablemente fue eliminado en otro sesion alterna.";
                                }
                            }
                        }
                    }else{
*/                        //Ponemos pedido como cancelado
                        pedidoSesionBO.cancelarPedido(true, true);
/*                    }
*/                 }
               }
                             
            }catch(Exception ex){
                msgError += ex.toString();
                ex.printStackTrace();
            }
            
            if (msgError.equals(""))
                    out.print("<!--EXITO-->El pedido ha sido cancelado satisfactoriamente.");
            
            
        }else{
            msgError += "<ul> No se específico el identificador (ID) del Pedido a recuperar. Intente de nuevo.";
        }
        
    }else if (mode==24){
        //24 = Marcar como entregado el pedido
        
        //Parametros
        int id_pedido = -1;
        try{ id_pedido = Integer.parseInt(request.getParameter("id_pedido")); }catch(Exception e){}
        
        //Procesamiento
        if (id_pedido>=0){
            SGPedidoBO pedidoSesionBO = new SGPedidoBO(id_pedido,user.getConn());
            SgfensPedido pedidoDto = pedidoSesionBO.getPedido();
            ArrayList<Concepto> listaConceptos = new ArrayList<Concepto>();
            
            if (msgError.equals("")){
                try{
                        
                        SGPedidoProductoBO pedidoProductoBO = new SGPedidoProductoBO(user.getConn());                        
                        SgfensPedidoProducto[] productosPedido = pedidoProductoBO.findByIdPedido(id_pedido, -1, -1, -1, "");

                        ConceptoBO conceptoBO = null;
                        Concepto conceptoDto;  
                        
                        ExistenciaAlmacen almPrincipal = null;
                        ExistenciaAlmacenBO exisAlmBO = new ExistenciaAlmacenBO(user.getConn());
                        

                        //Recorremos por primera vez para asegurar integridad
                        //Solo en caso de que todos los productos tengan stock suficiente se daran de baja TODOS
                        //  de lo contrario, no se dara de baja ninguno.
                        for (SgfensPedidoProducto productoDto : productosPedido){
                            conceptoBO = new ConceptoBO(productoDto.getIdConcepto(),user.getConn());
                            conceptoDto = conceptoBO.getConcepto();
                            
                            if (conceptoDto!=null){ 
                                
                                 //Verificamos si se consulta el stock o no
                                EmpresaBO empresaBO = new EmpresaBO(user.getConn());
                                EmpresaPermisoAplicacion empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl().findByPrimaryKey(empresaBO.getEmpresaMatriz(conceptoBO.getConcepto().getIdEmpresa()).getIdEmpresa());     
                                if (empresaPermisoAplicacionDto != null) {
/*                                    if (empresaPermisoAplicacionDto.getRevisionCantidadProducto() == 1) {
                                        
                                        
                                        if(productoDto.getIdAlmacenOrigen()>0){                                     
                                            almPrincipal = exisAlmBO.getExistenciaProductoAlmacen(productoDto.getIdAlmacenOrigen(), conceptoDto.getIdConcepto());
                                        }else if(productoDto.getIdAlmacenOrigen()==0){
                                            Almacen almacenGral =  null;
                                            AlmacenBO almacenGralBO = new AlmacenBO(user.getConn());
                                            almacenGral =  almacenGralBO.getAlmacenPrincipalByEmpresa(user.getUser().getIdEmpresa());
                                            
                                            almPrincipal = exisAlmBO.getExistenciaProductoAlmacen(almacenGral.getIdAlmacen(), conceptoDto.getIdConcepto());
                                        }
                                        
                                        BigDecimal numArticulosDisponibles = (new BigDecimal(almPrincipal!=null?almPrincipal.getExistencia():0)).setScale(2, RoundingMode.HALF_UP);
                                        BigDecimal prodSesionCantidad = (new BigDecimal(productoDto.getCantidad()-productoDto.getCantidadEntregada())).setScale(2, RoundingMode.HALF_UP);
                                        BigDecimal stockTotal = numArticulosDisponibles.subtract(prodSesionCantidad);

                                        double nuevoStock = stockTotal.doubleValue();
                                        if (nuevoStock < 0) {
                                            msgError += "<ul>El stock del articulo '" + conceptoBO.getNombreConceptoLegible() + "' en el almacén es insuficiente para cubrir la operación.<br/>No. de Articulos disponibles: " + (almPrincipal!=null?almPrincipal.getExistencia():0);                                            
                                        } else {
                                            listaConceptos.add(conceptoDto);                                            
                                        }
                                    }
*/                                }
                            }
                        }
                        
                        
                         //Verificamos si se consulta el stock o no
                        
                        EmpresaBO empresaBO = new EmpresaBO(user.getConn());
                        EmpresaPermisoAplicacion empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl().findByPrimaryKey(empresaBO.getEmpresaMatriz(conceptoBO.getConcepto().getIdEmpresa()).getIdEmpresa());     
                        if (empresaPermisoAplicacionDto != null) {
/*                            if (empresaPermisoAplicacionDto.getRevisionCantidadProducto() == 1) {

                                //Se recorre por segunda ocasion
                                //  Una vez que aseguramos la integridad y que todos los productos tienen stock suficiente
                                //  procedemos a darlos de baja del almacen (movimientos) y a actualizar su registro único.
                        
                                if (listaConceptos.size()>0 && msgError.equals("") ){
                                    for (SgfensPedidoProducto productoDto : productosPedido){
                                        conceptoBO = new ConceptoBO(productoDto.getIdConcepto(),user.getConn());
                                        conceptoDto = conceptoBO.getConcepto();

                                        if (conceptoDto!=null){
                                            
                                            int almacenDescuentaMerca = 0;
                                            
                                            
                                            
                                            
                                            if(productoDto.getIdAlmacenOrigen()>0){                                     
                                                almPrincipal = exisAlmBO.getExistenciaProductoAlmacen(productoDto.getIdAlmacenOrigen(), conceptoDto.getIdConcepto());
                                            }else if(productoDto.getIdAlmacenOrigen()==0){
                                                Almacen almacenGral =  null;
                                                AlmacenBO almacenGralBO = new AlmacenBO(user.getConn());
                                                almacenGral =  almacenGralBO.getAlmacenPrincipalByEmpresa(user.getUser().getIdEmpresa());

                                                almPrincipal = exisAlmBO.getExistenciaProductoAlmacen(almacenGral.getIdAlmacen(), conceptoDto.getIdConcepto());
                                            }

                                            BigDecimal numArticulosDisponibles = (new BigDecimal(almPrincipal!=null?almPrincipal.getExistencia():0)).setScale(2, RoundingMode.HALF_UP);
                                            BigDecimal prodSesionCantidad = (new BigDecimal(productoDto.getCantidad()-productoDto.getCantidadEntregada())).setScale(2, RoundingMode.HALF_UP);
                                            BigDecimal stockTotal = numArticulosDisponibles.subtract(prodSesionCantidad);

                                            double nuevoStock = stockTotal.doubleValue();                
                                            double prodCantidadEntregada = prodSesionCantidad.doubleValue(); 
                                            if (nuevoStock<0){
                                                msgError+="<ul>El stock del articulo '" + conceptoBO.getNombreConceptoLegible() + "' en el almacén es insuficiente para cubrir la operación.<br/>No. de Articulos disponibles: " + (almPrincipal!=null?almPrincipal.getExistencia():0);
                                            }else{


                                                //actualizamos partida producto

                                                SGPedidoProductoBO prodPedidoBO = new SGPedidoProductoBO(user.getConn());
                                                SgfensPedidoProducto conceptoOriginalDto = prodPedidoBO.findByIdConcepto(conceptoDto.getIdConcepto(), -1, -1, " ID_PEDIDO = " + id_pedido)[0];
                                                conceptoOriginalDto.setCantidadEntregada(conceptoOriginalDto.getCantidadEntregada() + prodCantidadEntregada);
                                                conceptoOriginalDto.setFechaEntrega(new Date());
                                                conceptoOriginalDto.setEstatus((short)1);


                                                new SgfensPedidoProductoDaoImpl(user.getConn()).update(conceptoOriginalDto.createPk(),conceptoOriginalDto);

                                                

                                                //Actualizamos registro único de concepto en almacen principal
                                                
                                                almPrincipal.setExistencia(nuevoStock);
                                                new ExistenciaAlmacenBO(user.getConn()).updateBD(almPrincipal);
                                                
                                                //conceptoDto.setNumArticulosDisponibles(nuevoStock);
                                                //conceptoBO.updateBD(conceptoDto);

                                                //Ponemos pedido como entregaso
                                                pedidoDto.setIdEstatusPedido((short)SGEstatusPedidoBO.ESTATUS_ENTREGADO);
                                                pedidoDto.setIsModificadoConsola((short)1);
                                                new SgfensPedidoDaoImpl(user.getConn()).update(pedidoDto.createPk(), pedidoDto);                                        
                                                    
                                                //Consumo de Creditos Operacion
                                                try{
                                                    BitacoraCreditosOperacionBO bcoBO = new BitacoraCreditosOperacionBO(user.getConn());
                                                    bcoBO.registraDescuento(user.getUser(), 
                                                            BitacoraCreditosOperacionBO.CONSUMO_ACCION_WS_REGISTRO_ENTREGA, 
                                                            null, pedidoDto.getIdCliente(), 0, pedidoDto.getTotal(), 
                                                            "Registro Entrega de Pedido", null, true);
                                                }catch(Exception ex){
                                                    ex.printStackTrace();
                                                }

                                                /* Si el pedido es en consigna se asigna el invetario vendido al vendedor */

/*                                                if(pedidoDto.getConsigna()==1){

                                                    //Buscamos empleado correspondiente al cliente
                                                    Cliente clienteDto = new ClienteBO(pedidoDto.getIdCliente(),user.getConn()).getCliente();
                                                    Empleado empCliente = new EmpleadoBO(clienteDto.getIdVendedorConsigna(),user.getConn()).getEmpleado();

                                                    //verificamos si ya existe en inventario el articulo
                                                    EmpleadoInventarioRepartidor[] inventarios = new EmpleadoInventarioRepartidorDaoImpl(user.getConn()).findByDynamicWhere("ID_EMPLEADO = "+empCliente.getIdEmpleado()+" AND ID_CONCEPTO = "+conceptoDto.getIdConcepto(), null);
                                                    if(inventarios.length > 0){//si existe lo actualizamos 

                                                        EmpleadoInventarioRepartidor inventarioExistente = inventarios[0];
                                                        //Si esta activo avisamos que ya se encuentra en el inventario del repartidor, cuando es nuevo, pero si se esta modificando la cantidad, vemos de que producto se actualiza:
                                                        if(inventarioExistente.getIdEstatus() == 1){

                                                            inventarioExistente.setIdEstatus(1);
                                                            inventarioExistente.setCantidad( (inventarioExistente.getCantidad() + prodCantidadEntregada) );
                                                            new EmpleadoInventarioRepartidorDaoImpl(user.getConn()).update(inventarioExistente.createPk(), inventarioExistente);

                                                        }else{//Si esta inactivo:      

                                                            inventarioExistente.setIdEstatus(1);
                                                            inventarioExistente.setCantidad(prodCantidadEntregada);
                                                            new EmpleadoInventarioRepartidorDaoImpl(user.getConn()).update(inventarioExistente.createPk(), inventarioExistente);
                                                            out.print("<!--EXITO-->Inventario actualizado satisfactoriamente");
                                                        }
                                                    }else{//si no existe lo creamos

                                                        EmpleadoInventarioRepartidor inventario = new EmpleadoInventarioRepartidor();
                                                        inventario.setIdEmpleado(empCliente.getIdEmpleado());
                                                        inventario.setIdConcepto(conceptoDto.getIdConcepto());
                                                        inventario.setTipoProductoServicio(1);//0 es servicio, 1 concepto.
                                                        inventario.setCantidad(prodCantidadEntregada);
                                                        inventario.setIdEstatus(1);
                                                        new EmpleadoInventarioRepartidorDaoImpl(user.getConn()).insert(inventario);
                                                        out.print("<!--EXITO-->Inventario asignado satisfactoriamente");
                                                    }

                                                }
                                                /*fin asignacion pedido*/


                                                //Creamos registro de movimiento de almacen
/*                                                Movimiento movimientoDto = new Movimiento();
                                                MovimientoDaoImpl movimientosDaoImpl = new MovimientoDaoImpl();
                                                int idEmpresa = conceptoDto.getIdEmpresa();

                                                movimientoDto.setIdEmpresa(idEmpresa);
                                                movimientoDto.setTipoMovimiento("SALIDA");
                                                movimientoDto.setNombreProducto(conceptoBO.getNombreConceptoLegible());
                                                movimientoDto.setContabilidad(prodCantidadEntregada);
                                                movimientoDto.setIdProveedor(-1);
                                                movimientoDto.setOrdenCompra("");
                                                movimientoDto.setNumeroGuia("");
                                                //movimientoDto.setIdAlmacen(alamacenMovimiento);
                                                movimientoDto.setIdAlmacen(almPrincipal.getIdAlmacen());
                                                movimientoDto.setConceptoMovimiento("Operación de Venta (Pedido/Factura)");                
                                                movimientoDto.setFechaRegistro(new Date());
                                                movimientoDto.setIdConcepto(conceptoDto.getIdConcepto());
                                                
                                                /**
                                                * Realizamos el insert
                                                */
/*                                                movimientosDaoImpl.insert(movimientoDto);

                                            }
                                        }else{
                                            msgError += "<ul>El producto con id " + conceptoDto.getIdConcepto() + "no existe en la base de datos, probablemente fue eliminado en otro sesion alterna.";
                                        }

                                    }
                                }                        
                                       
                            }else{
*/                                //solamente ponemos pedido como entregado si no e valida existencia
                                pedidoDto.setIdEstatusPedido((short)SGEstatusPedidoBO.ESTATUS_ENTREGADO);
                                pedidoDto.setIsModificadoConsola((short)1);
                                new SgfensPedidoDaoImpl(user.getConn()).update(pedidoDto.createPk(), pedidoDto);                                        

                                //Consumo de Creditos Operacion
/*                                try{
                                    BitacoraCreditosOperacionBO bcoBO = new BitacoraCreditosOperacionBO(user.getConn());
                                    bcoBO.registraDescuento(user.getUser(), 
                                            BitacoraCreditosOperacionBO.CONSUMO_ACCION_WS_REGISTRO_ENTREGA, 
                                            null, pedidoDto.getIdCliente(), 0, pedidoDto.getTotal(), 
                                            "Registro Entrega de Pedido", null, true);
                                }catch(Exception ex){
                                    ex.printStackTrace();
                                }                            
*/                            
/*                            }
*/                        }
                    
                }catch(Exception ex){
                    ex.printStackTrace();
                    msgError += "<ul>Error al actualizar estatus de pedido a entregado. " +ex.toString();
                }
                
                if (msgError.equals(""))
                    out.print("<!--EXITO-->El estado del pedido ha sido actualizado satisfactoriamente.");
            }
            
        }else{
            msgError += "<ul> No se específico el identificador (ID) del Pedido a marcar como entregado. Intente de nuevo.";
        }
        
    }else if (mode==25){
        //Sugerir precio en base a la cantida de producto seleccionada
        int productoId = -1;        
        try{ productoId = Integer.parseInt(request.getParameter("producto_id")); }catch(Exception e){}
        double cantidadProducto = -1;
        try{ cantidadProducto = Double.parseDouble(request.getParameter("producto_cantidad")); }catch(Exception e){}
        
         ConceptoBO conceptoBO;
         Concepto conceptoDto = new Concepto(); 
        try{
           conceptoBO = new ConceptoBO(productoId,user.getConn());
           conceptoDto = conceptoBO.getConcepto();
        }catch(Exception e){}        
        
        
        if(GenericUtil.esMultiplo(cantidadProducto, 12)){ //Docena y multiplos       
            out.print("<!--EXITO-->"+conceptoDto.getPrecioDocena());
        }else if(cantidadProducto <= conceptoDto.getMaxMenudeo()){            
            out.print("<!--EXITO-->"+conceptoDto.getPrecio());
        }else if(cantidadProducto >= conceptoDto.getMinMedioMayoreo() && cantidadProducto <= conceptoDto.getMaxMedioMayoreo()){            
            out.print("<!--EXITO-->"+conceptoDto.getPrecioMedioMayoreo());
        }else if(cantidadProducto >= conceptoDto.getMinMayoreo()){           
            out.print("<!--EXITO-->"+conceptoDto.getPrecioMayoreo());
        }else{            
            out.print("<!--EXITO-->"+conceptoDto.getPrecio());
        }        
        
    }else if (mode==26){
       //Asignar vendedor  y repartidor al pedido
        
        //Parametros
        int id_pedido = -1;
        try{ id_pedido = Integer.parseInt(request.getParameter("id_pedido")); }catch(Exception e){}
        
        int idVendedorAsignado = 0;
        try{ idVendedorAsignado = Integer.parseInt(request.getParameter("idVendedorAsignado")); }catch(Exception e){}
        
        int idConductorAsignado = 0;
        try{ idConductorAsignado = Integer.parseInt(request.getParameter("idConductorAsignado")); }catch(Exception e){}
        
        int idVendedorCompartido = 0;
        try{ idVendedorCompartido = Integer.parseInt(request.getParameter("idVendedorCompartido")); }catch(Exception e){}
        Date fechaLimite = null;
        try{
            fechaLimite = new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("q_fh_min"));            
        }catch(Exception e){}
        
        int compartidoFecha = 0;//checbox para marcar si se comparte hasta una fecha
        try{ compartidoFecha = Integer.parseInt(request.getParameter("compartidoFecha")); }catch(Exception e){}
        
        
        
        if (id_pedido>=0){
            
            if (idVendedorAsignado<=0)
                msgError = "<ul>Vendedor no específicado o incorrecto";
            if (idConductorAsignado<=0)
                msgError = "<ul>Conductor no específicado o incorrecto";            
            
            
            if (msgError.equals("")){
                
                SGPedidoBO pedidoSesionBO = new SGPedidoBO(id_pedido,user.getConn());
                SgfensPedido pedidoDto = pedidoSesionBO.getPedido();
                                               
                pedidoDto.setIdUsuarioVendedorAsignado(idVendedorAsignado);
                pedidoDto.setIdUsuarioConductorAsignado(idConductorAsignado);                
                
                pedidoDto.setIdUsuarioVendedorReasignado(idVendedorCompartido);
                if(compartidoFecha == 1){
                    pedidoDto.setFechaLimiteReasigancion(fechaLimite);
                }
                
/*                SgfensClienteVendedor clienteVendedorDto = null;    
                try{
                    clienteVendedorDto =  new SGClienteVendedorBO(pedidoDto.getIdCliente(),user.getConn()).getClienteVendedor();                   
                }catch(Exception e){
                    e.printStackTrace();
                };
*/                
                
                try{                            
                    //Asignar pedido a vendedor
                    new SgfensPedidoDaoImpl(user.getConn()).update(pedidoDto.createPk(), pedidoDto);  
                    
                    //Asignar cliente a vendedor
/*                    if(clienteVendedorDto!=null){                          
                        clienteVendedorDto.setIdUsuarioVendedor(idVendedorAsignado);
                        clienteVendedorDto.setIdUsuarioConductorAsignado(idConductorAsignado);
                        new SgfensClienteVendedorDaoImpl(user.getConn()).update(clienteVendedorDto.createPk(), clienteVendedorDto);
                    }else{
                        clienteVendedorDto = new SgfensClienteVendedor();
                        clienteVendedorDto.setIdUsuarioVendedor(idVendedorAsignado);
                        clienteVendedorDto.setIdUsuarioConductorAsignado(idConductorAsignado);
                        clienteVendedorDto.setIdCliente(pedidoDto.getIdCliente());
                        new SgfensClienteVendedorDaoImpl(user.getConn()).insert(clienteVendedorDto);
                    }
*/                    
                    
                }catch(Exception ex){
                    msgError += "<ul>Error al asignar pedido. " +ex.toString();
                }
                
                if (msgError.equals(""))
                    out.print("<!--EXITO-->El pedido ha sido asignado satisfactoriamente.");
                

            }else{
               out.print("<!--ERROR-->"+msgError);
            }
            
            
        }else{
                msgError += "<ul> No se específico el identificador (ID) de la Pedido a recuperar. Intente de nuevo.";
       }
         
        
    }/*else if (mode==27){//Verifica si los conceptos del pedido tiene impuestos relacionados
                        //para realizar factura con impuestos

        //Parametros       
        int id_pedido = -1;
        try{ id_pedido = Integer.parseInt(request.getParameter("id_pedido")); }catch(Exception e){}
        
        
        if (id_pedido>=0){
            
            
            SGPedidoProductoBO pedidoProductoBO = new SGPedidoProductoBO(user.getConn());                        
            SgfensPedidoProducto[] productosPedido = pedidoProductoBO.findByIdPedido(id_pedido, -1, -1, -1, "");
            
            
            for(SgfensPedidoProducto itemConcepto:productosPedido){
                
                ImpuestoPorConceptoBO porConceptoBO = new ImpuestoPorConceptoBO(user.getConn());            
                ImpuestoPorConcepto[] impuestos = porConceptoBO.findImpuestoPorConceptos(0, 0, 0, 0, " AND ID_CONCEPTO = " + itemConcepto.getIdConcepto() + " AND ID_ESTATUS != 2 ");

                if(impuestos.length>0){//Si algún producto tiene impuestos, se puede generar la factura
                    out.print("<!--EXITO-->El pedido se puede facturar con impuestos.");
                    //break;
                }                
            }
        
            
        }else{
                msgError += "<ul> No se específico el identificador (ID) de la Pedido a recuperar. Intente de nuevo.";
        }
    }*/
                

    if (msgError.equals("") && mode!=1 
            && mode!=12 && mode!=13
            && mode!=21 && mode!=23
            && mode!=24){
        out.print("<!--EXITO-->");
    }
    
    if(recargarListaProductos){
        if (msgError.equals("")){
            Concepto concepto = null;
            ConceptoBO conceptoBO = new ConceptoBO(user.getConn());
/*            Almacen almacen = null;
            AlmacenBO almacenBO = new AlmacenBO(user.getConn());
*/ %>
                <table class="data" width="100%" cellpadding="0" cellspacing="0">
                    <thead>
                        <tr>
                            <td colspan="7"><center>Seleccionados</center></td>
                        </tr>
                    </thead>
                    <tbody>
<%
            //Si no valida existencia
            EmpresaPermisoAplicacion empresaPermisoAplicacionDto = null;
            EmpresaBO empresaBO = new EmpresaBO(user.getConn());
            empresaPermisoAplicacionDto = new EmpresaPermisoAplicacionDaoImpl(user.getConn()).findByPrimaryKey(empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa());     
    
/*            String nombAlmacen = "";
            if (empresaPermisoAplicacionDto != null) {
                 if (empresaPermisoAplicacionDto.getRevisionCantidadProducto() == 0) {
                     nombAlmacen = "";
                 }else{
                     nombAlmacen = "Almacén Móvil";
                 }
            }
*/            
            
            int j=0;
                for (ProductoSesion itemProductoSesion : pedidoSesion.getListaProducto()){
                    concepto = null;

                    try{
                       conceptoBO = new ConceptoBO(itemProductoSesion.getIdProducto(),user.getConn());
                       concepto = conceptoBO.getConcepto();
                    }catch(Exception ex){
                        msgError += "Ocurrio un error al consultar el producto elegido con ID: "+itemProductoSesion.getIdProducto()+". " + ex.toString();
                    }
/*                    try{
                        almacenBO = new AlmacenBO(itemProductoSesion.getIdAlmacen(),user.getConn());
                        almacen = almacenBO.getAlmacen();
                       
                    }catch(Exception ex){
                        msgError += "Ocurrio un error al consultar el producto elegido con ID: "+itemProductoSesion.getIdProducto()+". " + ex.toString();
                    }
*/                    
                    if (concepto!=null){
                        //int id = concepto.getIdconcepto();
                        int id = j;
%>
                        <tr>
                            <td>
                                <input type="hidden" name="producto_id_<%=id%>" id="producto_id_<%=id%>" readonly value="<%=concepto.getIdConcepto()%>"/>                                       
                                <input type="text" maxlength="100" name="producto_nombre_<%=id%>" id="producto_nombre_<%=id%>" size="18" readonly
                                       disabled value="<%=conceptoBO.getNombreConceptoLegible() %>"/>
                                
                            </td>
                            <td>
                                <textarea name="producto_descripcion_<%=id%>" id="producto_descripcion_<%=id%>" 
                                       rows="3" cols="35" readonly
                                       disabled><%= itemProductoSesion.getDescripcionAlternativa()!=null?(itemProductoSesion.getDescripcionAlternativa().trim().length()>0?itemProductoSesion.getDescripcionAlternativa():conceptoBO.getConcepto().getDescripcion()) :conceptoBO.getConcepto().getDescripcion() %></textarea>
                                       <!--disabled><%=conceptoBO.getConcepto().getDescripcion() %></textarea>-->
                            </td>
                            <!--<td>
                                <input type="text" maxlength="100" name="producto_unidad_<%=id%>" id="producto_unidad_<%=id%>" size="18" readonly
                                       disabled value="<%=itemProductoSesion.getUnidad() %>"/>
                            </td>-->
                            <td>
                                <input type="text" maxlength="10" name="producto_precio_<%=id%>" id="producto_precio_<%=id%>" size="10"  style="text-align: right;" readonly
                                       disabled value="<%=itemProductoSesion.getPrecio() %>"/>
                            </td>
                            <td>
                           
                            <td>
                                <input type="text" maxlength="8" name="producto_cantidad_<%=id%>" id="producto_cantidad_<%=id%>" style="text-align: right;" size="8"
                                       disabled value="<%=itemProductoSesion.getCantidad() %>"/>
                            </td>
                            <td>
                                <input type="text" maxlength="16" name="producto_monto_<%=id%>" id="producto_monto_<%=id%>" style="text-align: right;" size="10"
                                       disabled value="<%=itemProductoSesion.getMonto() %>"/>
                            </td>
                            <td>
                                <a href="javascript:void(0);" onclick="subProducto(<%=id%>);" id="sub_producto_action_<%=id%>" title="Quitar Producto">
                                    <img src="../../images/minus.png" alt="Quitar Producto" height="20" width="20" title="Quitar Producto" class="help"/>
                                </a>
                                &nbsp;&nbsp;&nbsp;&nbsp;
                                <!--<a class="modalbox_iframe" href="../pedido/pedido_editaProducto_form.jsp?type=pedido&index_lista_producto=<//%=id%>&nomAlm=<//%=almacen!=null?almacen.getNombre():"Almacen Movil"%>"
                                    title="Editar campo" >
                                    <img src="../../images/icon_edit.png" alt="Modificar Producto" title="Modificar Producto" class="help" height="20" width="20"/>
                                </a>-->
                            </td>
                        </tr>
                        <script>
                            activarFancyBox();
                        </script>
<%
                    }
                    j++;
                }
                if(j<=0){
%>
                    <tr>
                        <td colspan="7"><h4>Agregue un producto para comenzar</h4></td>
                    </tr>
                <%}else{%>
                    <tr>
                        <td colspan="7">
                            <a href="javascript:void(0);" onclick="reiniciarListaProducto();" id="reiniciar_productos_action" style="text-align: right; float: right;">
                                    <img src="../../images/icon_cancel.png" alt="Quitar Producto" title="Quitar Todos los Producto" class="help" height="20" width="20"/> Quitar Todos 
                            </a>
                        </td>
                    </tr>
                <%}%>
                    
                    <tr style="text-align: right;">
                        <td colspan="7">
                            <h3>Subtotal:
                            <input type="text" maxlength="16" name="producto_subtotal" id="producto_subtotal" style="text-align: right;" size="10"
                                   readonly value="<%= pedidoSesion.getSubTotalProductos() %>"/>
                            </h3>
                        </td>
                    </tr>
                </tbody>
            </table>
<%
            }
    }

    if(recargarListaImpuestos){
        if (msgError.equals("")){
%>
                <table class="data" width="100%" cellpadding="0" cellspacing="0">
                    <thead>
                        <tr>
                            <td colspan="3"><center>Seleccionados</center></td>
                        </tr>
                        <tr>
                            <td>Impuesto</td>
                            <td>Monto</td>
                            <td>Acciones</td>
                        </tr>
                    </thead>
                    <tbody>
<%
                int j=0;
                for (ImpuestoSesion item : pedidoSesion.getListaImpuesto()){
                    if (item!=null){
                        //double montoImpuesto = (item.getPorcentaje()/100) * pedidoSesion.getSubTotalProductos().doubleValue();
                        double montoImpuesto =  pedidoSesion.getMontoImpuesto(j).doubleValue();
%>
                        <tr>
                            <td>
                                <input type="hidden" name="impuesto_id_<%=j%>" id="impuesto_id_<%=j%>" value="<%=item.getIdImpuesto()%>" readonly/>
                                <input type="text" name="impuesto_nombre_<%=j%>" id="impuesto_nombre_<%=j%>" 
                                       style="width: 250px" readonly disabled value="<%=item.getNombre() + " (" + item.getPorcentaje() +" %)" %>"/>
                            </td>
                            <td>
                                <input type="text" name="impuesto_monto_<%=j%>" id="impuesto_monto_<%=j%>" 
                                       style="width: 100px; text-align: right;" readonly disabled value="<%=montoImpuesto%>"/>
                            </td>
                            <td>
                                <a href="javascript:void(0);" onclick="subImpuesto(<%=j%>);" id="sub_impuesto_action_<%=j%>" title="Quitar Impuesto">
                                    <img src="../../images/minus.png" alt="Quitar Impuesto" height="20" width="20"/>
                                </a>
                            </td>
                        </tr>
<%
                    }
                    j++;
                }
                if(j<=0){
%>
                        <tr>
                            <td colspan="3"><h4>Selecciona algunos impuestos para el pedido.</h4></td>
                        </tr>
<%              }%>
                        <tr style="text-align: right;">
                            <td colspan="3">
                                <h3>Subtotal Traslados (+):
                                <input type="text" maxlength="16" name="subtotalImpuestos_traslados" id="subtotalImpuestos_traslados" style="text-align: right;" size="10"
                                    readonly value="<%= pedidoSesion.getSubTotalImpuestos_Traslados() %>"/>
                                </h3>
                            </td>
                        </tr>
                        <tr style="text-align: right;">
                            <td colspan="3">
                                <h3>Subtotal Retenciones (-):
                                <input type="text" maxlength="16" name="subtotalImpuestos_retenciones" id="subtotalImpuestos_retenciones" style="text-align: right;" size="10"
                                    readonly value="<%= pedidoSesion.getSubTotalImpuestos_Retenciones() %>"/>
                                </h3>
                            </td>
                        </tr>
                </tbody>
            </table>
<%
            }
    }
    
    if (recargarSelectClientes){
         // tipoClientes 1 - Normales  2 - Consigna
        
        String filtroCli = ""; 
        if(tipoClientes == 1){
            //filtroCli = " AND ID_VENDEDOR_CONSIGNA = 0 ";
        }else{
            //filtroCli = " AND ID_VENDEDOR_CONSIGNA > 0 ";
        }
        
        
%>
        <select size="1" id="id_cliente" name="id_cliente" class="flexselect" 
            onchange="selectCliente(this.value)"
            style="width: 300px;">
            <option value="-1"></option>
            <%= new ClienteBO(user.getConn()).getClientesByIdHTMLCombo(user.getUser().getIdEmpresa(), idCliente, "  AND (ID_ESTATUS= 1 OR ID_ESTATUS = 3) " + filtroCli ) %>
        </select>
<%
    }
    
%>

 <%
    if (!msgError.equals("")){
        out.print("<!--ERROR-->"+msgError);
    }
%>
