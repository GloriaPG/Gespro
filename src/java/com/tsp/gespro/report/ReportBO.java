/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.tsp.gespro.report;


import com.tsp.gespro.Services.Allservices;
import com.tsp.gespro.bo.*;
import com.tsp.gespro.dto.*;

import com.tsp.gespro.exceptions.DatosUsuarioDaoException;
import com.tsp.gespro.exceptions.EmpresaDaoException;
import com.tsp.gespro.exceptions.SgfensPedidoDaoException;
import com.tsp.gespro.exceptions.UsuariosDaoException;
import com.tsp.gespro.hibernate.dao.ClienteDAO;
import com.tsp.gespro.Services.Allservices;
import com.tsp.gespro.hibernate.dao.PromotorproyectoDAO;
import com.tsp.gespro.hibernate.pojo.Producto;
import com.tsp.gespro.hibernate.pojo.Promotorproyecto;
import com.tsp.gespro.hibernate.pojo.Proyecto;
import com.tsp.gespro.jdbc.DatosUsuarioDaoImpl;
import com.tsp.gespro.jdbc.EmpresaDaoImpl;
import com.tsp.gespro.jdbc.SgfensPedidoDaoImpl;
import com.tsp.gespro.jdbc.SgfensPedidoProductoDaoImpl;
import com.tsp.gespro.jdbc.UsuariosDaoImpl;
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
    public static final int PROYECTO_REPORT = 6;



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
                title = "Reporte de Prospectos";
                break;
            case PROYECTO_REPORT:
                title = "Reporte de Proyectos";
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
                fieldList.add(getDataInfo("CALLE","Calle","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("COLONIA","Colonia","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("MUNICIPIO","Municipio","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("ESTADO","Estado","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("LONGITUD","Longitud","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("LATITUD","Latitud","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("PROMOTOR","Promotor","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("PROYECTOS","Proyectos","","",""+DATA_STRING,""));
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
                fieldList.add(getDataInfo("PROMOTOR","Promotor","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("COMENTARIOS","Comentarios","","",""+DATA_STRING,""));
                break;
            case PROYECTO_REPORT:
                fieldList.add(getDataInfo("ID_PROYECTO","ID","","",""+DATA_INT,""));
                fieldList.add(getDataInfo("NOMBRE","Nombre","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("FECHA_INICIO","Fecha inicio","","",""+DATA_DATE,""));
                fieldList.add(getDataInfo("FECHA_PROGRAMADA","Fecha programada","","",""+DATA_DATE,""));
                fieldList.add(getDataInfo("FECHA_REAL","Fecha real","","",""+DATA_DATE,""));
                fieldList.add(getDataInfo("CLIENTE","Cliente","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("AVANCE","Avance","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("PROMOTOR","Promotor","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("ESTATUS","Estatus","","",""+DATA_STRING,""));
                fieldList.add(getDataInfo("PRODUCTOS","Productos","","",""+DATA_STRING,""));
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
             case PROYECTO_REPORT:
                String filtroBusqueda = "";
                if(params == null) {
                    params = "";
                }
                String filtroBusquedaEncoded = java.net.URLEncoder.encode(params, "UTF-8");
                Allservices allservices = new Allservices();
                List<Proyecto> proyectos = allservices.queryProyectoDAO(params);
                dataList = this.getDataList(proyectos);
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
        RelacionClienteVendedor relacionCliente = null;
        Allservices servicesObject = new Allservices();
        Usuarios usuario = null;

        String fechaReg ="";

        for(Cliente dto:objectDto){

            // Objects for get Pormotor
            try{ relacionCliente = new RelacionClienteVendedorBO( this.conn ).findRelacionClienteVendedors( dto.getIdCliente(), 0, 0, 0, "" )[0]; }catch(Exception e){};
            try{ usuario = new UsuariosBO( relacionCliente.getIdUsuario(), this.conn ).getUsuario(); }catch(Exception e){}

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
            hashData.put((String)dataInfo.get(6).get("field"), getRealData(dataInfo.get(6), "" + dto.getCalle() ));
            hashData.put((String)dataInfo.get(7).get("field"), getRealData(dataInfo.get(7), "" + dto.getColonia() ));
            hashData.put((String)dataInfo.get(8).get("field"), getRealData(dataInfo.get(8), "" + dto.getMunicipio() ));
            hashData.put((String)dataInfo.get(9).get("field"), getRealData(dataInfo.get(9), "" + dto.getEstado() ));
            hashData.put((String)dataInfo.get(10).get("field"), getRealData(dataInfo.get(10), "" + dto.getLongitud() ));
            hashData.put((String)dataInfo.get(11).get("field"), getRealData(dataInfo.get(11), "" + dto.getLatitud() ));

            // Get the promotor name
            String promotorName = "";
            if ( usuario!=null ){
                DatosUsuario datosUsuarioVendedor = new DatosUsuarioBO( usuario.getIdDatosUsuario(), this.conn ).getDatosUsuario();
                if (datosUsuarioVendedor!=null){
                    promotorName = StringManage.getValidString( datosUsuarioVendedor.getNombre() ) + " " + StringManage.getValidString( datosUsuarioVendedor.getApellidoPat() );
                }else{
                    promotorName = "¡ No Existe !";
                }
            }else{
                promotorName = "-Sin Asignar-";
            }
            hashData.put( ( String ) dataInfo.get(12).get("field"), getRealData(dataInfo.get(11), "" + promotorName ) );

            // Get the projects
            List<Proyecto> list_projects = servicesObject.queryProyectoDAO( "P where P.idCliente = " + dto.getIdCliente() );
            String projectsName = "- Sin Proyectos -";
            if( !list_projects.isEmpty() ) {
                projectsName = "";
                for ( Proyecto project: list_projects ) {
                    projectsName += " " + project.getNombre();
                }
            }
            hashData.put( ( String ) dataInfo.get(13).get("field"), getRealData(dataInfo.get(11), "" + projectsName ) );


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
    private ArrayList<HashMap> getDataList(RegistroCheckin[] objectDto) throws UsuariosDaoException {
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

            //Obtiene el nombre del promotor
            String nombrePromotor = "";
            if (dto.getIdUsuario() > 0){
                Usuarios promotorDto = null;
                DatosUsuario datosUsuarioPromotorDto = null;
                promotorDto = new UsuariosDaoImpl(this.conn).findByPrimaryKey(dto.getIdUsuario());
                datosUsuarioPromotorDto = new DatosUsuarioBO(promotorDto.getIdDatosUsuario(),this.conn).getDatosUsuario();

                nombrePromotor = datosUsuarioPromotorDto!=null?datosUsuarioPromotorDto.getNombreCompleto():"NA";
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
            hashData.put((String)dataInfo.get(6).get("field"), getRealData(dataInfo.get(6), "" + nombrePromotor));
            hashData.put((String)dataInfo.get(7).get("field"), getRealData(dataInfo.get(7), "" + dto.getComentarios()));

            dataList.add(hashData);

            hashData = new HashMap<String, String>();
        }

        return dataList;
    }

    /**
     *  PROYECTO_REPORT
     * @param proyectos Arreglo de objetos tipo Proyecto para fabricar reporte.
     * @return ArrayList<HashMap> con todos los datos para el reporte.
     */
    private ArrayList<HashMap> getDataList(List<Proyecto> proyectos) {
        ArrayList<HashMap> dataList = new ArrayList<HashMap>();
        HashMap<String,String> hashData = new HashMap<String, String>();
        ArrayList<HashMap> dataInfo = getFieldList(PROYECTO_REPORT);

        for(Proyecto proyecto:proyectos){
            // Obtenemos la informacion del cliente del proyecto
            ClienteDAO clienteDAO = new ClienteDAO();
            com.tsp.gespro.hibernate.pojo.Cliente cliente = clienteDAO.getById(proyecto.getIdCliente());

            // Obtenemos la informacion de los promotor del proyecto
            Allservices allservices = new Allservices();
            List<Promotorproyecto> promotoresProyecto = allservices.queryPromotorProyectoDAO("WHERE id_proyecto = " + proyecto.getIdProyecto());
            String promotores = "";
            for (Promotorproyecto promotorProyecto: promotoresProyecto) {
                com.tsp.gespro.hibernate.pojo.Cliente clientePromotor = clienteDAO.getById(promotorProyecto.getIdUser());
                promotores += clientePromotor.getNombreComercial() + "- ";
            }
            if (!promotores.trim().equals("")) {
                promotores = promotores.substring(0, promotores.length()-2);
            }

            // Obtenemos la informacion de los productos del proyecto
            List<Producto> productosList = allservices.QueryProductosDAO("WHERE id_proyecto = " + proyecto.getIdProyecto());
            String productos = "";
            for (Producto producto: productosList) {
                productos += producto.getNombre() + "- ";
            }
            if (!productos.trim().equals("")) {
                productos = productos.substring(0, productos.length()-2);
            }

            //Agregamos la informacion al reporte por cada proyecto
            hashData.put((String)dataInfo.get(0).get("field"), getRealData(dataInfo.get(0), "" + proyecto.getIdProyecto())); ;
            hashData.put((String)dataInfo.get(1).get("field"), getRealData(dataInfo.get(1), "" + proyecto.getNombre()));
            hashData.put((String)dataInfo.get(2).get("field"), getRealData(dataInfo.get(2), "" + proyecto.getFechaInicio()));
            hashData.put((String)dataInfo.get(3).get("field"), getRealData(dataInfo.get(3), "" + proyecto.getFechaProgramada()));
            hashData.put((String)dataInfo.get(4).get("field"), getRealData(dataInfo.get(4), "" + proyecto.getFechaReal()));
            hashData.put((String)dataInfo.get(5).get("field"), getRealData(dataInfo.get(5), "" + cliente.getNombreComercial()));
            hashData.put((String)dataInfo.get(6).get("field"), getRealData(dataInfo.get(6), "" + proyecto.getAvance()));
            hashData.put((String)dataInfo.get(7).get("field"), getRealData(dataInfo.get(7), "" + promotores));
            hashData.put((String)dataInfo.get(8).get("field"), getRealData(dataInfo.get(8), "" + (proyecto.getStatus() == 1 ? "Activo" : "Inactivo")));
            hashData.put((String)dataInfo.get(9).get("field"), getRealData(dataInfo.get(9), "" + productos));

            dataList.add(hashData);

            hashData = new HashMap<String, String>();
        }

        return dataList;
    }

}
