<%-- 
    Document   : catClientes_form.jsp
    Created on : 26-oct-2012, 12:13:49
    Author     : ISCesarMartinez poseidon24@hotmail.com
--%>

<%@page import="com.tsp.gespro.hibernate.pojo.ConceptoRegistroFotografico"%>
<%@page import="java.util.List"%>
<%@page import="com.tsp.gespro.hibernate.dao.ConceptoRegistroFotograficoDAO"%>
<%@page import="java.util.zip.ZipEntry"%>
<%@page import="java.util.zip.ZipOutputStream"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="com.tsp.gespro.config.Configuration"%>
<%@page import="java.io.File"%>
<%@page import="com.tsp.gespro.util.ZipUtil"%>
<%@page import="com.tsp.gespro.jdbc.ProspectoDaoImpl"%>
<%@page import="com.tsp.gespro.bo.ProspectoBO"%>
<%@page import="com.tsp.gespro.dto.Prospecto"%>
<%@page import="com.tsp.gespro.jdbc.RelacionClienteVendedorDaoImpl"%>
<%@page import="com.tsp.gespro.dto.RelacionClienteVendedor"%>
<%@page import="com.tsp.gespro.jdbc.EmpresaPermisoAplicacionDaoImpl"%>
<%@page import="com.tsp.gespro.dto.EmpresaPermisoAplicacion"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.dto.ClienteCategoria"%>
<%@page import="com.tsp.gespro.bo.ClienteCategoriaBO"%>
<%@page import="com.tsp.gespro.util.StringManage"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.tsp.gespro.bo.RolesBO"%>
<%@page import="com.tsp.gespro.bo.UsuariosBO"%>
<%@page import="com.tsp.gespro.bo.UsuarioBO"%>
<%@page import="com.tsp.gespro.bo.PasswordBO"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page import="com.tsp.gespro.jdbc.ClienteDaoImpl"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%

//Verifica si el cliente tiene acceso a este topico
    if (user == null || !user.permissionToTopicByURL(request.getRequestURI().replace(request.getContextPath(), ""))) {
        response.sendRedirect("../../jsp/inicio/login.jsp?action=loginRequired&urlSource=" + request.getRequestURI() + "?" + request.getQueryString());
        response.flushBuffer();
    } else {
        response.setContentType("application/octet-stream");
        response.setHeader("Content-Disposition", "attachment;filename=imagenes.zip");

        // Obtenermos el cliente y obtenermos la empreza matriz
        int idCliente = 0;
        Cliente clienteDto = null;
        Configuration configuration = null;
        Empresa empresaDto = null;
        String rfcEmpresaMatriz = "";
        try {
            idCliente = Integer.parseInt(request.getParameter("idCliente"));
            clienteDto = new ClienteBO(idCliente, user.getConn()).getCliente();
            empresaDto = new EmpresaBO(user.getConn()).getEmpresaMatriz(clienteDto.getIdEmpresa());
            rfcEmpresaMatriz = empresaDto.getRfc();
            configuration = new Configuration();
        } catch (NumberFormatException e) {
            System.out.println(e);
        }

        // Crear directorio temporar donde se guardara el archivo zip
        String os = System.getProperty("os.name").toLowerCase();
        String filename = "";
        File tempDir = null;
        String pathImages = null;
        if (os.indexOf("win") >= 0) {
            tempDir = new File(configuration.getApp_content_path() + "tmp\\");
            filename = tempDir.getPath() + "\\imagenes" + System.currentTimeMillis() + ".zip";
            pathImages = configuration.getApp_content_path() + "\\" + rfcEmpresaMatriz + "\\ImagenConcepto\\pop\\";
        } else {
            tempDir = new File(configuration.getApp_content_path() + "tmp/");
            filename = tempDir.getAbsolutePath() + "imagenes" + System.currentTimeMillis() + ".zip";
            pathImages = configuration.getApp_content_path() + "/" + rfcEmpresaMatriz + "/ImagenConcepto/pop/";
        }
        if (!tempDir.exists()) {
            tempDir.mkdirs();
        }

       
        // Archivos a comprimir
        ConceptoRegistroFotograficoDAO dao=new ConceptoRegistroFotograficoDAO();
        List<ConceptoRegistroFotografico> filesToZip=dao.listaByCliente(idCliente);
        // Comprimir el archivo
        FileInputStream fis = null;
        FileOutputStream fos = new FileOutputStream(filename);
        ZipOutputStream zipos = new ZipOutputStream(fos);
        byte[] buffer = new byte[1024];
        // comprimir ficheros
        for (ConceptoRegistroFotografico fileToZip : filesToZip) {
            if(fileToZip.getNombreFoto()!= null && fileToZip.getNombreFoto() != ""){
                File file=new File(pathImages + fileToZip.getNombreFoto());
                if(file.exists() && !file.isDirectory()){
                    String path=pathImages + fileToZip.getNombreFoto();
                    fis = new FileInputStream(path);
                    ZipEntry zipEntry = new ZipEntry(fileToZip.getNombreFoto());
                    zipos.putNextEntry(zipEntry);
                    int len = 0;
                    // zippear
                    while ((len = fis.read(buffer, 0, 1024)) != -1) {
                        zipos.write(buffer, 0, len);
                    }
                } 
            }
        }
        // volcar la memoria al disco
        zipos.flush();
        // cerramos los files
        zipos.close();
        if(fis!=null){
            fis.close();
        }
        fos.close();

        // Descargar el archivo
        File file = new File(filename);
        FileInputStream fileIn = new FileInputStream(file);
        ServletOutputStream servletOutputStream = response.getOutputStream();

        byte[] outputByte = new byte[4096];
        //copy binary contect to output stream
        while (fileIn.read(outputByte, 0, 4096) != -1) {
            servletOutputStream.write(outputByte, 0, 4096);
        }
        fileIn.close();
        servletOutputStream.flush();
        servletOutputStream.close();
        file.delete();
    }
%>