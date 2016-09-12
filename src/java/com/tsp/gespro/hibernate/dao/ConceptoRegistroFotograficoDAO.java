/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.hibernate.dao;

import com.tsp.gespro.hibernate.pojo.HibernateUtil;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import com.tsp.gespro.hibernate.pojo.ConceptoRegistroFotografico;
import java.util.List;

/**
 *
 * @author gloria
 */
public class ConceptoRegistroFotograficoDAO {
    private Session sesion; 
    private Transaction tx;  
    
    public ConceptoRegistroFotograficoDAO(){
    }
    
    public Integer guardar(ConceptoRegistroFotografico object) throws HibernateException 
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

    public void actualizar(ConceptoRegistroFotografico object) throws HibernateException 
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
            ConceptoRegistroFotografico object = (ConceptoRegistroFotografico) sesion.get(ConceptoRegistroFotografico.class,id); 
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

    public ConceptoRegistroFotografico getById(int id) throws HibernateException 
    { 
       
        ConceptoRegistroFotografico object = null;  
        try 
        { 
            iniciaOperacion(); 
            object = (ConceptoRegistroFotografico) sesion.get(ConceptoRegistroFotografico.class,id);
        } finally 
        { 
            sesion.close(); 
        }  

        return object; 
    }  

    public List lista() throws HibernateException 
    { 
        List<ConceptoRegistroFotografico> lista = null;  

        try 
        { 
            iniciaOperacion(); 
            lista = sesion.createQuery("from ConceptoRegistroFotografico").list(); 
        }
        finally 
        { 
            sesion.close(); 
        }  

        return lista; 
    }
    
    public List listaByCliente(int idCliente) throws HibernateException 
    { 
        List<ConceptoRegistroFotografico> lista = null;  

        try 
        { 
            iniciaOperacion(); 
            lista = sesion.createQuery("from ConceptoRegistroFotografico WHERE ID_CLIENTE="+idCliente).list(); 
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
