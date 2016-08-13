package com.tsp.gespro.hibernate.pojo;
// Generated 13/08/2016 01:15:33 PM by Hibernate Tools 3.6.0



/**
 * Producto generated by hbm2java
 */
public class Producto  implements java.io.Serializable {


     private Integer idProducto;
     private String nombre;
     private String descripcion;
     private Integer idProyecto;

    public Producto() {
    }

	
    public Producto(String nombre) {
        this.nombre = nombre;
    }
    public Producto(String nombre, String descripcion, Integer idProyecto) {
       this.nombre = nombre;
       this.descripcion = descripcion;
       this.idProyecto = idProyecto;
    }
   
    public Integer getIdProducto() {
        return this.idProducto;
    }
    
    public void setIdProducto(Integer idProducto) {
        this.idProducto = idProducto;
    }
    public String getNombre() {
        return this.nombre;
    }
    
    public void setNombre(String nombre) {
        this.nombre = nombre;
    }
    public String getDescripcion() {
        return this.descripcion;
    }
    
    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
    public Integer getIdProyecto() {
        return this.idProyecto;
    }
    
    public void setIdProyecto(Integer idProyecto) {
        this.idProyecto = idProyecto;
    }




}


