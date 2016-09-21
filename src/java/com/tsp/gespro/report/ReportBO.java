/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.tsp.gespro.report;


import com.tsp.gespro.bo.*;
import com.tsp.gespro.dto.*;

import com.tsp.gespro.exceptions.DatosUsuarioDaoException;
import com.tsp.gespro.exceptions.EmpresaDaoException;
import com.tsp.gespro.exceptions.SgfensPedidoDaoException;
import com.tsp.gespro.exceptions.SgfensPedidoProductoDaoException;
import com.tsp.gespro.jdbc.DatosUsuarioDaoImpl;
import com.tsp.gespro.jdbc.EmpresaDaoImpl;
import com.tsp.gespro.jdbc.SgfensPedidoDaoImpl;
import com.tsp.gespro.jdbc.SgfensPedidoProductoDaoImpl;
import com.tsp.gespro.util.DateManage;
import com.tsp.gespro.util.Encrypter;
import com.tsp.gespro.util.StringManage;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.text.NumberFormat;
import java.text.DecimalFormat;
import java.util.Date;

/**
 *
 * @author ISCesarMartinez  poseidon24@hotmail.com
 * @date 17-dic-2012 
 */
public class ReportBO {
    
    public static final int DATA_STRING = 1;
    public static final int DATA_INT = 2;
    public static final int DATA_DECIMAL = 3;
    public static final int DATA_DATE = 4;
    public static final int DATA_DATETIME = 5;
    public static final int DATA_BOOLEAN = 6;
    
    
    public static final int CUSTOM_REPORT = -1;
    public static final int USER_REPORT = 1;  
    public static final int CLIENTE_REPORT = 2;
    public static final int PRODUCTO_REPORT = 3;
    public static final int PROSPECTO_REPORT = 4;
    public static final int BITACORA_REPORT = 5;
    public static final int PEDIDO_REPORT = 6;
    public static final int DEGUSTACION_REPORT = 7;
    public static final int CADUCIDAD_REPORT = 8;
    public static final int GENERAL_REPORT = 9;
    public static final int COMPETENCIA_REPORT = 10;
    
    
    
    public static final int PEDIDO_REPRESENTACION_IMPRESA = 24;
    public static final int DEGUSTACION_REPRESENTACION_IMPRESA = 25;
    
    private int tipoReporte = 0;
   
    private UsuarioBO usuarioBO = null;

    private Connection conn = null;
    
    //Flag para Indicar si al generar los reportes al final se genera una fila 
    // con totales de acuerdo al tipo de Campo específicado en el reporte
    private boolean totalDecimalFields = false;
    private boolean totalIntegerFields = false;

    public Connection getConn() {
        return conn;
    }

    public void setConn(Connection conn) {
        this.conn = conn;
    }
    
    public UsuarioBO getUsuarioBO() {
        return usuarioBO;
    }

    public void setUsuarioBO(UsuarioBO usuarioBO) {
        this.usuarioBO = usuarioBO;
    }

    public boolean isTotalDecimalFields() {
        return totalDecimalFields;
    }

    public void setTotalDecimalFields(boolean totalDecimalFields) {
        this.totalDecimalFields = totalDecimalFields;
    }

    public boolean isTotalIntegerFields() {
        return totalIntegerFields;
    }

    public void setTotalIntegerFields(boolean totalIntegerFields) {
        this.totalIntegerFields = totalIntegerFields;
    }
    
    public static String getTitle(int REPORT){
        String title = "Reporte";
        switch(REPORT){
            case USER_REPORT:
                title = "Reporte de Usuarios";
                break; 
            case PEDIDO_REPRESENTACION_IMPRESA:
                title = "PEDIDO";
                break;
            case CLIENTE_REPORT:
                title = "Reporte de Clientes";
                break;
            case DEGUSTACION_REPRESENTACION_IMPRESA:
                title = "DEGUSTACION";
                break;
            case PRODUCTO_REPORT:
                title = "Reporte de Productos";
                break;
            case PROSPECTO_REPORT:
                title = "Reporte de Prospectos";
                break;
            case BITACORA_REPORT:
                title = "Reporte de Bitacora";
                break;
            case PEDIDO_REPORT:
                title = "Reporte de Pedidos";
                break;
            case DEGUSTACION_REPORT:
                title = "Reporte de Degustaciones";
                break;
            case CADUCIDAD_REPORT:
                title = "Reporte de Caducidad";
                break;
            case GENERAL_REPORT:
                title = "Reporte general";
                break;
            case COMPETENCIA_REPORT:
                title = "Reporte de competencia";
                break;
        }
        
        return title;
    }
    
    /**
     * 
     * 
     * @return String realData
     */
    private String getRealData(HashMap hashField,String data){
        String realData = "";
        try {
            switch(Integer.parseInt(hashField.get("type").toString())){
                case DATA_BOOLEAN:
                    realData = "" + (data.equals("1")?"TRUE":"FALSE");
                    if(hashField.get("mask")!=null && !hashField.get("mask").toString().equals("")){
                        String[] mask = hashField.get("mask").toString().split("\\|");
                        if(realData.equals("TRUE"))
                            realData = mask[0];
                        else
                            realData = mask[1];
                    }
                    break;
                case DATA_DATE:
                    realData = "" + new SimpleDateFormat("dd/MM/yyyy").format(new SimpleDateFormat("yyyy-MM-dd").parse(data));
                    if(hashField.get("mask")!=null && !hashField.get("mask").toString().equals("")){
                        realData = "" + new SimpleDateFormat(hashField.get("mask").toString()).format(new SimpleDateFormat("yyyy-MM-dd").parse(data));
                    }
                    break;
                case DATA_DATETIME:
                    if (data!=null){
                        try{
                            realData = "" + new SimpleDateFormat("dd/MM/yyyy hh:mm:ss a").format(new SimpleDateFormat("yyyy-MM-dd hh:mm:ss").parse(data));
                            if(hashField.get("mask")!=null && !hashField.get("mask").toString().equals("")){
                                realData = "" + new SimpleDateFormat(hashField.get("mask").toString()).format(new SimpleDateFormat("yyyy-MM-dd").parse(data));
                            }
                        }catch(Exception ex){}
                    }
                    break;
                case DATA_DECIMAL:
                    //realData = "" + Float.parseFloat(data);
                    realData = "" + new BigDecimal(data).setScale(2, RoundingMode.HALF_UP);
                    break;
                case DATA_INT:
                    realData = "" + Integer.parseInt(data);
                    break;
                case DATA_STRING:
                    realData = data;
                    break;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return realData;
    }

    /**
     * Devuelve un hash con los datos para el encabezado del reporte
     * 
     * @param String field
     * @param String label
     * @param String fkTable
     * @param String fkField
     * @param String type
     * @param String mask
     * 
     * @return Hash<String,String>
     */
    public HashMap getDataInfo(String field, String label, String fkTable, String fkField, String type, String mask){

        HashMap<String,String> dataMap = new HashMap<String, String>();

        dataMap.put("field", field);
        dataMap.put("label", label);
        dataMap.put("fkTable", fkTable);
        dataMap.put("fkField", fkField);
        dataMap.put("type",type);
        dataMap.put("mask",mask);

        return dataMap;
    }
    
    /**
     * Devuelve un arreglo de hash con los encabezados del reporte
     * 
     * @param int REPORT
     * 
     * @return ArrayList<HashMap>
     */
    public ArrayList<HashMap> getFieldList(int REPORT){
        ArrayList<HashMap> fieldList = new ArrayList<HashMap>();
        switch(REPORT){
            case USER_REPORT:
                fieldList.add(getDataInfo("ID_USUARIOS","ID","","",""+DATA_INT,""));
                fieldList.add(getDataInfo("SUCURSAL","Sucursal","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("USER_NAME","Usuario","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("FK_ROL","Rol","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("FK_NOMBRE","Nombre","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("ID_ESTATUS","Estatus","","",""+DATA_BOOLEAN,"Activo|Inactivo"));
                break;            
                
            case CLIENTE_REPORT:
                fieldList.add(getDataInfo("ID_CLIENTE","ID","","",""+DATA_INT,""));                
                fieldList.add(getDataInfo("NOMBRE_COMERCIAL","Nombre Comercial","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("CONTACTO","Contacto","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("CORREO","Correo","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("ID_ESTATUS","Estatus","","",""+DATA_BOOLEAN,"Activo|Inactivo"));                
                fieldList.add(getDataInfo("FECHA_REGISTRO","Fecha Registro","","",""+DATA_STRING,""));
                break;
                
            case PRODUCTO_REPORT:
                fieldList.add(getDataInfo("ID_CONCEPTO","ID","","",""+DATA_INT,""));
                fieldList.add(getDataInfo("CODIGO","Código","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("NOMBRE","Nombre","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("DESCRIPCION","Descripcion","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("FK_MARCA","Marca","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("FK_CATEGORIA","Categoria","","",""+DATA_STRING,""));                
                fieldList.add(getDataInfo("PRECIO","Precio","","",""+DATA_DECIMAL,""));                
                fieldList.add(getDataInfo("ID_ESTATUS","Estatus","","",""+DATA_BOOLEAN,"Activo|Inactivo"));
                break;
                
            case PROSPECTO_REPORT:
                fieldList.add(getDataInfo("ID_PROSPECTO","ID","","",""+DATA_INT,""));
                fieldList.add(getDataInfo("RAZON_SOCIAL","Razón Social","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("CONTACTO","Contacto","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("CORREO","Correo","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("FECHA_REGISTRO","Fecha Registro","","",""+DATA_STRING,""));
                break;
            case BITACORA_REPORT:
                fieldList.add(getDataInfo("ID_CHECK","ID","","",""+DATA_INT,""));
                fieldList.add(getDataInfo("FECHA","Fecha","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("TIPO","Tipo","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("DETALLE","Detalle","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("CLIENTE","Cliente","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("INCIDENCIA","Incidencia","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("COMENTARIOS","Comentarios","","",""+DATA_STRING,""));
                break;
            case PEDIDO_REPORT:
                fieldList.add(getDataInfo("ID_PEDIDO","ID","","",""+DATA_INT,""));
                fieldList.add(getDataInfo("FOLIO_PEDIDO","Folio","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("VENDEDOR","Vendedor","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("CLIENTE","Cliente","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("FECHA","Fecha","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("ESTADO","Estado","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("CANTIDAD","Cantidad Productos","","",""+DATA_INT,""));
                fieldList.add(getDataInfo("VENTA_TOTAL","Venta total","","",""+DATA_DECIMAL,""));
                fieldList.add(getDataInfo("TIPO","Tipo","","",""+DATA_STRING,""));
                break;
            case DEGUSTACION_REPORT:
                fieldList.add(getDataInfo("ID_DEGUSTACION","ID","","",""+DATA_INT,""));
                fieldList.add(getDataInfo("FECHA","Fecha","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("PROMOTOR","Promotor","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("CLIENTE","Cliente","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("HR_INICIO","Hr inicio","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("HR_TERMINO","Hr termino","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("TIEMPO_DEGUSTACION","Tiempo degustación(min)","","",""+DATA_INT,""));
                fieldList.add(getDataInfo("PIEZAS_DEGUSTADAS","Piezas degustadas","","",""+DATA_DECIMAL,""));
                break;
            case CADUCIDAD_REPORT:
                fieldList.add(getDataInfo("FECHA","Fecha","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("PROMOTOR","Promotor","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("PRODUCTO","Producto","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("FECHA_CADUCIDAD","Fecha caducidad","","",""+DATA_STRING,""));
                break;
            case GENERAL_REPORT:
                fieldList.add(getDataInfo("FECHA","Fecha","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("PROMOTOR","Promotor","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("CLIENTE","Cliente","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("SUCURSAL","Sucursal","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("CLAVE_PRODUCTO","Clave producto","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("NOMBRE_PRODUCTO","Nombre producto","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("UNIDAD_ANAQUEL","Unidades anaquel","","",""+DATA_DECIMAL,""));
                fieldList.add(getDataInfo("PRECIO_ANAQUEL","Precio anaquel","","",""+DATA_DECIMAL,""));
                fieldList.add(getDataInfo("PRECIO_OFERTA","Precio oferta","","",""+DATA_DECIMAL,""));
                fieldList.add(getDataInfo("UNIDAD_ALMACEN","Unidades almacen","","",""+DATA_DECIMAL,""));
                fieldList.add(getDataInfo("UNIDAD_TOTAL","Unidades totales","","",""+DATA_DECIMAL,""));
                break;
            case COMPETENCIA_REPORT:
                fieldList.add(getDataInfo("FECHA","Fecha","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("CLIENTE","Cliente","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("SUCURSAL","Sucursal","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("PRODUCTO","Producto","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("PRECIO_ANAQUEL","$ Anaquel","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("PRECIO_COMPETENCIA","$ Competencia","","",""+DATA_STRING,""));
                break;
        }
        return fieldList;
    }
    
    /**
     * Devuelve una lista con los valores del reporte seleccionado
     * 
     * @param int report - Tipo de reporte
     * @param String params - Parámetros de búsqueda
     * 
     * @return ArrayList<HashMap> - Arreglo de hash con los datos
     */
    public ArrayList<HashMap> getDataReport(int report, String params, String paramsExtra) throws Exception{
        tipoReporte = report;
        int idEmpresa = usuarioBO!=null?usuarioBO.getUser().getIdEmpresa():-1;
        String paramsDefault ="";
        ArrayList<HashMap> dataList = new ArrayList<HashMap>();
        switch(report){
            /*case USER_REPORT:
                if(params!=null && !params.equals(""))
                    dataList = this.getDataList(new UsuariosBO().findUsuarios(-1, idEmpresa, 0, 0, params));
                    //dataList = this.getDataList(new UsuariosDaoImpl().findByDynamicWhere(params, new Object[0]));
                else
                    dataList = this.getDataList(new UsuariosBO().findUsuarios(-1, idEmpresa, 0, 0, ""));
                    //dataList = this.getDataList(new UsuariosDaoImpl().findAll());
                break;*/
            case CLIENTE_REPORT:
                if(params!=null && !params.equals(""))
                    dataList = this.getDataList(new ClienteBO(this.conn).findClientes(-1, idEmpresa, 0, 0, params));
                else
                    dataList = this.getDataList(new ClienteBO(this.conn).findClientes(-1, idEmpresa, 0, 0, ""));
                break;
            case PRODUCTO_REPORT:
                if(params!=null && !params.equals(""))
                    dataList = this.getDataList(new ConceptoBO(this.conn).findConceptos(-1, idEmpresa, 0, 0, params));
                else
                    dataList = this.getDataList(new ConceptoBO(this.conn).findConceptos(-1, idEmpresa, 0, 0, ""));
                break;    
            case PROSPECTO_REPORT:
                if(params!=null && !params.equals(""))
                    dataList = this.getDataList(new ProspectoBO(this.conn).findProspecto(-1, idEmpresa, 0, 0, params));
                else
                    dataList = this.getDataList(new ProspectoBO(this.conn).findProspecto(-1, idEmpresa, 0, 0, ""));
                break;
             case BITACORA_REPORT:
                if(params!=null && !params.equals(""))
                    dataList = this.getDataList(new RegistroCheckInBO(this.conn).findRegistroCheckins(-1,-1, 0, 0, params));
                else
                    dataList = this.getDataList(new RegistroCheckInBO(this.conn).findRegistroCheckins(-1,-1, 0, 0, ""));
                break;
             case PEDIDO_REPORT:
                if(params!=null && !params.equals(""))
                    dataList = this.getDataList(new SGPedidoBO(this.conn).findPedido(-1,idEmpresa, 0, 0, params));
                else
                    dataList = this.getDataList(new SGPedidoBO(this.conn).findPedido(-1,idEmpresa, 0, 0, ""));
                break;
             case DEGUSTACION_REPORT:
                if(params!=null && !params.equals(""))
                    dataList = this.getDataList(new DegustacionBO(this.conn).findDegustaciones(-1,idEmpresa, 0, 0, params));
                else
                    dataList = this.getDataList(new DegustacionBO(this.conn).findDegustaciones(-1,idEmpresa, 0, 0, ""));
                break;
             case CADUCIDAD_REPORT:
                if(params!=null && !params.equals(""))
                    dataList = this.getDataList(new EstanteriaBO(this.conn).findEstanteria(-1,idEmpresa, 0, 0, params));
                else
                    dataList = this.getDataList(new EstanteriaBO(this.conn).findEstanteria(-1,idEmpresa, 0, 0, ""));
                break;
            case GENERAL_REPORT:
                if(params!=null && !params.equals(""))
                    dataList = this.getDataListGeneral(new EstanteriaBO(this.conn).findEstanteria(-1,idEmpresa, 0, 0, params));
                else
                    dataList = this.getDataListGeneral(new EstanteriaBO(this.conn).findEstanteria(-1,idEmpresa, 0, 0, ""));
                break;
            case COMPETENCIA_REPORT:
                if(params!=null && !params.equals(""))
                    dataList = this.getDataListCompetencia(new EstanteriaBO(this.conn).findEstanteria(-1,idEmpresa, 0, 0, params));
                else
                    dataList = this.getDataListCompetencia(new EstanteriaBO(this.conn).findEstanteria(-1,idEmpresa, 0, 0, ""));
                break;
             
        }
        return dataList;
    }
    
    
    /**
     *  CLIENTE_REPORT
     * @param objectDto Arreglo de objetos tipo DTO para fabricar reporte.
     * @return ArrayList<HashMap> con todos los datos para el reporte.
     */
    private ArrayList<HashMap> getDataList(Cliente[] objectDto) {
        ArrayList<HashMap> dataList = new ArrayList<HashMap>();
        HashMap<String,String> hashData = new HashMap<String, String>();
        ArrayList<HashMap> dataInfo = getFieldList(CLIENTE_REPORT);
        
        SimpleDateFormat format = new SimpleDateFormat("dd/MM/yyyy" );
        
        String fechaReg ="";
        
        for(Cliente dto:objectDto){
            
            fechaReg ="";
            try{            
               fechaReg = format.format(dto.getFechaRegistro());
            }catch(Exception e){}

            hashData.put((String)dataInfo.get(0).get("field"), getRealData(dataInfo.get(0), "" + dto.getIdCliente())); ;
            hashData.put((String)dataInfo.get(1).get("field"), getRealData(dataInfo.get(1), "" + dto.getNombreComercial()));
            hashData.put((String)dataInfo.get(2).get("field"), getRealData(dataInfo.get(2), "" + dto.getContacto()!=null?dto.getContacto():"" ));
            hashData.put((String)dataInfo.get(3).get("field"), getRealData(dataInfo.get(3), "" + dto.getCorreo() ));
            hashData.put((String)dataInfo.get(4).get("field"), getRealData(dataInfo.get(4), "" + dto.getIdEstatus() ));            
            hashData.put((String)dataInfo.get(5).get("field"), getRealData(dataInfo.get(5), "" + fechaReg));

            dataList.add(hashData);

            hashData = new HashMap<String, String>();
        }

        return dataList;
    }

    /**
     *  PRODUCTO_REPORT
     * @param objectDto Arreglo de objetos tipo DTO para fabricar reporte.
     * @return ArrayList<HashMap> con todos los datos para el reporte.
     */
    private ArrayList<HashMap> getDataList(Concepto[] objectDto) {
        ArrayList<HashMap> dataList = new ArrayList<HashMap>();
        HashMap<String,String> hashData = new HashMap<String, String>();
        ArrayList<HashMap> dataInfo = getFieldList(PRODUCTO_REPORT);

        ConceptoBO conceptoBO = new ConceptoBO(this.conn);
        ExistenciaAlmacenBO exisAlmBO = new ExistenciaAlmacenBO(this.conn);
        for(Concepto dto:objectDto){
            
            Marca marcaDto =null;
            Categoria categoriaDto = null;
            Categoria subcategoriaDto = null;
            double stockGral = 0;
            try{
                marcaDto = new MarcaBO(dto.getIdMarca(),this.conn).getMarca();
                categoriaDto = new CategoriaBO(dto.getIdCategoria(),this.conn).getCategoria();
                subcategoriaDto = new CategoriaBO(dto.getIdSubcategoria(),this.conn).getCategoria();
                stockGral = exisAlmBO.getExistenciaGeneralByEmpresaProducto(dto.getIdEmpresa(), dto.getIdConcepto());
            }catch(Exception ex){
                ex.printStackTrace();
            }
            hashData.put((String)dataInfo.get(0).get("field"), getRealData(dataInfo.get(0), "" + dto.getIdConcepto()));
            hashData.put((String)dataInfo.get(1).get("field"), getRealData(dataInfo.get(1), "" + dto.getIdentificacion()));         
            hashData.put((String)dataInfo.get(2).get("field"), getRealData(dataInfo.get(2), "" + dto.getNombreDesencriptado() ));          
            hashData.put((String)dataInfo.get(3).get("field"), getRealData(dataInfo.get(3), "" + dto.getDescripcion() ));
            hashData.put((String)dataInfo.get(4).get("field"), getRealData(dataInfo.get(4), "" + (dto.getIdMarca()>0?"[" + dto.getIdMarca() +"]":"") + (marcaDto!=null? marcaDto.getNombre():"") ));
            hashData.put((String)dataInfo.get(5).get("field"), getRealData(dataInfo.get(5), "" + (dto.getIdCategoria()>0?"[" + dto.getIdCategoria() +"]":"") + (categoriaDto!=null? categoriaDto.getNombreCategoria():"") ));          
            hashData.put((String)dataInfo.get(6).get("field"), getRealData(dataInfo.get(6), "" + dto.getPrecio() ));         
            hashData.put((String)dataInfo.get(7).get("field"), getRealData(dataInfo.get(7), "" + dto.getIdEstatus() ));

            dataList.add(hashData);

            hashData = new HashMap<String, String>();
        }

        return dataList;
    }
    
    
    /**
     *  PROSPECTO_REPORT
     * @param objectDto Arreglo de objetos tipo DTO para fabricar reporte.
     * @return ArrayList<HashMap> con todos los datos para el reporte.
     */
    private ArrayList<HashMap> getDataList(Prospecto[] objectDto) {
        ArrayList<HashMap> dataList = new ArrayList<HashMap>();
        HashMap<String,String> hashData = new HashMap<String, String>();
        ArrayList<HashMap> dataInfo = getFieldList(PROSPECTO_REPORT);
        
        SimpleDateFormat format = new SimpleDateFormat("dd/MM/yyyy" );

        String fechaReg ="";
        
        for(Prospecto dto:objectDto){

            fechaReg ="";
            try{            
               fechaReg = format.format(dto.getFechaRegistro());
            }catch(Exception e){}
            
            hashData.put((String)dataInfo.get(0).get("field"), getRealData(dataInfo.get(0), "" + dto.getIdProspecto()));
            hashData.put((String)dataInfo.get(1).get("field"), getRealData(dataInfo.get(1), "" + dto.getRazonSocial() ));
            hashData.put((String)dataInfo.get(2).get("field"), getRealData(dataInfo.get(2), "" + dto.getContacto()!=null?dto.getContacto():"" ));
            hashData.put((String)dataInfo.get(3).get("field"), getRealData(dataInfo.get(3), "" + dto.getCorreo() ));
            hashData.put((String)dataInfo.get(4).get("field"), getRealData(dataInfo.get(4), "" + fechaReg));

            
            dataList.add(hashData);

            hashData = new HashMap<String, String>();
        }

        return dataList;
    }
    
    /**
     *  CLIENTE_REPORT
     * @param objectDto Arreglo de objetos tipo DTO para fabricar reporte.
     * @return ArrayList<HashMap> con todos los datos para el reporte.
     */
    private ArrayList<HashMap> getDataList(RegistroCheckin[] objectDto) {
        ArrayList<HashMap> dataList = new ArrayList<HashMap>();
        HashMap<String,String> hashData = new HashMap<String, String>();
        ArrayList<HashMap> dataInfo = getFieldList(BITACORA_REPORT);        
    
        ClienteBO clienteBO = new ClienteBO(this.conn);
        for(RegistroCheckin dto:objectDto){
            
            String tipoCheck ="";
            try{
                tipoCheck = dto.getIdTipoCheck()==1?"ENTRADA":dto.getIdTipoCheck()==2?"SALIDA":"DESCONOCIDO";
            }catch(Exception e){}
            
            String nombreEstatus  = "SIN DETALLE";
            try{

                EstadoEmpleadoBO estadoEmpleadoBO =  new EstadoEmpleadoBO(dto.getIdDetalleCheck(),this.conn);

                nombreEstatus = estadoEmpleadoBO.getEstado().getNombre();
            }catch(Exception e){
                System.out.println("No se encontraron registros con los datos especificado");
            }
            
            
            String nombreCliente = "";
            if (dto.getIdCliente() > 0){
                Cliente clientesDto = null;
                clienteBO = new ClienteBO(dto.getIdCliente(), this.conn);
                clientesDto = clienteBO.getCliente();
                
                nombreCliente = clientesDto!=null?clientesDto.getNombreComercial():"NA";
            }
            
            String titleIncidencia = "";
            if(dto.getIdTipoCheck() == 1  && dto.getIdDetalleCheck() == 6){
               if(dto.getIncidencia()== 0){                  
                    titleIncidencia = "SIN COMENTARIO";
                }else if(dto.getIncidencia() == 1){                 
                    titleIncidencia = "RETARDO";
                }else if(dto.getIncidencia() == 2){                    
                    titleIncidencia = "FALTA";
                } 
            }else{
                titleIncidencia = "NA";
            }

            hashData.put((String)dataInfo.get(0).get("field"), getRealData(dataInfo.get(0), "" + dto.getIdCheck())); ;
            hashData.put((String)dataInfo.get(1).get("field"), getRealData(dataInfo.get(1), "" + dto.getFechaHora()));
            hashData.put((String)dataInfo.get(2).get("field"), getRealData(dataInfo.get(2), "" + tipoCheck ));
            hashData.put((String)dataInfo.get(3).get("field"), getRealData(dataInfo.get(3), "" + nombreEstatus));
            hashData.put((String)dataInfo.get(4).get("field"), getRealData(dataInfo.get(4), "" + nombreCliente ));            
            hashData.put((String)dataInfo.get(5).get("field"), getRealData(dataInfo.get(5), "" + titleIncidencia));
            hashData.put((String)dataInfo.get(6).get("field"), getRealData(dataInfo.get(6), "" + dto.getComentarios()));

            dataList.add(hashData);

            hashData = new HashMap<String, String>();
        }

        return dataList;
    }
    private ArrayList<HashMap> getDataList(SgfensPedido[] objectDto) {
        ArrayList<HashMap> dataList = new ArrayList<HashMap>();
        HashMap<String,String> hashData = new HashMap<String, String>();
        ArrayList<HashMap> dataInfo = getFieldList(PEDIDO_REPORT);        
    
        SGPedidoBO sgPedidoBO = new SGPedidoBO(this.conn);
        for(SgfensPedido dto:objectDto){
             
            String nombreCliente = "";
            String nombreVendedor = "";
            if (dto.getIdCliente() > 0){
                Cliente clientesDto = null;
                ClienteBO clienteBO = new ClienteBO(dto.getIdCliente(), this.conn);
                clientesDto = clienteBO.getCliente();
                nombreCliente = clientesDto!=null?clientesDto.getNombreComercial():"NA";
            }
            if (dto.getIdUsuarioVendedor()> 0){
                Usuarios usuariosDto = null;
                UsuariosBO usuariosBO = new UsuariosBO(dto.getIdUsuarioVendedor(), this.conn);
                usuariosDto = usuariosBO.getUsuario();
                
                nombreVendedor = usuariosDto!=null?usuariosDto.getUserName():"NA";
            }
            SgfensPedidoProducto[] spp;
            int cantidadProductos = 0;
            try {
                spp = new SgfensPedidoProductoDaoImpl(this.conn).findWhereIdPedidoEquals(dto.getIdPedido());
                cantidadProductos = spp.length;
            } catch (SgfensPedidoProductoDaoException ex) {
                Logger.getLogger(ReportBO.class.getName()).log(Level.SEVERE, null, ex);
            }
            String estatus = "";
            if(dto.getIdEstatusPedido() == 1 || dto.getIdEstatusPedido() == 2){
                estatus = "Vigente";
            }else if(dto.getIdEstatusPedido() == 3){
                estatus = "Cancelado";
            }
            String tipoVenta = "";
            switch(dto.getIdTipoPedido()){
                case 1:
                    tipoVenta = "Faltante a Cliente";
                    break;
                case 2: 
                    tipoVenta = "Degustación";
                    break;
                case 3:
                    tipoVenta = "Venta";
                    break;
                case 4: 
                    tipoVenta = "Devolución";
                    break;
                    
               
            }
            
            hashData.put((String)dataInfo.get(0).get("field"), getRealData(dataInfo.get(0), "" + dto.getIdPedido())); ;
            hashData.put((String)dataInfo.get(1).get("field"), getRealData(dataInfo.get(1), "" + dto.getFolioPedido()));
            hashData.put((String)dataInfo.get(2).get("field"), getRealData(dataInfo.get(2), "" + nombreVendedor));
            hashData.put((String)dataInfo.get(3).get("field"), getRealData(dataInfo.get(3), "" + nombreCliente ));
            hashData.put((String)dataInfo.get(4).get("field"), getRealData(dataInfo.get(4), "" + dto.getFechaPedido()));
            hashData.put((String)dataInfo.get(5).get("field"), getRealData(dataInfo.get(5), "" + estatus ));            
            hashData.put((String)dataInfo.get(6).get("field"), getRealData(dataInfo.get(6), "" + cantidadProductos));
            hashData.put((String)dataInfo.get(7).get("field"), getRealData(dataInfo.get(7), "" + dto.getTotal()));
            hashData.put((String)dataInfo.get(8).get("field"), getRealData(dataInfo.get(8), "" + tipoVenta));

            dataList.add(hashData);

            hashData = new HashMap<String, String>();
        }

        return dataList;
    }
    private ArrayList<HashMap> getDataList(Degustacion[] objectDto) {
        ArrayList<HashMap> dataList = new ArrayList<HashMap>();
        HashMap<String,String> hashData = new HashMap<String, String>();
        ArrayList<HashMap> dataInfo = getFieldList(DEGUSTACION_REPORT);        
    
        for(Degustacion dto:objectDto){
             
            String nombreCliente = "";
            if (dto.getIdCliente() > 0){
                Cliente clientesDto = null;
                ClienteBO clienteBO = new ClienteBO(dto.getIdCliente(), this.conn);
                clientesDto = clienteBO.getCliente();
                nombreCliente = clientesDto!=null?clientesDto.getNombreComercial():"NA";
            }
            String nombreProm = "";
            try{
                DatosUsuario datosUsuario = new UsuarioBO(dto.getIdUsuario()).getDatosUsuario();
                                                        
                if(datosUsuario!=null){
                    nombreProm += datosUsuario.getNombre()!=null?datosUsuario.getNombre():"";
                    nombreProm += " " +(datosUsuario.getApellidoPat()!=null?datosUsuario.getApellidoPat():"");
                    nombreProm += " " +(datosUsuario.getApellidoMat()!=null?datosUsuario.getApellidoMat():"");
                }
            }catch(Exception e){}
            SimpleDateFormat fecha = new SimpleDateFormat("dd/MM/yyyy" );
            SimpleDateFormat hora = new SimpleDateFormat("HH:mm:ss" );
            
            long inicio = dto.getFechaApertura().getTime();
            long fin = dto.getFechaCierre().getTime(); 
            long diff = fin - inicio;
            long diffMinutes = diff / (60 * 1000);
            String resultFecha = diffMinutes<0?"0":""+diffMinutes;
            double piezaDegustada = dto.getCantidad()-dto.getCantidadCierre();
            
            hashData.put((String)dataInfo.get(0).get("field"), getRealData(dataInfo.get(0), "" + dto.getIdDegustacion())); ;
            hashData.put((String)dataInfo.get(1).get("field"), getRealData(dataInfo.get(1), "" + fecha.format(dto.getFechaApertura())));
            hashData.put((String)dataInfo.get(2).get("field"), getRealData(dataInfo.get(2), "" + nombreProm));
            hashData.put((String)dataInfo.get(3).get("field"), getRealData(dataInfo.get(3), "" + nombreCliente ));
            hashData.put((String)dataInfo.get(4).get("field"), getRealData(dataInfo.get(4), "" + hora.format(dto.getFechaApertura())));
            hashData.put((String)dataInfo.get(5).get("field"), getRealData(dataInfo.get(5), "" + hora.format(dto.getFechaCierre()) ));            
            hashData.put((String)dataInfo.get(6).get("field"), getRealData(dataInfo.get(6), "" + resultFecha));
            hashData.put((String)dataInfo.get(7).get("field"), getRealData(dataInfo.get(7), "" + piezaDegustada));

            dataList.add(hashData);

            hashData = new HashMap<String, String>();
        }

        return dataList;
    }
       private ArrayList<HashMap> getDataList(Estanteria[] objectDto) {
        ArrayList<HashMap> dataList = new ArrayList<HashMap>();
        HashMap<String,String> hashData = new HashMap<String, String>();
        ArrayList<HashMap> dataInfo = getFieldList(CADUCIDAD_REPORT);        
    
        for(Estanteria dto:objectDto){
             
            String nombreUsuario = "";
            if (dto.getIdUsuario()> 0){
                DatosUsuario datosUsuarioPromotor = new UsuarioBO(dto.getIdUsuario()).getDatosUsuario();
                nombreUsuario = datosUsuarioPromotor!=null? (datosUsuarioPromotor.getNombre() +" " + datosUsuarioPromotor.getApellidoPat()) :"Sin promotor asignado";
            }
            String nombreProducto = "";
            try{
                  ConceptoBO conceptoBO = new ConceptoBO(this.getConn());
                  Concepto concepto = conceptoBO.findConceptobyId(dto.getIdConcepto());
                  nombreProducto = concepto.getNombre();
            }catch(Exception e){}
            
            
            hashData.put((String)dataInfo.get(0).get("field"), getRealData(dataInfo.get(0), "" + DateManage.formatDateToNormal(dto.getFecha()))); ;
            hashData.put((String)dataInfo.get(1).get("field"), getRealData(dataInfo.get(1), "" + nombreUsuario));
            hashData.put((String)dataInfo.get(2).get("field"), getRealData(dataInfo.get(2), "" + nombreProducto));
            hashData.put((String)dataInfo.get(3).get("field"), getRealData(dataInfo.get(3), "" + DateManage.formatDateToNormal(dto.getFechaCaducidad()) ));
            dataList.add(hashData);

            hashData = new HashMap<String, String>();
        }

        return dataList;
    }
    private ArrayList<HashMap> getDataListGeneral(Estanteria[] objectDto) {
        ArrayList<HashMap> dataList = new ArrayList<HashMap>();
        HashMap<String,String> hashData = new HashMap<String, String>();
        ArrayList<HashMap> dataInfo = getFieldList(GENERAL_REPORT);        
    
        for(Estanteria dto:objectDto){
             
            String nombreUsuario = "";
            if (dto.getIdUsuario()> 0){
                DatosUsuario datosUsuarioPromotor = new UsuarioBO(dto.getIdUsuario()).getDatosUsuario();
                nombreUsuario = datosUsuarioPromotor!=null? (datosUsuarioPromotor.getNombre() +" " + datosUsuarioPromotor.getApellidoPat()) :"Sin promotor asignado";
            }
            String nombreProducto = "";
            String claveProducto = "";
            try{
                  ConceptoBO conceptoBO = new ConceptoBO(this.getConn());
                  Concepto concepto = conceptoBO.findConceptobyId(dto.getIdConcepto());
                  nombreProducto = concepto.getNombre();
                  claveProducto = concepto.getClave();
            }catch(Exception e){}
            String nombreCliente = "";
            if (dto.getIdCliente()> 0){
                Cliente cliente = new ClienteBO(dto.getIdCliente(),this.getConn()).getCliente();
                nombreCliente = cliente!=null? (cliente.getNombreComercial()) :"Sin cliente";
            }
            String nombreSucursal = "";
            if(dto.getIdEmpresa() >0){
                try {
                    Empresa empresa = new EmpresaBO(this.getConn()).getEmpresaGenericoByEmpresa(dto.getIdEmpresa());
                    nombreSucursal = empresa!=null? (empresa.getNombreComercial()) :"Sin sucursal";
                } catch (Exception ex) {
                    Logger.getLogger(ReportBO.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
            double unidadesTotal = 0;
            double unidadesAnaquel = 0;
            double unidadesAlmacen = 0;
            unidadesAnaquel = dto.getCantidad();
            unidadesAlmacen = dto.getUnidadesAlmacen();
            unidadesTotal = unidadesAnaquel + unidadesAlmacen;
            
            
            hashData.put((String)dataInfo.get(0).get("field"), getRealData(dataInfo.get(0), "" + DateManage.formatDateToNormal(dto.getFecha()))); ;
            hashData.put((String)dataInfo.get(1).get("field"), getRealData(dataInfo.get(1), "" + nombreUsuario));
            hashData.put((String)dataInfo.get(2).get("field"), getRealData(dataInfo.get(2), "" + nombreCliente));
            hashData.put((String)dataInfo.get(3).get("field"), getRealData(dataInfo.get(3), "" + nombreSucursal ));
            hashData.put((String)dataInfo.get(4).get("field"), getRealData(dataInfo.get(4), "" + claveProducto ));
            hashData.put((String)dataInfo.get(5).get("field"), getRealData(dataInfo.get(5), "" + nombreProducto ));
            hashData.put((String)dataInfo.get(6).get("field"), getRealData(dataInfo.get(6), "" + dto.getCantidad() ));
            hashData.put((String)dataInfo.get(7).get("field"), getRealData(dataInfo.get(7), "" + dto.getPrecio() ));
            hashData.put((String)dataInfo.get(8).get("field"), getRealData(dataInfo.get(8), "" + dto.getPrecioOferta() ));
            hashData.put((String)dataInfo.get(9).get("field"), getRealData(dataInfo.get(9), "" + dto.getUnidadesAlmacen() ));
            hashData.put((String)dataInfo.get(10).get("field"), getRealData(dataInfo.get(10), "" + unidadesTotal ));
            dataList.add(hashData);

            hashData = new HashMap<String, String>();
        }

        return dataList;
    }
        private ArrayList<HashMap> getDataListCompetencia(Estanteria[] objectDto) {
        ArrayList<HashMap> dataList = new ArrayList<HashMap>();
        HashMap<String,String> hashData = new HashMap<String, String>();
        ArrayList<HashMap> dataInfo = getFieldList(COMPETENCIA_REPORT);        
    
        for(Estanteria dto:objectDto){
             
            
            String nombreProducto = "";
            try{
                  ConceptoBO conceptoBO = new ConceptoBO(this.getConn());
                  Concepto concepto = conceptoBO.findConceptobyId(dto.getIdConcepto());
                  nombreProducto = concepto.getNombre(); 
            }catch(Exception e){}
            String nombreCliente = "";
            if (dto.getIdCliente()> 0){
                Cliente cliente = new ClienteBO(dto.getIdCliente(),this.getConn()).getCliente();
                nombreCliente = cliente!=null? (cliente.getNombreComercial()) :"Sin cliente";
            }
            String nombreSucursal = "";
            if(dto.getIdEmpresa() >0){
                try {
                    Empresa empresa = new EmpresaBO(this.getConn()).getEmpresaGenericoByEmpresa(dto.getIdEmpresa());
                    nombreSucursal = empresa!=null? (empresa.getNombreComercial()) :"Sin sucursal";
                } catch (Exception ex) {
                    Logger.getLogger(ReportBO.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
            String competencias = "";
            EstanteriaDescripcion[] estanteriaDesc = new EstanteriaDescripcionBO(this.getConn()).findEstanteriaDescripcions(0, dto.getIdEstanteria(), 0, 0, 0, "");
            for(EstanteriaDescripcion estanteriaDescripcion : estanteriaDesc){
            Competencia competencia;
                try {
                    competencia = new CompetenciaBO(this.getConn()).findMarcabyId(estanteriaDescripcion.getIdCompetencia());
                    competencias += competencia.getNombre()+": "+estanteriaDescripcion.getPrecio()+",";  
                } catch (Exception ex) {
                    Logger.getLogger(ReportBO.class.getName()).log(Level.SEVERE, null, ex);
                }
                                                      
           }
            if(competencias.equals("")){
                competencias = "Sin competencias";
            }
        
            
            
            hashData.put((String)dataInfo.get(0).get("field"), getRealData(dataInfo.get(0), "" + DateManage.formatDateToNormal(dto.getFecha()))); ;
            hashData.put((String)dataInfo.get(1).get("field"), getRealData(dataInfo.get(1), "" + nombreCliente));
            hashData.put((String)dataInfo.get(2).get("field"), getRealData(dataInfo.get(2), "" + nombreSucursal));
            hashData.put((String)dataInfo.get(3).get("field"), getRealData(dataInfo.get(3), "" + nombreProducto ));
            hashData.put((String)dataInfo.get(4).get("field"), getRealData(dataInfo.get(4), "" + dto.getPrecio() ));
            hashData.put((String)dataInfo.get(5).get("field"), getRealData(dataInfo.get(5), "" + competencias ));
            
            dataList.add(hashData);

            hashData = new HashMap<String, String>();
        }

        return dataList;
    }
    
}
