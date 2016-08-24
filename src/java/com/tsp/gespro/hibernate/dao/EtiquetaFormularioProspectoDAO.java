/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.hibernate.dao;

import com.tsp.gespro.hibernate.pojo.HibernateUtil;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import com.tsp.gespro.hibernate.pojo.EtiquetaFormularioProspecto;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * @author edgar
 */
public class EtiquetaFormularioProspectoDAO {
    private Session sesion; 
    private Transaction tx;
    
    public static String RAZON_SOCIAL="razonSocial";
    public static String RAZON_SOCIAL_DEFAULT="Razón Social/Nombre empresa";
    public static boolean RAZON_SOCIAL_REQUERIDO_DEFAULT=true;
    public static String CONTACTO="contacto";
    public static String CONTACTO_DEFAULT="Contacto (Nombre completo)";
    public static boolean CONTACTO_REQUERIDO_DEFAULT=true;
    public static String LADA="lada";
    public static String LADA_DEFAULT="Lada";
    public static boolean LADA_REQUERIDO_DEFAULT=true;
    public static String TELEFONO="telefono";
    public static String TELEFONO_DEFAULT="Teléfono";
    public static boolean TELEFONO_REQUERIDO_DEFAULT=true;
    public static String CELULAR="celular";
    public static String CELULAR_DEFAULT="Celular";
    public static boolean CELULAR_REQUERIDO_DEFAULT=false;
    public static String CORREO_ELECTRONICO="correoElectronico";
    public static String CORREO_ELECTRONICO_DEFAULT="Correo Electrónico";
    public static boolean CORREO_ELECTRONICO_REQUERIDO_DEFAULT=true;
    public static String DESCRIPCION="descripcion";
    public static String DESCRIPCION_DEFAULT="Descripción (p. ej.: intereses de compra)";
    public static boolean DESCRIPCION_REQUERIDO_DEFAULT=true;    
    public static String ACTIVO="activo";
    public static String ACTIVO_DEFAULT="Activo";
    public static boolean ACTIVO_REQUERIDO_DEFAULT=false;    
    public static String FOTO_PROSPECTO="fotoProspecto";
    public static String FOTO_PROSPECTO_DEFAULT="Foto Prospecto";
    public static boolean FOTO_PROSPECTO_REQUERIDO_DEFAULT=false;
    
    
    public EtiquetaFormularioProspectoDAO(){
    }
    
    public void guardarCambios(Map<String,String[]> campos,int idUsuario){        
        String data="";
        for(Map.Entry<String,String[]> entry : campos.entrySet()){
            data=entry.getKey();
            break;            
        }
        data=data.replace("[", "").replace("]", "").replace("\"","");
        String[]parts=data.split("[,{]");
        int counter=1;
        EtiquetaFormularioProspecto efc=new EtiquetaFormularioProspecto();
        for(String line:parts){
            if(line!=null&&!line.isEmpty()){
                String[] lineParts=line.replaceAll("[{]", "").replaceAll("[}]", "").split(":");                
                switch(counter){
                    case 1:
                        efc.setIdEtiquetaFormularioProspecto(Integer.parseInt(lineParts[1]));
                        break;
                    case 2:
                        efc.setCampo(lineParts[1]);
                        break;
                    case 3:
                        efc.setEtiqueta(lineParts[1]);
                        break;
                    case 4:
                        counter=0;
                        efc.setObligatorio(Integer.parseInt(lineParts[1]));
                        efc.setIdUsuario(idUsuario);                        
                        saveObject(efc);
                        break;
                }
                counter++;
            }            
        }
    }
    
    public void saveObject(EtiquetaFormularioProspecto efc){
        if(efc.getIdEtiquetaFormularioProspecto()>0){
            actualizar(efc);
        }else{
            guardar(efc);
        }
    }
    public HashMap<String,EtiquetaFormularioProspecto> getMap(int idUsuario){
        HashMap<String,EtiquetaFormularioProspecto> mapa = new HashMap<String,EtiquetaFormularioProspecto>();  

        try 
        {   
            List<EtiquetaFormularioProspecto> lista=null;
            iniciaOperacion();
            lista = sesion.createQuery("from EtiquetaFormularioProspecto where idUsuario=:idUsuario").setParameter("idUsuario", idUsuario).list();
            if(lista!=null&&lista.size()>0){
                for(int i=0;i<lista.size();++i){
                    mapa.put(lista.get(i).getCampo(), lista.get(i));
                }
            }            
        }
        finally 
        { 
            sesion.close(); 
        }  

        return mapa; 
    }
    public Integer guardar(EtiquetaFormularioProspecto object) throws HibernateException 
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

    public void actualizar(EtiquetaFormularioProspecto object) throws HibernateException 
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
            EtiquetaFormularioProspecto object = (EtiquetaFormularioProspecto) sesion.get(EtiquetaFormularioProspecto.class,id); 
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

    public EtiquetaFormularioProspecto getById(int id) throws HibernateException 
    { 
       
        EtiquetaFormularioProspecto object = null;  
        try 
        { 
            iniciaOperacion(); 
            object = (EtiquetaFormularioProspecto) sesion.get(EtiquetaFormularioProspecto.class,id);
        } finally 
        { 
            sesion.close(); 
        }  

        return object; 
    }  

    public List lista() throws HibernateException 
    { 
        List<EtiquetaFormularioProspecto> lista = null;  

        try 
        { 
            iniciaOperacion(); 
            lista = sesion.createQuery("from EtiquetaFormularioProspecto").list(); 
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
