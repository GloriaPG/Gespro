/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package com.tsp.gespro.ws.bo;

import com.google.gson.Gson;
import com.itextpdf.text.pdf.codec.Base64;
import com.tsp.gespro.bo.EmpresaBO;
import com.tsp.gespro.bo.ProspectoBO;
import com.tsp.gespro.bo.UsuarioBO;
import com.tsp.gespro.bo.ZonaHorariaBO;
import com.tsp.gespro.config.Configuration;
import com.tsp.gespro.dto.ConceptoRegistroFotografico;
import com.tsp.gespro.dto.ConceptoRegistroFotograficoPk;
import com.tsp.gespro.dto.Degustacion;
import com.tsp.gespro.dto.DegustacionPk;
import com.tsp.gespro.dto.DetalleHorario;
import com.tsp.gespro.dto.DispositivoMovil;
import com.tsp.gespro.jdbc.DegustacionDaoImpl;
import com.tsp.gespro.dto.EmpleadoBitacoraPosicion;
import com.tsp.gespro.dto.Empresa;
import com.tsp.gespro.dto.Estanteria;
import com.tsp.gespro.dto.EstanteriaDescripcion;
import com.tsp.gespro.dto.EstanteriaDescripcionPk;
import com.tsp.gespro.dto.EstanteriaPk;
import com.tsp.gespro.dto.HorarioUsuario;
import com.tsp.gespro.dto.MovilMensaje;
import com.tsp.gespro.dto.MovilMensajePk;
import com.tsp.gespro.dto.PosMovilEstatus;
import com.tsp.gespro.dto.PosMovilEstatusParametros;
import com.tsp.gespro.dto.PosMovilEstatusPk;
import com.tsp.gespro.dto.Prospecto;
import com.tsp.gespro.dto.ProspectoPk;
import com.tsp.gespro.dto.RegistroCheckin;
import com.tsp.gespro.dto.RegistroCheckinPk;
import com.tsp.gespro.dto.RutaMarcador;
import com.tsp.gespro.dto.Usuarios;
import com.tsp.gespro.exceptions.EstanteriaDescripcionDaoException;
import com.tsp.gespro.jdbc.ConceptoRegistroFotograficoDaoImpl;
import com.tsp.gespro.jdbc.DetalleHorarioDaoImpl;
import com.tsp.gespro.jdbc.DispositivoMovilDaoImpl;
import com.tsp.gespro.jdbc.EmpleadoBitacoraPosicionDaoImpl;
import com.tsp.gespro.jdbc.EstanteriaDaoImpl;
import com.tsp.gespro.jdbc.EstanteriaDescripcionDaoImpl;
import com.tsp.gespro.jdbc.HorarioUsuarioDaoImpl;
import com.tsp.gespro.jdbc.MovilMensajeDaoImpl;
import com.tsp.gespro.jdbc.PosMovilEstatusDaoImpl;
import com.tsp.gespro.jdbc.PosMovilEstatusParametrosDaoImpl;
import com.tsp.gespro.jdbc.ProspectoDaoImpl;
import com.tsp.gespro.jdbc.RegistroCheckinDaoImpl;
import com.tsp.gespro.jdbc.ResourceManager;
import com.tsp.gespro.jdbc.RutaMarcadorDaoImpl;
import com.tsp.gespro.util.DateManage;
import com.tsp.gespro.util.FileManage;
import com.tsp.gespro.util.GenericValidator;
import com.tsp.gespro.ws.WSResponse;
import com.tsp.gespro.ws.request.CheckInDtoRequest;
import com.tsp.gespro.ws.request.ConceptoRegistroFotograficoDtoRequest;
import com.tsp.gespro.ws.request.DegustacionDtoRequest;
import com.tsp.gespro.ws.request.EstanteriaDescripcionDtoRequest;
import com.tsp.gespro.ws.request.EstanteriaDtoRequest;
import com.tsp.gespro.ws.request.ItemEstatusMensajeMovilRequest;
import com.tsp.gespro.ws.request.ItemMensajeMovilRequest;
import com.tsp.gespro.ws.request.ProspectoDtoRequest;
import com.tsp.gespro.ws.request.SendEstatusMensajesMovilRequest;
import com.tsp.gespro.ws.request.SendMensajesMovilRequest;
import com.tsp.gespro.ws.request.UsuarioDtoRequest;
import com.tsp.gespro.ws.response.InsertRegistroVisitaClienteResponse;
import com.tsp.gespro.ws.response.SendEstatusMensajesMovilResponse;
import com.tsp.gespro.ws.response.SendMensajesMovilResponse;
import com.tsp.gespro.ws.response.WSResponseInsert;
import com.tsp.gespro.ws.response.WsItemCheckInResponse;
import com.tsp.gespro.ws.response.WsItemConceptoRegistroFotograficoResponse;
import com.tsp.gespro.ws.response.WsItemDegustacionResponse;
import com.tsp.gespro.ws.response.WsItemEstanteriaResponse;
import com.tsp.gespro.ws.response.WsItemSendMensajeResponse;
import java.io.File;
import static java.lang.Math.abs;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Time;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 *
 * @author HpPyme
 */
public class InsertaActualizaWsBO {
    
    private final Gson gson = new Gson();
    private Connection conn = null;
    private final GenericValidator gc = new GenericValidator();

    public Connection getConn() {
        if (this.conn==null){
            try {
                this.conn = ResourceManager.getConnection();
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

    public InsertaActualizaWsBO() {
    }
    
    public InsertaActualizaWsBO(Connection conn) {
        this.conn = conn;
    }

    public WsItemCheckInResponse resgistrarCheckInUsuario(String usuarioDtoRequestJson, String checkInDtoRequestJson) {
        
        WsItemCheckInResponse response;
        
        UsuarioDtoRequest usuarioDtoRequest = null;
        CheckInDtoRequest checkInDtoRequest = null;
        
        try{
            
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJson, UsuarioDtoRequest.class);
            checkInDtoRequest = gson.fromJson(checkInDtoRequestJson, CheckInDtoRequest.class);
            
            //System.out.println("JSON:\n" + checkInDtoRequestJson);
            
            response = this.resgistrarCheckInUsuario(usuarioDtoRequest, checkInDtoRequest);
            
        }catch(Exception ex){
            response = new WsItemCheckInResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        return response;
        
        
    }

    private WsItemCheckInResponse resgistrarCheckInUsuario(UsuarioDtoRequest usuarioDtoRequest, CheckInDtoRequest checkInDtoRequest) {
        
        WsItemCheckInResponse response = new WsItemCheckInResponse();
        Configuration appConfig = new Configuration();
        
        int idEmpresa = 0 ;
        String rfcEmpresaMatriz ="";
        
        RegistroCheckin checkInDto = null;
        RegistroCheckinDaoImpl checkInDtoDaoImpl = new RegistroCheckinDaoImpl(getConn());
        try{
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            Empresa empresaDto;
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())){
                idEmpresa = usuarioBO.getUser().getIdEmpresa();
            }else{
                try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("El usuario y/o contraseña del Empleado son inválidos.");
                return response;
            }
                        
           
            if (usuarioBO==null){
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("No se pudo recuperar la información de Usuario del empleado para registrar el check in.");
                return response;
            }
            
            if(checkInDtoRequest.getIdRegistro()> 0){
                checkInDto = checkInDtoDaoImpl.findByPrimaryKey(checkInDtoRequest.getIdRegistro());
            }
            
            
            if(checkInDto!=null){//update 
                
                /*checkInDto.setIdEstatus(checkInDtoRequest.getIdEstatus());               
                checkInDtoDaoImpl.update(checkInDto.createPk(), checkInDto);*/
                
                //response.setIdObjetoCreado(checkInDto.getIdCheck());
                
            }else{//new
                checkInDto = new RegistroCheckin();
                
                checkInDto.setIdUsuario(usuarioBO.getUser().getIdUsuarios());
                checkInDto.setIdCliente(checkInDtoRequest.getIdCliente());
                checkInDto.setFechaHora(checkInDtoRequest.getFechaHora());
                checkInDto.setIdTipoCheck(checkInDtoRequest.getIdTipoCheck());
                checkInDto.setIdDetalleCheck(checkInDtoRequest.getIdDetalleCheck());
                checkInDto.setComentarios(checkInDtoRequest.getComentarios());
                checkInDto.setLatitud(checkInDtoRequest.getLatitud());
                checkInDto.setLongitud(checkInDtoRequest.getLongitud());
                checkInDto.setIdEstatus(checkInDtoRequest.getIdEstatus());
                
                //Valida check in de entrada
                try{
                    
                    if(checkInDtoRequest.getIdTipoCheck()==1 && checkInDtoRequest.getIdDetalleCheck()==6){
                    
                        if(usuarioBO.getUser().getIdHorarioAsignado()>0){
                            
                            
                            HorarioUsuario horarioUsuario = null;
                            horarioUsuario = new HorarioUsuarioDaoImpl().findByPrimaryKey(usuarioBO.getUser().getIdHorarioAsignado());


                            DateManage utilDate =  new DateManage();
                            String diaSemanaCheck ="";
                            try{
                                diaSemanaCheck = utilDate.getDiaSemana(checkInDtoRequest.getFechaHora());
                            }catch(Exception e){}

                            String filtroSem = "  DIA = '"+diaSemanaCheck+"' AND ID_HORARIO = " + usuarioBO.getUser().getIdHorarioAsignado() + " ";

                            DetalleHorario[] detalleHorario  = new DetalleHorario[0];                        
                            detalleHorario = new DetalleHorarioDaoImpl().findByDynamicWhere(filtroSem , null);

                            if(detalleHorario.length>0){//si no tiene horario es sin detalle
                                if(detalleHorario[0].getDiaDescanso()==0){
                                    
                                    
                                    SimpleDateFormat printFormat = new SimpleDateFormat("HH:mm:ss");       
                                    
                                    String dateCheck = printFormat.format(checkInDtoRequest.getFechaHora());
                                    String datehorario = printFormat.format(detalleHorario[0].getHoraEntrada());
                                    
                                    
                                    long nowHorario = printFormat.parse(datehorario).getTime();
                                    long horaCheck = printFormat.parse(dateCheck).getTime(); 

                                    long diff = nowHorario - horaCheck;
                                    long diffMinutes = diff / (60 * 1000);
                                    System.out.println("dif--------------> " + diffMinutes);
                                    long tiempoTolerancia = detalleHorario[0].getTolerancia();

                                    //validar diferencia respecto a entrada y tolreancia
                                    
                                    if(diffMinutes == 0){//Si llega en punto es sin detalle
                                        checkInDto.setIncidencia(0);
                                        response.setIncidencia(0);//retornamos detalle check
                                    }else if(diffMinutes < 0){//si llega mas de la hora validara la tolerancia
                                        
                                        if(abs(diffMinutes) <= tiempoTolerancia){//si diferencia menor o igual a tolerancia sin detalle
                                            checkInDto.setIncidencia(0);
                                            response.setIncidencia(0);//retornamos detalle check
                                        }else if(abs(diffMinutes) > tiempoTolerancia && abs(diffMinutes) <= 180){//Si supera su tolerancia se considera como retardo
                                            checkInDto.setIncidencia(1);
                                            response.setIncidencia(1);//retornamos detalle check
                                            
                                        }else if(abs(diffMinutes) > 180){// 3 horas despues de la entrada para considerarse falta
                                            checkInDto.setIncidencia(2);
                                            response.setIncidencia(2);//retornamos detalle check
                                        }
                                        
                                    }else if (diffMinutes > 0){// si llega antes de tiempo sera sin detalle
                                        checkInDto.setIncidencia(0);
                                        response.setIncidencia(0);//retornamos detalle check
                                    }                                    
                                        
                                     
                                }else{//si es su descanso es sin detalle
                                     checkInDto.setIncidencia(0);
                                     response.setIncidencia(0);//retornamos detalle check
                                }

                            }
                        }
                    }
                            
       
                }catch(Exception e){
                    System.out.println("Problema al validar Horario");
                    checkInDto.setIncidencia(0);
                }
                
                
                
                RegistroCheckinPk checkInDtoPk = checkInDtoDaoImpl.insert(checkInDto);
                
                response.setIdObjetoCreado(checkInDtoPk.getIdCheck());
            }
            
          
            //registramos ubicacion
            try{actualizarUbicacionUsuario(usuarioDtoRequest);}catch(Exception ex){}
            
            try{
                if(checkInDtoRequest.getIdDetalleCheck()==1){//Comida
                    usuarioBO.updateEstadoEmpleado(1); 
                }else if(checkInDtoRequest.getIdDetalleCheck()==2){//Descanso
                    usuarioBO.updateEstadoEmpleado(2); 
                }else if(checkInDtoRequest.getIdDetalleCheck()==3){//Permiso
                    usuarioBO.updateEstadoEmpleado(3); 
                }else if(checkInDtoRequest.getIdDetalleCheck()==4){//Fin jornada
                    usuarioBO.updateEstadoEmpleado(4); 
                }else if(checkInDtoRequest.getIdDetalleCheck()==5){//Otro
                    usuarioBO.updateEstadoEmpleado(5); 
                }else if(checkInDtoRequest.getIdDetalleCheck()==6){//Inicio Jornada
                    usuarioBO.updateEstadoEmpleado(6); 
                }
            }catch(Exception ex){}
            
            
        }catch(Exception ex){
            response.setError(true);
            response.setNumError(902);
            response.setMsgError("Error inesperado al crear o actualizar CheckIn. " + ex.getLocalizedMessage());
        }finally{
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }
        return response;
    }
    
    
    
    /**
     * Actualiza la ubicacion de un usuario segun los datos de longitud y latitud otorgados
     * @param usuarioDtoRequest EmpleadoDtoRequest Datos del empleado (móvil)
     * @return WSResponse Respuesta compuesta por objeto complejo con respuesta básica de exito
     */
    public WSResponse actualizarUbicacionUsuario(UsuarioDtoRequest usuarioDtoRequest) {
        WSResponse response = new WSResponse();
         
        try {
            //Consultamos y obtenemos el ID de Empresa del Usuario
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())) {
                usuarioBO.getUser().setLatitud(Double.parseDouble(usuarioDtoRequest.getUbicacionLatitud()));
                usuarioBO.getUser().setLongitud(Double.parseDouble(usuarioDtoRequest.getUbicacionLongitud()));
                usuarioBO.getUser().setUltimaUbicacion(usuarioDtoRequest.getFechaHora());
                
                if (usuarioBO.updateBD()){
                    
                    EmpleadoBitacoraPosicion bitacoraPosicionDto = new EmpleadoBitacoraPosicion();
                    EmpleadoBitacoraPosicionDaoImpl bitacoraPosicionDao = new EmpleadoBitacoraPosicionDaoImpl(getConn());
                    
                    bitacoraPosicionDto.setIdUsuario(usuarioBO.getUser().getIdUsuarios());
                    try{
                        bitacoraPosicionDto.setFecha(usuarioDtoRequest.getFechaHora()!=null?usuarioDtoRequest.getFechaHora() : (ZonaHorariaBO.DateZonaHorariaByIdEmpresa(getConn(), new Date(), (int)usuarioBO.getUser().getIdEmpresa()).getTime()) );
                    }catch(Exception e){
                        bitacoraPosicionDto.setFecha(usuarioDtoRequest.getFechaHora()!=null?usuarioDtoRequest.getFechaHora() : new Date() );
                    }
                    bitacoraPosicionDto.setLatitud(Double.parseDouble(usuarioDtoRequest.getUbicacionLatitud()));
                    bitacoraPosicionDto.setLongitud(Double.parseDouble(usuarioDtoRequest.getUbicacionLongitud()));
                    
                    try{
                        if (bitacoraPosicionDto.getLatitud()!=0
                                && bitacoraPosicionDto.getLongitud()!=0)
                            bitacoraPosicionDao.insert(bitacoraPosicionDto);                        
                    }catch(Exception ex){
                        response.setNumError(902);
                        response.setMsgError("No se pudo registrar la ubicación del usuario en la bitácora: " + ex.toString());
                        response.setError(true);
                        ex.printStackTrace();
                        return response;
                    }
                    
                    //Actualizamos porcentaje de bateria si fue enviado
                    if (usuarioDtoRequest.getPorcentajeBateria()>0){
                        try{
                            DispositivoMovilDaoImpl dmDao =  new DispositivoMovilDaoImpl(getConn());
                            DispositivoMovil dispositivoMovil = dmDao.findByPrimaryKey(usuarioBO.getUser().getIdDispositivo());
                            if (dispositivoMovil!=null){
                                dispositivoMovil.setPctPila(usuarioDtoRequest.getPorcentajeBateria());
                                dmDao.update(dispositivoMovil.createPk(), dispositivoMovil);
                            }
                        }catch(Exception ex){
                            response.setNumError(902);
                            response.setMsgError("No se pudo actualizar el porcentaje de bateria del dispositivo: " + ex.toString());
                            response.setError(true);
                            ex.printStackTrace();
                            return response;
                        }
                    }
                    
                    response.setError(false);
                }else{
                    response.setNumError(902);
                    response.setMsgError("No se pudo actualizar la ubicacion del usuario.");
                }
            } else {
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("El usuario y/o contraseña del Usuario son inválidos.");
            }
        } catch (Exception e) {
            response.setError(true);
            response.setNumError(902);
            response.setMsgError("Error al actualizar ubicacion del usuario. " + e.toString());
        }finally{
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }
         
        return response;
    }
    
    public WsItemDegustacionResponse registrarDegustacion(String usuarioDtoRequestJson, String degustacionDtoRequestJson) {
        
        WsItemDegustacionResponse response;
        
        UsuarioDtoRequest usuarioDtoRequest = null;
        DegustacionDtoRequest degustacionDtoRequest = null;
        
        try{
            
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJson, UsuarioDtoRequest.class);
            degustacionDtoRequest = gson.fromJson(degustacionDtoRequestJson, DegustacionDtoRequest.class);
            
            System.out.println("JSON:\n" + degustacionDtoRequest);
            
            response = this.resgistrarDegustacion(usuarioDtoRequest, degustacionDtoRequest);
            
        }catch(Exception ex){
            response = new WsItemDegustacionResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        return response;
        
        
    }
    
    private WsItemDegustacionResponse resgistrarDegustacion(UsuarioDtoRequest usuarioDtoRequest, DegustacionDtoRequest degustacionDtoRequest) {
        
        WsItemDegustacionResponse response = new WsItemDegustacionResponse();
        Configuration appConfig = new Configuration();
        
        int idEmpresa = 0 ;
        String rfcEmpresaMatriz ="";
        
        Degustacion degustacionDto = null;
        DegustacionDaoImpl degustacionDtoDaoImpl = new DegustacionDaoImpl(getConn());
        try{
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            Empresa empresaDto;
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())){
                idEmpresa = usuarioBO.getUser().getIdEmpresa();
            }else{
                try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("El usuario y/o contraseña del Empleado son inválidos.");
                return response;
            }
                        
           
            if (usuarioBO==null){
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("No se pudo recuperar la información de Usuario del empleado para registrar el prospecto.");
                return response;
            }
            
            if(degustacionDtoRequest.getIdDegustacion()> 0){
                degustacionDto = degustacionDtoDaoImpl.findByPrimaryKey(degustacionDtoRequest.getIdDegustacion());
            }
            
            
            if(degustacionDto!=null){//update 
                
                degustacionDto.setIdUsuario(usuarioBO.getUser().getIdUsuarios());
                degustacionDto.setIdEmpresa(idEmpresa);
                degustacionDto.setIdConcepto(degustacionDtoRequest.getIdConcepto());
                degustacionDto.setIdCliente(degustacionDtoRequest.getIdCliente());
                degustacionDto.setIdCheck(degustacionDtoRequest.getIdCheck());
                degustacionDto.setIdEstatus(degustacionDtoRequest.getIdEstatus());
                degustacionDto.setCantidad(degustacionDtoRequest.getCantidad());
                degustacionDto.setCantidadCierre(degustacionDtoRequest.getCantidadCierre());
                degustacionDto.setComentariosCierre(degustacionDtoRequest.getComentariosCierre());
                degustacionDto.setFechaApertura(degustacionDtoRequest.getFechaApertura());
                degustacionDto.setFechaCierre(degustacionDtoRequest.getFechaCierre());              
                degustacionDtoDaoImpl.update(degustacionDto.createPk(), degustacionDto);
                response.setIdObjetoCreado(degustacionDto.getIdDegustacion());                
            }else{//new
                degustacionDto = new Degustacion();
                
                degustacionDto.setIdUsuario(usuarioBO.getUser().getIdUsuarios());
                degustacionDto.setIdEmpresa(idEmpresa);
                degustacionDto.setIdConcepto(degustacionDtoRequest.getIdConcepto());
                degustacionDto.setIdCliente(degustacionDtoRequest.getIdCliente());
                degustacionDto.setIdCheck(degustacionDtoRequest.getIdCheck());
                degustacionDto.setIdEstatus(degustacionDtoRequest.getIdEstatus());
                degustacionDto.setCantidad(degustacionDtoRequest.getCantidad());
                degustacionDto.setCantidadCierre(degustacionDtoRequest.getCantidadCierre());
                degustacionDto.setComentariosCierre(degustacionDtoRequest.getComentariosCierre());
                degustacionDto.setFechaApertura(degustacionDtoRequest.getFechaApertura());
                degustacionDto.setFechaCierre(degustacionDtoRequest.getFechaCierre());
                DegustacionPk degustacionDtoPk = degustacionDtoDaoImpl.insert(degustacionDto);
                response.setIdObjetoCreado(degustacionDtoPk.getIdDegustacion());
            }
            
          
            //registramos ubicacion
            try{actualizarUbicacionUsuario(usuarioDtoRequest);}catch(Exception ex){}
            //Actualizo estatus de empleado
            try{
                if(degustacionDtoRequest.getIdEstatus()==1){
                    usuarioBO.updateEstadoEmpleado(7); 
                }else if(degustacionDtoRequest.getIdEstatus()==3){
                    usuarioBO.updateEstadoEmpleado(8); 
                }                    
            }catch(Exception ex){}
            
            
        }catch(Exception ex){
            response.setError(true);
            response.setNumError(902);
            response.setMsgError("Error inesperado al crear o actualizar Degustacion. " + ex.getLocalizedMessage());
        }finally{
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }
        return response;
    }
    
    public WsItemConceptoRegistroFotograficoResponse registrarConceptoRegistroFotografico(String usuarioDtoRequestJson, String conceptoRegistroFotograficoDtoRequestJson) {
        
        WsItemConceptoRegistroFotograficoResponse response;
        
        UsuarioDtoRequest usuarioDtoRequest = null;
        ConceptoRegistroFotograficoDtoRequest conceptoRegistroFotograficoDtoRequest = null;
        
        try{
            
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJson, UsuarioDtoRequest.class);
            conceptoRegistroFotograficoDtoRequest = gson.fromJson(conceptoRegistroFotograficoDtoRequestJson, ConceptoRegistroFotograficoDtoRequest.class);
            
            System.out.println("JSON:\n" + conceptoRegistroFotograficoDtoRequest);
            
            response = this.registrarConceptoRegistroFotografico(usuarioDtoRequest, conceptoRegistroFotograficoDtoRequest);
            
        }catch(Exception ex){
            response = new WsItemConceptoRegistroFotograficoResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        return response;
        
        
    }

    private WsItemConceptoRegistroFotograficoResponse registrarConceptoRegistroFotografico(UsuarioDtoRequest usuarioDtoRequest, ConceptoRegistroFotograficoDtoRequest conceptoRegistroFotograficoDtoRequest) {
        
        WsItemConceptoRegistroFotograficoResponse response = new WsItemConceptoRegistroFotograficoResponse();
        Configuration appConfig = new Configuration();
        
        int idEmpresa = 0 ;
        String rfcEmpresaMatriz ="";
        
        ConceptoRegistroFotografico conceptoRegistroFotograficoDto = null;
        ConceptoRegistroFotograficoDaoImpl conceptoRegistroFotograficoDtoDaoImpl = new ConceptoRegistroFotograficoDaoImpl(getConn());
        try{
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            Empresa empresaDto;
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())){
                idEmpresa = usuarioBO.getUser().getIdEmpresa();
            }else{
                try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("El usuario y/o contraseña del Empleado son inválidos.");
                return response;
            }
                        
           
            if (usuarioBO==null){
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("No se pudo recuperar la información de Usuario del empleado para registrar el prospecto.");
                return response;
            }
                        
            //Matriz de la empresa
            try{
                empresaDto = new EmpresaBO(getConn()).getEmpresaMatriz(idEmpresa);
                rfcEmpresaMatriz = empresaDto.getRfc();
            }catch(Exception ex){
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("No se pudo recuperar la información de la empresa del empleado. Verifique con su administrador de sistema." + ex.toString());
                return response;
            }
            
            if(conceptoRegistroFotograficoDtoRequest.getIdRegistro()> 0){
                conceptoRegistroFotograficoDto = conceptoRegistroFotograficoDtoDaoImpl.findByPrimaryKey(conceptoRegistroFotograficoDtoRequest.getIdRegistro());
            }
            
            
            if(conceptoRegistroFotograficoDto!=null){//update 
                
                conceptoRegistroFotograficoDto.setIdEmpresa(idEmpresa);
                conceptoRegistroFotograficoDto.setIdUsuario(usuarioBO.getUser().getIdUsuarios());
                conceptoRegistroFotograficoDto.setIdConcepto(conceptoRegistroFotograficoDtoRequest.getIdConcepto());
                conceptoRegistroFotograficoDto.setIdCliente(conceptoRegistroFotograficoDtoRequest.getIdCliente());
                conceptoRegistroFotograficoDto.setIdTipoFoto(conceptoRegistroFotograficoDtoRequest.getIdTipoFoto());
                conceptoRegistroFotograficoDto.setIdEstatus(conceptoRegistroFotograficoDtoRequest.getIdEstatus());
                File archivoImagenProspecto = null;

                if (conceptoRegistroFotograficoDtoRequest.getImagenProspectoBytesBase64()!=null){
                    if (conceptoRegistroFotograficoDtoRequest.getImagenProspectoBytesBase64().trim().length()>0){
                        try{
                            //Convertimos bytes en base64 a una imagen y la almacenamos en servidor
                            byte[] bytesImagenProspecto = Base64.decode(conceptoRegistroFotograficoDtoRequest.getImagenProspectoBytesBase64());

                            String ubicacionImagenesProspectos = appConfig.getApp_content_path() + rfcEmpresaMatriz +"/ImagenConcepto/pop/";
                            String nombreArchivoImagenProspecto = "img_pop_"+DateManage.getDateHourString()+".jpg";

                            archivoImagenProspecto = FileManage.createFileFromByteArray(bytesImagenProspecto, ubicacionImagenesProspectos, nombreArchivoImagenProspecto);
                        }catch(Exception ex){
                            response.setError(true);
                            response.setNumError(901);
                            response.setMsgError("Los archivos de imagen no son correctos. " + ex.getLocalizedMessage());
                            System.out.println(response.getMsgError());
                            ex.printStackTrace();
                            return response;
                        }
                    }
                }

                if (archivoImagenProspecto!=null)
                    conceptoRegistroFotograficoDto.setNombreFoto(archivoImagenProspecto.getName());
                
                conceptoRegistroFotograficoDto.setComentario(conceptoRegistroFotograficoDtoRequest.getComentario());
                conceptoRegistroFotograficoDto.setFechaHora(conceptoRegistroFotograficoDtoRequest.getFechaHora());
                
                conceptoRegistroFotograficoDtoDaoImpl.update(conceptoRegistroFotograficoDto.createPk(), conceptoRegistroFotograficoDto);
                response.setIdObjetoCreado(conceptoRegistroFotograficoDto.getIdRegistro());
                
            }else{//new
                conceptoRegistroFotograficoDto = new ConceptoRegistroFotografico();
                
                conceptoRegistroFotograficoDto.setIdEmpresa(idEmpresa);
                conceptoRegistroFotograficoDto.setIdUsuario(usuarioBO.getUser().getIdUsuarios());
                conceptoRegistroFotograficoDto.setIdConcepto(conceptoRegistroFotograficoDtoRequest.getIdConcepto());
                conceptoRegistroFotograficoDto.setIdCliente(conceptoRegistroFotograficoDtoRequest.getIdCliente());
                conceptoRegistroFotograficoDto.setIdTipoFoto(conceptoRegistroFotograficoDtoRequest.getIdTipoFoto());
                conceptoRegistroFotograficoDto.setIdEstatus(conceptoRegistroFotograficoDtoRequest.getIdEstatus());
                
                File archivoImagenProspecto = null;

                if (conceptoRegistroFotograficoDtoRequest.getImagenProspectoBytesBase64()!=null){
                    if (conceptoRegistroFotograficoDtoRequest.getImagenProspectoBytesBase64().trim().length()>0){
                        try{
                            //Convertimos bytes en base64 a una imagen y la almacenamos en servidor
                            byte[] bytesImagenProspecto = Base64.decode(conceptoRegistroFotograficoDtoRequest.getImagenProspectoBytesBase64());

                            String ubicacionImagenesProspectos = appConfig.getApp_content_path() + rfcEmpresaMatriz +"/ImagenConcepto/pop/";
                            String nombreArchivoImagenProspecto = "img_pop_"+DateManage.getDateHourString()+".jpg";

                            archivoImagenProspecto = FileManage.createFileFromByteArray(bytesImagenProspecto, ubicacionImagenesProspectos, nombreArchivoImagenProspecto);
                        }catch(Exception ex){
                            response.setError(true);
                            response.setNumError(901);
                            response.setMsgError("Los archivos de imagen no son correctos. " + ex.getLocalizedMessage());
                            System.out.println(response.getMsgError());
                            ex.printStackTrace();
                            return response;
                        }
                    }
                }

                if (archivoImagenProspecto!=null)
                    conceptoRegistroFotograficoDto.setNombreFoto(archivoImagenProspecto.getName());
                
                conceptoRegistroFotograficoDto.setComentario(conceptoRegistroFotograficoDtoRequest.getComentario());
                conceptoRegistroFotograficoDto.setFechaHora(conceptoRegistroFotograficoDtoRequest.getFechaHora());
                
                ConceptoRegistroFotograficoPk conceptoRegistroFotograficoDtoPk = conceptoRegistroFotograficoDtoDaoImpl.insert(conceptoRegistroFotograficoDto);
                response.setIdObjetoCreado(conceptoRegistroFotograficoDtoPk.getIdRegistro());
            }
            
          
            //registramos ubicacion
            try{actualizarUbicacionUsuario(usuarioDtoRequest);}catch(Exception ex){}
            
            
        }catch(Exception ex){
            response.setError(true);
            response.setNumError(902);
            response.setMsgError("Error inesperado al crear o actualizar ConceptoRegistroFotografico. " + ex.getLocalizedMessage());
        }finally{
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }
        return response;
    }
    
    public WsItemEstanteriaResponse resgistrarEstanteria(String usuarioDtoRequestJson, String estanteriaDtoRequestJson) {
        
        WsItemEstanteriaResponse response;
        
        UsuarioDtoRequest usuarioDtoRequest = null;
        EstanteriaDtoRequest estanteriaDtoRequest = null;
        
        try{
            
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJson, UsuarioDtoRequest.class);
            estanteriaDtoRequest = gson.fromJson(estanteriaDtoRequestJson, EstanteriaDtoRequest.class);
            
            System.out.println("JSON:\n" + estanteriaDtoRequest);
            
            response = this.resgistrarEstanteria(usuarioDtoRequest, estanteriaDtoRequest);
            
        }catch(Exception ex){
            response = new WsItemEstanteriaResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        return response;
        
        
    }

    private WsItemEstanteriaResponse resgistrarEstanteria(UsuarioDtoRequest usuarioDtoRequest, EstanteriaDtoRequest estanteriaDtoRequest) {
        
        WsItemEstanteriaResponse response = new WsItemEstanteriaResponse();
        Configuration appConfig = new Configuration();
        
        int idEmpresa = 0 ;
        String rfcEmpresaMatriz ="";
        
        Estanteria estanteriaDto = null;
        EstanteriaDaoImpl estanteriaDtoDaoImpl = new EstanteriaDaoImpl(getConn());
        try{
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            Empresa empresaDto;
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())){
                idEmpresa = usuarioBO.getUser().getIdEmpresa();
            }else{
                try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("El usuario y/o contraseña del Empleado son inválidos.");
                return response;
            }
                        
           
            if (usuarioBO==null){
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("No se pudo recuperar la información de Usuario del empleado para registrar la estanteria.");
                return response;
            }
            
            if(estanteriaDtoRequest.getIdEstanteria()> 0){
                estanteriaDto = estanteriaDtoDaoImpl.findByPrimaryKey(estanteriaDtoRequest.getIdEstanteria());
            }
            
            
            if(estanteriaDto!=null){//update 
                
                estanteriaDto.setIdEmpresa(idEmpresa);
                estanteriaDto.setIdEstatus(estanteriaDtoRequest.getIdEstatus());                
                estanteriaDto.setIdCliente(estanteriaDtoRequest.getIdCliente());
                estanteriaDto.setIdConcepto(estanteriaDtoRequest.getIdConcepto());
                estanteriaDto.setIdUsuario(usuarioBO.getUser().getIdUsuarios());                
                estanteriaDto.setCantidad(estanteriaDtoRequest.getCantidad());
                estanteriaDto.setPrecio(estanteriaDtoRequest.getPrecio());
                estanteriaDto.setFecha(estanteriaDtoRequest.getFecha());
                estanteriaDto.setFechaCaducidad(estanteriaDtoRequest.getFechaCaducidad());
                estanteriaDto.setNombreEmbalaje(estanteriaDtoRequest.getNombreEmbalaje()); 
                estanteriaDto.setUnidadesAlmacen(estanteriaDtoRequest.getUnidadesAlmacen());
                estanteriaDto.setPrecioOferta(estanteriaDtoRequest.getPrecioOferta());
                estanteriaDtoDaoImpl.update(estanteriaDto.createPk(), estanteriaDto);
                response.setIdObjetoCreado(estanteriaDto.getIdEstanteria());
                
                //quitamos los competidores que se habia registrado, para actualizar por los nuevos:
                EstanteriaDescripcionDaoImpl estanteriaDescripcionDtoDaoImpl = new EstanteriaDescripcionDaoImpl(getConn());
                //estanteriaDescripcionDtoDaoImpl.findByDynamicSelect("DELETE FROM "+estanteriaDescripcionDtoDaoImpl.getTableName() + " WHERE ID_ESTANTERIA = " + estanteriaDto.getIdEstanteria(), null);
                deleteEstanteriaDescripcion("DELETE FROM "+estanteriaDescripcionDtoDaoImpl.getTableName() + " WHERE ID_ESTANTERIA = " + estanteriaDto.getIdEstanteria(), getConn());
                
                //insertamos ahora los registros de la estanteria descripcion
                EstanteriaDescripcion estanteriaDescripcion = new EstanteriaDescripcion();                
                for(EstanteriaDescripcionDtoRequest descripcion : estanteriaDtoRequest.getEstanteriaDescripcionDtoRequest()){
                    EstanteriaDescripcion estanDesc = new EstanteriaDescripcion();
                    estanDesc.setIdEstanteria(estanteriaDto.getIdEstanteria());
                    estanDesc.setIdCompetencia(descripcion.getIdCompetencia());
                    estanDesc.setIdEstatus(descripcion.getIdEstatus());
                    estanDesc.setCantidad(descripcion.getCantidad());
                    estanDesc.setPrecio(descripcion.getPrecio());
                    estanDesc.setFechaCaducidad(descripcion.getFechaCaducidad());
                    estanDesc.setNombreEmbalaje(descripcion.getNombreEmbalaje());
                    estanDesc.setIdRelacionConceptoCompetencia(descripcion.getIdRelacionConceptoCompetencia());
                    estanDesc.setUnidadesAlmacen(descripcion.getUnidadesAlmacen());
                    estanDesc.setPrecioOferta(descripcion.getPrecioOferta());
                   
                    estanteriaDescripcionDtoDaoImpl.insert(estanDesc);
                }
                
            }else{//new
                estanteriaDto = new Estanteria();                
                estanteriaDto.setIdEmpresa(idEmpresa);
                estanteriaDto.setIdEstatus(estanteriaDtoRequest.getIdEstatus());                
                estanteriaDto.setIdCliente(estanteriaDtoRequest.getIdCliente());
                estanteriaDto.setIdConcepto(estanteriaDtoRequest.getIdConcepto());
                estanteriaDto.setIdUsuario(usuarioBO.getUser().getIdUsuarios());                
                estanteriaDto.setCantidad(estanteriaDtoRequest.getCantidad());
                estanteriaDto.setPrecio(estanteriaDtoRequest.getPrecio());
                estanteriaDto.setFecha(estanteriaDtoRequest.getFecha());
                estanteriaDto.setFechaCaducidad(estanteriaDtoRequest.getFechaCaducidad());
                estanteriaDto.setNombreEmbalaje(estanteriaDtoRequest.getNombreEmbalaje());
                estanteriaDto.setUnidadesAlmacen(estanteriaDtoRequest.getUnidadesAlmacen());
                estanteriaDto.setPrecioOferta(estanteriaDtoRequest.getPrecioOferta());
                
                EstanteriaPk estanteriaDtoPk = estanteriaDtoDaoImpl.insert(estanteriaDto);
                response.setIdObjetoCreado(estanteriaDtoPk.getIdEstanteria());
                
                //insertamos ahora los registros de la estanteria descripcion
                EstanteriaDescripcion estanteriaDescripcion = new EstanteriaDescripcion();
                EstanteriaDescripcionDaoImpl estanteriaDescripcionDtoDaoImpl = new EstanteriaDescripcionDaoImpl(getConn());
                for(EstanteriaDescripcionDtoRequest descripcion : estanteriaDtoRequest.getEstanteriaDescripcionDtoRequest()){
                    EstanteriaDescripcion estanDesc = new EstanteriaDescripcion();
                    estanDesc.setIdEstanteria(estanteriaDtoPk.getIdEstanteria());
                    estanDesc.setIdCompetencia(descripcion.getIdCompetencia());
                    estanDesc.setIdEstatus(descripcion.getIdEstatus());
                    estanDesc.setCantidad(descripcion.getCantidad());
                    estanDesc.setPrecio(descripcion.getPrecio());
                    estanDesc.setFechaCaducidad(descripcion.getFechaCaducidad());
                    estanDesc.setNombreEmbalaje(descripcion.getNombreEmbalaje());
                    estanDesc.setUnidadesAlmacen(descripcion.getUnidadesAlmacen());
                    estanDesc.setPrecioOferta(descripcion.getPrecioOferta());
                    estanDesc.setIdRelacionConceptoCompetencia(descripcion.getIdRelacionConceptoCompetencia());
                    estanteriaDescripcionDtoDaoImpl.insert(estanDesc);
                   
                }
                
            }
            
          
            //registramos ubicacion
            try{actualizarUbicacionUsuario(usuarioDtoRequest);}catch(Exception ex){}
            
            
        }catch(Exception ex){
            response.setError(true);
            response.setNumError(902);
            response.setMsgError("Error inesperado al crear o actualizar Estanteria. " + ex.getLocalizedMessage());
        }finally{
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }
        return response;
    }
    
    public SendMensajesMovilResponse insertaMensajeMovilByUsuario(String usuarioDtoRequestJSON, String sendMensajesMovilRequestJSON){
        
        SendMensajesMovilResponse response;
                
        UsuarioDtoRequest usuarioDtoRequest = null;
        //ItemMensajeMovilRequest crearMensajeMovilRequest = null;
        SendMensajesMovilRequest sendMensajesMovilRequest =null;
        try{
            //Transformamos de formato JSON a objeto
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJSON, UsuarioDtoRequest.class);
            sendMensajesMovilRequest = gson.fromJson(sendMensajesMovilRequestJSON, SendMensajesMovilRequest.class);
            
            response = this.insertaMensajeMovilByUsuario(usuarioDtoRequest,sendMensajesMovilRequest);
        }catch(Exception ex){
            response = new SendMensajesMovilResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        
        return response;
    }
    public SendMensajesMovilResponse insertaMensajeMovilByUsuario(UsuarioDtoRequest usuarioDtoRequest, SendMensajesMovilRequest sendMensajesMovilRequest){
        
        SendMensajesMovilResponse response = new SendMensajesMovilResponse();
        
        try{
            long idEmpresa = 0;
            
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())){
                idEmpresa = usuarioBO.getUser().getIdEmpresa();
            }else{
                   
                
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("El usuario y/o contraseña del Usuario son inválidos.");
                return response;
            }
        
            if (sendMensajesMovilRequest==null){
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("Objeto de datos de mensaje nulo.");
                return response;
            }
             
                
            for (ItemMensajeMovilRequest item:sendMensajesMovilRequest.getItemMensajeMovilRequest()){
                int idCreado=-1;
                WsItemSendMensajeResponse wsItemSendMensajeResponse = new WsItemSendMensajeResponse();
                if (item.getMensaje()==null){
                    wsItemSendMensajeResponse.setError(true);
                    wsItemSendMensajeResponse.setNumError(901);
                    wsItemSendMensajeResponse.setMsgError("Mensaje nulo.");
                    response.getWsItemSendMensajeResponse().add(wsItemSendMensajeResponse);
                    break;
                }else{
                    if (item.getMensaje().replaceAll(" ", "").trim().length()<=0){
                        wsItemSendMensajeResponse.setError(true);
                        wsItemSendMensajeResponse.setNumError(901);
                        wsItemSendMensajeResponse.setMsgError("Mensaje vacío.");
                        response.getWsItemSendMensajeResponse().add(wsItemSendMensajeResponse);
                        break;
                    }else if (item.getMensaje().length()>159){
                        wsItemSendMensajeResponse.setError(true);
                        wsItemSendMensajeResponse.setNumError(901);
                        wsItemSendMensajeResponse.setMsgError("Mensaje demasiado extenso. Se permite como máximo 160 carácteres.");
                        response.getWsItemSendMensajeResponse().add(wsItemSendMensajeResponse);
                        break;
                    }
                }
                
                try{
                    MovilMensaje movilMensajeDto = new MovilMensaje();

                    movilMensajeDto.setMensaje(item.getMensaje());
                    movilMensajeDto.setEmisorTipo(1);
                    movilMensajeDto.setIdUsuarioEmisor((int)usuarioBO.getUser().getIdUsuarios());
                    movilMensajeDto.setReceptorTipo(item.getReceptorTipo());
                    movilMensajeDto.setIdUsuarioReceptor(item.getReceptorTipo()!=2?item.getIdEmpleadoReceptor():0);
                    //tomamos la hora en base a la zona horaria, si existe                    
                    try{
                        movilMensajeDto.setFechaEmision(ZonaHorariaBO.DateZonaHorariaByIdEmpresa(getConn(), new Date(), (int)idEmpresa).getTime());
                    }catch(Exception e){
                        movilMensajeDto.setFechaEmision(new Date());
                    }
                    
                    movilMensajeDto.setRecibido(0);

                    MovilMensajePk movilMensajePk= new MovilMensajeDaoImpl(getConn()).insert(movilMensajeDto);

                    idCreado = movilMensajePk.getIdMovilMensaje();
                    wsItemSendMensajeResponse.setRastreadorMensaje(item.getRastreadorMensaje());
                    wsItemSendMensajeResponse.setIdObjetoCreado(idCreado);
                }catch(Exception ex){
                    wsItemSendMensajeResponse.setError(true);
                    wsItemSendMensajeResponse.setNumError(902);
                    wsItemSendMensajeResponse.setMsgError("Error al registrar mensaje en servidor: " + ex.toString());
                }
                
                response.getWsItemSendMensajeResponse().add(wsItemSendMensajeResponse);
            }
            
            //registramos ubicacion
            try{actualizarUbicacionUsuario(usuarioDtoRequest);}catch(Exception ex){}
            
        }catch(Exception ex){
            ex.printStackTrace();
            response.setError(true);
            response.setNumError(902);
            response.setMsgError("Error inesperado al crear un mensaje. " + ex.getLocalizedMessage());
        }finally{                
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}              
        }
        
        return response;
    }
    
    
    public SendEstatusMensajesMovilResponse insertaEstatusMensajeMovilByUsuario(String usuarioDtoRequestJSON, String sendEstatusMensajesMovilRequestJSON){
        System.out.println("MENSAJE:\n" + sendEstatusMensajesMovilRequestJSON);
        SendEstatusMensajesMovilResponse response;
                
        UsuarioDtoRequest usuarioDtoRequest = null;
        //ItemMensajeMovilRequest crearMensajeMovilRequest = null;
        SendEstatusMensajesMovilRequest sendMensajesMovilRequest =null;
        try{
            //Transformamos de formato JSON a objeto
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJSON, UsuarioDtoRequest.class);
            sendMensajesMovilRequest = gson.fromJson(sendEstatusMensajesMovilRequestJSON, SendEstatusMensajesMovilRequest.class);
            
            response = this.insertaEstatusMensajeMovilByUsuario(usuarioDtoRequest,sendMensajesMovilRequest);
        }catch(Exception ex){
            response = new SendEstatusMensajesMovilResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        
        return response;
    }
    public SendEstatusMensajesMovilResponse insertaEstatusMensajeMovilByUsuario(UsuarioDtoRequest usuarioDtoRequest, SendEstatusMensajesMovilRequest sendEstatusMensajesMovilRequest){
        
        SendEstatusMensajesMovilResponse response = new SendEstatusMensajesMovilResponse();
        
        try{
            int idEmpresa = 0;
            
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())){
                idEmpresa = usuarioBO.getUser().getIdEmpresa();
            }else{
               
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("El usuario y/o contraseña del Usuario son inválidos.");
                return response;
            }
        
            if (sendEstatusMensajesMovilRequest==null){
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("Objeto de datos de estatus mensaje nulo.");
                return response;
            }
             
                
            for (ItemEstatusMensajeMovilRequest item:sendEstatusMensajesMovilRequest.getItemEstatusMensajeMovilRequest()){
                int idCreado=-1;
                WsItemSendMensajeResponse wsItemSendMensajeResponse = new WsItemSendMensajeResponse();
                if (item.getMensajeEstatus()==null){
                    wsItemSendMensajeResponse.setError(true);
                    wsItemSendMensajeResponse.setNumError(901);
                    wsItemSendMensajeResponse.setMsgError("Mensaje nulo.");
                    response.getWsItemSendMensajeResponse().add(wsItemSendMensajeResponse);
                    break;
                }else{
                    if (item.getMensajeEstatus().replaceAll(" ", "").trim().length()<=0){
                        wsItemSendMensajeResponse.setError(true);
                        wsItemSendMensajeResponse.setNumError(901);
                        wsItemSendMensajeResponse.setMsgError("Mensaje vacío.");
                        response.getWsItemSendMensajeResponse().add(wsItemSendMensajeResponse);
                        break;
                    }else if (item.getMensajeEstatus().length()>159){
                        wsItemSendMensajeResponse.setError(true);
                        wsItemSendMensajeResponse.setNumError(901);
                        wsItemSendMensajeResponse.setMsgError("Mensaje demasiado extenso. Se permite como máximo 160 carácteres.");
                        response.getWsItemSendMensajeResponse().add(wsItemSendMensajeResponse);
                        break;
                    }
                }
                
                try{
                    PosMovilEstatus movilEstatusDto = new PosMovilEstatus();

                    movilEstatusDto.setFechaEstatus(item.getFechaHoraEstatus());
                    movilEstatusDto.setIdEmpleado(usuarioBO.getUser().getIdUsuarios());
                    movilEstatusDto.setIdEmpresa(idEmpresa);
                    movilEstatusDto.setLatitud(item.getLatitud());
                    movilEstatusDto.setLongitud(item.getLongitud());
                    movilEstatusDto.setMensajeEstatus(item.getMensajeEstatus());
                    
                    File archivoImagenSeguimiento = null;
                    Configuration appConfig = new Configuration();                    
                    String rfcEmpresaMatriz ="";
                    
                    //Matriz de la empresa
                    Empresa empresaDto = null;
                    try{
                        empresaDto = new EmpresaBO(getConn()).getEmpresaMatriz(idEmpresa);
                        rfcEmpresaMatriz = empresaDto.getRfc();
                    }catch(Exception ex){
                        response.setError(true);
                        response.setNumError(901);
                        response.setMsgError("No se pudo recuperar la información de la empresa del empleado. Verifique con su administrador de sistema." + ex.toString());
                        return response;
                    }

                    if (item.getImagenSeguimientoBytesBase64()!=null){
                        if (item.getImagenSeguimientoBytesBase64().trim().length()>0){
                            try{
                                //Convertimos bytes en base64 a una imagen y la almacenamos en servidor
                                byte[] bytesImagenProspecto = Base64.decode(item.getImagenSeguimientoBytesBase64());

                                String ubicacionImagenesProspectos = appConfig.getApp_content_path() + rfcEmpresaMatriz +"/seguimiento/";
                                String nombreArchivoImagenProspecto = "img_seguimiento_"+DateManage.getDateHourString()+".jpg";

                                archivoImagenSeguimiento = FileManage.createFileFromByteArray(bytesImagenProspecto, ubicacionImagenesProspectos, nombreArchivoImagenProspecto);
                            }catch(Exception ex){
                                response.setError(true);
                                response.setNumError(901);
                                response.setMsgError("Los archivos de imagen no son correctos. " + ex.getLocalizedMessage());
                                System.out.println(response.getMsgError());
                                ex.printStackTrace();
                                return response;
                            }
                        }
                    }
                    if (archivoImagenSeguimiento!=null)
                        movilEstatusDto.setImagenSeguimiento(archivoImagenSeguimiento.getName());

                    PosMovilEstatusPk movilEstatusPk= new PosMovilEstatusDaoImpl(getConn()).insert(movilEstatusDto);

                    idCreado = movilEstatusPk.getIdMovilEstatus();
                    wsItemSendMensajeResponse.setRastreadorMensaje(item.getRastreadorMensaje());
                    wsItemSendMensajeResponse.setIdObjetoCreado(idCreado);
                }catch(Exception ex){
                    wsItemSendMensajeResponse.setError(true);
                    wsItemSendMensajeResponse.setNumError(902);
                    wsItemSendMensajeResponse.setMsgError("Error al registrar mensaje de estatus en servidor: " + ex.toString());
                }finally{                
                    try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}            
                }
                
                response.getWsItemSendMensajeResponse().add(wsItemSendMensajeResponse);
            }
            
            try{
                //para enviar el tiempo que va a tener que estarse reportando el empleado               
                    response.setParametroTiempoMinutosActualiza(usuarioBO.getUser().getMinutosEstatus());
                
            }catch(Exception ex){
            }
            
            //registramos ubicacion
            try{actualizarUbicacionUsuario(usuarioDtoRequest);}catch(Exception ex){}
            
        }catch(Exception ex){
            ex.printStackTrace();
            response.setError(true);
            response.setNumError(902);
            response.setMsgError("Error inesperado al crear un mensaje. " + ex.getLocalizedMessage());
        }finally{                
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}              
        }
        
        return response;
    }
    
    
    /**
     * Crea o actualiza el registro de un Prospecto
     * procedente de la app móvil
     * @param prospectoDtoRequestJSON String Datos del prospecto en formato JSON 
     * @return WSResponseInsert respuesta básica de inserción
     */
    public WSResponseInsert insertaActualizaProspecto(String usuarioDtoRequestJSON, String prospectoDtoRequestJSON){
        WSResponseInsert response;
                
        UsuarioDtoRequest usuarioDtoRequest = null;
        ProspectoDtoRequest prospectoDtoRequest = null;
        try{
            //Transformamos de formato JSON a objeto
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJSON, UsuarioDtoRequest.class);
            //Transformamos de formato JSON a objeto
            prospectoDtoRequest = gson.fromJson(prospectoDtoRequestJSON, ProspectoDtoRequest.class);
            
            response = this.insertaActualizaProspecto(usuarioDtoRequest, prospectoDtoRequest);
        }catch(Exception ex){
            response = new WSResponseInsert();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        
        return response;
    }
    
    
    /**
     * Crea o actualiza el registro de un Prospecto
     * procedente de la app móvil
     * @param datosEmpleado
     * @param prospectoDtoRequest ProspectoDtoRequest Datos del prospecto
     * @return WSResponseInsert respuesta básica de inserción
     */
    public WSResponseInsert insertaActualizaProspecto(UsuarioDtoRequest usuarioDtoRequest, ProspectoDtoRequest prospectoDtoRequest){
        
        WSResponseInsert response = new WSResponseInsert();
        Configuration appConfig = new Configuration();
        
        int idEmpresa = 0 ;
        String rfcEmpresaMatriz ="";
        
        Prospecto prospectoDto = new Prospecto();
        ProspectoDaoImpl prospectoDao = new ProspectoDaoImpl(getConn());
        
        try{
            
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            Empresa empresaDto;
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())){
                idEmpresa = usuarioBO.getUser().getIdEmpresa();
            }else{
                try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("El usuario y/o contraseña del Empleado son inválidos.");
                return response;
            }
            
            //Matriz de la empresa
            try{
                empresaDto = new EmpresaBO(getConn()).getEmpresaMatriz(idEmpresa);
                rfcEmpresaMatriz = empresaDto.getRfc();
            }catch(Exception ex){
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("No se pudo recuperar la información de la empresa del empleado. Verifique con su administrador de sistema." + ex.toString());
                return response;
            }
            
            if (usuarioBO==null){
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("No se pudo recuperar la información de Usuario del empleado para registrar el prospecto.");
                return response;
            }
            
            
            if (prospectoDtoRequest.getIdProspecto()>0){
                //Si es edición recuperamos el objeto correspondiente de BD
                prospectoDto = new ProspectoBO(getConn()).findProspectobyId(prospectoDtoRequest.getIdProspecto());
            }
            
            prospectoDto.setIdEmpresa(idEmpresa);
            prospectoDto.setRazonSocial(prospectoDtoRequest.getRazonSocial());
            prospectoDto.setLada(prospectoDtoRequest.getLada());
            prospectoDto.setTelefono(prospectoDtoRequest.getTelefono());
            prospectoDto.setCelular(prospectoDtoRequest.getCelular());
            prospectoDto.setCorreo(prospectoDtoRequest.getCorreo());
            prospectoDto.setContacto(prospectoDtoRequest.getContacto());
            prospectoDto.setIdEstatus(1);
            prospectoDto.setDescripcion(prospectoDtoRequest.getDescripcion());
            prospectoDto.setLatitud(prospectoDtoRequest.getLatitud());
            prospectoDto.setLongitud(prospectoDtoRequest.getLongitud());
            prospectoDto.setDireccion(prospectoDtoRequest.getDireccion());
            prospectoDto.setIdUsuarioVendedor(usuarioBO.getUser().getIdUsuarios());
            try{
                prospectoDto.setFechaRegistro(prospectoDtoRequest.getFechaRegistro()!=null?prospectoDtoRequest.getFechaRegistro() : (ZonaHorariaBO.DateZonaHorariaByIdEmpresa(getConn(), new Date(), (int)idEmpresa).getTime()));
            }catch(Exception e){
                prospectoDto.setFechaRegistro(prospectoDtoRequest.getFechaRegistro()!=null?prospectoDtoRequest.getFechaRegistro() : new Date());
            }
            prospectoDto.setDirNumeroExterior(prospectoDtoRequest.getDirNumeroExterior());
            prospectoDto.setDirNumeroInterior(prospectoDtoRequest.getDirNumeroInterior());
            prospectoDto.setDirCodigoPostal(prospectoDtoRequest.getDirCodigoPostal());
            prospectoDto.setDirColonia(prospectoDtoRequest.getDirColonia());
            
            File archivoImagenProspecto = null;

            if (prospectoDtoRequest.getImagenProspectoBytesBase64()!=null){
                if (prospectoDtoRequest.getImagenProspectoBytesBase64().trim().length()>0){
                    try{
                        //Convertimos bytes en base64 a una imagen y la almacenamos en servidor
                        byte[] bytesImagenProspecto = Base64.decode(prospectoDtoRequest.getImagenProspectoBytesBase64());

                        String ubicacionImagenesProspectos = appConfig.getApp_content_path() + rfcEmpresaMatriz +"/prospectos/images/";
                        String nombreArchivoImagenProspecto = "img_prospecto_"+DateManage.getDateHourString()+".jpg";

                        archivoImagenProspecto = FileManage.createFileFromByteArray(bytesImagenProspecto, ubicacionImagenesProspectos, nombreArchivoImagenProspecto);
                    }catch(Exception ex){
                        response.setError(true);
                        response.setNumError(901);
                        response.setMsgError("Los archivos de imagen no son correctos. " + ex.getLocalizedMessage());
                        System.out.println(response.getMsgError());
                        ex.printStackTrace();
                        return response;
                    }
                }
            }
            
            if (archivoImagenProspecto!=null)
                prospectoDto.setNombreImagenProspecto(archivoImagenProspecto.getName());
            
            boolean edicion = false;
            if (prospectoDtoRequest.getIdProspecto()<=0){
                //Registro nuevo (INSERT)
                ProspectoPk prospectoPk = prospectoDao.insert(prospectoDto);
                response.setIdObjetoCreado(prospectoPk.getIdProspecto());
            }else{
                //Registro existente (UPDATE)
                prospectoDao.update(prospectoDto.createPk(), prospectoDto);
                response.setIdObjetoCreado(prospectoDto.getIdProspecto());
                edicion = true;
            }
            
            //registramos ubicacion
            try{actualizarUbicacionUsuario(usuarioDtoRequest);}catch(Exception ex){}
            
        }catch(Exception ex){
            ex.printStackTrace();
            response.setError(true);
            response.setNumError(902);
            response.setMsgError("Error inesperado al crear o actualizar Prospecto. " + ex.getLocalizedMessage());
        }finally{   
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }
        
        return response;
    }

    private Object HorarioUsuarioDaoImpl() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }
    
    /** 
	 * Deletes a single row in the estanteria_descripcion table.
	 */
	public void deleteEstanteriaDescripcion(String SQL_DELETE, Connection connec) throws EstanteriaDescripcionDaoException
	{
		long t1 = System.currentTimeMillis();
		// declare variables
		final boolean isConnSupplied = (connec != null);
		Connection conn = null;
		PreparedStatement stmt = null;
		
		try {
			// get the user-specified connection or get a connection from the ResourceManager
			conn = isConnSupplied ? connec : ResourceManager.getConnection();
		
			System.out.println( "Executing " + SQL_DELETE);
			stmt = conn.prepareStatement( SQL_DELETE );
			//stmt.setInt( 1, pk.getIdDescripcion() );
			int rows = stmt.executeUpdate();
			long t2 = System.currentTimeMillis();
			System.out.println( rows + " rows affected (" + (t2-t1) + " ms)" );
		}
		catch (Exception _e) {
			_e.printStackTrace();
			throw new EstanteriaDescripcionDaoException( "Exception: " + _e.getMessage(), _e );
		}
		finally {
			ResourceManager.close(stmt);
			if (!isConnSupplied) {
				ResourceManager.close(conn);
			}
		
		}
		
	}
        
    public InsertRegistroVisitaClienteResponse registrarRutaMarcadoresVisitados(String usuarioDtoRequestJSON, int[] rutaMarcadoresIDs){
        InsertRegistroVisitaClienteResponse response;
                
        UsuarioDtoRequest usuarioDtoRequest = null;
        try{
            //Transformamos de formato JSON a objeto
            usuarioDtoRequest = gson.fromJson(usuarioDtoRequestJSON, UsuarioDtoRequest.class);
            
            response = this.registrarRutaMarcadoresVisitados(usuarioDtoRequest, rutaMarcadoresIDs);
        }catch(Exception ex){
            response = new InsertRegistroVisitaClienteResponse();
            response.setError(true);
            response.setNumError(901);
            response.setMsgError("Los datos enviados no corresponden a los requeridos. No se pudo transformar de un cadena JSON a objetos. " + ex.toString());
            ex.printStackTrace();
        }
        
        return response;
     }
     
     public InsertRegistroVisitaClienteResponse registrarRutaMarcadoresVisitados(UsuarioDtoRequest usuarioDtoRequest, int[] rutaMarcadoresIDs){
         InsertRegistroVisitaClienteResponse response = new InsertRegistroVisitaClienteResponse();
         
         try{
             //Consultamos y obtenemos el ID de Empresa del Usuario
            UsuarioBO usuarioBO = new UsuarioBO(getConn());
            if (usuarioBO.login(usuarioDtoRequest.getUsuarioUsuario(), usuarioDtoRequest.getUsuarioPassword())) {
                
                if (rutaMarcadoresIDs!=null){
                    if (rutaMarcadoresIDs.length>0){
                        RutaMarcadorDaoImpl rutaMarcadorDao = new RutaMarcadorDaoImpl(getConn());
                        for (int marcadorVisitado : rutaMarcadoresIDs){
                            RutaMarcador rutaMarcador = rutaMarcadorDao.findByPrimaryKey(marcadorVisitado);
                            if (rutaMarcador!=null){
                                rutaMarcador.setIsVisitado((short)1);

                                rutaMarcadorDao.update(rutaMarcador.createPk(), rutaMarcador);
                            }
                        }
                    }
                }
                
            }else {
                response.setError(true);
                response.setNumError(901);
                response.setMsgError("El usuario y/o contraseña del Empleado son inválidos.");
            }
         } catch (Exception e) {
            response.setError(true);
            response.setNumError(902);
            response.setMsgError("Error al actualizar estatus de Marcadores visitados. " + e.toString());
            e.printStackTrace();
        }finally{   
            try{ if (this.conn!=null) getConn().close(); }catch(Exception ex){}
        }
         
        return response;
     }
}
