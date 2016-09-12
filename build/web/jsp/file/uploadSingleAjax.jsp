<%-- 
    Document   : uploadSingleAjax
    Created on : 23-jul-2012, 18:30:59
    Author     : ISCesarMartinez, ISC Cesar Martinez poseidon24@hotmail.com
--%>

<%@page import="java.util.Date"%>
<%@page import="com.tsp.gespro.dto.Empresa"%>
<%@page import="com.tsp.gespro.bo.EmpresaBO"%>
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
        out.flush();
        
        //Parametro , String separado por comas con las extensiones válidas de archivo, "any" en caso de aceptar cualquiera
        String validate = request.getParameter("validate")!=null?request.getParameter("validate"):"";
        String div = request.getParameter("div")!=null?request.getParameter("div"):"";
        String returnURL = request.getParameter("returnURL")!=null?request.getParameter("returnURL"):"";
        String reloadIFrameParent = request.getParameter("reloadIFrameParent")!=null?request.getParameter("reloadIFrameParent"):"false";
        
        //Para archivos adjuntos de certificados CSD
        int isCertificadoAdjunto = -1;
        try{
            isCertificadoAdjunto = Integer.parseInt(request.getParameter("isCertificadoAdjunto"));
        }catch(Exception ex){}
        
        int isKeyAdjunto = -1;
        try{
            isKeyAdjunto = Integer.parseInt(request.getParameter("isKeyAdjunto"));
        }catch(Exception ex){}
        
        int isImagenPersonalAdjunto = -1;
        try{
            isImagenPersonalAdjunto = Integer.parseInt(request.getParameter("isImagenPersonalAdjunto"));
        }catch(Exception ex){}
        int isXMLAdjunto = -1;
        try{
            isXMLAdjunto = Integer.parseInt(request.getParameter("isXMLAdjunto"));
        }catch(Exception ex){}        
        int isCbbAdjunto = -1;
        try{
            isCbbAdjunto = Integer.parseInt(request.getParameter("isCbbAdjunto"));
        }catch(Exception ex){}
        int isImagenConceptoAdjunto = -1;
        try{
            isImagenConceptoAdjunto = Integer.parseInt(request.getParameter("isImagenConceptoAdjunto"));
        }catch(Exception ex){}
        int isImagenProveedorAdjunto = -1;
        try{
            isImagenProveedorAdjunto = Integer.parseInt(request.getParameter("isImagenProveedorAdjunto"));
        }catch(Exception ex){}
        int isCargaXls = -1;
        try{
            isCargaXls = Integer.parseInt(request.getParameter("isCargaXls"));
        }catch(Exception ex){}
        
                    
        int ourMaxMemorySize  = 10000000;
        int ourMaxRequestSize = 2000000000;
        boolean bLastChunk = false;
        int numChunk = 0;

        Configuration appConfig = new Configuration();
        
        String ourRepositoryDirectory = appConfig.getApp_content_path();
        
        DiskFileItemFactory factory = new DiskFileItemFactory();

	factory.setSizeThreshold(ourMaxMemorySize);
	factory.setRepository(new File(ourRepositoryDirectory));

	ServletFileUpload upload = new ServletFileUpload(factory);

	upload.setSizeMax(ourMaxRequestSize);
        
        if (request.getContentType().startsWith("multipart/form-data")) {
            
            List /* FileItem */ items = upload.parseRequest(request);
            Iterator iter = items.iterator();
            System.out.println("_____ ITEM, tamaño: "+items.size());
            FileItem fileItem;
	    File fout;
            
            while (iter.hasNext()) {
                fileItem = (FileItem) iter.next();
                if (!fileItem.isFormField()) {
                    
                    out.print("<font style='color: #00A;font-family: Helvetica;font-size: 6pt' >Iniciando carga..</font><br/>");
                    out.flush();
                    
                    boolean archivoValido = false;
                    if(!validate.trim().equals("") && !validate.trim().equals("any")){
                        String extName = fileItem.getName().split("\\.")[1];
                        String[] valExt = validate.split(",");
                        for(int i = 0; i < valExt.length; i ++){
                            if(extName.equalsIgnoreCase(valExt[i])){
                                archivoValido = true;
                                break;
                            }
                            if (extName.endsWith(valExt[i])){
                                archivoValido = true;
                                break;
                            }
                        }
                    }else
                        archivoValido = true;
                    
                    if(archivoValido){
                        String uploadedFilename = new String(fileItem.getName().getBytes("ISO-8859-1"),"UTF-8") + ( numChunk>0 ? ".part"+numChunk : "") ;
                        
                        Empresa empresaDto = new EmpresaBO(user.getUser().getIdEmpresa(),user.getConn()).getEmpresa();
                        
                        if (isCertificadoAdjunto>0 || isKeyAdjunto>0 || isImagenPersonalAdjunto>0 || isCbbAdjunto > 0 ){
                            //Ruta conformada por "Ruta repositorio" + "RFC Empresa" + Separador carpeta
                            //p. ejemplo: "C:/SystemaDeArchivos/" + "PNU111128TV2" + "/"
                            //CREAMOS EL DIRECTORIO:
                            Configuration configuration = new Configuration();                                    
                            File folder = new File(configuration.getApp_content_path()+empresaDto.getRfc());
                            folder.mkdirs();
                            ourRepositoryDirectory += empresaDto.getRfc() + "/";
                        } else if(isXMLAdjunto > 0){
                            Configuration configuration = new Configuration();                                    
                            File folder = new File(configuration.getApp_content_path()+empresaDto.getRfc()+"/ValidacionXML");
                            folder.mkdirs();
                            ourRepositoryDirectory += empresaDto.getRfc() + "/ValidacionXML/";
                        } else if(isImagenConceptoAdjunto > 0){
                            //CREAMOS EL DIRECTORIO:
                            Configuration configuration = new Configuration();                                    
                            File folder = new File(configuration.getApp_content_path()+empresaDto.getRfc()+"/ImagenConcepto");
                            folder.mkdirs();
                            ourRepositoryDirectory += empresaDto.getRfc()+"/ImagenConcepto/";                            
                        } else if(isImagenProveedorAdjunto > 0){
                            //CREAMOS EL DIRECTORIO:
                            Configuration configuration = new Configuration();                                    
                            File folder = new File(configuration.getApp_content_path()+empresaDto.getRfc()+"/ImagenProveedor");
                            folder.mkdirs();
                            ourRepositoryDirectory += empresaDto.getRfc()+"/ImagenProveedor/";                            
                        }else if(isCargaXls==1){ //renombramos archivo cuando es carga de clientes por excel, para sobreescribirlo y no almacenarlos                         
                            
                            Configuration configuration = new Configuration();                                    
                            File folder = new File(configuration.getApp_content_path()+empresaDto.getRfc());
                            folder.mkdirs();
                                                        
                            uploadedFilename = "cargaConceptos.xls";
                            ourRepositoryDirectory += empresaDto.getRfc() + "/";
                        }else if(isCargaXls==2){ //renombramos archivo cuando es carga de clientes por excel, para sobreescribirlo y no almacenarlos                         
                            
                            Configuration configuration = new Configuration();                                    
                            File folder = new File(configuration.getApp_content_path()+empresaDto.getRfc());
                            folder.mkdirs();                                                     
                            
                            uploadedFilename = "cargaClientes.xls";
                            ourRepositoryDirectory += empresaDto.getRfc() + "/";
                        }
                        ///agregamos la fecha para que si se carga un archivo de identico nombre, este no sea reemplazado
                        String fechaConcatenarNombre = String.valueOf(new Date().getTime()) + "_";
                        ///

                        //Escribimos archivo en ruta específicada
                        if(isImagenConceptoAdjunto > 0 || isImagenProveedorAdjunto > 0){
                            fout = new File(ourRepositoryDirectory + (new File(fechaConcatenarNombre+uploadedFilename)).getName());
                            fileItem.write(fout); 
                        }else{
                            fout = new File(ourRepositoryDirectory + (new File(uploadedFilename)).getName());
                            fileItem.write(fout);
                        }
                        
                        if(isCertificadoAdjunto>0){
                            //Agrega el nombre del CER al formulario padre, por medio de un metodo predefinido en el parent con javascript
                            out.print("<script>parent.recuperarNombreArchivoCer('" + new String(fileItem.getName().getBytes("ISO-8859-1"),"UTF-8") + "');</script>");
                        }
                        
                        if(isKeyAdjunto>0){
                            //Agrega el nombre del KEY al formulario padre, por medio de un metodo predefinido en el parent con javascript
                            out.print("<script>parent.recuperarNombreArchivoKey('" + new String(fileItem.getName().getBytes("ISO-8859-1"),"UTF-8") + "');</script>");
                        }
                        
                        if(isImagenPersonalAdjunto>0){
                            //Agrega el nombre del KEY al formulario padre, por medio de un metodo predefinido en el parent con javascript
                            out.print("<script>parent.recuperarNombreArchivoImagen('" + new String(fileItem.getName().getBytes("ISO-8859-1"),"UTF-8") + "');</script>");
                        }
                        
                        if(isImagenConceptoAdjunto>0 || isImagenProveedorAdjunto > 0){
                            //Agrega el nombre de la imagen al formulario padre, por medio de un metodo predefinido en el parent con javascript                            
                            out.print("<script>parent.recuperarNombreArchivoImagen('"+fechaConcatenarNombre + new String(fileItem.getName().getBytes("ISO-8859-1"),"UTF-8") + "');</script>");
                        }
                        
                        if(isXMLAdjunto>0){
                            //Agrega el nombre del KEY al formulario padre, por medio de un metodo predefinido en el parent con javascript
                            out.print("<script>parent.recuperarNombreArchivoXML('" + new String(fileItem.getName().getBytes("ISO-8859-1"),"UTF-8") + "');</script>");
                        }
                        
                        if(isCbbAdjunto>0){
                            //Agrega el nombre del QR al formulario padre, por medio de un metodo predefinido en el parent con javascript
                            out.print("<script>parent.recuperarNombreArchivoImagen('" + new String(fileItem.getName().getBytes("ISO-8859-1"),"UTF-8") + "');</script>");
                        }
                        
                        if (isCargaXls==1){                         
                            out.print("<script>parent.recuperarNombreArchivoProds('" + new String(fileItem.getName().getBytes("ISO-8859-1"),"UTF-8") + "');</script>");
                        }
                        if (isCargaXls==2){                         
                            out.print("<script>parent.recuperarNombreArchivoClientes('" + new String(fileItem.getName().getBytes("ISO-8859-1"),"UTF-8") + "');</script>");
                        }

                        out.print("<font style='color: #00A;font-family: Helvetica;font-size: 8pt' >Archivo '"+uploadedFilename +"' cargado satisfactoriamente</font>");
                        
                        if("true".equals(reloadIFrameParent)){
                            out.print("<script>parent.location.reload();</script>");
                       }
                        //out.print("<script>parent.parent.recuperaId('"+new String(fileItem.getName().getBytes("ISO-8859-1"),"UTF-8").replaceAll("'", " ") +"','"+fileBO.getTspFile().getIdFile()+"','"+div+"');</script>");
                        if(!"".equals(returnURL)){
                            out.print("<br/><font style='color: #00A;font-family: Helvetica;font-size: 8pt' ><a href='"+returnURL+"'>Continuar</a></font>");
                        }
                        
                    }else
                        out.print("<font style='color: red;font-family: Helvetica;font-size: 8pt' >El archivo '"+new String(fileItem.getName().getBytes("ISO-8859-1"),"UTF-8") +"' es inválido, favor de verificar"
                                + "<br/><a href='#' onclick='history.back();'>Reintentar</a> </font>");
                }
                
            }
        }
        
    }catch(Exception e){out.print(e.toString());}
%>