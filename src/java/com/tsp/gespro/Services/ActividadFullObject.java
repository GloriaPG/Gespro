/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.Services;

import com.tsp.gespro.hibernate.pojo.Actividad;
import com.tsp.gespro.hibernate.pojo.Cliente;
import com.tsp.gespro.hibernate.pojo.Producto;
import com.tsp.gespro.hibernate.pojo.Promotorproyecto;
import com.tsp.gespro.hibernate.pojo.Proyecto;
import com.tsp.gespro.hibernate.pojo.Punto;
import com.tsp.gespro.hibernate.pojo.Usuarios;

/**
 *
 * @author gloria
 */
public class ActividadFullObject {
    private Actividad actividad;
    private Punto punto;
    private Proyecto proyecto;
    private Usuarios promotor;
    private DataUbicacion ubicacion;
    private Cliente cliente;
    private Producto producto;
    
    public  ActividadFullObject() {
    
    }

    /**
     * @return the punto
     */
    public Punto getPunto() {
        return punto;
    }

    /**
     * @param punto the punto to set
     */
    public void setPunto(Punto punto) {
        this.punto = punto;
    }

    /**
     * @return the actividad
     */
    public Actividad getActividad() {
        return actividad;
    }

    /**
     * @param actividad the actividad to set
     */
    public void setActividad(Actividad actividad) {
        this.actividad = actividad;
    }

    /**
     * @return the proyecto
     */
    public Proyecto getProyecto() {
        return proyecto;
    }

    /**
     * @param proyecto the proyecto to set
     */
    public void setProyecto(Proyecto proyecto) {
        this.proyecto = proyecto;
    }

    /**
     * @return the promotor
     */
    public Usuarios getPromotor() {
        return promotor;
    }

    /**
     * @param promotor the promotor to set
     */
    public void setPromotor(Usuarios promotor) {
        this.promotor = promotor;
    }

    /**
     * @return the ubicacion
     */
    public DataUbicacion getUbicacion() {
        return ubicacion;
    }

    /**
     * @param ubicacion the ubicacion to set
     */
    public void setUbicacion(DataUbicacion ubicacion) {
        this.ubicacion = ubicacion;
    }

    /**
     * @return the cliente
     */
    public Cliente getCliente() {
        return cliente;
    }

    /**
     * @param cliente the cliente to set
     */
    public void setCliente(Cliente cliente) {
        this.cliente = cliente;
    }

    /**
     * @return the producto
     */
    public Producto getProducto() {
        return producto;
    }

    /**
     * @param producto the producto to set
     */
    public void setProducto(Producto producto) {
        this.producto = producto;
    }

}
