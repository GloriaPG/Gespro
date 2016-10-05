/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package com.tsp.gespro.ws.bo;

import com.google.gson.Gson;
import com.tsp.gespro.bo.ClienteBO;
import com.tsp.gespro.bo.ClienteCategoriaBO;
import com.tsp.gespro.bo.CompetenciaBO;
import com.tsp.gespro.bo.ConceptoBO;
import com.tsp.gespro.bo.DatosUsuarioBO;
import com.tsp.gespro.bo.DispositivoMovilBO;
import com.tsp.gespro.bo.EmbalajeBO;
import com.tsp.gespro.bo.EmpresaBO;
import com.tsp.gespro.bo.ExistenciaAlmacenBO;
import com.tsp.gespro.bo.MarcaBO;
import com.tsp.gespro.bo.MovilMensajeBO;
import com.tsp.gespro.bo.ProspectoBO;
import com.tsp.gespro.bo.UsuarioBO;
import com.tsp.gespro.bo.UsuariosBO;
import com.tsp.gespro.bo.ZonaHorariaBO;
import com.tsp.gespro.dto.Cliente;
import com.tsp.gespro.dto.Competencia;
import com.tsp.gespro.dto.Concepto;
import com.tsp.gespro.dto.DatosUsuario;
import com.tsp.gespro.dto.Embalaje;
import com.tsp.gespro.dto.Empresa;
import com.tsp.gespro.dto.MovilMensaje;
import com.tsp.gespro.dto.Prospecto;
import com.tsp.gespro.dto.RelacionConceptoCompetencia;
import com.tsp.gespro.dto.RelacionConceptoEmbalaje;
import com.tsp.gespro.dto.Ruta;
import com.tsp.gespro.dto.RutaMarcador;
import com.tsp.gespro.dto.Ubicacion;
import com.tsp.gespro.dto.Usuarios;
import com.tsp.gespro.jdbc.ClienteDaoImpl;
import com.tsp.gespro.jdbc.ConceptoDaoImpl;
import com.tsp.gespro.jdbc.MovilMensajeDaoImpl;
import com.tsp.gespro.jdbc.ProspectoDaoImpl;
import com.tsp.gespro.jdbc.RelacionConceptoCompetenciaDaoImpl;
import com.tsp.gespro.jdbc.RelacionConceptoEmbalajeDaoImpl;
import com.tsp.gespro.jdbc.ResourceManager;
import com.tsp.gespro.jdbc.RutaDaoImpl;
import com.tsp.gespro.jdbc.RutaMarcadorDaoImpl;
import com.tsp.gespro.jdbc.UbicacionDaoImpl;
import com.tsp.gespro.util.Encrypter;
import com.tsp.gespro.util.StringManage;
import com.tsp.gespro.ws.request.GetMensajesMovilRequest;
import com.tsp.gespro.ws.request.UsuarioDtoRequest;
import com.tsp.gespro.ws.response.ConsultaClientesResponse;
import com.tsp.gespro.ws.response.ConsultaCompetenciaResponse;
import com.tsp.gespro.ws.response.ConsultaConceptosResponse;
import com.tsp.gespro.ws.response.ConsultaEmbalajeResponse;
import com.tsp.gespro.ws.response.ConsultaEmpleadoResponse;
import com.tsp.gespro.ws.response.ConsultaMensajesMovilResponse;
import com.tsp.gespro.ws.response.ConsultaProspectosResponse;
import com.tsp.gespro.ws.response.ConsultaRutasResponse;
import com.tsp.gespro.ws.response.LoginUsuarioMovilResponse;
import com.tsp.gespro.ws.response.WsItemCliente;
import com.tsp.gespro.ws.response.WsItemCompetencia;
import com.tsp.gespro.ws.response.WsItemConcepto;
import com.tsp.gespro.ws.response.WsItemEmbalaje;
import com.tsp.gespro.ws.response.WsItemEmpleado;
import com.tsp.gespro.ws.response.WsItemMovilMensaje;
import com.tsp.gespro.ws.response.WsItemProspecto;
import com.tsp.gespro.ws.response.WsItemRelacionConceptoCompetencia;
import com.tsp.gespro.ws.response.WsItemRelacionConceptoEmbalaje;
import com.tsp.gespro.ws.response.WsItemRuta;
import com.tsp.gespro.ws.response.WsItemRutaMarcador;
import com.tsp.gespro.ws.response.WsItemSucursal;
import com.tsp.gespro.ws.response.WsItemUbicacion;
import com.tsp.gespro.ws.response.WsItemUsuario;
import com.tsp.gespro.ws.response.WsListaClientes;
import com.tsp.gespro.ws.response.WsListaCompetencia;
import com.tsp.gespro.ws.response.WsListaConceptos;
import com.tsp.gespro.ws.response.WsListaEmbalaje;
import com.tsp.gespro.ws.response.WsListaEmpleado;
import java.io.File;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 *
 * @author HpPyme
 */
public class ConsultaWsBO {
    
    
     private final Gson gson = new Gson();
    private Connection conn = null;

    public Connection getConn() {
        if (this.conn==null){
            try {
                this.conn= ResourceManager.getConnection();
            } catch (SQLException ex) {}
        }else{
            try {
                if (this.conn.isClosed()){
                    this.conn = ResourceManager.getConnection();
                }
            } catch (SQLException ex) {}
        }
        return this.conn;
    }

    public void setConn(Connection conn) {
        this.conn = conn;
    }
    
    
    /**
     * Verifica si los datos de acceso del empleado son válidos
     * @param usuarioDtoRequest
     * @return AccionCatalogoResponse Respuesta compuesta por objeto complejo
     */
    public LoginUsuarioMovilResponse loginByUsuario(String usuarioDtoRequestJSON) {
        LoginUsuarioMovilResponse response;
        
        UsuarioDtoRequest usuarioDtoRequest = null;
        try{
            //Transformamos de formato JSON a objeto
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJSON, UsuarioDtoRequest.class);
            
            response = this.loginByUsuario(usuarioDtoRequest);
        }catch(Exception ex){
            response = new LoginUsuarioMovilResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        
        return response;
    }
    
    
    
    /**
     * Verifica si los datos de acceso del empleado son válidos
     * @param usuarioDtoRequest
     * @return AccionCatalogoResponse Respuesta compuesta por objeto complejo
     */
    public LoginUsuarioMovilResponse loginByUsuario(UsuarioDtoRequest usuarioDtoRequest) {
        LoginUsuarioMovilResponse response = new LoginUsuarioMovilResponse();
         
        try {
            //Consultamos y obtenemos el ID de Empresa del Usuario
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())) {
                if (usuarioBO.dispositivoAsignado(usuarioDtoRequest.getDispositivoIMEI())){
                    
                    DispositivoMovilBO dispositivoMovilBO = new DispositivoMovilBO(usuarioBO.getUser().getIdDispositivo(), getConn());
                    if (dispositivoMovilBO.getDispositivoMovil().getReporteRobo()==0){

                        
                        Usuarios usuarioDto = usuarioBO.getUser();
                        DatosUsuario datosUsuarioDto = usuarioBO.getDatosUsuario();
                        
                        WsItemUsuario wsItemUsuario= new WsItemUsuario();
                        
                        wsItemUsuario.setIdUsuario(usuarioDto.getIdUsuarios());
                        wsItemUsuario.setIdEmpresa(usuarioDto.getIdEmpresa());
                        wsItemUsuario.setIdEstatus(usuarioDto.getIdEstatus());
                        wsItemUsuario.setIdMovilEmpleadoRol(usuarioDto.getIdRoles());
                        wsItemUsuario.setLatitud(usuarioDto.getLatitud());
                        wsItemUsuario.setLongitud(usuarioDto.getLongitud());
                        wsItemUsuario.setNombre(datosUsuarioDto.getNombre());
                        wsItemUsuario.setApellidoPaterno(datosUsuarioDto.getApellidoPat());
                        wsItemUsuario.setApellidoMaterno(datosUsuarioDto.getApellidoPat());
                        wsItemUsuario.setTelefonoLocal(datosUsuarioDto.getTelefono());
                        wsItemUsuario.setNumEmpleado(usuarioDto.getNumEmpleado());
                        wsItemUsuario.setCorreoElectronico(datosUsuarioDto.getCorreo());
                        wsItemUsuario.setIdDispositivo(usuarioDto.getIdDispositivo());
                        wsItemUsuario.setPermisoVentaCredito(usuarioDto.getPermisoVentaCredito());
                        wsItemUsuario.setTrabajaFueraLinea(usuarioDto.getTrabajarFueraLinea());
                        wsItemUsuario.setClientesCodigoBarras(usuarioDto.getClientesCodigoBarras());
                        wsItemUsuario.setDistanciaObligatoria(usuarioDto.getDistanciaObligatorio());
                        wsItemUsuario.setPrecioCompra(usuarioDto.getPrecioDeCompra());
                        wsItemUsuario.setPermisoAccionesClientes(usuarioDto.getPermisoAccionesCliente());
                        wsItemUsuario.setMinutosEstatus(usuarioDto.getMinutosEstatus());
                        
                        response.setWsItemUsuario(wsItemUsuario);

                        //recuperamos datos de la empresa a la q pertenece el empleado
                        EmpresaBO empresaBO = new EmpresaBO(getConn());
                        Empresa empresaDto = empresaBO.findEmpresabyId(usuarioDto.getIdEmpresa());

                        WsItemSucursal wsItemSucursal = new WsItemSucursal();
                        WsItemUbicacion wsItemUbicacion= null;
                        Ubicacion ubicacionDto = null;

                        wsItemSucursal.setIdEmpresa((int)empresaDto.getIdEmpresa());
                        wsItemSucursal.setIdEmpresaPadre((int)empresaDto.getIdEmpresaPadre());
                        wsItemSucursal.setIdTipoEmpresa((int)empresaDto.getIdTipoEmpresa());
                        wsItemSucursal.setRfc(empresaDto.getRfc());
                        wsItemSucursal.setRazonSocial(empresaDto.getRazonSocial());
                        wsItemSucursal.setNombreComercial(empresaDto.getNombreComercial());                         
                        wsItemSucursal.setRegimenFiscal(empresaDto.getRegimenFiscal());                       
                      
                        
                                                
                        
                        //cargamos la ubicacion fiscal de esa sucursal                            
                        ubicacionDto = new UbicacionDaoImpl(getConn()).findByPrimaryKey(empresaDto.getIdUbicacionFiscal());

                        if (ubicacionDto!=null){
                            wsItemUbicacion = new WsItemUbicacion();

                            wsItemUbicacion.setCalle(ubicacionDto.getCalle());
                            wsItemUbicacion.setCodigoPostal(ubicacionDto.getCodigoPostal());
                            wsItemUbicacion.setColonia(ubicacionDto.getColonia());
                            wsItemUbicacion.setEstado(ubicacionDto.getEstado());
                            wsItemUbicacion.setIdUbicacionFiscal(ubicacionDto.getIdUbicacion());
                            wsItemUbicacion.setMunicipio(ubicacionDto.getMunicipio());
                            wsItemUbicacion.setNumExt(ubicacionDto.getNumExt());
                            wsItemUbicacion.setNumInt(ubicacionDto.getNumInt());
                            wsItemUbicacion.setPais(ubicacionDto.getPais());
                        }

                        wsItemSucursal.setUbicacion(wsItemUbicacion);                        
                        response.setWsItemSucursal(wsItemSucursal);

                        response.setError(false);
                    }else{
                        response.setError(true);
                        response.setNumError(901);
                        response.setMsgError("El dispositivo tiene reporte de robo.");
                    }
                }else{
                    response.setError(true);
                    response.setNumError(901);
                    response.setMsgError("El dispositivo no esta asignado al empleado.");
                }
            } else {
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("Datos de acceso inválidos.");
            }
        } catch (Exception e) {
            response.setError(true);
            response.setNumError(902);
            response.setMsgError("Error al verificar login del empleado: " + e.toString());
            e.printStackTrace();
        }finally{
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }
         
        return response;
    }
    
    
    /**
     * Obtiene el catalogo de Clientes por usuario
     * @param userName 
     */
    public ConsultaClientesResponse getCatalogoClientesByUsuario(String usuarioDtoRequestJSON) {
        ConsultaClientesResponse response;
                
        UsuarioDtoRequest usuarioDtoRequest = null;
        try{
            //Transformamos de formato JSON a objeto
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJSON, UsuarioDtoRequest.class);
            
            response = this.getCatalogoClientesByUsuario(usuarioDtoRequest);
        }catch(Exception ex){
            response = new ConsultaClientesResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        
        return response;
    }

    private ConsultaClientesResponse getCatalogoClientesByUsuario(UsuarioDtoRequest usuarioDtoRequest) {
        
        int idEmpresa = 0;
        int idUsuario = 0;
        ConsultaClientesResponse consultaResponse = new ConsultaClientesResponse();
        try {
            //Consultamos y obtenemos el ID de Empresa del Usuario
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())) {
                idEmpresa = usuarioBO.getUser().getIdEmpresa();
                idUsuario = usuarioBO.getUser().getIdUsuarios();
                //Si se encontro el registro buscamos su catalogo de clientes
                if (idEmpresa > 0) {
                    consultaResponse.setError(false);
                    //Filtramos con Estatus Activo y que esten asignados a este empleado
                    consultaResponse.setListaClientes(this.getListaClientes(idEmpresa, 
                            " AND (ID_ESTATUS = 1 )  "
                          + " AND ( ID_CLIENTE IN (SELECT ID_CLIENTE FROM relacion_cliente_vendedor WHERE ID_USUARIO=" + idUsuario + " )"                         
                          + " ) "
                    ));
                }
                
                //registramos ubicacion
                try{new InsertaActualizaWsBO(getConn()).actualizarUbicacionUsuario(usuarioDtoRequest);}catch(Exception ex){}
            } else {
                consultaResponse.setError(true);
                consultaResponse.setNumError(901);
                consultaResponse.setMsgError("El usuario y/o contraseña del Usuario son inválidos.");
            }
        } catch (Exception e) {
            consultaResponse.setError(true);
            consultaResponse.setNumError(902);
            consultaResponse.setMsgError("Error inesperado al consultar catalogos del usuario. " + e.getLocalizedMessage());
        }finally{
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }

        return consultaResponse;
        
        
    }
    
    /**
     * Consulta los Clientes de una empresa.
     * @param idEmpresa
     * @return 
     */
    private ArrayList<WsItemCliente> getListaClientes(int idEmpresa, String filtroBusqueda){//int idEmpresa) {
        
        WsListaClientes listaClientes = new WsListaClientes();
        //Buscamos los clientes definidos para el usuario/empresa
        ClienteDaoImpl clienteDao = new ClienteDaoImpl(getConn());
        ClienteBO clienteBO = new ClienteBO(getConn());
        Cliente[] arrayClienteDto;
        ClienteCategoriaBO clienteCategoriaBO = new ClienteCategoriaBO(getConn());
        
        
        try {
            //arrayClienteDto = clienteDao.findWhereIdEmpresaEquals(idEmpresa);
            arrayClienteDto = clienteBO.findClientes(-1, idEmpresa, 0, 0, filtroBusqueda);
            if (arrayClienteDto.length > 0) {
                //Llenamos la lista de clientes del objeto respuesta
                for (Cliente item : arrayClienteDto) {
                    try {
                        if (item.getIdEstatus()!=2){
                            WsItemCliente wsItemCliente = new WsItemCliente();

                            wsItemCliente.setIdCliente(item.getIdCliente());  
                            wsItemCliente.setNombreComercial(item.getNombreComercial());                           
                            wsItemCliente.setContacto(item.getContacto());
                            wsItemCliente.setTelefono(item.getTelefono());
                            wsItemCliente.setCalle(item.getCalle());
                            wsItemCliente.setNumero(item.getNumero());
                            wsItemCliente.setNumeroInterior(item.getNumeroInterior());
                            wsItemCliente.setColonia(item.getColonia());
                            wsItemCliente.setCodigoPostal(item.getCodigoPostal());
                            wsItemCliente.setPais(item.getPais());
                            wsItemCliente.setEstado(item.getEstado());
                            wsItemCliente.setMunicipio(item.getMunicipio());
                            wsItemCliente.setLatitud(item.getLatitud());
                            wsItemCliente.setLongitud(item.getLongitud());
                            wsItemCliente.setCorreo(item.getCorreo());    
                            
                            wsItemCliente.setIdCategoria(item.getIdCategoria());
                            wsItemCliente.setCategoria("");
                            if(item.getIdCategoria()> 0){
                                try{
                                    wsItemCliente.setCategoria(clienteCategoriaBO.findClienteCategoriaById(item.getIdCategoria()).getNombreClasificacion());
                                }catch(Exception e){
                                    
                                }
                            }
                            
                            listaClientes.addItem(wsItemCliente);//Add elemento a list                                                    
                            
                        }
                        
                        
                    } catch (Exception e) {
                    }
                }
            }
        } catch (Exception e) {
        }

        return listaClientes.getLista();
    }
    
    /**
     * Obtiene el catalogo de Conceptos de una empresa, haciendo login por usuario
     * @param usuarioDtoRequestJSON Datos de autenticacion en formato JSON, correspondientes a objeto UsuarioDtoRequest
     */
    public ConsultaConceptosResponse getCatalogoConceptosByUsuario(String usuarioDtoRequestJSON) {
        ConsultaConceptosResponse response;
                
        UsuarioDtoRequest usuarioDtoRequest = null;
        try{
            //Transformamos de formato JSON a objeto
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJSON, UsuarioDtoRequest.class);
            
            response = this.getCatalogoConceptosByUsuario(usuarioDtoRequest);
        }catch(Exception ex){
            response = new ConsultaConceptosResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        
        return response;
    }
    
    
    /**
     * Obtiene el catalogo de Conceptos de una empresa, haciendo login por usuario
     * @param usuarioDtoRequest Datos de autenticacion
     */
    public ConsultaConceptosResponse getCatalogoConceptosByUsuario(UsuarioDtoRequest usuarioDtoRequest) {
        int idEmpresa = 0;
        int idUsuario = 0;
        ConsultaConceptosResponse consultaConceptosResponse = new ConsultaConceptosResponse();
        try {
            //Consultamos y obtenemos el ID de Empresa del Usuario
            //Consultamos y obtenemos el ID de Empresa del Usuario
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())) {
                idEmpresa = usuarioBO.getUser().getIdEmpresa();
                idUsuario = usuarioBO.getUser().getIdUsuarios();
                //Si se encontro el registro buscamos su catalogo de productos
                if (idEmpresa > 0) {
                    consultaConceptosResponse.setError(false);
                    consultaConceptosResponse.setListaConceptos(this.getListaConceptos(idEmpresa, idUsuario,-1,-1));
                }
                
                //registramos ubicacion
                try{new InsertaActualizaWsBO(getConn()).actualizarUbicacionUsuario(usuarioDtoRequest);}catch(Exception ex){}
            } else {
                consultaConceptosResponse.setError(true);
                consultaConceptosResponse.setNumError(901);
                consultaConceptosResponse.setMsgError("El usuario y/o contraseña del Empleado son inválidos.");
            }
        } catch (Exception e) {
            consultaConceptosResponse.setError(true);
            consultaConceptosResponse.setNumError(902);
            consultaConceptosResponse.setMsgError("Error inesperado al consultar catalogos del usuario. " + e.getLocalizedMessage());
        }finally{
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }

        return consultaConceptosResponse;
    }
    
    
    /**
     * Consulta un listado de Conceptos por empresa
     * @param idEmpresa ID de la empresa que se va a consultar, en caso de ser sucursal se recuperan tambien lo correspondiente a la empresa padre
     * @return Lista de objetos WsItemConcepto
     */
    public ArrayList<WsItemConcepto> getListaConceptos(int idEmpresa, int idEmpleado , int limMin , int limMax) {

        WsListaConceptos wsListaConceptos = new WsListaConceptos();
        Encrypter encriptacion = new Encrypter();        
        ExistenciaAlmacenBO exisAlmBO = new ExistenciaAlmacenBO(this.conn);
        double stockGral = 0;

        //Buscamos todos los Conceptos de la Empresa
        //ConceptoDaoImpl conceptoDao = new ConceptoDaoImpl(getConn());
        Concepto[] arrayConceptoDto;
        List<Concepto> arrayConceptoDto2 = new ArrayList<Concepto>();
        ConceptoBO conceptoBO = new ConceptoBO(getConn());

        try {          
            arrayConceptoDto = conceptoBO.findConceptos(-1, idEmpresa, limMin, limMax, " AND ID_ESTATUS = 1");
            
           
          
            if (arrayConceptoDto.length>0) {
                                
                //Llenamos la lista de conceptos del objeto respuesta
                for (Concepto itemConcepto : arrayConceptoDto) {
                    WsItemConcepto wsItemConcepto = new WsItemConcepto();
                    //String nombreConcepto = "";
                    stockGral = 0;
                    
                    //Buscamos inventario específico de empleado
                    double cantidadInventarioEmpleado = 0;
                    double pesoStock = 0;
                   
                    
                    pesoStock  = itemConcepto.getPeso();                   

                    wsItemConcepto.setIdConcepto(itemConcepto.getIdConcepto());
                    
/*                    try {
                        nombreConcepto = encriptacion.decodeString(itemConcepto.getNombre());
                    } catch (Exception e) {
                        System.out.println("############ Error en el sistema al intentar desencriptar el nombre de un concepto." + e.getMessage());
                    }
*/                    
                    //Buscamos la marca a la que pertenece
                    String nombreMarca = "";
                    try{
                        if (itemConcepto.getIdMarca()>0){
                            MarcaBO marcaBO = new MarcaBO(itemConcepto.getIdMarca(), getConn());
                            nombreMarca = marcaBO.getMarca()!=null?StringManage.getValidString(marcaBO.getMarca().getNombre()):"";
                        }
                    }catch(Exception ex){
                        ex.printStackTrace();
                    }
                    
/*                    try{
                        stockGral = exisAlmBO.getExistenciaGeneralByEmpresaProducto(itemConcepto.getIdEmpresa(), itemConcepto.getIdConcepto());
                    }catch(Exception e){
                        System.out.println("############ Error en el sistema al intentar buscar existencia de un concepto." + e.getMessage());
                    }
*/                    
                    BigDecimal precioBigD = (new BigDecimal(itemConcepto.getPrecio())).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal stockBigD = (new BigDecimal(stockGral)).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal precioCompraBigD = (new BigDecimal(itemConcepto.getPrecioCompra())).setScale(2, RoundingMode.HALF_UP);
                    
                    BigDecimal precioDocenaBigD = (new BigDecimal(itemConcepto.getPrecioDocena())).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal precioMedioMayoreoBigD = (new BigDecimal(itemConcepto.getPrecioMedioMayoreo())).setScale(2, RoundingMode.HALF_UP);                    
                    BigDecimal precioMayoreoBigD = (new BigDecimal(itemConcepto.getPrecioMayoreo())).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal precioEspecialBigD = (new BigDecimal(itemConcepto.getPrecioEspecial())).setScale(2, RoundingMode.HALF_UP);
                    
                    BigDecimal precioUnitarioGranel = (new BigDecimal(itemConcepto.getPrecioUnitarioGranel())).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal precioMedioGranel = (new BigDecimal(itemConcepto.getPrecioMedioGranel())).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal precioMayoreoGranel = (new BigDecimal(itemConcepto.getPrecioMayoreoGranel())).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal precioEspecialGranel = (new BigDecimal(itemConcepto.getPrecioEspecialGranel())).setScale(2, RoundingMode.HALF_UP);
                    
                    BigDecimal maxMenudeoBigD = (new BigDecimal(itemConcepto.getMaxMenudeo())).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal minMedioMayoreoBigD = (new BigDecimal(itemConcepto.getMinMedioMayoreo())).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal maxMedioMayoreoBigD = (new BigDecimal(itemConcepto.getMaxMedioMayoreo())).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal minMayoreoBigD = (new BigDecimal(itemConcepto.getMinMayoreo())).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal descuentoMontoBigD = (new BigDecimal(itemConcepto.getDescuentoMonto())).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal descuentoPorcentajeBigD = (new BigDecimal(itemConcepto.getDescuentoPorcentaje())).setScale(2, RoundingMode.HALF_UP);
                    
                    BigDecimal precioMinimoVentaBigD = (new BigDecimal(itemConcepto.getPrecioMinimoVenta())).setScale(2, RoundingMode.HALF_UP);
                    
                    wsItemConcepto.setNombre(itemConcepto.getNombre());
                    wsItemConcepto.setDescripcion(itemConcepto.getDescripcion());
                    wsItemConcepto.setPrecio(precioBigD.doubleValue());
                    wsItemConcepto.setIdentificacion(itemConcepto.getIdentificacion());
                    wsItemConcepto.setIdCategoria(itemConcepto.getIdCategoria());
                    wsItemConcepto.setIdAlmacen(itemConcepto.getIdAlmacen());
                    //Stock de empleado repartidor (empleado movil-camioneta)
                    wsItemConcepto.setStock(cantidadInventarioEmpleado);
                    //Stock de almacen general
                    wsItemConcepto.setStockAlmacen(stockBigD.doubleValue());
                    
                    wsItemConcepto.setMarca(nombreMarca);
                    wsItemConcepto.setPrecioCompra(precioCompraBigD.doubleValue());
                    
                    wsItemConcepto.setPrecioDocena(precioDocenaBigD.doubleValue());
                    wsItemConcepto.setPrecioMedioMayoreo(precioMedioMayoreoBigD.doubleValue());
                    wsItemConcepto.setPrecioMayoreo(precioMayoreoBigD.doubleValue());
                    wsItemConcepto.setPrecioEspecial(precioEspecialBigD.doubleValue());
                    wsItemConcepto.setMaxMenudeo(maxMenudeoBigD.doubleValue());
                    wsItemConcepto.setMinMedioMayoreo(minMedioMayoreoBigD.doubleValue());
                    wsItemConcepto.setMaxMedioMayoreo(maxMedioMayoreoBigD.doubleValue());
                    wsItemConcepto.setMinMayoreo(minMayoreoBigD.doubleValue());
                    
                    wsItemConcepto.setDescuentoMonto(descuentoMontoBigD.doubleValue());
                    wsItemConcepto.setDescuentoPorcentaje(descuentoPorcentajeBigD.doubleValue());
                    
                    wsItemConcepto.setPrecioMinimoVenta(precioMinimoVentaBigD.doubleValue());
                    
                    if(itemConcepto.getCaracteristiscas() != null){
                        wsItemConcepto.setCaracteristicas(itemConcepto.getCaracteristiscas());
                    }
                    
                    BigDecimal montoComision = (new BigDecimal(itemConcepto.getComisionMonto())).setScale(2, RoundingMode.HALF_UP);
                    BigDecimal porcentajeComision = (new BigDecimal(itemConcepto.getComisionPorcentaje())).setScale(2, RoundingMode.HALF_UP);                            
                    wsItemConcepto.setMontoComision(montoComision.doubleValue());
                    wsItemConcepto.setPorcentajeComision(porcentajeComision.doubleValue());
                    
                    BigDecimal deglosePiezas = (new BigDecimal(itemConcepto.getDesglosePiezas())).setScale(2, RoundingMode.HALF_UP);
                    
                    wsItemConcepto.setClave(itemConcepto.getClave());
                    wsItemConcepto.setDesglose_piezas(deglosePiezas.doubleValue());
                    
                    wsItemConcepto.setPrecioUnitarioGranel(precioUnitarioGranel.doubleValue());
                    wsItemConcepto.setPrecioMedioGranel(precioMedioGranel.doubleValue());
                    wsItemConcepto.setPrecioMayoreoGranel(precioMayoreoGranel.doubleValue());
                    wsItemConcepto.setPrecioEspecialGranel(precioEspecialGranel.doubleValue());
                    wsItemConcepto.setPesoProducto(itemConcepto.getPeso());
                    wsItemConcepto.setPesoStock(pesoStock);
                    wsItemConcepto.setIdInventarioEmpleado(itemConcepto.getIdSubcategoria4());  
                    
                    //añadimos la relacion de los embalajes con el concepto:
                    RelacionConceptoEmbalaje[] conceptoEmbalajes = new RelacionConceptoEmbalaje[0];                            
                    try{conceptoEmbalajes = new RelacionConceptoEmbalajeDaoImpl(this.conn).findWhereIdConceptoEquals(itemConcepto.getIdConcepto());}catch(Exception e){}
                    if(conceptoEmbalajes != null && conceptoEmbalajes.length > 0){
                        for(RelacionConceptoEmbalaje relacion : conceptoEmbalajes){
                            WsItemRelacionConceptoEmbalaje relConceEmba = new WsItemRelacionConceptoEmbalaje();
                            relConceEmba.setIdRelacion(relacion.getIdRelacion());
                            relConceEmba.setIdConcepto(relacion.getIdConcepto());
                            relConceEmba.setIdEmbalaje(relacion.getIdEmbalaje());
                            relConceEmba.setCantidad(relacion.getCantidad());
                            wsItemConcepto.getRelacionConceptoEmbalaje().add(relConceEmba);
                        }
                    }
                    
                    //añadimos la relacion de los competidores con el concepto:
                    RelacionConceptoCompetencia[] conceptoCompetencia = new RelacionConceptoCompetencia[0];                            
                    try{conceptoCompetencia = new RelacionConceptoCompetenciaDaoImpl(this.conn).findWhereIdConceptoEquals(itemConcepto.getIdConcepto());}catch(Exception e){}
                    if(conceptoCompetencia != null && conceptoCompetencia.length > 0){
                        for(RelacionConceptoCompetencia relacion : conceptoCompetencia){
                            WsItemRelacionConceptoCompetencia relConceCompe = new WsItemRelacionConceptoCompetencia();
                            relConceCompe.setIdRelacion(relacion.getIdRelacion());
                            relConceCompe.setIdConcepto(relacion.getIdConcepto());
                            relConceCompe.setIdCompetencia(relacion.getIdCompetencia());
                            relConceCompe.setNombreConceptoCompetencia(relacion.getNombreConceptoCompetencia());
                            relConceCompe.setDescripcion(relacion.getDescripcion());
                            relConceCompe.setCantidad(relacion.getCantidad());
                            relConceCompe.setPrecio(relacion.getPrecio());
                            relConceCompe.setPrecioCompra(relacion.getPrecioCompra());
                            relConceCompe.setPrecioDocena(relacion.getPrecioDocena());
                            relConceCompe.setPrecioMayoreo(relacion.getPrecioMayoreo());
                            relConceCompe.setPrecioEspecial(relacion.getPrecioEspecial());
                            relConceCompe.setPrecioMinimoVenta(relacion.getPrecioMinimoVenta());
                            relConceCompe.setPrecioMedioMayoreo(relacion.getPrecioMedioMayoreo());
                            relConceCompe.setMaxMenudeo(relacion.getMaxMenudeo());
                            relConceCompe.setMinMedioMayoreo(relacion.getMinMedioMayoreo());
                            relConceCompe.setMaxMedioMayoreo(relacion.getMaxMedioMayoreo());
                            relConceCompe.setMinMayoreo(relacion.getMinMayoreo());
                            relConceCompe.setDescuentoPorcentaje(relacion.getDescuentoPorcentaje());
                            relConceCompe.setDescuentoMonto(relacion.getDescuentoMonto());
                            
                            wsItemConcepto.getRelacionConceptoCompetencia().add(relConceCompe);
                        }
                    }
                    
                    wsListaConceptos.addItem(wsItemConcepto);
                    
                    
                }
            }
        } catch (Exception e) {
        }
        return wsListaConceptos.getLista();
    }
    
   
    /**
     * Obtiene el catalogo de Embalaje de una empresa, haciendo login por usuario
     * @param usuarioDtoRequestJSON Datos de autenticacion en formato JSON, correspondientes a objeto UsuarioDtoRequest
     */
    public ConsultaEmbalajeResponse getCatalogoEmbalajeByUsuario(String usuarioDtoRequestJSON) {
        ConsultaEmbalajeResponse response;
                
        UsuarioDtoRequest usuarioDtoRequest = null;
        try{
            //Transformamos de formato JSON a objeto
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJSON, UsuarioDtoRequest.class);
            
            response = this.getCatalogoEmbalajeByUsuario(usuarioDtoRequest);
        }catch(Exception ex){
            response = new ConsultaEmbalajeResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        
        return response;
    }
    
    
    /**
     * Obtiene el catalogo de Embalaje de una empresa, haciendo login por usuario
     * @param usuarioDtoRequest Datos de autenticacion
     */
    public ConsultaEmbalajeResponse getCatalogoEmbalajeByUsuario(UsuarioDtoRequest usuarioDtoRequest) {
        int idEmpresa = 0;
        int idUsuario = 0;
        ConsultaEmbalajeResponse consultaEmbalajeResponse = new ConsultaEmbalajeResponse();
        try {
            //Consultamos y obtenemos el ID de Empresa del Usuario
            //Consultamos y obtenemos el ID de Empresa del Usuario
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())) {
                idEmpresa = usuarioBO.getUser().getIdEmpresa();
                idUsuario = usuarioBO.getUser().getIdUsuarios();
                //Si se encontro el registro buscamos su catalogo de productos
                if (idEmpresa > 0) {
                    consultaEmbalajeResponse.setError(false);
                    consultaEmbalajeResponse.setListaEmbalaje(this.getListaEmbalaje(idEmpresa, idUsuario,-1,-1));
                }
                
                //registramos ubicacion
                try{new InsertaActualizaWsBO(getConn()).actualizarUbicacionUsuario(usuarioDtoRequest);}catch(Exception ex){}
            } else {
                consultaEmbalajeResponse.setError(true);
                consultaEmbalajeResponse.setNumError(901);
                consultaEmbalajeResponse.setMsgError("El usuario y/o contraseña del Empleado son inválidos.");
            }
        } catch (Exception e) {
            consultaEmbalajeResponse.setError(true);
            consultaEmbalajeResponse.setNumError(902);
            consultaEmbalajeResponse.setMsgError("Error inesperado al consultar catalogos del usuario. " + e.getLocalizedMessage());
        }finally{
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }

        return consultaEmbalajeResponse;
    }
    
    
    /**
     * Consulta un listado de Embalaje por empresa
     * @param idEmpresa ID de la empresa que se va a consultar, en caso de ser sucursal se recuperan tambien lo correspondiente a la empresa padre
     * @return Lista de objetos WsItemEmbalaje
     */
    public ArrayList<WsItemEmbalaje> getListaEmbalaje(int idEmpresa, int idEmpleado , int limMin , int limMax) {

        WsListaEmbalaje wsListaEmbalaje = new WsListaEmbalaje();
       
        //Buscamos todos los Embalaje de la Empresa
        //EmbalajeDaoImpl embalajeDao = new EmbalajeDaoImpl(getConn());
        Embalaje[] arrayEmbalajeDto;
        List<Embalaje> arrayEmbalajeDto2 = new ArrayList<Embalaje>();
        EmbalajeBO embalajeBO = new EmbalajeBO(getConn());

        try {          
            arrayEmbalajeDto = embalajeBO.findEmbalajes(-1, idEmpresa, limMin, limMax, " AND ID_ESTATUS = 1");
          
            if (arrayEmbalajeDto.length>0) {
                                
                //Llenamos la lista de embalajes del objeto respuesta
                for (Embalaje itemEmbalaje : arrayEmbalajeDto) {
                    WsItemEmbalaje wsItemEmbalaje = new WsItemEmbalaje();
                   
                    wsItemEmbalaje.setIdEmbalaje(itemEmbalaje.getIdEmbalaje());
                    
                    wsItemEmbalaje.setNombre(itemEmbalaje.getNombre());
                    wsItemEmbalaje.setDescripcion(itemEmbalaje.getDescripcion());                                    
                    
                    wsListaEmbalaje.addItem(wsItemEmbalaje);                   
                    
                }
            }
        } catch (Exception e) {
        }
        return wsListaEmbalaje.getLista();
    }
    
    /**
     * Obtiene el catalogo de Competencia de una empresa, haciendo login por usuario
     * @param usuarioDtoRequestJSON Datos de autenticacion en formato JSON, correspondientes a objeto UsuarioDtoRequest
     */
    public ConsultaCompetenciaResponse getCatalogoCompetenciaByUsuario(String usuarioDtoRequestJSON) {
        ConsultaCompetenciaResponse response;
                
        UsuarioDtoRequest usuarioDtoRequest = null;
        try{
            //Transformamos de formato JSON a objeto
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJSON, UsuarioDtoRequest.class);
            
            response = this.getCatalogoCompetenciaByUsuario(usuarioDtoRequest);
        }catch(Exception ex){
            response = new ConsultaCompetenciaResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        
        return response;
    }
    
    
    /**
     * Obtiene el catalogo de Competencia de una empresa, haciendo login por usuario
     * @param usuarioDtoRequest Datos de autenticacion
     */
    public ConsultaCompetenciaResponse getCatalogoCompetenciaByUsuario(UsuarioDtoRequest usuarioDtoRequest) {
        int idEmpresa = 0;
        int idUsuario = 0;
        ConsultaCompetenciaResponse consultaCompetenciaResponse = new ConsultaCompetenciaResponse();
        try {
            //Consultamos y obtenemos el ID de Empresa del Usuario
            //Consultamos y obtenemos el ID de Empresa del Usuario
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())) {
                idEmpresa = usuarioBO.getUser().getIdEmpresa();
                idUsuario = usuarioBO.getUser().getIdUsuarios();
                //Si se encontro el registro buscamos su catalogo de productos
                if (idEmpresa > 0) {
                    consultaCompetenciaResponse.setError(false);
                    consultaCompetenciaResponse.setListaCompetencia(this.getListaCompetencia(idEmpresa, idUsuario,-1,-1));
                }
                
                //registramos ubicacion
                try{new InsertaActualizaWsBO(getConn()).actualizarUbicacionUsuario(usuarioDtoRequest);}catch(Exception ex){}
            } else {
                consultaCompetenciaResponse.setError(true);
                consultaCompetenciaResponse.setNumError(901);
                consultaCompetenciaResponse.setMsgError("El usuario y/o contraseña del Empleado son inválidos.");
            }
        } catch (Exception e) {
            consultaCompetenciaResponse.setError(true);
            consultaCompetenciaResponse.setNumError(902);
            consultaCompetenciaResponse.setMsgError("Error inesperado al consultar catalogos del usuario. " + e.getLocalizedMessage());
        }finally{
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }

        return consultaCompetenciaResponse;
    }
    
    
    /**
     * Consulta un listado de Competencia por empresa
     * @param idEmpresa ID de la empresa que se va a consultar, en caso de ser sucursal se recuperan tambien lo correspondiente a la empresa padre
     * @return Lista de objetos WsItemCompetencia
     */
    public ArrayList<WsItemCompetencia> getListaCompetencia(int idEmpresa, int idEmpleado , int limMin , int limMax) {

        WsListaCompetencia wsListaCompetencia = new WsListaCompetencia();
       
        //Buscamos todos los Competencia de la Empresa
        //CompetenciaDaoImpl embalajeDao = new CompetenciaDaoImpl(getConn());
        Competencia[] arrayCompetenciaDto;
        List<Competencia> arrayCompetenciaDto2 = new ArrayList<Competencia>();
        CompetenciaBO embalajeBO = new CompetenciaBO(getConn());

        try {          
            arrayCompetenciaDto = embalajeBO.findCompetencias(-1, idEmpresa, limMin, limMax, " AND ID_ESTATUS = 1");
          
            if (arrayCompetenciaDto.length>0) {
                                
                //Llenamos la lista de embalajes del objeto respuesta
                for (Competencia itemCompetencia : arrayCompetenciaDto) {
                    WsItemCompetencia wsItemCompetencia = new WsItemCompetencia();
                   
                    wsItemCompetencia.setIdCompetencia(itemCompetencia.getIdCompetencia());
                    
                    wsItemCompetencia.setNombre(itemCompetencia.getNombre());
                    wsItemCompetencia.setDescripcion(itemCompetencia.getDescripcion());                                    
                    
                    wsListaCompetencia.addItem(wsItemCompetencia);                   
                    
                }
            }
        } catch (Exception e) {
        }
        return wsListaCompetencia.getLista();
    }
    
    /**
     * Obtiene el catalogo de Empleado de una empresa, haciendo login por usuario
     * @param usuarioDtoRequestJSON Datos de autenticacion en formato JSON, correspondientes a objeto UsuarioDtoRequest
     */
    public ConsultaEmpleadoResponse getCatalogoEmpleadoByUsuario(String usuarioDtoRequestJSON) {
        ConsultaEmpleadoResponse response;
                
        UsuarioDtoRequest usuarioDtoRequest = null;
        try{
            //Transformamos de formato JSON a objeto
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJSON, UsuarioDtoRequest.class);
            
            response = this.getCatalogoEmpleadoByUsuario(usuarioDtoRequest);
        }catch(Exception ex){
            response = new ConsultaEmpleadoResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        
        return response;
    }
    
    
    /**
     * Obtiene el catalogo de Empleado de una empresa, haciendo login por usuario
     * @param usuarioDtoRequest Datos de autenticacion
     */
    public ConsultaEmpleadoResponse getCatalogoEmpleadoByUsuario(UsuarioDtoRequest usuarioDtoRequest) {
        int idEmpresa = 0;
        int idUsuario = 0;
        ConsultaEmpleadoResponse consultaEmpleadoResponse = new ConsultaEmpleadoResponse();
        try {
            //Consultamos y obtenemos el ID de Empresa del Usuario
            //Consultamos y obtenemos el ID de Empresa del Usuario
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())) {
                idEmpresa = usuarioBO.getUser().getIdEmpresa();
                idUsuario = usuarioBO.getUser().getIdUsuarios();
                //Si se encontro el registro buscamos su catalogo de productos
                if (idEmpresa > 0) {
                    consultaEmpleadoResponse.setError(false);
                    consultaEmpleadoResponse.setListaEmpleado(this.getListaEmpleado(idEmpresa, idUsuario,-1,-1));
                }
                
                //registramos ubicacion
                try{new InsertaActualizaWsBO(getConn()).actualizarUbicacionUsuario(usuarioDtoRequest);}catch(Exception ex){}
            } else {
                consultaEmpleadoResponse.setError(true);
                consultaEmpleadoResponse.setNumError(901);
                consultaEmpleadoResponse.setMsgError("El usuario y/o contraseña del Empleado son inválidos.");
            }
        } catch (Exception e) {
            consultaEmpleadoResponse.setError(true);
            consultaEmpleadoResponse.setNumError(902);
            consultaEmpleadoResponse.setMsgError("Error inesperado al consultar catalogos del usuario. " + e.getLocalizedMessage());
        }finally{
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }

        return consultaEmpleadoResponse;
    }
    
    
    /**
     * Consulta un listado de Empleado por empresa
     * @param idEmpresa ID de la empresa que se va a consultar, en caso de ser sucursal se recuperan tambien lo correspondiente a la empresa padre
     * @return Lista de objetos WsItemEmpleado
     */
    public ArrayList<WsItemEmpleado> getListaEmpleado(int idEmpresa, int idEmpleado , int limMin , int limMax) {

        WsListaEmpleado wsListaEmpleado = new WsListaEmpleado();
       
        //Buscamos todos los Empleado de la Empresa
        //EmpleadoDaoImpl embalajeDao = new EmpleadoDaoImpl(getConn());
        Usuarios[] arrayEmpleadoDto;
        List<Usuarios> arrayEmpleadoDto2 = new ArrayList<Usuarios>();
        UsuariosBO embalajeBO = new UsuariosBO(getConn());

        try {          
            arrayEmpleadoDto = embalajeBO.findUsuarios(-1, idEmpresa, limMin, limMax, " AND ID_ESTATUS = 1");
          
            if (arrayEmpleadoDto.length>0) {
                                
                //Llenamos la lista de embalajes del objeto respuesta
                for (Usuarios itemEmpleado : arrayEmpleadoDto) {
                    try{
                    DatosUsuario datosUsuario = new DatosUsuarioBO(itemEmpleado.getIdDatosUsuario(), this.conn).getDatosUsuario();
                    
                    WsItemEmpleado wsItemEmpleado = new WsItemEmpleado();
                   
                    wsItemEmpleado.setIdEmpleado(itemEmpleado.getIdUsuarios());
                    wsItemEmpleado.setIdEmpresa(itemEmpleado.getIdEmpresa());
                    wsItemEmpleado.setIdEstatus(itemEmpleado.getIdEstatus());
                    wsItemEmpleado.setNombre(datosUsuario.getNombre());
                    wsItemEmpleado.setApellidoPaterno(datosUsuario.getApellidoPat());
                    wsItemEmpleado.setTelefonoLocal(datosUsuario.getTelefono());
                    wsItemEmpleado.setNumEmpleado(itemEmpleado.getNumEmpleado());
                    wsItemEmpleado.setCorreoElectronico(datosUsuario.getCorreo());
                    wsItemEmpleado.setIdSucursal(itemEmpleado.getIdEmpresa());
                    wsItemEmpleado.setIdDispositivo(itemEmpleado.getIdDispositivo());
                    wsItemEmpleado.setLatitud(itemEmpleado.getLatitud());
                    wsItemEmpleado.setLongitud(itemEmpleado.getLongitud());
                    
                    
                    wsListaEmpleado.addItem(wsItemEmpleado); 
                    
                    }catch(Exception e){e.printStackTrace();}
                    
                }
            }
        } catch (Exception e) {
        }
        return wsListaEmpleado.getLista();
    }
    
    public  ConsultaMensajesMovilResponse getMensajesMovilRecibidos(String usuarioDtoRequestJSON, String getMensajesMovilRequestJSON){
        
        ConsultaMensajesMovilResponse response;
                
        UsuarioDtoRequest usuarioDtoRequest = null;
        GetMensajesMovilRequest getMensajesMovilRequest = null;
        try{
            //Transformamos de formato JSON a objeto
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJSON, UsuarioDtoRequest.class);
            getMensajesMovilRequest = gson.fromJson(getMensajesMovilRequestJSON, GetMensajesMovilRequest.class);
            
            response = this.getMensajesMovilRecibidos(usuarioDtoRequest,getMensajesMovilRequest);
        }catch(Exception ex){
            response = new ConsultaMensajesMovilResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        
        return response;
        
    }
    
    public  ConsultaMensajesMovilResponse getMensajesMovilRecibidos(UsuarioDtoRequest usuarioDtoRequest, GetMensajesMovilRequest getMensajesMovilRequest){
        ConsultaMensajesMovilResponse response = new ConsultaMensajesMovilResponse();
        
        try {
            //Consultamos y obtenemos el ID de Empresa del Usuario
            UsuarioBO usuariosBO = new UsuarioBO(getConn());
            if (usuariosBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())) {
                //int idEmpresa = usuariosBO.getUsuarios().getIdEmpresa();
                long idUsuarios = usuariosBO.getUser().getIdUsuarios();
                
                /*if (idEmpresa > 0) {
                    
                }*/
                MovilMensaje[] movilMensajeDtoA = new MovilMensajeBO(getConn()).getMovilMensajesByFilter(
                        true, 
                        getMensajesMovilRequest.getFiltroFechaInicio(), 
                        getMensajesMovilRequest.getFiltroFechaFinal(), 
                        getMensajesMovilRequest.isFiltroNoRecibidos(),
                        getMensajesMovilRequest.isFiltroComunicacionConsola(), 
                        getMensajesMovilRequest.getFiltroIdReceptor(), 
                        getMensajesMovilRequest.getFiltroIdEmisor());
                
                response.setWsItemMovilMensajes(new ArrayList<WsItemMovilMensaje>());
                for (MovilMensaje msg:movilMensajeDtoA){
                    WsItemMovilMensaje wsItemMovilMensaje = new WsItemMovilMensaje();
                    
                    wsItemMovilMensaje.setEmisorTipo(msg.getEmisorTipo());
                    wsItemMovilMensaje.setFechaEmision(msg.getFechaEmision());
                    wsItemMovilMensaje.setFechaRecepcion(msg.getFechaRecepcion());
                    wsItemMovilMensaje.setIdEmpleadoEmisor(msg.getIdUsuarioEmisor());
                    wsItemMovilMensaje.setIdEmpleadoReceptor(msg.getIdUsuarioReceptor());
                    wsItemMovilMensaje.setIdMovilMensaje(msg.getIdMovilMensaje());
                    wsItemMovilMensaje.setMensaje(msg.getMensaje());
                    wsItemMovilMensaje.setReceptorTipo(msg.getReceptorTipo());
                    wsItemMovilMensaje.setRecibido(msg.getRecibido()==1);
                    
                    
                    response.getWsItemMovilMensajes().add(wsItemMovilMensaje);
                    
                    //Actualizamos registro a leido
                    msg.setRecibido(1);
                    try{
                        msg.setFechaRecepcion(ZonaHorariaBO.DateZonaHorariaByIdEmpresa(getConn(), new Date(), (int)usuariosBO.getUser().getIdEmpresa()).getTime());
                    }catch(Exception e){
                        msg.setFechaRecepcion(new Date());
                    }
                    new MovilMensajeDaoImpl(getConn()).update(msg.createPk(), msg);
                }
                        
                response.setError(false);
                
                //registramos ubicacion
                try{new InsertaActualizaWsBO(getConn()).actualizarUbicacionUsuario(usuarioDtoRequest);}catch(Exception ex){}
                
                //Recuperamos información sobre reporte de robo
                try{
                    DispositivoMovilBO dispositivoMovilBO = new DispositivoMovilBO(usuariosBO.getUser().getIdDispositivo(), getConn());
                    if (dispositivoMovilBO.getDispositivoMovil()!=null){
                        response.setReporteRobo( dispositivoMovilBO.getDispositivoMovil().getReporteRobo()!=0 );
                    }
                }catch(Exception ex){}
                
                //Recuperamos información de Créditos de Operación de la empresa
                /*try{
                    Empresa empresaMatriz = new EmpresaBO(getConn()).getEmpresaMatriz(usuariosBO.getUsuario().getIdEmpresa());
                    response.setCreditosOperacionDisponibles(empresaMatriz.getCreditosOperacion());
                }catch(Exception ex){
                    ex.printStackTrace();
                }*/
                
            } else {
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("El usuario y/o contraseña del Usuarios son inválidos.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setError(true);
            response.setNumError(902);
            response.setMsgError("Error inesperado al consultar mensajes del usuarios. " + e.toString());
        }finally{
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }
        
        return response;
    }
    
    public  ConsultaMensajesMovilResponse getMensajesMovilEnviados(String usuarioDtoRequestJSON, String getMensajesMovilRequestJSON){
        
        ConsultaMensajesMovilResponse response;
                
        UsuarioDtoRequest usuarioDtoRequest = null;
        GetMensajesMovilRequest getMensajesMovilRequest = null;
        try{
            //Transformamos de formato JSON a objeto
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJSON, UsuarioDtoRequest.class);
            getMensajesMovilRequest = gson.fromJson(getMensajesMovilRequestJSON, GetMensajesMovilRequest.class);
            
            response = this.getMensajesMovilEnviados(usuarioDtoRequest,getMensajesMovilRequest);
        }catch(Exception ex){
            response = new ConsultaMensajesMovilResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        
        return response;
        
    }
    
    public  ConsultaMensajesMovilResponse getMensajesMovilEnviados(UsuarioDtoRequest usuarioDtoRequest, GetMensajesMovilRequest getMensajesMovilRequest){
        ConsultaMensajesMovilResponse response = new ConsultaMensajesMovilResponse();
        
        try {
            //Consultamos y obtenemos el ID de Empresa del Usuario
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())) {
                //int idEmpresa = usuarioBO.getEmpleado().getIdEmpresa();
                long idUsuario = usuarioBO.getUser().getIdUsuarios();
                
                /*if (idEmpresa > 0) {
                    
                }*/
                MovilMensaje[] movilMensajeDtoA = new MovilMensajeBO(getConn()).getMovilMensajesByFilter(
                        false, 
                        getMensajesMovilRequest.getFiltroFechaInicio(), 
                        getMensajesMovilRequest.getFiltroFechaFinal(), 
                        getMensajesMovilRequest.isFiltroNoRecibidos(),
                        getMensajesMovilRequest.isFiltroComunicacionConsola(), 
                        getMensajesMovilRequest.getFiltroIdReceptor(), 
                        getMensajesMovilRequest.getFiltroIdEmisor());
                
                response.setWsItemMovilMensajes(new ArrayList<WsItemMovilMensaje>());
                for (MovilMensaje msg:movilMensajeDtoA){
                    WsItemMovilMensaje wsItemMovilMensaje = new WsItemMovilMensaje();
                    
                    wsItemMovilMensaje.setEmisorTipo(msg.getEmisorTipo());
                    wsItemMovilMensaje.setFechaEmision(msg.getFechaEmision());
                    wsItemMovilMensaje.setFechaRecepcion(msg.getFechaRecepcion());
                    wsItemMovilMensaje.setIdEmpleadoEmisor(msg.getIdUsuarioEmisor());
                    wsItemMovilMensaje.setIdEmpleadoReceptor(msg.getIdUsuarioReceptor());
                    wsItemMovilMensaje.setIdMovilMensaje(msg.getIdMovilMensaje());
                    wsItemMovilMensaje.setMensaje(msg.getMensaje());
                    wsItemMovilMensaje.setReceptorTipo(msg.getReceptorTipo());
                    wsItemMovilMensaje.setRecibido(msg.getRecibido()==1?true:false);
                    
                    
                    response.getWsItemMovilMensajes().add(wsItemMovilMensaje);
                }
                        
                response.setError(false);
                
                //registramos ubicacion
                try{new InsertaActualizaWsBO(getConn()).actualizarUbicacionUsuario(usuarioDtoRequest);}catch(Exception ex){}
                
            } else {
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("El usuario y/o contraseña del Empleado son inválidos.");
            }
        } catch (Exception e) {
            response.setError(true);
            response.setNumError(902);
            response.setMsgError("Error inesperado al consultar ventas del empleado. " + e.toString());
        }finally{
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }
        
        return response;
    }
    
    /**
     * Consulta las Rutas que corresponden a un empleado promotor
     * que solicita los datos
     * @param usuarioDtoRequesttJSON
     * @return 
     */
    public ConsultaRutasResponse getRutasByUsuario(String usuarioDtoRequesttJSON){
        ConsultaRutasResponse response;
                
        UsuarioDtoRequest usuarioDtoRequest = null;
        try{
            //Transformamos de formato JSON a objeto
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequesttJSON, UsuarioDtoRequest.class);
            
            response = this.getRutasByUsuario(usuarioDtoRequest);
        }catch(Exception ex){
            response = new ConsultaRutasResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        
        return response;
    }
    
    /**
     * Consulta las Rutas que corresponden a un empleado promotor
     * que solicita los datos
     * @param usuarioDtoRequest
     * @return 
     */
    public ConsultaRutasResponse getRutasByUsuario(UsuarioDtoRequest usuarioDtoRequest){
        long idEmpresa = 0;
        long idUsuario = 0;
        ConsultaRutasResponse consultaResponse = new ConsultaRutasResponse();
        try {
            //Consultamos y obtenemos el ID de Empresa del Usuario
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())) {
                idEmpresa = usuarioBO.getUser().getIdEmpresa();
                idUsuario = usuarioBO.getUser().getIdUsuarios();
                
                if (idEmpresa > 0) {
                    
                    Ruta[] rutas = new RutaDaoImpl(getConn()).findByDynamicWhere(
                            " ID_USUARIO=" + idUsuario
                            , null);
                    
                    if (rutas.length<=0){
                        //No hay mas registros o actualizaciones pendientes
                        
                        consultaResponse.setError(false);
                        consultaResponse.setWsItemRuta(new ArrayList<WsItemRuta>());
                        return consultaResponse;
                    }else{
                        
                        for (Ruta ruta : rutas){
                            WsItemRuta wsItemRuta = new WsItemRuta();
                            wsItemRuta.setComentarioRuta(ruta.getComentarioRuta());
                            wsItemRuta.setFhRegRuta(ruta.getFhRegRuta());
                            wsItemRuta.setIdUsuario(ruta.getIdUsuario());
                            wsItemRuta.setIdRuta(ruta.getIdRuta());
                            wsItemRuta.setIdTipoRuta(ruta.getIdTipoRuta());
                            wsItemRuta.setNombreRuta(ruta.getNombreRuta());
                            wsItemRuta.setParadasRuta(ruta.getParadasRuta());
                            //wsItemRuta.setRecorridoRuta(ruta.getRecorridoRuta());
                            wsItemRuta.setDiasSemanaRuta(ruta.getDiasSemanaRuta());
                            
                            RutaMarcador[] rutaMarcadoresDto = new RutaMarcadorDaoImpl(getConn()).findByDynamicWhere(
                                    " ID_RUTA=" + ruta.getIdRuta()
                                    , null);
                            List<WsItemRutaMarcador> wsItemRutaMarcadores = new ArrayList<WsItemRutaMarcador>();
                            for (RutaMarcador marcadorDto : rutaMarcadoresDto){
                                WsItemRutaMarcador wsItemRutaMarcador = new WsItemRutaMarcador();
                                wsItemRutaMarcador.setIdCliente(marcadorDto.getIdCliente());
                                wsItemRutaMarcador.setIdProspecto(marcadorDto.getIdProspecto());
                                wsItemRutaMarcador.setIdRuta(marcadorDto.getIdRuta());
                                wsItemRutaMarcador.setIdRutaMarcador(marcadorDto.getIdRutaMarcador());
                                wsItemRutaMarcador.setInformacionMarcador(marcadorDto.getInformacionMarcador());
                                wsItemRutaMarcador.setIsVisitado(marcadorDto.getIsVisitado());
                                wsItemRutaMarcador.setLatitudMarcador(marcadorDto.getLatitudMarcador());
                                wsItemRutaMarcador.setLongitudMarcador(marcadorDto.getLongitudMarcador());
                                
                                wsItemRutaMarcadores.add(wsItemRutaMarcador);   
                            }
                            
                            wsItemRuta.setWsItemRutaMarcador(wsItemRutaMarcadores);
                            
                            consultaResponse.getWsItemRuta().add(wsItemRuta);
                        }
                        
                        consultaResponse.setError(false);
                        return consultaResponse;
                        
                    }
                    
                }
                
                //registramos ubicacion
                try{new InsertaActualizaWsBO(getConn()).actualizarUbicacionUsuario(usuarioDtoRequest);}catch(Exception ex){}
            } else {
                consultaResponse.setError(true);
                consultaResponse.setNumError(901);
                consultaResponse.setMsgError("El usuario y/o contraseña del Empleado son inválidos.");
            }
        } catch (Exception e) {
            consultaResponse.setError(true);
            consultaResponse.setNumError(902);
            consultaResponse.setMsgError("Error inesperado al consultar Rutas. " + e.getLocalizedMessage());
        } finally{
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }

        return consultaResponse;
    }
    
    /**
     * Obtiene el catalogo de Prospectos por usuario
     * @param userName 
     */
    public ConsultaProspectosResponse getCatalogoProspectosByUsuario(String usuarioDtoRequestJSON) {
        ConsultaProspectosResponse response;
                
        UsuarioDtoRequest usuarioDtoRequest = null;
        try{
            //Transformamos de formato JSON a objeto
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJSON, UsuarioDtoRequest.class);
            
            response = this.getCatalogoProspectoByUsuario(usuarioDtoRequest);
        }catch(Exception ex){
            response = new ConsultaProspectosResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        
        return response;
    }

    private ConsultaProspectosResponse getCatalogoProspectoByUsuario(UsuarioDtoRequest usuarioDtoRequest) {
        
        int idEmpresa = 0;
        int idUsuario = 0;
        ConsultaProspectosResponse consultaResponse = new ConsultaProspectosResponse();
        try {
            //Consultamos y obtenemos el ID de Empresa del Usuario
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())) {
                idEmpresa = usuarioBO.getUser().getIdEmpresa();
                idUsuario = usuarioBO.getUser().getIdUsuarios();
                //Si se encontro el registro buscamos su catalogo de clientes
                if (idEmpresa > 0) {
                    consultaResponse.setError(false);
                    //Filtramos con Estatus Activo y que esten asignados a este empleado
                    consultaResponse.setWsItemProspecto(this.getListaProspectos(idEmpresa, 
                            " AND (ID_ESTATUS = 1 )  "
                          + " AND ( ID_PROSPECTO IN (SELECT ID_PROSPECTO FROM relacion_prospecto_vendedor WHERE ID_USUARIO=" + idUsuario + " )"                         
                          + " ) "
                    ));
                }
                
                //registramos ubicacion
                try{new InsertaActualizaWsBO(getConn()).actualizarUbicacionUsuario(usuarioDtoRequest);}catch(Exception ex){}
            } else {
                consultaResponse.setError(true);
                consultaResponse.setNumError(901);
                consultaResponse.setMsgError("El usuario y/o contraseña del Usuario son inválidos.");
            }
        } catch (Exception e) {
            consultaResponse.setError(true);
            consultaResponse.setNumError(902);
            consultaResponse.setMsgError("Error inesperado al consultar catalogos del usuario. " + e.getLocalizedMessage());
        }finally{
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }

        return consultaResponse;
        
        
    }
    
    /**
     * Consulta los prospectos de una empresa.
     * @param idEmpresa
     * @return 
     */
    private ArrayList<WsItemProspecto> getListaProspectos(int idEmpresa, String filtroBusqueda){//int idEmpresa) {
        
        ArrayList<WsItemProspecto> listaWsItemProspecto = new ArrayList<>();
        //Buscamos los prospectos definidos para el usuario/empresa
        ProspectoDaoImpl prospetoDao = new ProspectoDaoImpl(getConn());
        ProspectoBO prospectoBO = new ProspectoBO(getConn());
        Prospecto[] arrayProspectoDto;

        
        
        try {
            arrayProspectoDto = prospectoBO.findProspecto(-1, idEmpresa, 0, 0, filtroBusqueda);
            if (arrayProspectoDto.length > 0) {
                //Llenamos la lista de prospectos del objeto respuesta
                for (Prospecto item : arrayProspectoDto) {
                    try {
                        if(item.getIdEstatus() != 2){
                            WsItemProspecto wsItemProspecto = new WsItemProspecto();
                            wsItemProspecto.setIdProspecto(item.getIdProspecto());   
                            wsItemProspecto.setIdEmpresa(item.getIdEmpresa());
                            wsItemProspecto.setRazonSocial(item.getRazonSocial());
                            wsItemProspecto.setLada(item.getLada());
                            wsItemProspecto.setTelefono(item.getTelefono());
                            wsItemProspecto.setCelular(item.getCelular());
                            wsItemProspecto.setCorreo(item.getCorreo());
                            wsItemProspecto.setContacto(item.getContacto());
                            wsItemProspecto.setIdEstatus(item.getIdEstatus());
                            wsItemProspecto.setDescripcion(item.getDescripcion());
                            wsItemProspecto.setLatitud(item.getLatitud());
                            wsItemProspecto.setLongitud(item.getLongitud());
                            wsItemProspecto.setDireccion(item.getDireccion());
                            wsItemProspecto.setNombreImagenProspecto(item.getNombreImagenProspecto());
                            wsItemProspecto.setIdUsuarioVendedor(item.getIdUsuarioVendedor());
                            wsItemProspecto.setFechaRegistro(item.getFechaRegistro());
                            wsItemProspecto.setDirNumeroExterior(item.getDirNumeroExterior());
                            wsItemProspecto.setDirNumeroInterior(item.getDirNumeroInterior());
                            wsItemProspecto.setDirCodigoPostal(item.getDirCodigoPostal());
                            wsItemProspecto.setDirColonia(item.getDirColonia());
                            listaWsItemProspecto.add(wsItemProspecto);
                    }
                        
                    } catch (Exception e) {
                    }
                }
            }
        } catch (Exception e) {
        }

        return listaWsItemProspecto;
    }
    
    
}
