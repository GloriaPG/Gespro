<%-- 
    Document   : Mapa_ajax
    Created on : 2/07/2014, 12:57:39 PM
    Author     : leonardo
--%>

<%@page import="com.tsp.gespro.jdbc.ClienteDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<!DOCTYPE html>
<%
System.out.println("------------------- 1");
    String mode = "";
    mode = request.getParameter("mode")!=null?request.getParameter("mode"):"";
    
    
    if(mode.equals("1")){ //si se van a editar las coordenadas de cliente
        int idCliente = -1;
        /*
        * Parámetros
        */
        String longitudActualizada = "0";
        String latitudActualizada = "0";
        /*
        * Recepción de valores
        */
        try{
            idCliente = Integer.parseInt(request.getParameter("idActualizar"));
        }catch(NumberFormatException ex){}
        try{
            latitudActualizada = request.getParameter("latitudActualizada")!=null?request.getParameter("latitudActualizada"):"0";
        }catch(Exception e){}
        try{                             
            longitudActualizada = request.getParameter("longitudActualizada")!=null?request.getParameter("longitudActualizada"):"0";
        }catch(Exception e){}
        /*
        * Actualizamos coordenadas
        */
            ClienteBO clienteBO = new ClienteBO(idCliente,user.getConn());
            Cliente clienteDto = clienteBO.getCliente();
            clienteDto.setLatitud(Double.parseDouble(latitudActualizada));
            clienteDto.setLongitud(Double.parseDouble(longitudActualizada));
            try{
                new ClienteDaoImpl(user.getConn()).update(clienteDto.createPk(), clienteDto);
                out.print("<!--EXITO-->Coordenadas actualizadas satisfactoriamente");
            }catch(Exception ex){
                out.print("<!--ERROR-->No se pudieron actualizar las coordenadas. Informe del error al administrador del sistema: " + ex.toString());
                ex.printStackTrace();
            }
    }else if(mode.equals("2")){ //si se van a editar las coordenadas de prospecto
        int idProspecto = -1;
        /*
        * Parámetros
        */
        double longitudActualizada = 0;
        double latitudActualizada = 0;
        /*
        * Recepción de valores
        */
        try{
            idProspecto = Integer.parseInt(request.getParameter("idActualizar"));
        }catch(NumberFormatException ex){}
        try{
            latitudActualizada = Double.parseDouble(request.getParameter("latitudActualizada"));
        }catch(Exception e){}
        try{                             
            longitudActualizada = Double.parseDouble(request.getParameter("longitudActualizada"));
        }catch(Exception e){}
        /*
        * Actualizamos coordenadas
        */
        /*    SGProspectoBO prospectoBO = new SGProspectoBO(idProspecto,user.getConn());
            SgfensProspecto prospectoDto = prospectoBO.getSgfensProspecto();
            prospectoDto.setLatitud(latitudActualizada);
            prospectoDto.setLongitud(longitudActualizada);
            try{
                new SgfensProspectoDaoImpl(user.getConn()).update(prospectoDto.createPk(), prospectoDto);
                out.print("<!--EXITO-->Coordenadas actualizadas satisfactoriamente");
            }catch(Exception ex){
                out.print("<!--ERROR-->No se pudieron actualizar las coordenadas. Informe del error al administrador del sistema: " + ex.toString());
                ex.printStackTrace();
            }*/
    }else if(mode.equals("3")){// actualizar coordenadas de proveedor
        int idSgfensProveedor = -1;
        try{
            idSgfensProveedor = Integer.parseInt(request.getParameter("idActualizar"));
        }catch(NumberFormatException ex){}
        /*
        * Parámetros
        */
        String longitudActualizada = "0";
        String latitudActualizada = "0";
        /*
        * Recepción de valores
        */
        try{
            latitudActualizada = request.getParameter("latitudActualizada")!=null?request.getParameter("latitudActualizada"):"0";
        }catch(Exception e){}
        try{                             
            longitudActualizada = request.getParameter("longitudActualizada")!=null?request.getParameter("longitudActualizada"):"0";
        }catch(Exception e){}
        /*
        * Actualizamos coordenadas
        */
        /*    SGProveedorBO proveedorBO = new SGProveedorBO(idSgfensProveedor,user.getConn());
            SgfensProveedor proveedorDto = proveedorBO.getSgfensProveedor();
            proveedorDto.setLatitud(latitudActualizada);
            proveedorDto.setLongitud(longitudActualizada);
            try{
                new SgfensProveedorDaoImpl(user.getConn()).update(proveedorDto.createPk(), proveedorDto);
                out.print("<!--EXITO-->Coordenadas actualizadas satisfactoriamente");
            }catch(Exception ex){
                out.print("<!--ERROR-->No se pudieron actualizar las coordenadas. Informe del error al administrador del sistema: " + ex.toString());
                ex.printStackTrace();
            }*/
    }else{
        System.out.println("___ NO HAY MODO SELECCIONADO");
    }

%>