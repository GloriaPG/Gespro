package com.tsp.gespro.Services;

import com.tsp.gespro.dto.Ubicacion;
import java.util.List;

import com.tsp.gespro.hibernate.pojo.HibernateUtil;
import org.hibernate.Session;
import com.tsp.gespro.hibernate.dao.RepartoDAO;
import com.tsp.gespro.hibernate.pojo.Reparto;
import com.tsp.gespro.hibernate.pojo.Promotorproyecto;
import com.tsp.gespro.hibernate.dao.PromotorproyectoDAO;
import com.tsp.gespro.hibernate.pojo.Producto;
import com.tsp.gespro.hibernate.dao.ProductoDAO;
import com.tsp.gespro.hibernate.pojo.Usuarios;
import com.tsp.gespro.hibernate.pojo.Proyecto;
import com.tsp.gespro.hibernate.dao.UsuariosDAO;
import com.tsp.gespro.hibernate.pojo.Actividad;
import com.tsp.gespro.hibernate.dao.ActividadDAO;
import com.tsp.gespro.hibernate.dao.CampoAdicionalClienteDAO;
import com.tsp.gespro.hibernate.dao.ClienteDAO;
import com.tsp.gespro.hibernate.dao.ClientesClientesDAO;
import com.tsp.gespro.hibernate.dao.ProyectoDAO;
import com.tsp.gespro.hibernate.dao.PuntoDAO;
import com.tsp.gespro.hibernate.dao.FotoActividadDAO;
import com.tsp.gespro.hibernate.pojo.FotoActividad;
import com.tsp.gespro.hibernate.pojo.Cobertura;
import com.tsp.gespro.hibernate.pojo.Coberturaproyecto;
import com.tsp.gespro.hibernate.pojo.Producto;
import com.tsp.gespro.hibernate.pojo.Punto;

import com.tsp.gespro.hibernate.dao.ConceptoRegistroFotograficoDAO;
import com.tsp.gespro.hibernate.pojo.ConceptoRegistroFotografico;
import java.util.ArrayList;
import com.tsp.gespro.hibernate.dao.CoberturaProyectoDAO;
import com.tsp.gespro.hibernate.pojo.CampoAdicionalClienteValor;
import com.tsp.gespro.hibernate.pojo.Cliente;

import org.hibernate.Session;
import org.hibernate.Transaction;

public class Allservices {
    
    private static PromotorproyectoDAO promotorproyectoDAO;
    private static UsuariosDAO usuariosDAO;
    private static ProyectoDAO proyectoDAO;    
    private static ProductoDAO productoDAO;
    private static ActividadDAO actividadDAO;
    private static CoberturaProyectoDAO coberturaproyectoDAO;
    private static ConceptoRegistroFotograficoDAO conceptoregistrofotograficoDAO;
    private static CampoAdicionalClienteDAO campoadicionalcliente;

    public Allservices() {
    }
    
    public List queryConceptoRegistroFotografico(String where){  
        
            List<ConceptoRegistroFotografico> lista = null;  
            Session session = null;

        try 
        { 
            session = HibernateUtil.getSessionFactory().openSession(); 
            Transaction tx = session.beginTransaction(); 
            String query = "from ConceptoRegistroFotografico "+where;
            lista = session.createQuery(query).list(); 
        }
        finally 
        { 
            session.close(); 
        }  

        return lista; 
    }
    
    public List queryCobertura(String where){  
        
            List<Cobertura> lista = null;  
            Session session = null;

        try 
        { 
            session = HibernateUtil.getSessionFactory().openSession(); 
            Transaction tx = session.beginTransaction(); 
            String query = "from Cobertura "+where;
            lista = session.createQuery(query).list(); 
        }
        finally 
        { 
            session.close(); 
        }  

        return lista; 
    }
    
    public List queryFotoActividad(String where){  
        
            List<FotoActividad> lista = null;  
            Session session = null;

        try 
        { 
            session = HibernateUtil.getSessionFactory().openSession(); 
            Transaction tx = session.beginTransaction(); 
            String query = "from FotoActividad "+where;
            lista = session.createQuery(query).list(); 
        }
        finally 
        { 
            session.close(); 
        }  

        return lista; 
    }
    
    
    
    public List queryCoberturaProyecto(String where){  
        
            List<Coberturaproyecto> lista = null;  
            Session session = null;

        try 
        { 
            session = HibernateUtil.getSessionFactory().openSession(); 
            Transaction tx = session.beginTransaction(); 
            String query = "from Coberturaproyecto "+where;
            lista = session.createQuery(query).list(); 
        }
        finally 
        { 
            session.close(); 
        }  

        return lista; 
    }
    
    
    public List QueryPromotorProyecto(String where){  
        
            List<Promotorproyecto> lista = null;  
            Session session = null;

        try 
        { 
            session = HibernateUtil.getSessionFactory().openSession(); 
            Transaction tx = session.beginTransaction(); 
            String query = "from Promotorproyecto "+where;
            lista = session.createQuery(query).list(); 
        }
        finally 
        { 
            session.close(); 
        }  

        return lista; 
    }
    
    
    public List QueryUsuariosDAO(String where){  
        
            List<Usuarios> lista = null;  
            Session session = null;

        try 
        { 
            session = HibernateUtil.getSessionFactory().openSession(); 
            Transaction tx = session.beginTransaction(); 
            String query = "from Usuarios "+where;
            lista = session.createQuery(query).list(); 
        }
        finally 
        { 
            session.close(); 
        }  

        return lista; 
    }
    
    public List queryProyectoDAO(String where) {

        List<Proyecto> lista = null;
        Session session = null;

        try {
            session = HibernateUtil.getSessionFactory().openSession();
            Transaction tx = session.beginTransaction();
            String query = "from Proyecto " + where;
            lista = session.createQuery(query).list();
        } finally {
            session.close();
        }
        
        return lista;
    }
    
    public List<CampoAdicionalClienteValor> queryCampoAdicionalClienteValorDAO(String where) {

        List<CampoAdicionalClienteValor> lista = null;
        Session session = null;

        try {
            session = HibernateUtil.getSessionFactory().openSession();
            Transaction tx = session.beginTransaction();
            String query = "from CampoAdicionalClienteValor " + where;
            lista = session.createQuery(query).list();
        } finally {
            session.close();
        }
        
        return lista;
    }
    
    public List queryPromotorProyectoDAO(String where) {

        List<Promotorproyecto> lista = null;
        Session session = null;

        try {
            session = HibernateUtil.getSessionFactory().openSession();
            Transaction tx = session.beginTransaction();
            String query = "from Promotorproyecto " + where;
            lista = session.createQuery(query).list();
        } finally {
            session.close();
        }
        
        return lista;
    }

    public List QueryProductosDAO(String where){  
        
            List<Producto> lista = null;  
            Session session = null;

        try 
        { 
            session = HibernateUtil.getSessionFactory().openSession(); 
            Transaction tx = session.beginTransaction(); 
            String query = "from Producto "+where;
            lista = session.createQuery(query).list(); 
        }
        finally 
        { 
            session.close(); 
        }  

        return lista; 
    }
     public List queryPuntoDAO(String where){  
        
            List<Punto> lista = null;  
            Session session = null;

        try 
        { 
            session = HibernateUtil.getSessionFactory().openSession();  
            String query = "from Punto "+where;
            System.out.println("Lista punto "+query);
            lista = session.createQuery(query).list(); 
            System.out.println("Lista size "+lista.size());
        }
        finally 
        { 
            session.close(); 
        }  
        
        return lista; 
    }
    
     public List QueryActividadDAO(String where){  
        
            List<Actividad> lista = null;  
            Session session = null;

        try 
        { 
            session = HibernateUtil.getSessionFactory().openSession(); 
            Transaction tx = session.beginTransaction(); 
            String query = "from Actividad "+where;
            lista = session.createQuery(query).list(); 
        }
        finally 
        { 
            session.close(); 
        }  

        return lista; 
    }
    
     
     public List getProyectoByEmpresa(String empresa){  
        
            List<Proyecto> lista = new ArrayList<>();  

        try 
        { 
            List<Cliente> clientes=queryClienteDAO("where ID_EMPRESA="+empresa);
            List<Proyecto> proyectosByCliente=new ArrayList<>();
            for(Cliente obj:clientes){
                proyectosByCliente=queryProyectoDAO("where id_cliente="+obj.getIdCliente());
                for(Proyecto proyectoItem:proyectosByCliente){
                    lista.add(proyectoItem);
                }
            }
        }
        catch(Exception e){
            System.out.println("Error : " + e.getMessage());
        }
        return lista; 
    }
    
     public List queryRepartoDAO(String where){  
        
            List<Reparto> lista = null;  
            Session session = null;

        try 
        { 
            session = HibernateUtil.getSessionFactory().openSession(); 
            Transaction tx = session.beginTransaction(); 
            String query = "from Reparto "+where;
            lista = session.createQuery(query).list(); 
        }
        finally 
        { 
            session.close(); 
        }  

        return lista; 
    }
    
    public List queryCoberturaProyectoDAO(String where){  
        
            List<Coberturaproyecto> lista = null;  
            Session session = null;

        try 
        { 
            session = HibernateUtil.getSessionFactory().openSession(); 
            Transaction tx = session.beginTransaction(); 
            String query = "from CoberturaProyecto "+where;
            lista = session.createQuery(query).list(); 
        }
        finally 
        { 
            session.close(); 
        }  

        return lista; 
    }
    
    public List queryClienteDAO(String where){  
        
            List<Cliente> lista = null;  
            Session session = null;

        try 
        { 
            session = HibernateUtil.getSessionFactory().openSession(); 
            Transaction tx = session.beginTransaction(); 
            String query = "from Cliente "+where;
            lista = session.createQuery(query).list(); 
        }
        finally 
        { 
            session.close(); 
        }  

        return lista; 
    }
      
    public List getActividadesFull(List<Actividad> listaActividades){  
        // Lista de objeto con los objectos de actividades, punto y proyeco
        // Por actividad.
        List<ActividadFullObject> lista = new ArrayList<>();
        ActividadFullObject actividadFull;
        
        // Punto
        Punto punto;
        PuntoDAO puntoDAO=new PuntoDAO();
        
        // Proyecto
        Proyecto proyecto;
        ProyectoDAO proyectoDAO=new ProyectoDAO();
        
        //Promotor
        Usuarios promotor;
        UsuariosDAO promotorDAO=new UsuariosDAO();
        
        // Cliente
        Cliente cliente;
        ClienteDAO clienteDAO=new ClienteDAO();
        
        //Ubicacion
        DataUbicacion ubicacion=new DataUbicacion();
        
        //  Producto
        Producto producto=new Producto();
        ProductoDAO productoDAO=new ProductoDAO();
        
        // Cliente Geocode google
        ClientGoogleServicesAPI api=new ClientGoogleServicesAPI();
        
        for (Actividad obj: listaActividades) {
           actividadFull=new ActividadFullObject();
           // Buscar objeto punto de esta actividad.
           punto=puntoDAO.getById(obj.getIdPunto());
           if(punto!=null){
               actividadFull.setPunto(punto);
           }
           
           // Buscar objeto proyecto de esta actividad.
           proyecto=proyectoDAO.getById(obj.getIdProyecto());
           if(proyecto!=null){
               actividadFull.setProyecto(proyecto);
           }
           
           // Setear actividad a el objeto ActividadFullObject
           actividadFull.setActividad(obj);
           
           // Setear promotor
           promotor=promotorDAO.getById(obj.getIdUser());
           if(promotor != null){
             actividadFull.setPromotor(promotor);
           }
           
           // Setear cliente al que pertenece el proyecto.
           cliente=clienteDAO.getById(proyecto.getIdUser());
           if(cliente!=null){
               actividadFull.setCliente(cliente);
           }
           
           if(obj.getIdProducto()!=null){
               producto=productoDAO.getById(obj.getIdProducto());
               actividadFull.setProducto(producto);
           }
           // Agregar ubicacion
           //Tipo de punto : ciudad 2 , Cliente 1, lugar 3
           // Si es diferente de 2 sacar estado y ciudad por lt y lng.
           if(punto.getTipo()!=2){
              try{
                ubicacion=api.getCiudadRegion(punto.getLatitud(),punto.getLongitud());
                actividadFull.setUbicacion(ubicacion);
              }catch(Exception e){
                  System.out.print("Ocurrio un error intentando sacar ciudad y estado");
                  System.out.print("punto_id :" + punto.getIdPunto());
                  e.printStackTrace();
              }
           }
           // Aegregar objeto ActividadFullObject a la lista.
           lista.add(actividadFull);
        }
        
        return lista; 
    }
}
