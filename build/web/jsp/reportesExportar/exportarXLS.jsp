<%-- 
    Document   : exportarXLS
    Created on : 19-sep-2011, 22:11:53
    Author     : luismorales
--%>

<%@page import="com.tsp.gespro.bo.ImagenPersonalBO"%>
<%@page import="com.tsp.gespro.dto.ImagenPersonal"%>
<%@page import="java.io.File"%>
<%@page import="com.tsp.gespro.report.xls.ReportExportableXLS"%>
<%@page import="java.io.ByteArrayOutputStream"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    int i = 0;
    String parametrosCustom="";
    String parametrosExtra="";
    String infoTitle="";
    try{
        i = Integer.parseInt(request.getParameter("i"));
    }catch(Exception e){}
    parametrosCustom = request.getParameter("parametrosCustom")!=null?new String(request.getParameter("parametrosCustom").getBytes("ISO-8859-1"),"UTF-8"):"";
    parametrosExtra = request.getParameter("parametrosExtra")!=null?new String(request.getParameter("parametrosExtra").getBytes("ISO-8859-1"),"UTF-8"):"";
    infoTitle = request.getParameter("infoTitle")!=null?new String(request.getParameter("infoTitle").getBytes("ISO-8859-1"),"UTF-8"):"";

    if(i > 0){

        ByteArrayOutputStream bXLS = new ByteArrayOutputStream();

        ReportExportableXLS toXls = new ReportExportableXLS();
        toXls.setUser(user);
        String params = "";
        
        if (!"".equals(params)){
            params = params + " AND " + parametrosCustom;
        }else{
            params = parametrosCustom;
        }

        
        /*
        * Imagen Logo para reporte
        */
//Recuperar archivo de imagen logo de la empresa (usuario en sesion)
		try{
        File fileImagenPersonal = new ImagenPersonalBO(user.getConn()).getFileImagenPersonalByEmpresa(user.getUser().getIdEmpresa());
        if (fileImagenPersonal!=null)
            toXls.setFileImageLogo(fileImagenPersonal);
        //File logoImage = new File("/C:/SystemaDeArchivos/pretoNull.jpg");
        }catch(Exception eLo){
            File logoImage = null;
                        try{
                            logoImage = new File("/C:/SystemaDeArchivos/pretoNull.jpg");
                        }catch(Exception el){
                            logoImage = new File("../../images/reporteNull.png");
                        }
			toXls.setFileImageLogo(logoImage);
		}
        
        
        
        bXLS = toXls.generarReporte(i, params, parametrosExtra,infoTitle);
        
        if (bXLS!=null){
            if (bXLS.size()>0){
                response.setContentType("application/vnd.ms-excel");
                response.setHeader("Content-Disposition", "attachment; filename=reporte.xls");
                response.setContentLength(bXLS.size());

                ServletOutputStream outputStream = response.getOutputStream();
                bXLS.writeTo(outputStream);
                outputStream.flush();
            }else{
                String msgError="<script> alert('El reporte que se intenta descargar esta vacío. Intente con otro filtro de busqueda.');"
                    + " window.close(); </script>"
                    + "<h1>El reporte que se intenta descargar esta vacío. Intente de nuevo.</h1>";
                out.print(msgError);
            }
        }else{
            String msgError="<script> alert('El reporte que se intenta descargar esta vacío. Intente con otro filtro de busqueda.');"
                    + " window.close(); </script>"
                    + "<h1>El reporte que se intenta descargar esta vacío. Intente de nuevo.</h1>";
            out.print(msgError);
        }

        /*response.setContentType("application/vnd.ms-excel");
        response.setContentLength(bXLS.size());
        response.setHeader("Content-Disposition", "attachment; filename=reporte.xls");
        ServletOutputStream outputStream = response.getOutputStream();
        bXLS.writeTo(outputStream);
        outputStream.flush();
        * */
    }else{
        out.print("No se seleccionó algún reporte");
    }
%>