<%-- 
    Document   : showImageConcepto
    Created on : 29/10/2015, 12:15:06 PM
    Author     : leonardo
--%>

<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.config.Configuration"%>
<%@page import="java.io.BufferedInputStream"%>
<%@page import="java.io.BufferedOutputStream"%>
<%@page import="java.io.IOException"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.File"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    //ServletOutputStream strm = response.getOutputStream();
    final int DEFAULT_BUFFER_SIZE = 10240;
    try{
         String p = request.getParameter("p");
         String a = request.getParameter("a");
         String i = request.getParameter("i"); 
         
         Configuration appConfig = new Configuration();
         
         String ubicacionImagenesProspectos = appConfig.getApp_content_path() +"\\proyectos\\"+p+"\\actividades\\"+a+"\\"+i;
         
         String archivoImagen= ubicacionImagenesProspectos;
         File fileImagen = new File(archivoImagen);
         /*
         FileInputStream fis = new FileInputStream(new File(archivoImagen));
         BufferedInputStream bis = new BufferedInputStream(fis);             
         response.setContentType("image/jpeg");
         BufferedOutputStream output = new BufferedOutputStream(response.getOutputStream());
         for (int data; (data = bis.read()) > -1;) {
           output.write(data);
         } */

         if (fileImagen.exists()){
            response.reset();
            response.setBufferSize(DEFAULT_BUFFER_SIZE);
            response.setContentType("image/jpeg");
            response.setHeader("Content-Length", String.valueOf(fileImagen.length()));
            response.setHeader("Content-Disposition", "inline; filename=\"" + fileImagen.getName() + "\"");
            
            
            // Prepare streams.
            BufferedInputStream input = null;
            BufferedOutputStream output = null;

            try {
                // Open streams.
                input = new BufferedInputStream(new FileInputStream(fileImagen), DEFAULT_BUFFER_SIZE);
                output = new BufferedOutputStream(response.getOutputStream(), DEFAULT_BUFFER_SIZE);

                // Write file contents to response.
                byte[] buffer = new byte[DEFAULT_BUFFER_SIZE];
                int length;
                while ((length = input.read(buffer)) > 0) {
                    output.write(buffer, 0, length);
                }
            } finally {
                // Gently close streams.
                if (input!=null) 
                    input.close();
                if (output!=null)
                    output.close();
            }
        }else{
             //
        }
                                    
    }
    catch(Exception e){
        e.printStackTrace();
    }finally{
        // close the streams
    }
%>