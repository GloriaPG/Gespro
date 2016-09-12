<%-- 
    Document   : catCargaManual_ajax
    Created on : 7/08/2015, 01:45:08 PM
    Author     : HpPyme
--%>



<%@page import="com.tsp.gespro.importa.ReadClientesExcel"%>
<%@page import="com.tsp.gespro.importa.ReadConceptosExcel"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.config.Configuration"%>
<%@page import="com.tsp.gespro.jdbc.CargaXlsDaoImpl"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page import="com.tsp.gespro.dto.CargaXls"%>
<%@page import="java.util.Date"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    String mode = "";
    
    long idEmpresa = user.getUser().getIdEmpresa();
    long idUsuario = user.getUser().getIdUsuarios();
    String nombreArchivoDefaultConceptos = "cargaConceptos.xls";
    String nombreArchivoDefaultClientes = "cargaClientes.xls";
    String tipoCarga = "";
    
    /*
    Parametros
    */
    
    String nombreArchivo = "";
    String nombreArchivocli = "";
    /*
    * Recepción de valores
    */
    mode = request.getParameter("mode")!=null?request.getParameter("mode"):"";    
    nombreArchivo = request.getParameter("nombreArchivo")!=null?new String(request.getParameter("nombreArchivo").getBytes("ISO-8859-1"),"UTF-8"):"";
    nombreArchivocli = request.getParameter("nombreArchivocli")!=null?new String(request.getParameter("nombreArchivocli").getBytes("ISO-8859-1"),"UTF-8"):"";
    tipoCarga = request.getParameter("tipoCarga")!=null?new String(request.getParameter("tipoCarga").getBytes("ISO-8859-1"),"UTF-8"):"";
    
    
    /*
    * Validaciones del servidor
    */
    String msgError = "";
    GenericValidator gc = new GenericValidator();    
    
    if(tipoCarga.equals("productos")){
        if(!gc.isValidString(nombreArchivo, 1, 300))
            msgError += "<ul>El 'Archivo Excel' es requerido.";
    }else if(tipoCarga.equals("clientes")){
        if(!gc.isValidString(nombreArchivocli, 1, 300))
            msgError += "<ul>El 'Archivo Excel' es requerido.";
    }
                       

    if(msgError.equals("")){    
        
        
        if(tipoCarga.equals("productos")){
        
            
            try {                
                
                /**
                 * Creamos el registro de Carga del Archivo
                 */
                CargaXls cargaXlsDto = new CargaXls();
                CargaXlsDaoImpl cargaXlsDaoImpl = new CargaXlsDaoImpl(user.getConn());             
                ReadConceptosExcel readXls = new ReadConceptosExcel();         
              
                
                cargaXlsDto.setIdEmpresa((int)idEmpresa);
                cargaXlsDto.setIdUsuario((int)idUsuario);
                cargaXlsDto.setNombreArchivo(nombreArchivo);
                cargaXlsDto.setFecha(new Date());
                
                //Carga 1- CARGA COMPLETA, 2- CARGA INCOMPLETA (CON ERRORES), 3- OTRO
                int estatuscarga = 3;        
                String logErroresInsertado = "";     
                String logErroresLeer = "";     
                String msgUsuario = "";
                
                
                
                                
                
                //Leemos archivo de excel             
                try{                
                      Empresa empresaDto = new EmpresaBO(user.getUser().getIdEmpresa(),user.getConn()).getEmpresa();
                     
                      
                      Configuration appConfig = new Configuration();
                      String ourRepositoryDirectory = appConfig.getApp_content_path();
                      
                      String path = ourRepositoryDirectory += empresaDto.getRfc() + "/" + nombreArchivoDefaultConceptos;
                      //System.out.println("Path............" + path );
                      
                      
                      //Leemos e insertamos nuevos datos
                      logErroresLeer = readXls.leerArchivoExcelConceptos(path, (int)idEmpresa); 
                      
                      if(logErroresLeer.equals("")){
                          
                        //insertar datos  
                        logErroresInsertado = readXls.insertaConceptosExcel(idEmpresa);
                        
                            //errores al guardar
                          if(!logErroresInsertado.equals("")){ 
                              estatuscarga = 2;
                              msgUsuario = "Carga con errores , revisar Log.";
                          }else if(logErroresInsertado.equals("")){
                              estatuscarga = 1;
                              logErroresInsertado = "Carga realizada sin errores.";
                              msgUsuario = "Carga realizada sin errores.";
                          }else{
                              estatuscarga = 3;
                          }                        
                      }else{//errores al leer
                          
                        if(!logErroresLeer.equals("")){ 
                              estatuscarga = 2;
                              msgUsuario = " Lectura con errores , revisar Log.";
                          }else if(logErroresLeer.equals("")){
                              estatuscarga = 1;
                              logErroresLeer = " Lectura realizada sin errores.";
                              msgUsuario = " Lectura realizada sin errores. ";
                          }else{
                              estatuscarga = 3;
                          }  
                           
                          //solo para insertar en log
                          logErroresInsertado = logErroresLeer;
                      }
                      
                      
                      
                }catch(Exception e){
                    System.out.println("Error al insertar datos desde Excel");
                    e.printStackTrace();
                }
                
                cargaXlsDto.setIdEstatusCarga(estatuscarga);   
                cargaXlsDto.setLogText(logErroresInsertado);
                cargaXlsDto.setIdTipoCarga(1); //1-> Conceptos
                
                /**
                 * Realizamos el insert
                 */
               cargaXlsDaoImpl.insert(cargaXlsDto);

                out.print("<!--EXITO-->Estatus Proceso:<br/>"+ msgUsuario +"<br/>");
            
            }catch(Exception e){
                e.printStackTrace();
                msgError += "Ocurrio un error al importar los datos: " + e.toString() ;
            }
            
        }else if(tipoCarga.equals("clientes")){
            
            try {                
                
                /**
                 * Creamos el registro de Carga del Archivo
                 */
                CargaXls cargaXlsDto = new CargaXls();
                CargaXlsDaoImpl cargaXlsDaoImpl = new CargaXlsDaoImpl(user.getConn());             
                ReadClientesExcel readXls = new ReadClientesExcel();         
              
                
                cargaXlsDto.setIdEmpresa((int)idEmpresa);
                cargaXlsDto.setIdUsuario((int)idUsuario);
                cargaXlsDto.setNombreArchivo(nombreArchivocli);
                cargaXlsDto.setFecha(new Date());
                
                //Carga 1- CARGA COMPLETA, 2- CARGA INCOMPLETA (CON ERRORES), 3- OTRO
                int estatuscarga = 3;        
                String logErroresInsertado = "";     
                String logErroresLeer = "";     
                String msgUsuario = "";
                                                
                
                //Leemos archivo de excel             
                try{                
                      Empresa empresaDto = new EmpresaBO(user.getUser().getIdEmpresa(),user.getConn()).getEmpresa();
                     
                      
                      Configuration appConfig = new Configuration();
                      String ourRepositoryDirectory = appConfig.getApp_content_path();
                      
                      String path = ourRepositoryDirectory += empresaDto.getRfc() + "/" + nombreArchivoDefaultClientes;
                      //System.out.println("Path............" + path );
                      
                      
                      //Leemos e insertamos nuevos datos
                      logErroresLeer = readXls.leerArchivoExcelClientes(path, (int)idEmpresa); 
                      
                      if(logErroresLeer.equals("")){
                          
                        //insertar datos  
                        logErroresInsertado = readXls.insertaClientesExcel(idEmpresa, (int)idUsuario);
                        
                            //errores al guardar
                          if(!logErroresInsertado.equals("")){ 
                              estatuscarga = 2;
                              msgUsuario = "Carga con errores , revisar Log.";
                          }else if(logErroresInsertado.equals("")){
                              estatuscarga = 1;
                              logErroresInsertado = "Carga realizada sin errores.";
                              msgUsuario = "Carga realizada sin errores.";
                          }else{
                              estatuscarga = 3;
                          }                        
                      }else{//errores al leer
                          
                        if(!logErroresLeer.equals("")){ 
                              estatuscarga = 2;
                              msgUsuario = " Lectura con errores , revisar Log.";
                          }else if(logErroresLeer.equals("")){
                              estatuscarga = 1;
                              logErroresLeer = " Lectura realizada sin errores.";
                              msgUsuario = " Lectura realizada sin errores. ";
                          }else{
                              estatuscarga = 3;
                          }  
                           
                          //solo para insertar en log
                          logErroresInsertado = logErroresLeer;
                      }
                      
                      
                      
                }catch(Exception e){
                    System.out.println("Error al insertar datos desde Excel");
                    e.printStackTrace();
                }
                
                cargaXlsDto.setIdEstatusCarga(estatuscarga);   
                cargaXlsDto.setLogText(logErroresInsertado);
                cargaXlsDto.setIdTipoCarga(2); //2-> Clientes
                
                /**
                 * Realizamos el insert
                 */
               cargaXlsDaoImpl.insert(cargaXlsDto);

                out.print("<!--EXITO-->Estatus Proceso:<br/>"+ msgUsuario +"<br/>");
            
            }catch(Exception e){
                e.printStackTrace();
                msgError += "Ocurrio un error al importar los datos: " + e.toString() ;
            }
            
            
            
            
        }else{
             out.print("<!--ERROR-->Opción no Válida");
        }
        
        
        
        
        
       
    }else{
        out.print("<!--ERROR-->"+msgError);
    }

%>
