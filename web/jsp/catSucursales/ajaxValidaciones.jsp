<%@page import="com.tsp.gespro.hibernate.pojo.CampoAdicionalSucursal"%>
<%@page import="com.tsp.gespro.hibernate.pojo.CampoAdicionalSucursalValor"%>
<%@page import="java.util.Map"%>
<%@page import="com.tsp.gespro.hibernate.dao.CampoAdicionalSucursalDAO"%>
<%@page import="com.tsp.gespro.hibernate.dao.CampoAdicionalSucursalValorDAO"%>
<%@page import="org.hibernate.HibernateException"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    CampoAdicionalSucursalValorDAO cacvdao=new CampoAdicionalSucursalValorDAO();    
    try{
        Map<String, String[]> campos=request.getParameterMap();
        CampoAdicionalSucursalDAO cacdao = new CampoAdicionalSucursalDAO();
        String data = "";
        for (Map.Entry<String, String[]> entry : campos.entrySet()) {
            data = entry.getKey();
            break;
        }
        data = data.replace("[", "").replace("]", "").replace("\"", "");
        String[] parts = data.split("[,{]");
        int counter = 1;
        CampoAdicionalSucursalValor cacv = new CampoAdicionalSucursalValor();
        String msgError="";
        System.out.println("POR AQUI");
        for (String line : parts) {
            if (line != null && !line.isEmpty()) {
                System.out.println("line: "+line);
                String[] lineParts = line.replaceAll("[{]", "").replaceAll("[}]", "").split(":");
                switch (counter) {
                    case 1:
                        CampoAdicionalSucursal cac = new CampoAdicionalSucursal();
                        cac = cacdao.getById(Integer.parseInt(lineParts[1]));
                        cacv.setCampoAdicionalSucursal(cac);
                        break;
                    case 2:
                        cacv.setIdSucursal(Integer.parseInt(lineParts[1]));
                        break;
                    case 3:
                    case 4:
                    case 5:
                        break;
                    case 6:
                        counter = 0;
                        cacv.setValor(lineParts.length>1?lineParts[1]:"");
                        if(cacv.getCampoAdicionalSucursal().getObligatorio()==1&&(cacv.getValor()==null||cacv.getValor().isEmpty())){
                            msgError += "<ul>El dato '"+cacv.getCampoAdicionalSucursal().getEtiqueta()+"' es requerido";
                        }else if(!(cacv.getValor()==null||cacv.getValor().isEmpty())){
                            switch(cacv.getCampoAdicionalSucursal().getTipoDato()){
                                case 1:
                                    if(!cacv.getValor().matches("^[0-9]+$")){
                                        msgError += "<ul>El dato '"+cacv.getCampoAdicionalSucursal().getEtiqueta()+"' debe ser numerico";
                                    }
                                    break;
                                case 2:
                                    if(!cacv.getValor().matches("[a-zA-Z]+")){
                                        msgError += "<ul>El dato '"+cacv.getCampoAdicionalSucursal().getEtiqueta()+"' debe contener solo letras";
                                    }
                                    break;
                                case 3:
                                    break;
                            }
                        }
                        break;
                }
                counter++;

            }
        }     
        if(msgError.isEmpty()){
            out.print("<--EXITO-->" + "Se guardó correctamente. ");
        }else{
            out.print("<!--ERROR-->"+msgError);
        }
       
    }catch(Exception ex){
        out.print("<--ERROR-->" + ex.getMessage());
    }
           
%>