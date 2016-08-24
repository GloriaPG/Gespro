/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package com.tsp.gespro.ws;

import com.google.gson.Gson;
import com.tsp.gespro.hibernate.dao.ActividadDAO;
import com.tsp.gespro.hibernate.dao.ProyectoDAO;
import com.tsp.gespro.hibernate.pojo.Actividad;
import com.tsp.gespro.hibernate.pojo.Proyecto;
import com.tsp.gespro.ws.bo.InsertaActualizaWsBO;
import com.tsp.gespro.ws.response.LoginUsuarioMovilResponse;
import com.tsp.gespro.ws.bo.*;
import com.tsp.gespro.ws.response.ConsultaClientesResponse;
import com.tsp.gespro.ws.response.CrearPedidoResponse;
import com.tsp.gespro.ws.response.ModificarPedidoResponse;
import com.tsp.gespro.ws.response.ConsultaCompetenciaResponse;
import com.tsp.gespro.ws.response.ConsultaConceptosResponse;
import com.tsp.gespro.ws.response.ConsultaEmbalajeResponse;
import com.tsp.gespro.ws.response.ConsultaEmpleadoResponse;
import com.tsp.gespro.ws.response.ConsultaMensajesMovilResponse;
import com.tsp.gespro.ws.response.ConsultaRutasResponse;
import com.tsp.gespro.ws.response.SendEstatusMensajesMovilResponse;
import com.tsp.gespro.ws.response.SendMensajesMovilResponse;
import com.tsp.gespro.ws.response.WSResponseInsert;
import com.tsp.gespro.ws.response.WsItemConceptoRegistroFotograficoResponse;
import com.tsp.gespro.ws.response.WsItemEstanteriaResponse;
import com.tsp.gespro.ws.response.WsItemDegustacionResponse;
import java.util.Arrays;
import java.util.Date;
import javax.jws.WebService;
import javax.jws.WebMethod;
import javax.jws.WebParam;

/**
 *
 * @author HpPyme
 */
@WebService(serviceName = "GesproWS")
public class GesproWS {

   /**
     * Método para verificar credenciales de acceso
     * para usuario desde dispositivo móvil (usuario)
     * @param UsuarioDtoRequestJson String con formato JSON representando un objeto de tipo UsuarioDtoRequest
     * @return String en formato JSON representando un objeto tipo LoginUsuarioMovilResponse
     */
    @WebMethod(operationName = "loginByUsuario", action="loginByUsuario")
    public String loginByUsuario(
            @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson ) {
        ConsultaWsBO consultaWsBO = new ConsultaWsBO();
        
        System.out.println("METODO: loginByUsuario \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson);
        
        //Efectuamos operación
        LoginUsuarioMovilResponse response = consultaWsBO.loginByUsuario(usuarioDtoRequestJson);
                
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    
    /**
     * Método para recibir el check in de ubicación
     * geográfica del usuario, usando latitud y longitud.
     * @param usuarioDtoRequestJson String con formato JSON representando un objeto de tipo EmpleadoDtoRequest
     * @return String con formato JSON representando un objeto de tipo WSResponse
     */
    @WebMethod(operationName = "registrarCheckInUsuario", action="registrarCheckInUsuario")
    public String registrarCheckInUsuario(
        @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson ,
        @WebParam(name = "checkInDtoRequestJson") String checkInDtoRequestJson ) {
        
        InsertaActualizaWsBO insertaWsBO = new InsertaActualizaWsBO();
        
        System.out.println("METODO: registrarCheckInUsuario \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson);
        System.out.println("REQUEST JSON: \n" + checkInDtoRequestJson);
        
        
        //Efectuamos operación
        WSResponse response = insertaWsBO.resgistrarCheckInUsuario(usuarioDtoRequestJson,checkInDtoRequestJson);
                
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    
    
    
    /**
     * Método para obtener el catalogo de Clientes de una Empresa
     * haciendo autenticación por empleado desde un dispositivo móvil
     * @param usuarioDtoRequestJson String con formato JSON representando un objeto de tipo ConsultaConceptosResponse
     * @return String con formato JSON representando un objeto de tipo ConsultaConceptosResponse
     */
    @WebMethod(operationName = "getCatalogoClientesByUsuario", action="getCatalogoClientesByUsuario")
    public String getCatalogoClientesByusuario(
            @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson ) {
        
        System.out.println("METODO: getCatalogoClientesByUsuario \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson);
        
        ConsultaWsBO consultaWsBO = new ConsultaWsBO();
        
        ConsultaClientesResponse response = consultaWsBO.getCatalogoClientesByUsuario(usuarioDtoRequestJson);
        
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    
    
    
    /**
     * Método para consultar el listado de Conceptos de una empresa
     * haciendo autenticación por empleado desde un dispositivo móvil
     * @param usuarioDtoRequestJson String con formato JSON representando un objeto de tipo UsuarioDtoRequest
     * @return String con formato JSON representando un objeto de tipo ConsultaConceptosResponse
     */
    @WebMethod(operationName = "getCatalogoConceptosByUsuario", action="getCatalogoConceptosByUsuario")
    public String getCatalogoConceptosByUsuario(
            @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson ) {        
        System.out.println("METODO: getCatalogoConceptosByUsuario \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson);
        
        ConsultaWsBO consultaWsBO = new ConsultaWsBO();
        
        ConsultaConceptosResponse response = consultaWsBO.getCatalogoConceptosByUsuario(usuarioDtoRequestJson);
                
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    
    /**
     * Método para recibir la degustacion.
     * @param usuarioDtoRequestJson String con formato JSON representando un objeto de tipo EmpleadoDtoRequest
     * @return String con formato JSON representando un objeto de tipo WSResponse
     */
    @WebMethod(operationName = "registrarDegustacion", action="registrarDegustacion")
    public String registrarDegustacion(
        @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson ,
        @WebParam(name = "degustacionDtoRequestJson") String degustacionDtoRequestJson ) {
        
        InsertaActualizaWsBO insertaWsBO = new InsertaActualizaWsBO();
        
        System.out.println("METODO: registrarCheckInUsuario \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson);
        
        //Efectuamos operación
        WsItemDegustacionResponse response = insertaWsBO.registrarDegustacion(usuarioDtoRequestJson,degustacionDtoRequestJson);
                
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    
    /**
     * Método para recibir el registro fotografico de los conceptos
     * @param usuarioDtoRequestJson String con formato JSON representando un objeto de tipo EmpleadoDtoRequest
     * @return String con formato JSON representando un objeto de tipo WSResponse
     */
    @WebMethod(operationName = "registrarConceptoRegistroFotografico", action="registrarConceptoRegistroFotografico")
    public String registrarConceptoRegistroFotografico(
        @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson ,
        @WebParam(name = "conceptoRegistroFotograficoDtoRequestJson") String conceptoRegistroFotograficoDtoRequestJson ) {
        
        InsertaActualizaWsBO insertaWsBO = new InsertaActualizaWsBO();
        
        System.out.println("METODO: registrarConceptoRegistroFotografico \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson);
        
        //Efectuamos operación
        WsItemConceptoRegistroFotograficoResponse response = insertaWsBO.registrarConceptoRegistroFotografico(usuarioDtoRequestJson,conceptoRegistroFotograficoDtoRequestJson);
                
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    
    /**
     * Método para recibir el la estanteria de un cliente.
     * @param usuarioDtoRequestJson String con formato JSON representando un objeto de tipo EmpleadoDtoRequest
     * @return String con formato JSON representando un objeto de tipo WSResponse
     */
    @WebMethod(operationName = "registrarEstanteria", action="registrarEstanteria")
    public String registrarEstanteria(
        @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson ,
        @WebParam(name = "estanteriaDtoRequestJson") String estanteriaDtoRequestJson ) {
        
        InsertaActualizaWsBO insertaWsBO = new InsertaActualizaWsBO();
        
        System.out.println("METODO: registrarEstanteria \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson);
        
        //Efectuamos operación
        WsItemEstanteriaResponse response = insertaWsBO.resgistrarEstanteria(usuarioDtoRequestJson,estanteriaDtoRequestJson);
                
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    
    /**
     * Método para obtener los embalajes
     * haciendo autenticación por empleado desde un dispositivo móvil
     * @param usuarioDtoRequestJson String con formato JSON representando un objeto de tipo ConsultaEmbalajeResponse
     * @return String con formato JSON representando un objeto de tipo ConsultaEmbalajeResponse
     */
    @WebMethod(operationName = "getCatalogoEmbalajeByUsuario", action="getCatalogoEmbalajeByUsuario")
    public String getCatalogoEmbalajeByUsuario(
            @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson ) {
        
        System.out.println("METODO: getCatalogoEmbalajeByUsuario \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson);
        
        ConsultaWsBO consultaWsBO = new ConsultaWsBO();
        
        ConsultaEmbalajeResponse response = consultaWsBO.getCatalogoEmbalajeByUsuario(usuarioDtoRequestJson);
        
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    
    /**
     * Método para obtener el catalogo de la competencia
     * haciendo autenticación por empleado desde un dispositivo móvil
     * @param usuarioDtoRequestJson String con formato JSON representando un objeto de tipo ConsultaCompetenciaResponse
     * @return String con formato JSON representando un objeto de tipo ConsultaCompetenciaResponse
     */
    @WebMethod(operationName = "getCatalogoCompetenciaByUsuario", action="getCatalogoCompetenciaByUsuario")
    public String getCatalogoCompetenciaByUsuario(
            @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson ) {
        
        System.out.println("METODO: getCatalogoCompetenciaByUsuario \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson);
        
        ConsultaWsBO consultaWsBO = new ConsultaWsBO();
        
        ConsultaCompetenciaResponse response = consultaWsBO.getCatalogoCompetenciaByUsuario(usuarioDtoRequestJson);
        
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    
    /**
     * Método para obtener los empleados
     * haciendo autenticación por empleado desde un dispositivo móvil
     * @param usuarioDtoRequestJson String con formato JSON representando un objeto de tipo ConsultaEmpleadoResponse
     * @return String con formato JSON representando un objeto de tipo ConsultaEmpleadoResponse
     */
    @WebMethod(operationName = "getCatalogoEmpleadoByUsuario", action="getCatalogoEmpleadoByUsuario")
    public String getCatalogoEmpleadoByUsuario(
            @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson ) {
        
        System.out.println("METODO: getCatalogoEmpleadoByUsuario \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson);
        
        ConsultaWsBO consultaWsBO = new ConsultaWsBO();
        
        ConsultaEmpleadoResponse response = consultaWsBO.getCatalogoEmpleadoByUsuario(usuarioDtoRequestJson);
        
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    
    /**
     * Consulta los mensajes recibidos para cierto empleado
     * asociado a un dispositivo móvil.
     * @param usuarioDtoRequestJson String con formato JSON representando un objeto de tipo EmpleadoDtoRequest
     * @param getMensajesMovilRequestJson String con formato JSON representando un objeto de tipo MensajesMovilRequest
     * @return String con formato JSON representando un objeto de tipo ConsultaMensajesMovilResponse
     */
    @WebMethod(operationName = "mensajesConsultaRecibidos", action="mensajesConsultaRecibidos")
    public String mensajesConsultaRecibidos(
            @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson,
            @WebParam(name = "getMensajesMovilRequestJson") String getMensajesMovilRequestJson){
        ConsultaWsBO consultaWsBO = new ConsultaWsBO();
        
        System.out.println("METODO: mensajesConsultaRecibidos \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson + "\n" + getMensajesMovilRequestJson);
        
        //Efectuamos operación
        ConsultaMensajesMovilResponse response = consultaWsBO.getMensajesMovilRecibidos(usuarioDtoRequestJson,getMensajesMovilRequestJson);
                
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    
    /**
     * Consulta los mensajes enviados desde cierto empleado
     * asociado a un dispositivo móvil.
     * @param usuarioDtoRequestJson String con formato JSON representando un objeto de tipo EmpleadoDtoRequest
     * @param getMensajesMovilRequestJson String con formato JSON representando un objeto de tipo MensajesMovilRequest
     * @return String con formato JSON representando un objeto de tipo ConsultaMensajesMovilResponse
     */
    @WebMethod(operationName = "mensajesConsultaEnviados", action="mensajesConsultaEnviados")
    public String mensajesConsultaEnviados(
            @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson,
            @WebParam(name = "getMensajesMovilRequestJson") String getMensajesMovilRequestJson){
        ConsultaWsBO consultaWsBO = new ConsultaWsBO();
                
        System.out.println("METODO: mensajesConsultaEnviados \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson + "\n" + getMensajesMovilRequestJson);
        
        //Efectuamos operación
        ConsultaMensajesMovilResponse response = consultaWsBO.getMensajesMovilEnviados(usuarioDtoRequestJson,getMensajesMovilRequestJson);
                
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    
    /**
     * Crea un nuevo mensaje de comunicación interna,
     * usando los datos de un empleado emisor y receptor específicos.
     * <p/>
     * Puede ser tambien enviado hacia la consola central.
     * @param usuarioDtoRequestJson String con formato JSON representando un objeto de tipo EmpleadoDtoRequest
     * @param sendMensajesMovilRequestJson String con formato JSON representando un objeto de tipo SendMensajesMovilRequest
     * @return String con formato JSON representando un objeto de tipo SendMensajesMovilResponse
     */
    @WebMethod(operationName = "mensajesEnviarNuevo", action="mensajesEnviarNuevo")
    public String mensajesEnviarNuevo(
        @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson,
        @WebParam(name = "sendMensajesMovilRequestJson") String sendMensajesMovilRequestJson
            ) {
        
        InsertaActualizaWsBO insertaActualizaWsBO = new InsertaActualizaWsBO();
        
        System.out.println("METODO: mensajesEnviarNuevo \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson + "\n" +sendMensajesMovilRequestJson);
        
        //Efectuamos operación
        SendMensajesMovilResponse response = insertaActualizaWsBO.insertaMensajeMovilByUsuario(usuarioDtoRequestJson,sendMensajesMovilRequestJson);
                
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    
    /**
     * Crea un nuevo estatus proveniente de un empleado-dispositivo móvil
     * para informar sobre las acciones que lleva a cabo en el momento de notificación.
     * @param usuarioDtoRequestJson String con formato JSON representando un objeto de tipo EmpleadoDtoRequest
     * @param sendEstatusMensajesMovilRequestJson String con formato JSON representando un objeto de tipo SendEstatusMensajesMovilRequest
     * @return String con formato JSON representando un objeto de tipo SendEstatusMensajesMovilResponse
     */
    @WebMethod(operationName = "mensajesEstatusEnviarNuevo", action="mensajesEstatusEnviarNuevo")
    public String mensajesEstatusEnviarNuevo(
        @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson,
        @WebParam(name = "sendEstatusMensajesMovilRequestJson") String sendEstatusMensajesMovilRequestJson
            ) {
        
        InsertaActualizaWsBO insertaActualizaWsBO = new InsertaActualizaWsBO();
        
        System.out.println("METODO: mensajesEstatusEnviarNuevo \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson + "\n" +sendEstatusMensajesMovilRequestJson);
        
        //Efectuamos operación
        SendEstatusMensajesMovilResponse response = insertaActualizaWsBO.insertaEstatusMensajeMovilByUsuario(usuarioDtoRequestJson,sendEstatusMensajesMovilRequestJson);
                
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    
    @WebMethod(operationName = "insertaActualizaProspecto", action="insertaActualizaProspecto")
    public String insertaActualizaProspecto(
            @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson,
            @WebParam(name = "prospectoDtoRequestJson") String prospectoDtoRequestJson
            ) {
        InsertaActualizaWsBO insertaActualizaWsBO = new InsertaActualizaWsBO();
        
        Gson gson = new Gson();
        
        System.out.println("METODO: insertaActualizaProspecto \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson);
        System.out.println("\t" + prospectoDtoRequestJson);
        
        //Efectuamos operación
        WSResponseInsert wSResponseInsert = insertaActualizaWsBO.insertaActualizaProspecto(usuarioDtoRequestJson,prospectoDtoRequestJson);
                
        //Transformamos de objeto a formato JSON
        String jsonResponse = gson.toJson(wSResponseInsert);
        
        return jsonResponse;
        
    }
    
    // Proyectos
    @WebMethod(operationName = "insertaActualizaProyecto", action="insertaActualizaProyecto")
    public String insertaActualizaProyecto(
            @WebParam(name = "proyectoJson") String proyectoJson
            ) {
        
        Gson gson = new Gson();
        System.out.println(new Date());
        
        System.out.println("METODO: insertaActualizaProyecto \n");
        System.out.println("REQUEST JSON: \n" + proyectoJson);
        
        Proyecto proyecto= gson.fromJson(proyectoJson, Proyecto.class);

        ProyectoDAO proyectoDAO= new ProyectoDAO();
        
        if(proyecto.getIdProyecto()!= 0 && proyecto.getIdProyecto()!= null){
           Proyecto proyectoUpdate= proyectoDAO.getById(proyecto.getIdProyecto());
           if(proyectoUpdate!= null){
               proyectoDAO.actualizar(proyecto);
               String jsonResponse = gson.toJson(proyecto);
               return jsonResponse;
           }else{
               return "{status:404,error: Proyecto no encontrado}";
           }
        }else{
            int proyectoId=proyectoDAO.guardar(proyecto);
            return "{IdProyecto:"+proyectoId+"}";
        }
    }
    // Actividades
    @WebMethod(operationName = "insertaActualizaActividad", action="insertaActualizaActividad")
    public String insertaActualizaActividad(
            @WebParam(name = "actividadJson") String actividadJson
            ) {
        
        Gson gson = new Gson();
        System.out.println(new Date());
        
        System.out.println("METODO: insertaActualizaProyecto \n");
        System.out.println("REQUEST JSON: \n" + actividadJson);
        
        Actividad actividad= gson.fromJson(actividadJson, Actividad.class);

        ActividadDAO actividadDAO= new ActividadDAO();
        
        if(actividad.getIdActividad()!= 0 && actividad.getIdActividad()!= null){
           Actividad actividadUpdate= actividadDAO.getById(actividad.getIdActividad());
           if(actividadUpdate!= null){
               actividadDAO.actualizar(actividad);
               String jsonResponse = gson.toJson(actividad);
               return jsonResponse;
           }else{
               return "{status:404,error: Actividad no encontrada}";
           }
        }else{
            int actividadId=actividadDAO.guardar(actividad);
            return "{idActividad:"+actividadId+"}";
        }
    }
    //METODOS PARA PEDIDOS
    //-------------------------------------------------------------------------------
    
    @WebMethod(operationName = "creaPedidoByEmpleado", action="creaPedidoByEmpleado")
    public String creaPedidoByEmpleado(
            @WebParam(name = "empleadoDtoRequestJson") String empleadoDtoRequestJson,
            @WebParam(name = "crearPedidoRequestJson") String crearPedidoRequestJson
            ) {
        
        System.out.println("METODO: creaPedidoByEmpleado \n");
        System.out.println("REQUEST JSON: \n" + empleadoDtoRequestJson);
        System.out.println("\t" + crearPedidoRequestJson);
        
        PedidoWsBO pedidoWsBO = new PedidoWsBO();
        
        CrearPedidoResponse response = pedidoWsBO.crearPedidoByEmpleado(empleadoDtoRequestJson, crearPedidoRequestJson);
        
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    
    @WebMethod(operationName = "modificaPedido", action="modificaPedido")
    public String modificaPedido(
            @WebParam(name = "empleadoDtoRequestJson") String empleadoDtoRequestJson,
            @WebParam(name = "modificarPedidoRequestJson") String modificarPedidoRequestJson
            ) {
        
        System.out.println("METODO: modificaPedido \n");
        System.out.println("REQUEST JSON: \n" + empleadoDtoRequestJson);
        System.out.println("\t" + modificarPedidoRequestJson);
        
        PedidoWsBO pedidoWsBO = new PedidoWsBO();
        
        ModificarPedidoResponse response = pedidoWsBO.modificaPedido(empleadoDtoRequestJson, modificarPedidoRequestJson);
        
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    
    @WebMethod(operationName = "cancelarPedido", action="cancelarPedido")
    public String cancelarPedido(
            @WebParam(name = "empleadoDtoRequestJson") String empleadoDtoRequestJson,
            @WebParam(name = "cancelarPedidoRequestJson") String cancelarPedidoRequestJson
            ) {
        
        System.out.println("METODO: cancelarPedido \n");
        System.out.println("REQUEST JSON: \n" + empleadoDtoRequestJson);
        System.out.println("\t" + cancelarPedidoRequestJson);
        
        PedidoWsBO pedidoWsBO = new PedidoWsBO();
        
        com.tsp.gespro.ws.response.WSResponse response = pedidoWsBO.cancelarPedido(empleadoDtoRequestJson, cancelarPedidoRequestJson);
        
        //Transformamos de objeto a formato JSON
        Gson gson = new Gson();
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
    }
    //FIN METODOS PARA PEDIDOS
    //-------------------------------------------------------------------------------
    
    
    @WebMethod(operationName = "getRutasByUsuario", action="getRutasByUsuario")
    public String getRutasByUsuario(
            @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson) {
        ConsultaWsBO consultaWsBO = new ConsultaWsBO();
        
        Gson gson = new Gson();
        
        System.out.println("METODO: getRutasByUsuario \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson);
        
        //Efectuamos operación
        ConsultaRutasResponse response = consultaWsBO.getRutasByUsuario(usuarioDtoRequestJson);
                
        //Transformamos de objeto a formato JSON
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
        
    }
    
    /*
    @WebMethod(operationName = "registrarRutaMarcadoresVisitados", action="registrarRutaMarcadoresVisitados")
    public String registrarRutaMarcadoresVisitados(
            @WebParam(name = "usuarioDtoRequestJson") String usuarioDtoRequestJson,
            @WebParam(name = "rutaMarcadoresIDs") int[] rutaMarcadoresIDs) {
        InsertaActualizaWsBO insertaWsBO = new InsertaActualizaWsBO();
        
        Gson gson = new Gson();
        
        System.out.println("METODO: registrarRutaMarcadoresVisitados \n");
        System.out.println("REQUEST JSON: \n" + usuarioDtoRequestJson);
        try{
            System.out.println("IDs Marcadores visitados: \n" + Arrays.toString(rutaMarcadoresIDs));
        }catch(Exception ex){}
        
        //Efectuamos operación
        WSResponse response = insertaWsBO.registrarRutaMarcadoresVisitados(usuarioDtoRequestJson,rutaMarcadoresIDs);
                
        //Transformamos de objeto a formato JSON
        String jsonResponse = gson.toJson(response);
        
        return jsonResponse;
        
    }
    */
    
}
