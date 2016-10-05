/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package com.tsp.gespro.ws.request;

import java.util.Date;
import java.util.List;

/**
 *
 * @author leonardo
 */
public class EstanteriaDtoRequest {
    
    private int idEstanteria;
    private int idEstatus;
    private int idCliente;
    private int idConcepto;
    private double cantidad;
    private double precio;
    private Date fecha;
    private Date fechaCaducidad;
    private String nombreEmbalaje;
    private double precioOferta;
    private double unidadesAlmacen;
    
    private List<EstanteriaDescripcionDtoRequest> estanteriaDescripcionDtoRequest;

    /**
     * @return the idEstanteria
     */
    public int getIdEstanteria() {
        return idEstanteria;
    }

    /**
     * @param idEstanteria the idEstanteria to set
     */
    public void setIdEstanteria(int idEstanteria) {
        this.idEstanteria = idEstanteria;
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
     * @return the idCliente
     */
    public int getIdCliente() {
        return idCliente;
    }

    /**
     * @param idCliente the idCliente to set
     */
    public void setIdCliente(int idCliente) {
        this.idCliente = idCliente;
    }

    /**
     * @return the idConcepto
     */
    public int getIdConcepto() {
        return idConcepto;
    }

    /**
     * @param idConcepto the idConcepto to set
     */
    public void setIdConcepto(int idConcepto) {
        this.idConcepto = idConcepto;
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
     * @return the fecha
     */
    public Date getFecha() {
        return fecha;
    }

    /**
     * @param fecha the fecha to set
     */
    public void setFecha(Date fecha) {
        this.fecha = fecha;
    }

    /**
     * @return the estanteriaDescripcionDtoRequest
     */
    public List<EstanteriaDescripcionDtoRequest> getEstanteriaDescripcionDtoRequest() {
        return estanteriaDescripcionDtoRequest;
    }

    /**
     * @param estanteriaDescripcionDtoRequest the estanteriaDescripcionDtoRequest to set
     */
    public void setEstanteriaDescripcionDtoRequest(List<EstanteriaDescripcionDtoRequest> estanteriaDescripcionDtoRequest) {
        this.estanteriaDescripcionDtoRequest = estanteriaDescripcionDtoRequest;
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
