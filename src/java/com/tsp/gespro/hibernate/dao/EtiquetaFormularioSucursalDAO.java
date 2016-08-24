/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.hibernate.dao;

import com.tsp.gespro.hibernate.pojo.HibernateUtil;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import com.tsp.gespro.hibernate.pojo.EtiquetaFormularioSucursal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * @author edgar
 */
public class EtiquetaFormularioSucursalDAO {
    private Session sesion; 
    private Transaction tx;  
    
    public static String RFC="rfc";
    public static String RFC_DEFAULT="RFC";
    public static boolean RFC_REQUERIDO_DEFAULT=false;
    public static String RAZON_SOCIAL="razonSocial";
    public static String RAZON_SOCIAL_DEFAULT="Razón Social";
    public static boolean RAZON_SOCIAL_REQUERIDO_DEFAULT=false;
    public static String REGIMEN_FISCAL="regimenFiscal";
    public static String REGIMEN_FISCAL_DEFAULT="Tipo";
    public static boolean REGIMEN_FISCAL_REQUERIDO_DEFAULT=false;
    public static String NOMBRE_COMERCIAL="nombreComercial";
    public static String NOMBRE_COMERCIAL_DEFAULT="Nombre comercial";
    public static boolean NOMBRE_COMERCIAL_REQUERIDO_DEFAULT=true;
    public static String MATRIZ="matriz";
    public static String MATRIZ_DEFAULT="Matriz";
    public static boolean MATRIZ_REQUERIDO_DEFAULT=false;    
    public static String ACTIVO="activo";
    public static String ACTIVO_DEFAULT="Activo";
    public static boolean ACTIVO_REQUERIDO_DEFAULT=false;
    public static String CALLE="calle";
    public static String CALLE_DEFAULT="Calle";
    public static boolean CALLE_REQUERIDO_DEFAULT=true;
    public static String NUMERO_EXTERIOR="numeroExterior";
    public static String NUMERO_EXTERIOR_DEFAULT="Numero exterior";
    public static boolean NUMERO_EXTERIOR_REQUERIDO_DEFAULT=true;
    public static String NUMERO_INTERIOR="numeroInterior";
    public static String NUMERO_INTERIOR_DEFAULT="Numero interior";
    public static boolean NUMERO_INTERIOR_REQUERIDO_DEFAULT=false;
    public static String COLONIA="colonia";
    public static String COLONIA_DEFAULT="Colonia";
    public static boolean COLONIA_REQUERIDO_DEFAULT=true;
    public static String CODIGO_POSTAL="codigoPostal";
    public static String CODIGO_POSTAL_DEFAULT="Código Postal";
    public static boolean CODIGO_POSTAL_REQUERIDO_DEFAULT=false;
    public static String MUNICIPIO="municipio";
    public static String MUNICIPIO_DEFAULT="Municipio/Delegación";
    public static boolean MUNICIPIO_REQUERIDO_DEFAULT=true;
    public static String ESTADO="estado";
    public static String ESTADO_DEFAULT="Estado";
    public static boolean ESTADO_REQUERIDO_DEFAULT=true;
    public static String PAIS="pais";
    public static String PAIS_DEFAULT="País";
    public static boolean PAIS_REQUERIDO_DEFAULT=true;
    
    public EtiquetaFormularioSucursalDAO(){
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
        EtiquetaFormularioSucursal efc=new EtiquetaFormularioSucursal();
        for(String line:parts){
            if(line!=null&&!line.isEmpty()){
                String[] lineParts=line.replaceAll("[{]", "").replaceAll("[}]", "").split(":");                
                switch(counter){
                    case 1:
                        efc.setIdEtiquetaFormularioSucursal(Integer.parseInt(lineParts[1]));
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
    
    public void saveObject(EtiquetaFormularioSucursal efc){
        if(efc.getIdEtiquetaFormularioSucursal()>0){
            actualizar(efc);
        }else{
            guardar(efc);
        }
    }    
    
    public HashMap<String,EtiquetaFormularioSucursal> getMap(int idUsuario){
        HashMap<String,EtiquetaFormularioSucursal> mapa = new HashMap<String,EtiquetaFormularioSucursal>();  

        try 
        {   
            List<EtiquetaFormularioSucursal> lista=null;
            iniciaOperacion();
            lista = sesion.createQuery("from EtiquetaFormularioSucursal where idUsuario=:idUsuario").setParameter("idUsuario", idUsuario).list();
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
    
    public Integer guardar(EtiquetaFormularioSucursal object) throws HibernateException 
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

    public void actualizar(EtiquetaFormularioSucursal object) throws HibernateException 
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
            EtiquetaFormularioSucursal object = (EtiquetaFormularioSucursal) sesion.get(EtiquetaFormularioSucursal.class,id); 
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

    public EtiquetaFormularioSucursal getById(int id) throws HibernateException 
    { 
       
        EtiquetaFormularioSucursal object = null;  
        try 
        { 
            iniciaOperacion(); 
            object = (EtiquetaFormularioSucursal) sesion.get(EtiquetaFormularioSucursal.class,id);
        } finally 
        { 
            sesion.close(); 
        }  

        return object; 
    }  

    public List lista() throws HibernateException 
    { 
        List<EtiquetaFormularioSucursal> lista = null;  

        try 
        { 
            iniciaOperacion(); 
            lista = sesion.createQuery("from EtiquetaFormularioSucursal").list(); 
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
