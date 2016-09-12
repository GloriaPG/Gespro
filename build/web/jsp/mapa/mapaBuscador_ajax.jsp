<%-- 
    Document   : mapaBuscador_ajax
    Created on : 8/01/2015, 06:18:58 PM
    Author     : 
--%>

<%@page import="com.tsp.gespro.bo.DatosUsuarioBO"%>
<%@page import="com.tsp.gespro.dto.DatosUsuario"%>
<%@page import="com.tsp.gespro.factory.UsuariosDaoFactory"%>
<%@page import="com.tsp.gespro.dto.Usuarios"%>
<%@page import="com.tsp.gespro.bo.ClienteBO"%>
<%@page import="com.tsp.gespro.factory.ProspectoDaoFactory"%>
<%@page import="com.tsp.gespro.dto.Prospecto"%>
<%@page import="com.tsp.gespro.factory.ClienteDaoFactory"%>
<%@page import="com.tsp.gespro.dto.Cliente"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    /*
    * Datos a buscar
    */
    String txtBuscar = request.getParameter("txt_buscar")!=null?request.getParameter("txt_buscar"):"";
    String txtTipoBuscar = request.getParameter("cmb_tipo_buscar");
    
    ///**Dias de visita
    String domingoReporte = request.getParameter("domingoReporte")!=null?new String(request.getParameter("domingoReporte").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String lunesReporte = request.getParameter("lunesReporte")!=null?new String(request.getParameter("lunesReporte").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String martesReporte = request.getParameter("martesReporte")!=null?new String(request.getParameter("martesReporte").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String miercolesReporte = request.getParameter("miercolesReporte")!=null?new String(request.getParameter("miercolesReporte").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String juevesReporte = request.getParameter("juevesReporte")!=null?new String(request.getParameter("juevesReporte").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String viernesReporte = request.getParameter("viernesReporte")!=null?new String(request.getParameter("viernesReporte").getBytes("ISO-8859-1"),"UTF-8"):""; 
    String sabadoReporte = request.getParameter("sabadoReporte")!=null?new String(request.getParameter("sabadoReporte").getBytes("ISO-8859-1"),"UTF-8"):"";     
    ///**
    
    long idPromotor = 0;
    try{
        idPromotor = Long.parseLong(request.getParameter("cmb_promotor_buscar"));
    }catch(Exception e){}
    
    Cliente[] clientesDto = new Cliente[0];
    Prospecto[] prospectosDto = new Prospecto[0];
    Usuarios[] promotoresDto = new Usuarios[0];
   
            
    /*Automovil[] vehiculosDto = new Automovil[0];
    PuntosInteres[] puntosDto = new PuntosInteres[0];*/
    
    if(txtTipoBuscar.equals("todos") || txtTipoBuscar.equals("clientes")){
         System.out.println("clientes") ;
         
         ///**armamos query de consulta por días:
         String diasVisita = "";
         if(!lunesReporte.trim().equals("") || !martesReporte.trim().equals("") || !miercolesReporte.trim().equals("") || !juevesReporte.trim().equals("")
                 || !viernesReporte.trim().equals("") || !sabadoReporte.trim().equals("") || !domingoReporte.trim().equals("")){
         diasVisita = " AND (DIAS_VISITA LIKE '%TODOS%' ";                
            if(!lunesReporte.trim().equals(""))
                diasVisita += " OR DIAS_VISITA LIKE '%"+lunesReporte+"%' ";
            if(!martesReporte.trim().equals(""))
                diasVisita += " OR DIAS_VISITA LIKE '%"+martesReporte+"%' ";
            if(!miercolesReporte.trim().equals(""))
                diasVisita += " OR DIAS_VISITA LIKE '%"+miercolesReporte+"%' ";
            if(!juevesReporte.trim().equals(""))
                diasVisita += " OR DIAS_VISITA LIKE '%"+juevesReporte+"%' ";
            if(!viernesReporte.trim().equals(""))
                diasVisita += " OR DIAS_VISITA LIKE '%"+viernesReporte+"%' ";
            if(!sabadoReporte.trim().equals(""))
                diasVisita += " OR DIAS_VISITA LIKE '%"+sabadoReporte+"%' ";
            if(!domingoReporte.trim().equals(""))
                diasVisita += " OR DIAS_VISITA LIKE '%"+domingoReporte+"%' ";
            
            diasVisita += ") ";
         }
         ///**
        String filtroClientes = "";
        filtroClientes += ""
            + "NOMBRE_COMERCIAL LIKE '%"+txtBuscar+"%' AND "  
            + "(LATITUD IS NOT NULL AND LATITUD <> '0' AND LATITUD <> 'null' AND LATITUD <> '') AND "
            + "(LONGITUD IS NOT NULL AND LONGITUD <> '0' AND LONGITUD <> 'null' AND LONGITUD <> '') AND ("
            + "ID_ESTATUS = 1 OR ID_ESTATUS = 3) AND ID_EMPRESA = ? "
            + diasVisita  ;
        
        if(idPromotor>0){
            filtroClientes += " AND  ID_CLIENTE IN ( SELECT ID_CLIENTE FROM relacion_cliente_vendedor WHERE ID_USUARIO = "+ idPromotor + ") ";
        }
        
        clientesDto = ClienteDaoFactory.create(user.getConn()).findByDynamicWhere(  filtroClientes  , new Object[]{user.getUser().getIdEmpresa()});
    }
    
    if(txtTipoBuscar.equals("todos") || txtTipoBuscar.equals("prospectos")){
        System.out.println("prospectos") ;
        prospectosDto = ProspectoDaoFactory.create(user.getConn()).findByDynamicWhere(""
            + "(CONTACTO LIKE '%"+txtBuscar+"%' OR "
            + "DESCRIPCION LIKE '%"+txtBuscar+"%') AND "
            + "(LATITUD IS NOT NULL AND LATITUD <> 0) AND "
            + "(LONGITUD IS NOT NULL AND LONGITUD <> 0) AND "
            + "ID_ESTATUS = 1 AND ID_EMPRESA = ? "
            //+ (idPromotor>0?"AND ID_EMPLEADO_PROMOTOR = " + idPromotor:""), new Object[]{user.getUser().getIdEmpresa()});
            , new Object[]{user.getUser().getIdEmpresa()});
    }
    
    if(txtTipoBuscar.equals("todos") || txtTipoBuscar.equals("promotores")){
        System.out.println("promotores") ;
        promotoresDto = UsuariosDaoFactory.create(user.getConn()).findByDynamicWhere(""
            + "ID_USUARIOS IN ( SELECT DISTINCT ID_USUARIOS FROM datos_usuario WHERE "    
            + "(NOMBRE LIKE '%"+txtBuscar+"%' OR "
            + "APELLIDO_PAT LIKE '%"+txtBuscar+"%' OR "
            + "APELLIDO_MAT LIKE '%"+txtBuscar+"%')) AND "
            + "ID_ESTATUS = 1 AND ID_EMPRESA = ? ", new Object[]{user.getUser().getIdEmpresa()});
    }
    
    
   
    
    
    if(clientesDto.length>0 || prospectosDto.length>0 || promotoresDto.length>0 ){
    
        String html = "<table class=\"data\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">"
                    + "  <thead>"
                    + "        <tr>"
                    + "            <th>Tipo</th>"
                    + "            <th>Descripci&oacute;n</th>"
                    + "            <th>Ubicar</th>"
                    + "        </tr>"
                    + "    </thead>";

        html +=  "    <tbody>";

        for(Cliente clienteDto : clientesDto){
            String nombreCliente = ""; 
            if(clienteDto.getNombreComercial()!=null){
                nombreCliente += "" + clienteDto.getNombreComercial();
            }
                    
            html += "<tr>"
                + "<td>"
                + "Cliente"
                + "</td>"
                + "<td>"
                + nombreCliente
                + "</td>"
                + "<td>"
                + "<a href='javascript:void(0)' "
                + "onclick='muestraMarcadorBusqueda("+clienteDto.getLatitud()+","+clienteDto.getLongitud()+",\"clientes\","+clienteDto.getIdCliente()+")'> "
                + "<img src='../../images/icon_movimiento.png' alt='Ubicar'/></a> "
                + "</td>"
                + "<tr>";
        }
        
        for(Prospecto prospectoDto : prospectosDto){
            html += "<tr>"
                + "<td>"
                + "Prospecto"
                + "</td>"
                + "<td>"
                + prospectoDto.getContacto()
                + "</td>"
                + "<td>"
                + "<a href='javascript:void(0)' "
                + "onclick='muestraMarcadorBusqueda("+prospectoDto.getLatitud()+","+prospectoDto.getLongitud()+",\"prospectos\","+prospectoDto.getIdProspecto()+")'> "
                + "<img src='../../images/icon_movimiento.png' alt='Ubicar'/></a> "
                + "</td>"
                + "<tr>";
        }
        
        for(Usuarios promotorDto : promotoresDto){
            
            DatosUsuario datosUsuario = new DatosUsuarioBO(promotorDto.getIdDatosUsuario(),user.getConn()).getDatosUsuario();
            
            if(promotorDto.getIdRoles()== 4){
            html += "<tr>"
                + "<td>";
                if(promotorDto.getIdRoles() == 4)
                    html += "Promotor";
                
             
            
           html += "<td>"
                + datosUsuario.getNombre() + " " + datosUsuario.getApellidoPat() +" "+ datosUsuario.getApellidoMat()
                + "</td>"
                + "<td>"
                + "<a href='javascript:void(0)' "
                + "onclick='muestraMarcadorBusqueda("+promotorDto.getLatitud()+","+promotorDto.getLongitud()+",\"promotores\","+promotorDto.getIdUsuarios()+")'> "
                + "<img src='../../images/icon_movimiento.png' alt='Ubicar'/></a> "
                + "</td>"
                + "<tr>";
            }
            
        }
        
      

        html +=  "    </tbody>"
             + "</table><!--EXITO-->";
        
        out.print(html);
        
    }else{
        out.print("<!--ERROR-->No se encontraron registros.");
    }
    
%>