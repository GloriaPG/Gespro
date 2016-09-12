/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.tsp.gespro.Services;

import com.google.maps.GeoApiContext;
import com.google.maps.GeocodingApi;
import com.google.maps.OkHttpRequestHandler;
import com.google.maps.model.GeocodingResult;
import com.google.maps.model.LatLng;

/**
 *
 * @author gloria
 */
public class ClientGoogleServicesAPI {
    
    public DataUbicacion getCiudadRegion(double lat,double lng) throws Exception{
       // @Gloria Palma Gonzalez
       // Esta es el api key de google: AIzaSyCWOsSW7Z8AVvO5wTXTI8n-RWQyNt9AnZs
       // si en algún momento deja de funcionar
       // se puede generar una nueva. Seguir la documentación:
       // https://github.com/googlemaps/google-maps-services-java/tree/v0.1.15
       GeoApiContext context = new GeoApiContext().setApiKey("AIzaSyCWOsSW7Z8AVvO5wTXTI8n-RWQyNt9AnZs");
       
       LatLng coordenadas=new LatLng(lat,lng);
       GeocodingResult[] results =  GeocodingApi.reverseGeocode(context,coordenadas).await();
       DataUbicacion ubicacion= new DataUbicacion();
       ubicacion.setCiudad(results[0].addressComponents[3].longName);
       ubicacion.setEstado(results[1].addressComponents[2].longName);
       ubicacion.setNombrCortoEstado(results[1].addressComponents[2].shortName);
       ubicacion.setNombreCortoCiudad(results[0].addressComponents[3].shortName);
       ubicacion.setLat(lat);
       ubicacion.setLng(lng);
       return ubicacion; 
    }
   
}
