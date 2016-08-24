/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.hibernate.dao;

import com.tsp.gespro.hibernate.pojo.CampoAdicionalCliente;
import com.tsp.gespro.hibernate.pojo.HibernateUtil;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.Transaction;
import com.tsp.gespro.hibernate.pojo.CampoAdicionalClienteValor;
import java.util.List;
import java.util.Map;

/**
 *
 * @author edgar
 */
public class CampoAdicionalClienteValorDAO {

    private Session sesion;
    private Transaction tx;

    public CampoAdicionalClienteValorDAO() {
    }

    public void guardarCambios(Map<String, String[]> campos) {
        CampoAdicionalClienteDAO cacdao = new CampoAdicionalClienteDAO();
        String data = "";
        for (Map.Entry<String, String[]> entry : campos.entrySet()) {
            data = entry.getKey();
            break;
        }
        data = data.replace("[", "").replace("]", "").replace("\"", "");
        String[] parts = data.split("[,{]");
        int counter = 1;
        CampoAdicionalClienteValor cacv = new CampoAdicionalClienteValor();
        for (String line : parts) {
            if (line != null && !line.isEmpty()) {
                String[] lineParts = line.replaceAll("[{]", "").replaceAll("[}]", "").split(":");
                switch (counter) {
                    case 1:
                        CampoAdicionalCliente cac = new CampoAdicionalCliente();
                        cac = cacdao.getById(Integer.parseInt(lineParts[1]));
                        cacv.setCampoAdicionalCliente(cac);
                        break;
                    case 2:
                        cacv.setIdCliente(Integer.parseInt(lineParts[1]));
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

    public void saveObject(CampoAdicionalClienteValor cacv) {
        CampoAdicionalClienteValor campoExistente = getByIdAndCliente(cacv.getCampoAdicionalCliente().getIdCampoAdicionalCliente(), cacv.getIdCliente());
        if (campoExistente != null) {
            cacv.setIdCampoAdicionalClienteValor(campoExistente.getIdCampoAdicionalClienteValor());
        }
        if (cacv.getIdCampoAdicionalClienteValor() > 0) {
            actualizar(cacv);
        } else {
            guardar(cacv);

        }
    }

    public Integer guardar(CampoAdicionalClienteValor object) throws HibernateException {
        Integer id = 0;
        try {
            iniciaOperacion();
            id = (Integer) sesion.save(object);
            tx.commit();
        } catch (HibernateException he) {
            manejaExcepcion(he);
            throw he;
        } finally {
            sesion.close();
        }

        return id;
    }

    public void actualizar(CampoAdicionalClienteValor object) throws HibernateException {
        try {

            iniciaOperacion();
            sesion.update(object);
            tx.commit();

        } catch (HibernateException he) {
            manejaExcepcion(he);
            throw he;
        } finally {
            sesion.close();
        }
    }

    public void eliminar(int id) throws HibernateException {
        try {
            iniciaOperacion();
            CampoAdicionalClienteValor object = (CampoAdicionalClienteValor) sesion.get(CampoAdicionalClienteValor.class, id);
            sesion.delete(object);
            tx.commit();
        } catch (HibernateException he) {
            manejaExcepcion(he);
            throw he;
        } finally {
            sesion.close();
        }
    }

    public CampoAdicionalClienteValor getByIdAndCliente(int id, int idCliente) throws HibernateException {
        CampoAdicionalClienteValor object = null;
        try {
            iniciaOperacion();            
            object = (CampoAdicionalClienteValor) sesion.createQuery("select CACV from CampoAdicionalClienteValor CACV join CACV.campoAdicionalCliente CAC where CAC.idCampoAdicionalCliente=:idCampoAdicionalCliente and CACV.idCliente=:idCliente")
                    .setParameter("idCampoAdicionalCliente", id).setParameter("idCliente", idCliente).uniqueResult();            
        } finally {
            sesion.close();
        }

        return object;
    }

    public List lista() throws HibernateException {
        List<CampoAdicionalClienteValor> lista = null;

        try {
            iniciaOperacion();
            lista = sesion.createQuery("from CampoAdicionalClienteValor").list();
        } finally {
            sesion.close();
        }

        return lista;
    }

    public List getLista() {
        return lista();
    }

    private void iniciaOperacion() throws HibernateException {
        sesion = HibernateUtil.getSessionFactory().openSession();
        tx = sesion.beginTransaction();
    }

    private void manejaExcepcion(HibernateException he) throws HibernateException {
        tx.rollback();
        throw new HibernateException("Ocurrió un error en la capa de acceso a datos", he);
    }
}
