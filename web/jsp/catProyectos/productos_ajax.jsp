<%-- 
    Document   : productos_ajax
    Created on : 17/07/2016, 08:51:11 PM
    Author     : Fabian
--%>

<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="org.hibernate.HibernateException"%>
<%@page import="com.tsp.gespro.hibernate.dao.ProductoDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Producto"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    // Crear objeto que almacenará los datos a actulizar de el usuario.
    Producto obj= new Producto();
    ProductoDAO proyecto = new ProductoDAO();
    // Si el id viene que el request parsearlo a integer.
    Integer id = request.getParameter("id") != null ? new Integer(request.getParameter("id")): 0;
    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
    String message = "";
    String json = "";
    boolean status = false;
    
    try{
        // Setear los datos que vienen en el request a un objeto de el tipo
        // UsuarioMonitor para poder actulizarlos o crearlos.
        obj.setNombre(request.getParameter("nombreProducto") != null ? new String(request.getParameter("nombreProducto").getBytes("ISO-8859-1"), "UTF-8"): "");
        obj.setDescripcion(request.getParameter("descripcionProducto") != null ? new String(request.getParameter("descripcionProducto").getBytes("ISO-8859-1"), "UTF-8"): "");
        obj.setIdProyecto(request.getParameter("idProyectoProducto") != null ? Integer.parseInt(new String(request.getParameter("idProyectoProducto").getBytes("ISO-8859-1"), "UTF-8")):0);

    }catch(Exception ex){
        message = "<--ERROR1-->" + ex.getMessage();
    }
     
   
       try{ 
           if(obj.getNombre().equals("")){
               message = "<--ERROR-->" + "Simbolo y nombre son obligatorios.";
           }else{
                proyecto.guardar(obj);
                message = "<--EXITO-->" + "Se guardó correctamente.";
                status = true;
            }
       }catch(HibernateException e){
           message = "<--ERROR-->" + "Ocurrió un error al actualizar." + e.getMessage();
       }
       json = "{ status:" + (status ? "true":"false") +", message:'" + message + "'}";
       out.print(json);
           
%>