/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.hibernate.dao;

import com.tsp.gespro.hibernate.pojo.CampoAdicionalSucursal;
import com.tsp.gespro.hibernate.pojo.HibernateUtil;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import com.tsp.gespro.hibernate.pojo.CampoAdicionalSucursalValor;
import java.util.List;
import java.util.Map;

/**
 *
 * @author edgar
 */
public class CampoAdicionalSucursalValorDAO {
    private Session sesion; 
    private Transaction tx;  
    
    public CampoAdicionalSucursalValorDAO(){
    }
    public void guardarCambios(Map<String, String[]> campos) {
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
        for (String line : parts) {
            if (line != null && !line.isEmpty()) {
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
                        saveObject(cacv);
                        break;
                }
                counter++;

            }
        }
    }

    public void saveObject(CampoAdicionalSucursalValor cacv) {
        CampoAdicionalSucursalValor campoExistente = getByIdAndSucursal(cacv.getCampoAdicionalSucursal().getIdCampoAdicionalSucursal(), cacv.getIdSucursal());
        if (campoExistente != null) {
            cacv.setIdCampoAdicionalSucursalValor(campoExistente.getIdCampoAdicionalSucursalValor());
        }
        if (cacv.getIdCampoAdicionalSucursalValor() > 0) {
            actualizar(cacv);
        } else {
            guardar(cacv);

        }
    }
    
    public CampoAdicionalSucursalValor getByIdAndSucursal(int id, int idSucursal) throws HibernateException {
        CampoAdicionalSucursalValor object = null;
        try {
            iniciaOperacion();            
            object = (CampoAdicionalSucursalValor) sesion.createQuery("select CACV from CampoAdicionalSucursalValor CACV join CACV.campoAdicionalSucursal CAC where CAC.idCampoAdicionalSucursal=:idCampoAdicionalSucursal and CACV.idSucursal=:idSucursal")
                    .setParameter("idCampoAdicionalSucursal", id).setParameter("idSucursal", idSucursal).uniqueResult();            
        } finally {
            sesion.close();
        }

        return object;
    }
    
    public Integer guardar(CampoAdicionalSucursalValor object) throws HibernateException 
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

    public void actualizar(CampoAdicionalSucursalValor object) throws HibernateException 
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
            CampoAdicionalSucursalValor object = (CampoAdicionalSucursalValor) sesion.get(CampoAdicionalSucursalValor.class,id); 
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

    public CampoAdicionalSucursalValor getById(int id) throws HibernateException 
    { 
       
        CampoAdicionalSucursalValor object = null;  
        try 
        { 
            iniciaOperacion(); 
            object = (CampoAdicionalSucursalValor) sesion.get(CampoAdicionalSucursalValor.class,id);
        } finally 
        { 
            sesion.close(); 
        }  

        return object; 
    }  

    public List lista() throws HibernateException 
    { 
        List<CampoAdicionalSucursalValor> lista = null;  

        try 
        { 
            iniciaOperacion(); 
            lista = sesion.createQuery("from CampoAdicionalSucursalValor").list(); 
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
