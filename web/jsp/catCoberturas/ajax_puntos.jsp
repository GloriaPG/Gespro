<%-- 
    Document   : ajax_puntos.jsp
    Created on : 14/08/2016, 06:19:39 PM
    Author     : gloria
--%>

<%@page import="org.hibernate.HibernateException"%>
<%@page import="com.tsp.gespro.hibernate.dao.PuntoDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Punto"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Crear objeto que almacenará los datos a actulizar de el usuario.
    Punto obj= new Punto();
    PuntoDAO punto = new PuntoDAO();
    // Si el id viene que el request parsearlo a integer.
    Integer id = request.getParameter("id") != null ? new Integer(request.getParameter("id")): 0;
    String message = "";
    String json = "";
    boolean status=true;
     try{
         
        // Setear los datos que vienen en el request a un objeto de el tipo
        // UsuarioMonitor para poder actulizarlos o crearlos.
        if(request.getParameter("id_cobertura") != null){
            int idCobertura=Integer.parseInt(request.getParameter("id_cobertura"));
            obj.setIdCobertura(idCobertura);
        }
        obj.setLugar(request.getParameter("lugar") != null ? new String(request.getParameter("lugar").getBytes("ISO-8859-1"),"UTF-8") : "" );
        obj.setLugar(request.getParameter("longitud") != null ? new String(request.getParameter("longitud").getBytes("ISO-8859-1"),"UTF-8") : "" );
        obj.setLugar(request.getParameter("latitud") != null ? new String(request.getParameter("latitud").getBytes("ISO-8859-1"),"UTF-8") : "" );
        obj.setLugar(request.getParameter("descripcion") != null ? new String(request.getParameter("descripcion").getBytes("ISO-8859-1"),"UTF-8") : "" );
    }catch(Exception ex){
        message = "<--ERROR1-->" + ex.getMessage();
        status=false;
    }
    
    try{ 
        if(id!=0){
            obj.setIdPunto(id);
            punto.eliminar(obj.getIdPunto());
            message = "<--EXITO-->" +"Se elimino correctamente.";
        }else{
            punto.guardar(obj);
            message = "<--EXITO-->" + "Se guardó correctamente.";
        }
       }catch(HibernateException e){
           message = "<--ERROR-->" + "Ocurrió un error al actualizar." + e.getMessage();
           status=false;
       }
       json = "{ status:" + (status ? "true":"false") +", message:'" + message + "'}";
       out.print(json);
%>