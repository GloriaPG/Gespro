<%-- 
    Document   : catEmpleado_Relacion_Cliente_ajax
    Created on : 10/03/2016, 01:39:34 PM
    Author     : leonardo
--%>

<%@page import="com.tsp.gespro.jdbc.DatosUsuarioDaoImpl"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.jdbc.UsuariosDaoImpl"%>
<%@page import="com.tsp.gespro.util.StringManage"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="com.tsp.gespro.bo.RelacionClienteVendedorBO"%>
<%@page import="com.tsp.gespro.mail.TspMailBO"%>
<%@page import="com.tsp.gespro.util.Encrypter"%>
<%@page import="com.tsp.gespro.jdbc.LdapDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Ldap"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.jdbc.RelacionClienteVendedorDaoImpl"%>
<%@page import="com.tsp.gespro.dto.RelacionClienteVendedor"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    String mode = "";
    
    int idEmpresa = user.getUser().getIdEmpresa();
    
    /*
    * Parámetros
    */
    int idUsuarioEmpleado = -1;
    int idCliente = -1;
    
    /*
    * Recepción de valores
    */
    mode = request.getParameter("mode")!=null?request.getParameter("mode"):"";
    try{
        idUsuarioEmpleado = Integer.parseInt(request.getParameter("idUsuarioEmpleado"));
    }catch(NumberFormatException ex){}
    
    try{
        idCliente = Integer.parseInt(request.getParameter("idCliente"));
    }catch(NumberFormatException ex){}   
    
    /*
    * Validaciones del servidor
    */
    String msgError = "";
    GenericValidator gc = new GenericValidator();    
    if(idUsuarioEmpleado <= 0){
        msgError += "<ul>El dato 'Empleado' es requerido";
    }  
    if(idCliente <= 0 && !mode.equals("asignacionClientesMasivos")){
        msgError += "<ul>El dato 'Cliente' es requerido";
    }
    /*
    if(idVendedor<=0)
        msgError += "<ul>El dato 'Vendedor' es requerido";
 * */

    if(msgError.equals("")){
        if( (idCliente > 0 && idUsuarioEmpleado > 0) || mode.equals("asignacionClientesMasivos")){
            if (mode.equals("eliminar")){
            /*
            * Editar
            */
                RelacionClienteVendedorBO relacionClienteVendedorBO = new RelacionClienteVendedorBO(user.getConn());
                //RelacionClienteVendedor relacionClienteVendedorDto = relacionClienteVendedorBO.getRelacionClienteVendedor();
                               
                try{
                    relacionClienteVendedorBO.delete(idCliente, idUsuarioEmpleado);
                    out.print("<!--EXITO-->Registro eliminado satisfactoriamente");
                }catch(Exception ex){
                    out.print("<!--ERROR-->No se pudo eliminar el registro. Informe del error al administrador del sistema: " + ex.toString());
                    ex.printStackTrace();
                }
                
            }else if(mode.equals("relacion")){
                
                int asignacionPrevia = 0;
                try{
                    asignacionPrevia = Integer.parseInt(request.getParameter("asignacionPrevia"));
                }catch(NumberFormatException ex){}
                        
                RelacionClienteVendedor clienteVendedor = null;
                RelacionClienteVendedorBO relacionClienteVendedorBO = new RelacionClienteVendedorBO(user.getConn());
                try{
                    clienteVendedor = relacionClienteVendedorBO.findRelacionClienteVendedors(idCliente, idUsuarioEmpleado, 0, 0, "")[0];
                }catch(Exception e){}
                if(clienteVendedor != null){ //es de que ya el cliente ha sido asignado previamente al empleado
                    out.print("<!--ERROR-->El Cliente ya se encuentra asignado al empleado.");
                }else{
                    //buscamos si el cliente ya esta asignado a algun empleado para preguntar su asignamos o reasignamos.
                    RelacionClienteVendedor[] relacionesClientesVendedor = relacionClienteVendedorBO.findRelacionClienteVendedors(idCliente, -1, 0, 0, "");                    
                    if(relacionesClientesVendedor != null && relacionesClientesVendedor.length > 0 && asignacionPrevia == 0){//si se encontro con algun otro usuario relacionado el cliente, se pregunta si se desea conservar los usuarios que lo tienen asignado o si se reasigna al nuevo cliente seleccionado
                        String nombreEmpleadosAsignados = "";
                        UsuariosDaoImpl usuariosDaoImpl = new UsuariosDaoImpl(user.getConn());
                        DatosUsuarioDaoImpl datosUsuarioDaoImpl = new DatosUsuarioDaoImpl(user.getConn());
                        Usuarios usuarios = null;
                        DatosUsuario datosUsuario = null;
                        for(RelacionClienteVendedor relaciones : relacionesClientesVendedor){
                            usuarios = null;
                            datosUsuario = null;
                            try{
                                usuarios = usuariosDaoImpl.findByPrimaryKey(relaciones.getIdUsuario());
                                datosUsuario = datosUsuarioDaoImpl.findByPrimaryKey(usuarios.getIdDatosUsuario());
                                nombreEmpleadosAsignados += "<br/>" + (datosUsuario!=null?(datosUsuario.getNombre() + " " + datosUsuario.getApellidoPat() + " " + datosUsuario.getApellidoMat()):"");
                            }catch(Exception e){}                           
                       }
                        out.print("<!--CONFIRMACION-->El Cliente ya se encuentra asignado a otro(s) empleado(s)." + nombreEmpleadosAsignados);
                    }else{
                        if(asignacionPrevia == 2){//no conservar la asignacion previa del cliente, entonces eliminamos la relación
                            for(RelacionClienteVendedor relaciones : relacionesClientesVendedor){
                                try{
                                    relacionClienteVendedorBO.deleteCliente(relaciones.getIdCliente());
                                }catch(Exception e){}
                            }
                        }
                        clienteVendedor = new RelacionClienteVendedor();
                        clienteVendedor.setIdCliente(idCliente);
                        clienteVendedor.setIdUsuario(idUsuarioEmpleado);
                        clienteVendedor.setFechaAsignacion(new Date());
                        try{
                             new RelacionClienteVendedorDaoImpl(user.getConn()).insert(clienteVendedor);
                             out.print("<!--EXITO-->Cliente asignado satisfactoriamente");
                        }catch(Exception ex){
                             out.print("<!--ERROR-->No se pudo asignar el cliente. Informe del error al administrador del sistema: " + ex.toString());
                             ex.printStackTrace();
                        }
                    }
                }
                
            }else if(mode.equals("asignacionClientesMasivos")){
                //variable para masivos
                int conservarAsignacion = 0;
                try{ conservarAsignacion = Integer.parseInt(request.getParameter("conservarAsignacion")); }catch(NumberFormatException e){}
                
                String idsClientes = request.getParameter("idsClientes")!=null?new String(request.getParameter("idsClientes").getBytes("ISO-8859-1"),"UTF-8"):"";
                System.out.println(" ---- id clientes: " +idsClientes);
                List<RelacionClienteVendedor> relacionClienteVendedorsDto = new ArrayList<RelacionClienteVendedor>();
                
                try{
                    if (StringManage.getValidString(idsClientes).length()>0){
                        String[] arrayData = new String[0];
                        try{
                            arrayData = idsClientes.split(",");
                        }catch(Exception ex){}
                        if (arrayData.length>0){
                            RelacionClienteVendedorBO relacionClienteVendedorBO = new RelacionClienteVendedorBO(user.getConn());
                            for (String strIdCliente : arrayData){
                                try{
                                    if (StringManage.getValidString(strIdCliente).length()>0){
                                        int idClienteInt = Integer.parseInt(strIdCliente);
                                        //RelacionClienteVendedor clienteVendedor = new RelacionClienteVendedor();
                                        //lienteVendedor.setIdCliente(idClienteInt);
                                        //clienteVendedor.setIdUsuario(idUsuarioEmpleado);
                                        
                                        if(conservarAsignacion ==  2){/////no conservar la asignacion previa del cliente 
                                            try{/////
                                                relacionClienteVendedorBO.deleteCliente(idClienteInt);/////
                                            }catch(Exception e){}/////                                        
                                        }/////

                                        RelacionClienteVendedor clienteVendedor = null;                                        
                                        try{
                                            clienteVendedor = relacionClienteVendedorBO.findRelacionClienteVendedors(idClienteInt, idUsuarioEmpleado, 0, 0, "")[0];
                                        }catch(Exception e){}
                                        if(clienteVendedor == null){
                                           clienteVendedor = new RelacionClienteVendedor();
                                           clienteVendedor.setIdCliente(idClienteInt);
                                           clienteVendedor.setIdUsuario(idUsuarioEmpleado);
                                           clienteVendedor.setFechaAsignacion(new Date());
                                           try{
                                                new RelacionClienteVendedorDaoImpl(user.getConn()).insert(clienteVendedor);                                            
                                           }catch(Exception ex){ex.printStackTrace();}
                                        }

                                        relacionClienteVendedorsDto.add(clienteVendedor);
                                    }
                                 }catch(Exception ex){ ex.printStackTrace(); }   
                            }
                        }
                    }
                    out.print("<!--EXITO-->Clientes asignados satisfactoriamente");
                }catch(Exception e){
                    out.print("<!--ERROR-->No se pudieron asignar los clientes. Informe del error al administrador del sistema: " + e.toString());
                }                
            }else{
                out.print("<!--ERROR-->Acción no válida.");
            }
        }else{
            out.print("<!--ERROR-->No se selecciono un cliente y/o un empleado valido.");
        }
    }else{
        out.print("<!--ERROR-->"+msgError);
    }

%>