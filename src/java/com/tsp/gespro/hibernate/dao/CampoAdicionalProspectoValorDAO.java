/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.hibernate.dao;

import com.tsp.gespro.hibernate.pojo.CampoAdicionalProspecto;
import com.tsp.gespro.hibernate.pojo.HibernateUtil;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import com.tsp.gespro.hibernate.pojo.CampoAdicionalProspectoValor;
import java.util.List;
import java.util.Map;

/**
 *
 * @author edgar
 */
public class CampoAdicionalProspectoValorDAO {
    private Session sesion; 
    private Transaction tx;  
    
    public CampoAdicionalProspectoValorDAO(){
    }
    public void guardarCambios(Map<String, String[]> campos) {
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
                        saveObject(cacv);
                        break;
                }
                counter++;

            }
        }
    }

    public void saveObject(CampoAdicionalProspectoValor cacv) {
        CampoAdicionalProspectoValor campoExistente = getByIdAndProspecto(cacv.getCampoAdicionalProspecto().getIdCampoAdicionalProspecto(), cacv.getIdProspecto());
        if (campoExistente != null) {
            cacv.setIdCampoAdicionalProspectoValor(campoExistente.getIdCampoAdicionalProspectoValor());
        }
        if (cacv.getIdCampoAdicionalProspectoValor() > 0) {
            actualizar(cacv);
        } else {
            guardar(cacv);

        }
    }
    public Integer guardar(CampoAdicionalProspectoValor object) throws HibernateException 
    { 
        Integer id = 0;  
        try 
        { 
            iniciaOperacion();
            id= (Integer) sesion.save(object); 
            tx.commit(); 
        } catch (HibernateException he) 
        { 
            manejaExcepcion(he); 
            throw he; 
        } finally 
        { 
            sesion.close(); 
        }  

        return id; 
    }  

    public void actualizar(CampoAdicionalProspectoValor object) throws HibernateException 
    { 
        try 
        { 
            
            iniciaOperacion(); 
            sesion.update(object); 
            tx.commit(); 
            
        } catch (HibernateException he) 
        { 
            manejaExcepcion(he); 
            throw he; 
        } finally 
        { 
            sesion.close(); 
        } 
    }  

    public void eliminar(int id) throws HibernateException 
    { 
        try 
        { 
            iniciaOperacion(); 
            CampoAdicionalProspectoValor object = (CampoAdicionalProspectoValor) sesion.get(CampoAdicionalProspectoValor.class,id); 
            sesion.delete(object); 
            tx.commit(); 
        } catch (HibernateException he) 
        {   
            manejaExcepcion(he); 
            throw he; 
        } finally 
        { 
            sesion.close(); 
        } 
    }  

    public CampoAdicionalProspectoValor getById(int id) throws HibernateException 
    { 
       
        CampoAdicionalProspectoValor object = null;  
        try 
        { 
            iniciaOperacion(); 
            object = (CampoAdicionalProspectoValor) sesion.get(CampoAdicionalProspectoValor.class,id);
        } finally 
        { 
            sesion.close(); 
        }  

        return object; 
    }  
    public CampoAdicionalProspectoValor getByIdAndProspecto(int id, int idProspecto) throws HibernateException {
        CampoAdicionalProspectoValor object = null;
        try {
            iniciaOperacion();            
            object = (CampoAdicionalProspectoValor) sesion.createQuery("select CACV from CampoAdicionalProspectoValor CACV join CACV.campoAdicionalProspecto CAC where CAC.idCampoAdicionalProspecto=:idCampoAdicionalProspecto and CACV.idProspecto=:idProspecto")
                    .setParameter("idCampoAdicionalProspecto", id).setParameter("idProspecto", idProspecto).uniqueResult();            
        } finally {
            sesion.close();
        }

        return object;
    }

    public List lista() throws HibernateException 
    { 
        List<CampoAdicionalProspectoValor> lista = null;  

        try 
        { 
            iniciaOperacion(); 
            lista = sesion.createQuery("from CampoAdicionalProspectoValor").list(); 
        }
        finally 
        { 
            sesion.close(); 
        }  

        return lista; 
    }
  
    public List getLista()
    { 
        return lista(); 
    }    
     
    private void iniciaOperacion() throws HibernateException 
    { 
        sesion = HibernateUtil.getSessionFactory().openSession(); 
        tx = sesion.beginTransaction(); 
    }  

    private void manejaExcepcion(HibernateException he) throws HibernateException 
    { 
        tx.rollback(); 
        throw new HibernateException("Ocurrió un error en la capa de acceso a datos", he); 
    }
}
