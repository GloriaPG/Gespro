<%@page import="com.tsp.gespro.hibernate.pojo.CampoAdicionalProspecto"%>
<%@page import="com.tsp.gespro.hibernate.pojo.CampoAdicionalProspectoValor"%>
<%@page import="java.util.Map"%>
<%@page import="com.tsp.gespro.hibernate.dao.CampoAdicionalProspectoDAO"%>
<%@page import="com.tsp.gespro.hibernate.dao.CampoAdicionalProspectoValorDAO"%>
<%@page import="org.hibernate.HibernateException"%>
<%@page import="com.tsp.gespro.util.GenericValidator"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:useBean id="user" scope="session" class="com.tsp.gespro.bo.UsuarioBO"/>
<%
    CampoAdicionalProspectoValorDAO cacvdao=new CampoAdicionalProspectoValorDAO();    
    try{
        Map<String, String[]> campos=request.getParameterMap();
        CampoAdicionalProspectoDAO cacdao = new CampoAdicionalProspectoDAO();
        String data = "";
        for (Map.Entry<String, String[]> entry : campos.entrySet()) {
            data = entry.getKey();
            break;
        }
        data = data.replace("[", "").replace("]", "").replace("\"", "");
        String[] parts = data.split("[,{]");
        int counter = 1;
        CampoAdicionalProspectoValor cacv = new CampoAdicionalProspectoValor();
        String msgError="";
        for (String line : parts) {
            if (line != null && !line.isEmpty()) {
                String[] lineParts = line.replaceAll("[{]", "").replaceAll("[}]", "").split(":");
                switch (counter) {
                    case 1:
                        CampoAdicionalProspecto cac = new CampoAdicionalProspecto();
                        cac = cacdao.getById(Integer.parseInt(lineParts[1]));
                        cacv.setCampoAdicionalProspecto(cac);
                        break;
                    case 2:
                        cacv.setIdProspecto(Integer.parseInt(lineParts[1]));
                        break;
                    case 3:
                    case 4:
                    case 5:
                        break;
                    case 6:
                        counter = 0;
                        cacv.setValor(lineParts.length>1?lineParts[1]:"");
                        if(cacv.getCampoAdicionalProspecto().getObligatorio()==1&&(cacv.getValor()==null||cacv.getValor().isEmpty())){
                            msgError += "<ul>El dato '"+cacv.getCampoAdicionalProspecto().getEtiqueta()+"' es requerido";
                        }else if(!(cacv.getValor()==null||cacv.getValor().isEmpty())){
                            switch(cacv.getCampoAdicionalProspecto().getTipoDato()){
                                case 1:
                                    if(!cacv.getValor().matches("^[0-9]+$")){
                                        msgError += "<ul>El dato '"+cacv.getCampoAdicionalProspecto().getEtiqueta()+"' debe ser numerico";
                                    }
                                    break;
                                case 2:
                                    if(!cacv.getValor().matches("[a-zA-Z]+")){
                                        msgError += "<ul>El dato '"+cacv.getCampoAdicionalProspecto().getEtiqueta()+"' debe contener solo letras";
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