/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package com.tsp.gespro.ws.request;

import java.util.Date;

/**
 *
 * @author leonardo
 */
public class EstanteriaDescripcionDtoRequest {
    
    private int idDescripcion;    
    private int idCompetencia;
    private int idEstatus;
    private double cantidad;
    private double precio;
    private Date fechaCaducidad;
    private String nombreEmbalaje;
    private int idRelacionConceptoCompetencia;
    private double precioOferta;
    private double unidadesAlmacen;

    /**
     * @return the idDescripcion
     */
    public int getIdDescripcion() {
        return idDescripcion;
    }

    /**
     * @param idDescripcion the idDescripcion to set
     */
    public void setIdDescripcion(int idDescripcion) {
        this.idDescripcion = idDescripcion;
    }

    /**
     * @return the idCompetencia
     */
    public int getIdCompetencia() {
        return idCompetencia;
    }

    /**
     * @param idCompetencia the idCompetencia to set
     */
    public void setIdCompetencia(int idCompetencia) {
        this.idCompetencia = idCompetencia;
    }

    /**
     * @return the idEstatus
     */
    public int getIdEstatus() {
        return idEstatus;
    }

    /**
     * @param idEstatus the idEstatus to set
     */
    public void setIdEstatus(int idEstatus) {
        this.idEstatus = idEstatus;
    }

    /**
     * @return the cantidad
     */
    public double getCantidad() {
        return cantidad;
    }

    /**
     * @param cantidad the cantidad to set
     */
    public void setCantidad(double cantidad) {
        this.cantidad = cantidad;
    }

    /**
     * @return the precio
     */
    public double getPrecio() {
        return precio;
    }

    /**
     * @param precio the precio to set
     */
    public void setPrecio(double precio) {
        this.precio = precio;
    }

    /**
     * @return the fechaCaducidad
     */
    public Date getFechaCaducidad() {
        return fechaCaducidad;
    }

    /**
     * @param fechaCaducidad the fechaCaducidad to set
     */
    public void setFechaCaducidad(Date fechaCaducidad) {
        this.fechaCaducidad = fechaCaducidad;
    }

    /**
     * @return the nombreEmbalaje
     */
    public String getNombreEmbalaje() {
        return nombreEmbalaje;
    }

    /**
     * @param nombreEmbalaje the nombreEmbalaje to set
     */
    public void setNombreEmbalaje(String nombreEmbalaje) {
        this.nombreEmbalaje = nombreEmbalaje;
    }
    
     /**
     * @return the idRelacionConceptoCompetencia
     */
    public int getIdRelacionConceptoCompetencia() {
        return idRelacionConceptoCompetencia;
    }

    /**
     * @param idRelacionConceptoCompetencia the idRelacionConceptoCompetencia to set
     */
    public void setIdRelacionConceptoCompetencia(int idRelacionConceptoCompetencia) {
        this.idRelacionConceptoCompetencia = idRelacionConceptoCompetencia;
    }
    /**
     * @return the unidadesAlmacen
     */
    public double getUnidadesAlmacen() {
	return unidadesAlmacen;
    }

    /**
     * @param unidadesAlmacen the unidadesAlmacen to set
     */
    public void setUnidadesAlmacen(double unidadesAlmacen) {
	this.unidadesAlmacen = unidadesAlmacen;
    }
    /**
     * @return the precioOferta
     */
    public double getPrecioOferta() {
    	return precioOferta;
    }

    /**
     * @param precioOferta the precioOferta to set
     */
    public void setPrecioOferta(double precioOferta) {
    	this.precioOferta = precioOferta;
    }
}
