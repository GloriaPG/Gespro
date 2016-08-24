<%-- 
    Document   : ajax
    Created on : 17/07/2016, 08:51:11 PM
    Author     : gloria
--%>

<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.Services.Allservices"%>
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="org.hibernate.HibernateException"%>
<%@page import="com.tsp.gespro.hibernate.dao.CoberturaDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Cobertura"%>
<%@page import="com.tsp.gespro.hibernate.dao.PuntoDAO"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Punto"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    // Crear objeto que almacenará los datos a actulizar de el usuario.
    Cobertura cobertura = new Cobertura();
    CoberturaDAO coberturaDAO = new CoberturaDAO();
    EmpresaBO empresaBO = new EmpresaBO(user.getConn());
    int idEmpresa = empresaBO.getEmpresaMatriz(user.getUser().getIdEmpresa()).getIdEmpresa();
    // Si el id viene que el request parsearlo a integer.
    Integer id = request.getParameter("id") != null ? new Integer(request.getParameter("id")) : 0;
    String accion = request.getParameter("accion");
    String message = "";
    String json = "";
    boolean status = false;

    if (accion.equalsIgnoreCase("guardar")) {
        try {
            // Setear los datos que vienen en el request a un objeto de el tipo
            // UsuarioMonitor para poder actulizarlos o crearlos.
            cobertura.setNombre(request.getParameter("nombre") != null ? new String(request.getParameter("nombre").getBytes("ISO-8859-1"), "UTF-8") : "");

        } catch (Exception ex) {
            message = "<--ERROR1-->" + ex.getMessage();
        }

        Integer idCobertura = 0;
        try {
            if (cobertura.getNombre().equals("")) {
                message = "<--ERROR-->" + "Simbolo y nombre son obligatorios.";
            } else {
                if (id != 0) {
                    idCobertura = id;
                    cobertura.setIdCobertura(id);
                    cobertura.setActivo(1);
                    cobertura.setIdEmpresa(idEmpresa);
                    coberturaDAO.actualizar(cobertura);
                    message = "<--EXITO-->" + "La actualización fue exitosa.";
                    status = true;
                } else {
                    cobertura.setActivo(1);
                    cobertura.setIdEmpresa(idEmpresa);
                    idCobertura = coberturaDAO.guardar(cobertura);
                    message = "<--EXITO-->" + "Se guardó correctamente.";
                    status = true;
                }
            }
        } catch (HibernateException e) {
            message = "<--ERROR-->" + "Ocurrió un error al actualizar." + e.getMessage();
        }

        if (idCobertura != 0) {
            String[] lugar = request.getParameterValues("punto_nombre[]");
            String[] longitud = request.getParameterValues("punto_longitud[]");
            String[] latitud = request.getParameterValues("punto_latitud[]");
            String[] tipo = request.getParameterValues("punto_tipo[]");
            Punto punto = new Punto();
            PuntoDAO puntoDao = new PuntoDAO();
            if (id != 0) {
                idCobertura = id;
            }
            //Eliminar los puntos anteriores de esta cobertura
            List<Punto> puntoList = new Allservices().queryPuntoDAO("where id_cobertura = " + idCobertura);
            for (Punto puntoEliminar : puntoList) {
                puntoDao.eliminar(puntoEliminar.getIdPunto());
            }
            // Guardamos los nuevos puntos
            if (lugar != null) {
                for (int i = 0; i < lugar.length; i++) {
                    punto.setIdCobertura(idCobertura);
                    punto.setLugar(lugar[i].toString());
                    punto.setLatitud(Double.parseDouble(latitud[i]));
                    punto.setLongitud(Double.parseDouble(longitud[i]));
                    punto.setDescripcion("");
                    punto.setTipo(Integer.parseInt(tipo[i]));// cliente = 1, ciudad = 2, lugar = 3
                    puntoDao.guardar(punto);
                }
            }
        }
    } else if (accion.equalsIgnoreCase("eliminar")) {
        if (id != 0) {
            cobertura = coberturaDAO.getById(id);
            cobertura.setActivo(0);
            coberturaDAO.actualizar(cobertura);
            message = "<--EXITO-->" + "Se eliminó correctamente.";
            status = true;
        } else {
            message = "<--ERROR-->" + "Ocurrió un error al eliminar.";
            status = true;
        }
    }

    json = "{ status:" + (status ? "true" : "false") + ", message:'" + message + "'}";
    out.print(json);

%>