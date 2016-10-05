/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.ws.response;

import java.io.Serializable;
import java.util.Date;

/**
 *
 * @author DXN
 */
public class WsItemProspecto implements Serializable{
    private int idProspecto;
    private int idEmpresa;
    private String razonSocial;
    private String lada;
    private String telefono;
    private String celular;
    private String correo;
    private String contacto;
    private int idEstatus;
    private String descripcion;
    private double latitud;
    private double longitud;
    private String direccion;
    private String nombreImagenProspecto;
    private int idUsuarioVendedor;
    private Date fechaRegistro;
    private String dirNumeroExterior;
    private String dirNumeroInterior;
    private String dirCodigoPostal;
    private String dirColonia;

    public int getIdProspecto() {
        return idProspecto;
    }

    public void setIdProspecto(int idProspecto) {
        this.idProspecto = idProspecto;
    }

    public int getIdEmpresa() {
        return idEmpresa;
    }

    public void setIdEmpresa(int idEmpresa) {
        this.idEmpresa = idEmpresa;
    }

    public String getRazonSocial() {
        return razonSocial;
    }

    public void setRazonSocial(String razonSocial) {
        this.razonSocial = razonSocial;
    }

    public String getLada() {
        return lada;
    }

    public void setLada(String lada) {
        this.lada = lada;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getCelular() {
        return celular;
    }

    public void setCelular(String celular) {
        this.celular = celular;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getContacto() {
        return contacto;
    }

    public void setContacto(String contacto) {
        this.contacto = contacto;
    }

    public int getIdEstatus() {
        return idEstatus;
    }

    public void setIdEstatus(int idEstatus) {
        this.idEstatus = idEstatus;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public double getLatitud() {
        return latitud;
    }

    public void setLatitud(double latitud) {
        this.latitud = latitud;
    }

    public double getLongitud() {
        return longitud;
    }

    public void setLongitud(double longitud) {
        this.longitud = longitud;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public String getNombreImagenProspecto() {
        return nombreImagenProspecto;
    }

    public void setNombreImagenProspecto(String nombreImagenProspecto) {
        this.nombreImagenProspecto = nombreImagenProspecto;
    }

    public int getIdUsuarioVendedor() {
        return idUsuarioVendedor;
    }

    public void setIdUsuarioVendedor(int idUsuarioVendedor) {
        this.idUsuarioVendedor = idUsuarioVendedor;
    }

    public Date getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(Date fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public String getDirNumeroExterior() {
        return dirNumeroExterior;
    }

    public void setDirNumeroExterior(String dirNumeroExterior) {
        this.dirNumeroExterior = dirNumeroExterior;
    }

    public String getDirNumeroInterior() {
        return dirNumeroInterior;
    }

    public void setDirNumeroInterior(String dirNumeroInterior) {
        this.dirNumeroInterior = dirNumeroInterior;
    }

    public String getDirCodigoPostal() {
        return dirCodigoPostal;
    }

    public void setDirCodigoPostal(String dirCodigoPostal) {
        this.dirCodigoPostal = dirCodigoPostal;
    }

    public String getDirColonia() {
        return dirColonia;
    }

    public void setDirColonia(String dirColonia) {
        this.dirColonia = dirColonia;
    }
    
    
    
}
