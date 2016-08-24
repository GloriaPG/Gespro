/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.hibernate.dao;

import com.tsp.gespro.hibernate.pojo.HibernateUtil;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import com.tsp.gespro.hibernate.pojo.CampoAdicionalProspecto;
import java.util.List;
import java.util.Map;

/**
 *
 * @author edgar
 */
public class CampoAdicionalProspectoDAO {
    private Session sesion; 
    private Transaction tx;  
    
    public CampoAdicionalProspectoDAO(){
    }
    
    public void guardarCambios(Map<String, String[]> campos, int idUsuario) {
        String data = "";
        for (Map.Entry<String, String[]> entry : campos.entrySet()) {
            data = entry.getKey();
            break;
        }
        data = data.replace("[", "").replace("]", "").replace("\"", "");        
        String[] parts = data.split("[,{]");
        int counter = 1;
        CampoAdicionalProspecto cac = new CampoAdicionalProspecto();
        for (String line : parts) {
            if (line != null && !line.isEmpty()) {
                String[] lineParts = line.replaceAll("[{]", "").replaceAll("[}]", "").split(":");
                switch (counter) {
                    case 1:
                        cac.setIdCampoAdicionalProspecto(Integer.parseInt(lineParts[1]));
                        break;
                    case 2:
                        cac.setEtiqueta(lineParts[1]);
                        break;
                    case 3:
                        cac.setObligatorio(Integer.parseInt(lineParts[1]));
                        break;
                    case 4:
                        counter = 0;
                        cac.setTipoDato(Integer.parseInt(lineParts[1]));
                        cac.setIdUsuario(idUsuario);
                        saveObject(cac);
                        break;
                }
                counter++;
            }
        }
    }

    public void saveObject(CampoAdicionalProspecto cac) {
        CampoAdicionalProspecto campoExistente = getByEtiquetaAndUserId(cac.getEtiqueta(), cac.getIdUsuario());
        if (campoExistente != null) {
            cac.setIdCampoAdicionalProspecto(campoExistente.getIdCampoAdicionalProspecto());
        }        
        if (cac.getIdCampoAdicionalProspecto() > 0) {
            actualizar(cac);
        } else {
            guardar(cac);

        }
    }
    public CampoAdicionalProspecto getByEtiquetaAndUserId(String etiqueta, int userId) throws HibernateException {

        CampoAdicionalProspecto object = null;
        try {
            iniciaOperacion();
            object = (CampoAdicionalProspecto) sesion.createQuery("from CampoAdicionalProspecto where idUsuario=:idUsuario and etiqueta=:etiqueta").
                    setParameter("idUsuario", userId).setParameter("etiqueta", etiqueta).uniqueResult();
        } finally {
            sesion.close();
        }

        return object;
    }
    
    public Integer guardar(CampoAdicionalProspecto object) throws HibernateException 
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

    public void actualizar(CampoAdicionalProspecto object) throws HibernateException 
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
            CampoAdicionalProspecto object = (CampoAdicionalProspecto) sesion.get(CampoAdicionalProspecto.class,id); 
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

    public CampoAdicionalProspecto getById(int id) throws HibernateException 
    { 
       
        CampoAdicionalProspecto object = null;  
        try 
        { 
            iniciaOperacion(); 
            object = (CampoAdicionalProspecto) sesion.get(CampoAdicionalProspecto.class,id);
        } finally 
        { 
            sesion.close(); 
        }  

        return object; 
    }  

    public List lista(int idUsuario) throws HibernateException {
        List<CampoAdicionalProspecto> lista = null;

        try {
            iniciaOperacion();
            lista = sesion.createQuery("from CampoAdicionalProspecto where idUsuario=:idUsuario").setParameter("idUsuario", idUsuario).list();
        } finally {
            sesion.close();
        }

        return lista;
    }
  
    public List getLista(int idUsuario)
    { 
        return lista(idUsuario); 
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
