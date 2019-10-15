//
//  ViewController.swift
//  Mapview
//
//  Created by Artoon Solutions on 21/12/2018.
//  Copyright © 2018 Artoon Solutions. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

//custom class to add annotation pin.
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


@available(iOS 10.0, *)
class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    // initialize Array.
    var locationImageArray = NSMutableArray()
    var imageTextArray = NSMutableArray()
    var daysArray = NSMutableArray()
    var hoursArray = NSMutableArray()
    var kilometerArray = NSMutableArray()
    var dateArray = NSMutableArray()
    let locationArray = NSMutableArray()
    let annotationArray = NSMutableArray()
    
    // Collectionview Outlet.
    @IBOutlet weak var locationCollectionView: UICollectionView!
    
    // Mapview
    @IBOutlet weak var mapView: MKMapView!
    
    // LocationManager object.
    let locationManager = CLLocationManager()
    
    // source and destination CLLocationCoordinate2D object.
    var sourceLocation : CLLocationCoordinate2D?
    var destinationLocation1 : CLLocationCoordinate2D?
    var destinationLocation2 : CLLocationCoordinate2D?
    var destinationLocation3 : CLLocationCoordinate2D?
    var destinationLocation4 : CLLocationCoordinate2D?
    var destinationLocation5 : CLLocationCoordinate2D?
    let regionInMeter:Double = 20000
    
    let previousPinAry = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set values.
        locationImageArray.addObjects(from: ["location1.jpeg","location2.jpeg","location3.jpeg","location4.jpg","location5.jpg"])
        imageTextArray.addObjects(from: ["hiking","climbing","walking","travaling","running","walking"])
        daysArray.addObjects(from: ["Day 1","Day 2","Day 3","Day 4","Day 5","Day 6"])
        hoursArray.addObjects(from: ["8 hour","6 hour","7 hour","10 hour","5 hour","3 hour"])
        kilometerArray.addObjects(from: ["2 km","5 km","7 km","4 km","8 km"])
        dateArray.addObjects(from: ["3 Aug","4 Aug","5 Aug","6 Aug","7 Aug"])
        
        // Add all destinations & annotation pins.
        addDestinations()
        
        //To request location authorization when the app is in use.
        self.locationManager.requestWhenInUseAuthorization()
        
        // Set location manager to update
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
  
    }
    
    //set latitude and logitude and anotation pins for different locations.
    func addDestinations()
    {
        // Add 5 different locations.
        destinationLocation1 = CLLocationCoordinate2D(latitude: 21.2408, longitude: 72.8806)//motavarachha
        destinationLocation2 = CLLocationCoordinate2D(latitude: 21.1418, longitude: 72.7709)//vesu
        destinationLocation3 = CLLocationCoordinate2D(latitude: 21.4006, longitude: 72.9269)//kim
        destinationLocation4 = CLLocationCoordinate2D(latitude: 21.1926, longitude: 72.7997)//adajan
        destinationLocation5 = CLLocationCoordinate2D(latitude: 21.1255, longitude: 73.1122)//bardoli
        
        // Name of the different locations.
        let desPin1 = CustomPin(pinTitle: "Mota Varachha", pinSubTitle: "", location: destinationLocation1!)
        let desPin2 = CustomPin(pinTitle: "Vesu", pinSubTitle: "", location: destinationLocation2!)
        let desPin3 = CustomPin(pinTitle: "Kim", pinSubTitle: "", location: destinationLocation3!)
        let desPin4 = CustomPin(pinTitle: "Adajan", pinSubTitle: "", location: destinationLocation4!)
        let desPin5 = CustomPin(pinTitle: "Bardoli", pinSubTitle: "", location: destinationLocation5!)
        
        // Set first pin in mapview.
        mapView.addAnnotation(desPin1)
        
        // Store pin in previous pin array to remove previous route.
        previousPinAry.add(desPin1)
        
        // Add Objects in Location and Pins array.
        locationArray.addObjects(from: [destinationLocation1!,destinationLocation2!,destinationLocation3!,destinationLocation4!,destinationLocation5!])
        annotationArray.addObjects(from: [desPin1,desPin2,desPin3,desPin4,desPin5])
    }
    
    //MARK: LocationManager Delegates methods to get updated location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // get current location.
        sourceLocation  = manager.location!.coordinate
        print("location : \(sourceLocation!.latitude) \(sourceLocation!.longitude)")
        let userLocation = locations.last
        
        // Set Region.
        let viewRegion =  MKCoordinateRegion(center: (userLocation?.coordinate)!, latitudinalMeters: regionInMeter, longitudinalMeters: regionInMeter)
        self.mapView.setRegion(viewRegion, animated: true)
        
        // Add anotation pin for source location.
        let annotation = CustomPin(pinTitle: "Home", pinSubTitle: "", location: sourceLocation!)
        mapView.addAnnotation(annotation)
        
        // set route between source and first destination of five.
        setRoute(source: sourceLocation!, destination: destinationLocation1!)
    }
    
    //method to set route between source and destination.
    func setRoute(source:CLLocationCoordinate2D,destination:CLLocationCoordinate2D){
        
        // Create source and destination placemark.
        let sourcePlaceMark = MKPlacemark(coordinate: source)
        let destinationPlaceMark = MKPlacemark(coordinate: destination)
        
        // Set direction request object.
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile
    
        // Make direction request object.
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
    
    // mapview method to draw polyline path.
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
    
    
}

//MARK: TextField Delegate Method.
extension ViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
//MARK: Collection view delegates.
extension ViewController : UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locationArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LocationCollectionCell
        
        // Add all cell details.
        cell.locationImgV.image = UIImage(named:locationImageArray.object(at: indexPath.row) as! String)
        cell.imgTxtLabel.text = imageTextArray.object(at: indexPath.row) as? String
        cell.dayLabel.text = daysArray.object(at: indexPath.row) as? String
        cell.hourLabel.text = hoursArray.object(at: indexPath.row) as? String
        cell.kmLabel.text = kilometerArray.object(at: indexPath.row) as? String
        cell.dateLabel.text = dateArray.object(at: indexPath.row) as? String
        
        // Set cell and imageview rounded.
        cell.layoutIfNeeded()
        cell.layer.cornerRadius = 10
        cell.locationImgV.layer.cornerRadius = 10
        cell.locationImgV.clipsToBounds = true
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // To remove path from mapview.
        mapView.removeOverlays(mapView.overlays)
        
        // To remove previous destination anotation pin.
        mapView.removeAnnotation(previousPinAry.lastObject as! MKAnnotation)
        
        // Add anotation pin for new destination and store in previous array.
        mapView.addAnnotation(annotationArray.object(at: indexPath.row) as! MKAnnotation)
        previousPinAry.add(annotationArray.object(at: indexPath.row) as! MKAnnotation)
        
        // Set route between source and selected destination from collection view.
        setRoute(source: sourceLocation!, destination: locationArray.object(at: indexPath.row) as! CLLocationCoordinate2D)
        
    }
}



