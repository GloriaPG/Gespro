/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.hibernate.dao;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import com.tsp.gespro.hibernate.pojo.UsuarioMonitor;
import com.tsp.gespro.hibernate.pojo.HibernateUtil;
import com.tsp.gespro.mail.TspMailBO;
import java.util.List;

/**
 *
 * @author gloria
 */
public class UsuarioMonitorDAO {
    
    private Session sesion; 
    private Transaction tx;  
    
    public UsuarioMonitorDAO(){
    }
    
    public Integer guardar(UsuarioMonitor object) throws HibernateException 
    { 
        Integer id = 0;  
        try 
        { 
            iniciaOperacion();
            id= (Integer) sesion.save(object); 
            tx.commit(); 
            
            enviarCorreoConCredenciales(object);
        } catch (HibernateException he) 
        { 
            System.out.println("error");
            System.out.println(he.getMessage());
            manejaExcepcion(he); 
            throw he; 
        } finally 
        { 
            sesion.close(); 
        }  

        return id; 
    }  

    public void actualizar(UsuarioMonitor object) throws HibernateException 
    { 
        try 
        { 
            System.out.println("Actualizando...");
            iniciaOperacion(); 
            UsuarioMonitor old= (UsuarioMonitor) sesion.get(UsuarioMonitor.class,object.getId());
            sesion.close(); 
            iniciaOperacion();
            sesion.update(object); 
            if(old.getPassword()!= object.getPassword()){
                System.out.println("Mandandp correo 1");
                enviarCorreoConCredenciales(object);
                System.out.println("Mandandp correo 2");
            }
            tx.commit(); 
            
        } catch (HibernateException he) 
        { 
            manejaExcepcion(he); 
            System.out.println("error hibernate " + he.getMessage());
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
            UsuarioMonitor object = (UsuarioMonitor) sesion.get(UsuarioMonitor.class,id); 
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

    public UsuarioMonitor getById(int id) throws HibernateException 
    { 
       
        UsuarioMonitor object = null;  
        try 
        { 
            iniciaOperacion(); 
            object = (UsuarioMonitor) sesion.get(UsuarioMonitor.class,id);
        } finally 
        { 
            sesion.close(); 
        }  

        return object; 
    }  

    public List lista() throws HibernateException 
    { 
        List<UsuarioMonitor> lista = null;  

        try 
        { 
            iniciaOperacion(); 
            lista = sesion.createQuery("from UsuarioMonitor").list(); 
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
     
    private void enviarCorreoConCredenciales(UsuarioMonitor obj){
        try {
            TspMailBO mail = new TspMailBO();
            String contenido ="<b>Tus credenciales :</b><br/><br/>Usuario: <h3>"+ obj.getEmail() +"</h3><br/>Password: <h3>"+ obj.getPassword()+"</h3>";
            try {
                String correoContacto = obj.getEmail();
                mail.addTo(correoContacto, correoContacto);
            }catch(Exception e){}
            mail.setConfigurationMovilpyme(); 
            mail.addMessageMovilpyme(contenido,1);
            mail.setFrom(mail.getUSER(), mail.getFROM_NAME());            
            mail.send("Hola, tenemos tus credenciales GESPRO! " + obj.getEmail());
        } catch (Exception ex) {
            System.out.println("No se pudo enviar el correo de credenciales. Error: "+ ex.getMessage());
        }
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
