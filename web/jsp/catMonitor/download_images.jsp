<%@page import="java.io.OutputStream"%>
<%@page import="com.tsp.gespro.util.ZipUtil"%>
<%@page import="java.io.File"%>
<%@page import="com.tsp.gespro.hibernate.pojo.Actividad"%>
<%@page import="com.tsp.gespro.hibernate.dao.ActividadDAO"%>
<%@page import="com.tsp.gespro.config.Configuration"%>
<%@page import="java.util.zip.ZipEntry"%>
<%@page import="java.util.zip.ZipOutputStream"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.util.List"%>
<%@page import="com.tsp.gespro.Services.Allservices"%>
<%@page import="com.tsp.gespro.hibernate.pojo.FotoActividad"%>
<% 
    String idActividad = request.getParameter("idActividad") != null ? request.getParameter("idActividad") : "";
    Allservices services = new Allservices();
    List<FotoActividad> fotoActividad = services.queryFotoActividad("WHERE idActividad = "+idActividad);
    Configuration appConfig = new Configuration();
    ActividadDAO actividadDAO= new ActividadDAO();
    Actividad objActividad= new Actividad();
    objActividad = actividadDAO.getById(Integer.parseInt(idActividad));

        response.setContentType("application/octet-stream");
        response.setHeader("Content-Disposition", "attachment;filename=Actividad"+objActividad.getIdActividad()+"pictures.zip");

        Configuration configuration = null;
        configuration = new Configuration();
        String filename = "";
        File tempDir = null;
        File fileToZip = null;
            tempDir = new File(configuration.getApp_content_path() + "\\tmp\\");
            filename = tempDir.getPath()+"\\Actividad"+objActividad.getIdActividad()+"pictures.zip";;
            fileToZip = new File(configuration.getApp_content_path() +"\\proyectos\\"+objActividad.getIdProyecto()+"\\actividades\\"+objActividad.getIdActividad());
        
        if (!tempDir.exists()) {
            tempDir.mkdirs();
        }
        
        //
        if (!fileToZip.exists()) {
            fileToZip.mkdir();
        }

        // Comprimir el archivo
        ZipUtil.zipFile(fileToZip.getPath(), filename, true);

        // Descargar el archivo
        File file = new File(filename);
        FileInputStream fileIn = new FileInputStream(file);
        OutputStream servletOutputStream = response.getOutputStream();

        byte[] outputByte = new byte[4096];
        //copy binary contect to output stream
        while (fileIn.read(outputByte, 0, 4096) != -1) {
            servletOutputStream.write(outputByte, 0, 4096);
        }
        fileIn.close();
        servletOutputStream.flush();
        servletOutputStream.close();
        file.delete();
        


%>
