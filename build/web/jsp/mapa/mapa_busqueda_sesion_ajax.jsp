<%-- 
    Document   : mapa_busqueda_sesion_ajax
    Created on : 1/07/2013, 03:38:08 PM
    Author     : Leonardo
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%
    /*
    * Parámetros
    */     
    String txt_buscar = "";    
    String mode = "";
    String cmb_tipo_buscar = "";
    String lat = "";
    String lng = "";
    String tipo = "";
    String aux = "";
    String promId = "";
    String promTipo = "";   
    String latCl = "";
    String lngCl = "";
    String clieId = "";
    String clieTipo = "";   
    String prosId = "";
    String prosTipo = "";
    String latPros = "";
    String lngPros = "";
    
    
    /*
    * Recepción de valores
    */
    mode = request.getParameter("mode")!=null?request.getParameter("mode"):"";    
    System.out.println("*-**-*-*-*---*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-: "+mode);
    if(mode.equals("")){
        txt_buscar = request.getParameter("txt_buscar")!=null?new String(request.getParameter("txt_buscar").getBytes("ISO-8859-1"),"UTF-8"):"";    
        cmb_tipo_buscar = request.getParameter("cmb_tipo_buscar")!=null?new String(request.getParameter("cmb_tipo_buscar").getBytes("ISO-8859-1"),"UTF-8"):"";    
        System.out.println("///////////////////////DATO A CARGAR: "+txt_buscar);
        try{        
            request.getSession().setAttribute("busqueda",txt_buscar);
            request.getSession().setAttribute("buscarTipoEnte",cmb_tipo_buscar);
            out.print("<!--EXITO-->cargado en sesion.<br/>");
        }catch(Exception e){
            e.printStackTrace();
            String msgError = "Ocurrio un error al enviar el mensaje " + e.toString() ;
            out.print("<!--ERROR-->"+msgError);
        }
    }else if(mode.equals("promotores")){
        lat = request.getParameter("lat")!=null?new String(request.getParameter("lat").getBytes("ISO-8859-1"),"UTF-8"):"";    
        lng = request.getParameter("lng")!=null?new String(request.getParameter("lng").getBytes("ISO-8859-1"),"UTF-8"):"";    
        tipo = request.getParameter("tipo")!=null?new String(request.getParameter("tipo").getBytes("ISO-8859-1"),"UTF-8"):"";    
        aux = request.getParameter("aux")!=null?new String(request.getParameter("aux").getBytes("ISO-8859-1"),"UTF-8"):"";    
        request.getSession().setAttribute("lat",lat);
        request.getSession().setAttribute("lng",lng);
        request.getSession().setAttribute("tipo",tipo);
        request.getSession().setAttribute("aux",aux);
        request.getSession().setAttribute("cooredenadasPromotor","si");
    }else if(mode.equals("detallesPromotor")){
        promId = request.getParameter("lat")!=null?new String(request.getParameter("lat").getBytes("ISO-8859-1"),"UTF-8"):"";
        promTipo = request.getParameter("lng")!=null?new String(request.getParameter("lng").getBytes("ISO-8859-1"),"UTF-8"):"";
        request.getSession().setAttribute("promId",promId);
        request.getSession().setAttribute("promTipo",promTipo);
        request.getSession().setAttribute("promotorDetalles","si");
    }else if(mode.equals("prospectos")){
        latPros = request.getParameter("lat")!=null?new String(request.getParameter("lat").getBytes("ISO-8859-1"),"UTF-8"):"";    
        lngPros = request.getParameter("lng")!=null?new String(request.getParameter("lng").getBytes("ISO-8859-1"),"UTF-8"):"";    
        tipo = request.getParameter("tipo")!=null?new String(request.getParameter("tipo").getBytes("ISO-8859-1"),"UTF-8"):"";    
        aux = request.getParameter("aux")!=null?new String(request.getParameter("aux").getBytes("ISO-8859-1"),"UTF-8"):"";    
        request.getSession().setAttribute("latPros",latPros);
        request.getSession().setAttribute("lngPros",lngPros);
        request.getSession().setAttribute("tipo",tipo);
        request.getSession().setAttribute("aux",aux);
        request.getSession().setAttribute("cooredenadasPros","si");
    }else if(mode.equals("detallesProspecto")){        
        prosId = request.getParameter("lat")!=null?new String(request.getParameter("lat").getBytes("ISO-8859-1"),"UTF-8"):"";
        prosTipo = request.getParameter("lng")!=null?new String(request.getParameter("lng").getBytes("ISO-8859-1"),"UTF-8"):"";
        request.getSession().setAttribute("prosId",promId);
        request.getSession().setAttribute("prosTipo",promTipo);
        request.getSession().setAttribute("prospectoDetalles","si");
        System.out.println("CARGANDO PROSPECTO!!!!!!!!!!!!!!!!!!!!!!");
    }else if(mode.equals("clientes")){
        latCl = request.getParameter("lat")!=null?new String(request.getParameter("lat").getBytes("ISO-8859-1"),"UTF-8"):"";    
        lngCl = request.getParameter("lng")!=null?new String(request.getParameter("lng").getBytes("ISO-8859-1"),"UTF-8"):"";    
        tipo = request.getParameter("tipo")!=null?new String(request.getParameter("tipo").getBytes("ISO-8859-1"),"UTF-8"):"";    
        request.getSession().setAttribute("latCl",latCl);
        request.getSession().setAttribute("lngCl",lngCl);
        request.getSession().setAttribute("tipo",tipo);
        request.getSession().setAttribute("cooredenadasCliente","si");
        
    }else if(mode.equals("detallesCliente")){
        clieId = request.getParameter("lat")!=null?new String(request.getParameter("lat").getBytes("ISO-8859-1"),"UTF-8"):"";
        clieTipo = request.getParameter("lng")!=null?new String(request.getParameter("lng").getBytes("ISO-8859-1"),"UTF-8"):"";
        request.getSession().setAttribute("clieId",clieId);
        request.getSession().setAttribute("clieTipo",clieTipo);
        request.getSession().setAttribute("clienteDetalles","si");
    }else if(mode.equals("vaciadoDatosSesion")){
        System.out.println("EEEEEEEEEEEEEEEEEEEEEEEEEEEEE");
        request.getSession().setAttribute("busqueda","");
        request.getSession().setAttribute("buscarTipoEnte","");
        request.getSession().setAttribute("lat","");
        request.getSession().setAttribute("lng","");
        request.getSession().setAttribute("promotores","");
        request.getSession().setAttribute("aux","");
        request.getSession().setAttribute("promId","");
        request.getSession().setAttribute("promTipo","");
        request.getSession().setAttribute("cooredenadasPromotor","");
        request.getSession().setAttribute("promotorDetalles","");
        request.getSession().setAttribute("latCl","");
        request.getSession().setAttribute("lngCl","");
        request.getSession().setAttribute("cooredenadasCliente","");
        request.getSession().setAttribute("clienteDetalles","");
        request.getSession().setAttribute("clieId","");
        request.getSession().setAttribute("clieTipo","");
        request.getSession().setAttribute("clienteDetalles","");
        request.getSession().setAttribute("cooredenadasProspecto","");
        request.getSession().setAttribute("prosId","");
        request.getSession().setAttribute("prosDetalles","");
        request.getSession().setAttribute("prosTipo","");
        request.getSession().setAttribute("latPros","");
        request.getSession().setAttribute("lngPros","");
    }
        
    
%>
