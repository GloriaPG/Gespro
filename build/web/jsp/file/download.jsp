<%-- 
    Document   : download
    Created on : 24/09/2011, 01:01:11 PM
    Author     : ISC Cesar Martinez poseidon24@hotmail.com
--%>

<%@page import="com.tsp.gespro.bo.AccionBitacoraBO"%>
<%@page import="com.tsp.gespro.dto.AccionBitacora"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.File"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>

<%
    int idArchivo = 0;
    String rutaNombreArchivo = "";
    /*String strFormato;
    String strNombre;
    String formatoArchivo;
*/
    if (false && (user==null || user.getUser()==null)) {
        out.print("No tiene privilegios para consultar el archivo seleccionado, o se ha terminado la sesión de su usuario, vuelva a ingresar al sistema");
    }else {
        try{
             idArchivo=Integer.parseInt(request.getParameter("id_file"));
        }catch(Exception e){
        }
        rutaNombreArchivo = request.getParameter("ruta_archivo")!=null?java.net.URLDecoder.decode(request.getParameter("ruta_archivo"), "UTF-8"):"";
        
        /**
        * Recuperar usando clase manejadora
        */
        /*TspFile archivo = new TspFileDaoImpl(user.getConn()).findByPrimaryKey(idArchivo);
        if (archivo==null) {
            out.print("No se encontró el archivo seleccionado.");
        }else{*/
            File fileDownload;
            fileDownload = new File(rutaNombreArchivo);
            
            String mimetype = "";//archivo.getContentTypeFile();
            if ((mimetype==null ||  mimetype.equals("")) && fileDownload.getName()!=null && fileDownload.getName().toLowerCase().trim().endsWith(".xml")) {
                mimetype = "text/xml";
            }

            if (fileDownload.getName()!=null && fileDownload.getName().toLowerCase().trim().endsWith(".xml")) {
                response.setContentType("text/xml");
                response.setCharacterEncoding("UTF-8");
            }
            if (fileDownload.getName()!=null && fileDownload.getName().toLowerCase().trim().endsWith(".pdf")) {
                response.setContentType("application/pdf");
            }
            if (fileDownload.getName()!=null && (fileDownload.getName().toLowerCase().trim().endsWith(".jpe")
                    || fileDownload.getName().toLowerCase().trim().endsWith(".jpg")
                    || fileDownload.getName().toLowerCase().trim().endsWith(".jpeg"))
                    ) {
                response.setContentType("image/jpeg");
            }
            else {
                response.setContentType( (mimetype != null) ? mimetype : "application/octet-stream" );
            }

            String fileName = fileDownload.getName();
            if (fileName.indexOf("/")>=0) {
                fileName = fileName.substring(fileName.lastIndexOf("/")+1);
            }

            response.setHeader("Content-Disposition","attachment; filename=\""+ fileName + "\"");
            //byte[] bytes = new byte[(int)fileDownload.length()];

            byte[] bytes = new byte[(int)fileDownload.length()];
            FileInputStream fis = new FileInputStream(fileDownload);
            fis.read(bytes);
            out.clear();
            out.clearBuffer();
            out.close();

            if(bytes.length>0){

                AccionBitacoraBO accionBitacoraBO = new AccionBitacoraBO(user.getConn());
                accionBitacoraBO.insertAccionDescarga(user.getUser().getIdUsuarios(), "Descarga del archivo: "+fileName);

                ServletOutputStream output = response.getOutputStream();
                response.setContentLength(bytes.length);

                for( int i = 0; i < bytes.length; i++ ) {

                    output.write( bytes[i] );

                }
                output.flush();
            }

        /*
        }
        */

    }
%>