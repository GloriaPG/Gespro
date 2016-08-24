<%-- 
    Document   : ajax
    Created on : 17/07/2016, 08:51:11 PM
    Author     : gloria
--%>

<%@page import="com.tsp.gespro.hibernate.dao.ClienteDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Cliente"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="org.hibernate.HibernateException"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    // Crear objeto que almacenará los datos a actulizar de el usuario.
    Cliente cliente= new Cliente();
    ClienteDAO clienteDAO = new ClienteDAO();
    // Si el id viene que el request parsearlo a integer.
    Integer id = request.getParameter("id") != null ? new Integer(request.getParameter("id")): 0;
    String message = "";
    String json = "";
    boolean status = false;
    cliente = clienteDAO.getById(id);
    json = "{\"ciudad\":\"" + cliente.getMunicipio() + "\", \"longitud\":\"" + cliente.getLongitud() + "\", \"latitud\":\"" + cliente.getLatitud() + "\"}";
    out.print(json);
           
%>