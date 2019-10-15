//
//  ReadMe.md
//  Apple MapKit Tutorial
//
//  Created by Artoon Solution on 21/12/2018.
//  Copyright © 2018 Artoon Solution. All rights reserved.
//

Apple MapKit 

MapKit is Apple's framework that allows to embed fully functional map interface into mobile application. The map provided by this framework includes many features of the Maps in both iOS and OS X. You can display standard street-level map information, satellite imagery, or a combination of the two. You can zoom, pan, and pitch the map programmatically, display 3D buildings, and annotate the map with custom information. The Map Kit framework also provides automatic support for the touch events that let users zoom and pan the map.

This tutorial uses Mapkit framework and CoreLoaction framework to show route between source to multiple destination. It contains collectionview of destination locations. Based on selected destination it set route direction from source to destination location using mapkit. LocationManager provides source location is user's current location. Tutorial shows how to display user’s current location on a MapView programmatically as well as how to create MapView using Xcode Storyboard. You will also learn how to drop a Pin(MKPointAnnotation) at user’s current location, set MKPointAnnotation custom title and set direction using MKDirections.

Get User Location : 
To get a user’s current location, need to import MapKit and CoreLocation. Need to create a CLLocationManager and implement  CLLocationManagerDelegate. To get user current location request to location authorization.
didUpdateLocations method will provide user's updated location everytime.

MKDirections : 
The MKDirections class was introduced into iOS  is used to generate directions from one geographical location to another. MKDirection provides MKPlacemark to set source and destination. You can make request to set route using MKDirection.request object and it also provide parmeters to set transport type. MKOverlayPathRenderer use to set directionpath using gredient polyline 




> first need to import framework.

    import MapKit
    import CoreLocation
    
> Custom class to add annotation pin. 
    
        class CustomPin : NSObject,MKAnnotation
        {
            var coordinate: CLLocationCoordinate2D
            var title : String?
            var subTitle : String?
            init(pinTitle : String,pinSubTitle : String,location:CLLocationCoordinate2D) {
                self.title = pinTitle
                self.subTitle = pinSubTitle
                self.coordinate = location
            }
        } 
                                                                                       
> Create locationmanager and mapview outlet.

        @IBOutlet weak var mapView: MKMapView!
        let locationManager = CLLocationManager()
       
> Request location authorization and set show user location flag true.

        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
        
> CoreLocation Delegate Method provides user's updated location 

      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
      {
        
        sourceLocation  = manager.location!.coordinate
        print("location : \(sourceLocation!.latitude) \(sourceLocation!.longitude)")
        let userLocation = locations.last
        let viewRegion =  MKCoordinateRegion(center: (userLocation?.coordinate)!, latitudinalMeters: regionInMeter, longitudinalMeters: regionInMeter)
        self.mapView.setRegion(viewRegion, animated: true)
        
        let annotation = CustomPin(pinTitle: "Home", pinSubTitle: "", location: sourceLocation!)
        mapView.addAnnotation(annotation)
        setRoute(source: sourceLocation!, destination: destinationLocation1!)
    }
    
> Method to set route between source and destination.


     func setRoute(source:CLLocationCoordinate2D,destination:CLLocationCoordinate2D){
         
         let sourcePlaceMark = MKPlacemark(coordinate: source)
         let destinationPlaceMark = MKPlacemark(coordinate: destination)
         let directionRequest = MKDirections.Request()
         
         directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
         directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
         directionRequest.transportType = .automobile
     
         let direction = MKDirections(request: directionRequest)
         direction.calculate { (response, error) in
             guard let directionResonse = response else {
                 if let error = error {
                     print("we have error getting directions==\(error.localizedDescription)")
                 }
                 return
             }
             for route in directionResonse.routes {
                 
                 self.mapView.addOverlay(route.polyline)
                 self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
             }
          }
         self.mapView.delegate = self
         locationManager.stopUpdatingLocation()
    }
    
> Mapview method to draw polyline path.
                
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       
        let overlay = overlay as? MKPolyline
        /// define a list of colors you want in your gradient
        let gradientColors = [UIColor.green, UIColor.blue, UIColor.red]
        
        /// Initialise a GradientPathRenderer with the colors
        let polylineRenderer = GradientPathRenderer(polyline: overlay!, colors: gradientColors)
        
        /// set a linewidth
        polylineRenderer.lineWidth = 10
        return polylineRenderer
        
    }
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
