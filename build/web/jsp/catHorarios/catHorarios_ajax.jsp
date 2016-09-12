<%-- 
    Document   : catHorarios_ajax
    Created on : 29/10/2015, 10:28:46 AM
    Author     : HpPyme
--%>

<%@page import="com.tsp.gespro.bo.DetalleHorarioBO"%>
<%@page import="com.tsp.gespro.dto.HorarioUsuarioPk"%>
<%@page import="com.tsp.gespro.jdbc.DetalleHorarioDaoImpl"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page import="com.tsp.gespro.dto.DetalleHorario"%>
<%@page import="com.tsp.gespro.bo.HorariosBO"%>
<%@page import="com.tsp.gespro.jdbc.HorarioUsuarioDaoImpl"%>
<%@page import="com.tsp.gespro.dto.HorarioUsuario"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    String mode = "";
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
    /*
    * Parámetros
    */
    int idHorario = -1;
    String nombreHorario ="";   
    int estatus = 2;//deshabilitado
    
    /*
    * Recepción de valores
    */
    mode = request.getParameter("mode")!=null?request.getParameter("mode"):"";
    try{
        idHorario = Integer.parseInt(request.getParameter("idHorario"));
    }catch(NumberFormatException ex){}
    nombreHorario = request.getParameter("nombreHorario")!=null?new String(request.getParameter("nombreHorario").getBytes("ISO-8859-1"),"UTF-8"):"";    
    try{
        estatus = Integer.parseInt(request.getParameter("estatus"));
    }catch(NumberFormatException ex){}   
    
    /*
    * Validaciones del servidor
    */
    String msgError = "";
    GenericValidator gc = new GenericValidator();    
    if(!gc.isValidString(nombreHorario, 1, 30))
        msgError += "<ul>El dato 'Nombre' es requerido.";     
    if(idHorario <= 0 && (!mode.equals("")))
        msgError += "<ul>El dato ID 'Horario' es requerido";
   

        
    for(int i= 1;i<=7;i++){  
        
        String dia ="";
        int tolerancia = -1;
        int periodo = -1;
        String horaEntrada = "";
        String horaSalida = "";
        String salidaComida = "";
        String entradaComida = "";
        int diaDescanso = 0;

        if(i==1)
            dia = "LUNES";
        else if(i==2)
            dia = "MARTES";
        else if(i==3)
            dia = "MIERCOLES";
        else if(i==4)
            dia = "JUEVES";
        else if(i==5)
            dia = "VIERNES";
        else if(i==6)
            dia = "SABADO";
        else if(i==7)
            dia = "DOMINGO";
                
        try{
            tolerancia = Integer.parseInt(request.getParameter("tolerancia_"+dia));
        }catch(NumberFormatException ex){}
        try{
            periodo = Integer.parseInt(request.getParameter("periodo_"+dia));
        }catch(NumberFormatException ex){}
        
        horaEntrada = request.getParameter("entrada_"+dia)!=null?new String(request.getParameter("entrada_"+dia).getBytes("ISO-8859-1"),"UTF-8"):"";   
        horaSalida = request.getParameter("salida_"+dia)!=null?new String(request.getParameter("salida_"+dia).getBytes("ISO-8859-1"),"UTF-8"):"";   
        salidaComida = request.getParameter("salidaComida_"+dia)!=null?new String(request.getParameter("salidaComida_"+dia).getBytes("ISO-8859-1"),"UTF-8"):"";   
        entradaComida = request.getParameter("entradaComida_"+dia)!=null?new String(request.getParameter("entradaComida_"+dia).getBytes("ISO-8859-1"),"UTF-8"):"";   
                
        
        try{
            diaDescanso = Integer.parseInt(request.getParameter("descanso_"+dia));
        }catch(NumberFormatException ex){}
        
        if(diaDescanso==0){
        
            if (horaEntrada.equals("")) {
                //msgError = "<ul>El dato 'Hora de Entrada' es obligatorio. ";
                msgError = "Todos los datos son Obligatorios.";

            }        
            if (horaSalida.equals("")) {
               // msgError = "<ul>El dato 'Hora de Salida' es obligatorio. ";
                 msgError = "Todos los datos son Obligatorios.";
            }        
            if (tolerancia < 0) {
                //msgError = "<ul>El dato 'Tolerancia' debe ser cero o mayor a cero. ";
                 msgError = "Todos los datos son Obligatorios.";
            }        
            if (salidaComida.equals("")) {
               // msgError = "<ul>El dato 'Salida Comida'  es obligatorio. ";
                 msgError = "Todos los datos son Obligatorios.";
            }        
            if (entradaComida.equals("")) {
                //msgError = "<ul>El dato 'Entrada Comida' es obligatorio. ";
                 msgError = "Todos los datos son Obligatorios.";
            }        
            if (periodo < 0) {
               // msgError = "<ul>El dato 'Periodo' debe ser cero o mayor a cero. ";
                 msgError = "Todos los datos son Obligatorios.";
            }
        }
                    
    }
    
    if(msgError.equals("")){
        if(idHorario>0){
            if (mode.equals("1")){
            /*
            * Editar
            */
                try{
                    
                    
                    HorariosBO horarioBO = new HorariosBO(idHorario,user.getConn());
                    HorarioUsuario horarioDto = horarioBO.getHorarioUsuario();                
                
                
                    horarioDto.setNombreHorario(nombreHorario); 
                    horarioDto.setIdEstatus(estatus);               
                
                
                    new HorarioUsuarioDaoImpl(user.getConn()).update(horarioDto.createPk(), horarioDto);
                    
                    //Detalle horario 
                
                    for(int i= 1;i<=7;i++){  

                        String dia ="";
                        int tolerancia = 0;
                        int periodo = 0;
                        int diaDescanso = 0;
                        String horaEntrada = "";
                        String horaSalida = "";
                        String salidaComida = "";
                        String entradaComida = "";
                        int idDetalleHorario = 0;


                        if(i==1)
                            dia = "LUNES";
                        else if(i==2)
                            dia = "MARTES";
                        else if(i==3)
                            dia = "MIERCOLES";
                        else if(i==4)
                            dia = "JUEVES";
                        else if(i==5)
                            dia = "VIERNES";
                        else if(i==6)
                            dia = "SABADO";
                        else if(i==7)
                            dia = "DOMINGO";
                        
                        
                        try{
                            diaDescanso = Integer.parseInt(request.getParameter("descanso_"+dia));
                        }catch(NumberFormatException ex){}
                        try{
                            tolerancia = Integer.parseInt(request.getParameter("tolerancia_"+dia));
                        }catch(NumberFormatException ex){}
                        try{
                            periodo = Integer.parseInt(request.getParameter("periodo_"+dia));
                        }catch(NumberFormatException ex){}
                        try{
                            idDetalleHorario = Integer.parseInt(request.getParameter("idDetalleHorario_"+dia));
                        }catch(NumberFormatException ex){}                        

                        horaEntrada = request.getParameter("entrada_"+dia)!=null?new String(request.getParameter("entrada_"+dia).getBytes("ISO-8859-1"),"UTF-8"):"";   
                        horaSalida = request.getParameter("salida_"+dia)!=null?new String(request.getParameter("salida_"+dia).getBytes("ISO-8859-1"),"UTF-8"):"";   
                        salidaComida = request.getParameter("salidaComida_"+dia)!=null?new String(request.getParameter("salidaComida_"+dia).getBytes("ISO-8859-1"),"UTF-8"):"";   
                        entradaComida = request.getParameter("entradaComida_"+dia)!=null?new String(request.getParameter("entradaComida_"+dia).getBytes("ISO-8859-1"),"UTF-8"):"";   


                        try{

                             DateFormat sdf = new SimpleDateFormat("HH:mm:ss");

                             DetalleHorarioBO detalleHorarioBO = new DetalleHorarioBO(idDetalleHorario,user.getConn());
                             DetalleHorario detalleHorario = detalleHorarioBO.getDetalleHorario();
                             
                             
                             detalleHorario.setDia(dia);                            
                             detalleHorario.setTolerancia(tolerancia);                             
                             detalleHorario.setPeriodoComida(periodo);
                             detalleHorario.setDiaDescanso(diaDescanso);
                             try{
                                 detalleHorario.setHoraEntrada(sdf.parse(horaEntrada+":00"));
                                 detalleHorario.setHoraSalida(sdf.parse(horaSalida+":00"));
                                 detalleHorario.setComidaSalida(sdf.parse(salidaComida+":00"));
                                 detalleHorario.setComidaEntrada(sdf.parse(entradaComida+":00"));
                             }catch(Exception e){}
                             
                             
                             new DetalleHorarioDaoImpl(user.getConn()).update(detalleHorario.createPk(),detalleHorario);

                        }catch(Exception e){
                              System.out.println("Error al parsear hora");
                               throw new Exception("No se pudo parsear la hora al formato especificado");
                        }

                    }

                    //Fin detalle 
                    
                    
                    
                    

                    out.print("<!--EXITO-->Registro actualizado satisfactoriamente");
                }catch(Exception ex){
                    out.print("<!--ERROR-->No se pudo actualizar el registro. Informe del error al administrador del sistema: " + ex.toString());
                    ex.printStackTrace();
                }
                
            }else{
                out.print("<!--ERROR-->Acción no válida.");
            }
        }else{
            /*
            *  Nuevo
            */
            
            try {                
                
                /**
                 * Creamos el registro de Cliente
                 */
                HorarioUsuario horarioDto = new HorarioUsuario();
                HorarioUsuarioDaoImpl horarioDaoImpl = new HorarioUsuarioDaoImpl(user.getConn());
                
               
                horarioDto.setNombreHorario(nombreHorario);                                            
                horarioDto.setIdEmpresa(idEmpresa);
                horarioDto.setIdEstatus(estatus);

                 /**
                 * Realizamos el insert
                 */
                HorarioUsuarioPk horarioPk = horarioDaoImpl.insert(horarioDto);
                                
                
                
                //Detalle horario 
                
                for(int i= 1;i<=7;i++){  
        
                    String dia ="";
                    int tolerancia = 0;
                    int periodo = 0;
                    int diaDescanso = 0;
                    String horaEntrada = "";
                    String horaSalida = "";
                    String salidaComida = "";
                    String entradaComida = "";


                    if(i==1)
                        dia = "LUNES";
                    else if(i==2)
                        dia = "MARTES";
                    else if(i==3)
                        dia = "MIERCOLES";
                    else if(i==4)
                        dia = "JUEVES";
                    else if(i==5)
                        dia = "VIERNES";
                    else if(i==6)
                        dia = "SABADO";
                    else if(i==7)
                        dia = "DOMINGO";

                    try{
                        tolerancia = Integer.parseInt(request.getParameter("tolerancia_"+dia));
                    }catch(NumberFormatException ex){}
                    try{
                        periodo = Integer.parseInt(request.getParameter("periodo_"+dia));
                    }catch(NumberFormatException ex){}
                    try{
                        diaDescanso = Integer.parseInt(request.getParameter("descanso_"+dia));
                    }catch(NumberFormatException ex){}

                    horaEntrada = request.getParameter("entrada_"+dia)!=null?new String(request.getParameter("entrada_"+dia).getBytes("ISO-8859-1"),"UTF-8"):"";   
                    horaSalida = request.getParameter("salida_"+dia)!=null?new String(request.getParameter("salida_"+dia).getBytes("ISO-8859-1"),"UTF-8"):"";   
                    salidaComida = request.getParameter("salidaComida_"+dia)!=null?new String(request.getParameter("salidaComida_"+dia).getBytes("ISO-8859-1"),"UTF-8"):"";   
                    entradaComida = request.getParameter("entradaComida_"+dia)!=null?new String(request.getParameter("entradaComida_"+dia).getBytes("ISO-8859-1"),"UTF-8"):"";   

                    
                    try{
                                               
                         DateFormat sdf = new SimpleDateFormat("HH:mm:ss");
                        

                         DetalleHorario detalleHorario = new DetalleHorario();
                         detalleHorario.setIdHorario(horarioPk.getIdHorario());
                         detalleHorario.setDia(dia);                         
                         detalleHorario.setTolerancia(tolerancia);             
                         detalleHorario.setPeriodoComida(periodo);
                         detalleHorario.setDiaDescanso(diaDescanso);
                         try{
                             detalleHorario.setHoraEntrada(sdf.parse(horaEntrada+":00"));
                             detalleHorario.setHoraSalida(sdf.parse(horaSalida+":00"));
                             detalleHorario.setComidaSalida(sdf.parse(salidaComida+":00"));
                             detalleHorario.setComidaEntrada(sdf.parse(entradaComida+":00"));
                         }catch(Exception e){}
                         
                         
                         new DetalleHorarioDaoImpl(user.getConn()).insert(detalleHorario);
                        
                    }catch(Exception e){
                          System.out.println("Error al parsear hora");
                           throw new Exception("No se pudo parsear la hora al formato especificado");
                    }

                }
                
                //Fin detalle 
                
                              

                out.print("<!--EXITO-->Registro creado satisfactoriamente.<br/>");
            
            }catch(Exception e){
                e.printStackTrace();
                msgError += "Ocurrio un error al guardar el registro: " + e.toString() ;
            }
        }
    }else{
        out.print("<!--ERROR-->"+msgError);
    }

%>