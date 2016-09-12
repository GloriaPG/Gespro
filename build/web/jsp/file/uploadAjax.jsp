<%-- 
    Document   : uploadAjax
    Created on : 12-oct-2011, 22:50:56
    Author     : ISC Cesar Martinez poseidon24@hotmail.com
--%>
<%@page import="com.tsp.gespro.util.StringManage"%>
<%@page import="com.tsp.gespro.util.DateManage"%>
<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.config.Configuration"%>
<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.List"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@page import="java.io.File"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="java.util.Enumeration"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    try{
        out.print("<font style='color: #00A;font-family: Helvetica;font-size: 6pt' >Conectando con el servidor..</font><br/>");
        
        String validate = request.getParameter("validate")!=null?request.getParameter("validate"):"";
        String div = request.getParameter("div")!=null?request.getParameter("div"):"";
        String idControl = request.getParameter("id_control")!=null?request.getParameter("id_control"):"";
                    
        int ourMaxMemorySize  = 10000000;
        int ourMaxRequestSize = 2000000000;
        boolean bLastChunk = false;
        int numChunk = 0;

        Configuration appConfig = new Configuration();

        String ourRepositoryDirectory =  appConfig.getApp_content_path();
        
        DiskFileItemFactory factory = new DiskFileItemFactory();

	factory.setSizeThreshold(ourMaxMemorySize);
	factory.setRepository(new File(ourRepositoryDirectory));

	ServletFileUpload upload = new ServletFileUpload(factory);

	upload.setSizeMax(ourMaxRequestSize);
        
        if (request.getContentType().startsWith("multipart/form-data")) {
            
            List /* FileItem */ items = upload.parseRequest(request);
            Iterator iter = items.iterator();
            FileItem fileItem;
	    File fout;
            
            while (iter.hasNext()) {
                fileItem = (FileItem) iter.next();
                if (!fileItem.isFormField()) {
                    
                    out.print("<font style='color: #00A;font-family: Helvetica;font-size: 8pt' >Iniciando carga..</font><br/>");
                    
                    boolean archivoValido = false;
                    if(!validate.trim().equals("") && !validate.trim().equals("any")){
                        String extName = fileItem.getName().split("\\.")[1];
                        String[] valExt = validate.split(",");
                        for(int i = 0; i < valExt.length; i ++){
                            if(extName.equalsIgnoreCase(valExt[i])){
                                archivoValido = true;
                                break;
                            }
                        }
                    }else
                        archivoValido = true;
                    
                    if(archivoValido){                        
                        String uploadedFilename = new String(fileItem.getName().getBytes("ISO-8859-1"),"UTF-8") + ( numChunk>0 ? ".part"+numChunk : "") ;
                        System.out.println("uploadedFilename: =======" + uploadedFilename);
                        
                        Empresa empresaDto = new EmpresaBO(user.getUser().getIdEmpresa(),user.getConn()).getEmpresa();
                        
                        if (idControl.equals("archivo_adjunto")){
                            ourRepositoryDirectory += empresaDto.getRfc() + "/ArchivosSAR/";
                        }
                        
                        //Formamos nombre de archivo unico: nombreArchivoOriginal + _ + fechahora +. extensionOriginal;
                        String extensionArchivo = org.apache.commons.io.FilenameUtils.getExtension(uploadedFilename);
                        String nombreArchivoFinal = org.apache.commons.io.FilenameUtils.removeExtension(uploadedFilename) 
                                                    + "_" + DateManage.getDateHourString() 
                                                    + "." + extensionArchivo ; 
                        //Eliminamos espacios en blanco, tabuladores y saltos de linea
                        nombreArchivoFinal = StringManage.getValidString(nombreArchivoFinal).replaceAll("\\s","");
                        //Reemplazamos consonantes con acentos y caracteres especiales
                        nombreArchivoFinal = StringManage.removeEspecialChar(nombreArchivoFinal);
                        System.out.println("nombreArchivoFinal: =======" + nombreArchivoFinal);

                        File path = new File(ourRepositoryDirectory);
                        path.mkdirs();
                        fout = new File(ourRepositoryDirectory + (new File(nombreArchivoFinal)).getName());
                        fileItem.write(fout);

                        out.print("<font style='color: #00A;font-family: Helvetica;font-size: 8pt' >Archivo '"+nombreArchivoFinal +"' cargado satisfactoriamente</font>");
                        
                        if (idControl.equals("archivo_adjunto")){
                            out.print("<script>parent.parent.recuperaId('"+nombreArchivoFinal.replaceAll("'", " ") +"','"+nombreArchivoFinal+"','"+div+"','"+idControl+"');</script>");
                        }
                    }else
                        out.print("<font style='color: red;font-family: Helvetica;font-size: 8pt' >El archivo '"+new String(fileItem.getName().getBytes("ISO-8859-1"),"UTF-8") +"' es inválido, favor de verificar</font>");
                }
                
            }
        }
        
    }catch(Exception e){out.print(e.toString());}
%>