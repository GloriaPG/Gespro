<%-- 
    Document   : skinCSS
    Created on : 19-10-2012, 19:23:14
    Author     : ISCesarMartinez, ISC Cesar Martinez poseidon24@hotmail.com
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    //Recuperamos parametros de custom del Cliente al que pertenece el usuario en sesion
 /*
    TspCustomParameter customParameter=null;
    String nombreArchivoCSS = "";
    try{
        if (user!=null){
            if (user.getUser()!=null){
                if(user.getClienteData()!=null){
                    int idCliente = 0;
                    if (user.hasRole(TspRoleBO.ROLE_PROVEEDOR)){
                        idCliente = user.getClienteData().getProveedorCliente();
                    }
                    if (idCliente<=0){
                        //No es proveedor, es un usuario interno del cliente
                        idCliente = user.getClienteData().getIdCliente();
                    }
                    
                    customParameter = new TspCustomParameterDaoImpl(user.getConn()).findByPrimaryKey(idCliente);
                    
                    if (customParameter!=null){
                        if (customParameter.getCustomCssFileName()!=null){
                            if (!"".equals(customParameter.getCustomCssFileName())){
                                nombreArchivoCSS = customParameter.getCustomCssFileName().trim();
                            }
                        }
                   }
                    
                }
            }
        }
   }catch(Exception ex){
       ex.printStackTrace();
   }

    if (!nombreArchivoCSS.equals("")){
 */
    if (false){
%>
            <link rel="stylesheet" type="text/css" href="../../css/<%//nombreArchivoCSS%>" />
<%
   }else{
%>
            <link href="../../css/blue/screen.css" rel="stylesheet" type="text/css" media="all"/>
            <link href="../../css/blue/datepicker.css" rel="stylesheet" type="text/css" media="all"/>
<%
   }
%>
            <link href="../../css/tipsy.css" rel="stylesheet" type="text/css" media="all">
            <link href="../../js/visualize/visualize.css" rel="stylesheet" type="text/css" media="all"/>
            <link href="../../js/jwysiwyg/jquery.wysiwyg.css" rel="stylesheet" type="text/css" media="all"/>
            <link href="../../js/fancybox/jquery.fancybox-1.3.0.css" rel="stylesheet" type="text/css" media="all"/>
            <link href="../../css/pace/themes/pace_theme_corner_indicator_navy_blue.css" rel="stylesheet" type="text/css" media="all"/>
            <link href="../../css/slick-carousel/slick.css" rel="stylesheet" type="text/css" media="all"/>
            <link href="../../css/slick-carousel/slick-theme.css" rel="stylesheet" type="text/css" media="all"/>
            <link href="../../css/slick-carousel/slick-lightbox.css" rel="stylesheet" type="text/css" media="all"/>
            <!--[if IE]>
                    <link href="../../css/ie.css" rel="stylesheet" type="text/css" media="all">
                    <script type="text/javascript" src="../../js/excanvas.js"></script>
            <![endif]-->