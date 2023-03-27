//
//  ViewController.swift
//  DGarciaMapas
//
//  Created by MacBookMBA3 on 21/03/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    
    // 19.427484, -99.1687087
    // 19.4272668, -99.1658356
    // 19.4264253, -99.1737045
    // 19.434395, -99.191860
    // 19.426402, -99.167054
    
    let mapView = MKMapView()
    
    let slider = UISlider()
    
    let label = UILabel()
    
    let coordinate = CLLocation(latitude: 19.4270245, longitude: -99.1676647)
    var locationManager = CLLocationManager()
    var location : CLLocation!
    var sucursales : [Sucursal] = []
    var selectedAnnotation : MKPointAnnotation?
    
    override func viewDidAppear(_ animated: Bool) {
    
        sucursales.append(Sucursal(latitude: 19.427484, longitude: -99.1687087, nombre: "sucursal 1"))
        sucursales.append(Sucursal(latitude: 19.4272668, longitude: -99.1658356, nombre: "sucursal 2"))
        sucursales.append(Sucursal(latitude: 19.434395, longitude: -99.191860, nombre: "sucursal 3"))
        sucursales.append(Sucursal(latitude: 19.426402, longitude: -99.167054, nombre: "sucursal 4"))
        sucursales.append(Sucursal(latitude: 19.435169, longitude: -99.167421, nombre: "sucursal 5"))
        
        
        AddCustomPin(sucursales: sucursales)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let safeG = view.safeAreaLayoutGuide
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
        mapView.showsUserLocation = true
        
        
        slider.maximumValue = 1000
        slider.minimumValue = 200
        slider.value = 500
        slider.addTarget(self, action: #selector(SliderValueChange), for: .touchUpInside)
        
        
        label.text = "\(slider.value) mts"
        label.textAlignment = .center
        
        
        view.addSubview(mapView)
        view.addSubview(slider)
        view.addSubview(label)
        
        //mapView.frame = view.bounds
        mapView.translatesAutoresizingMaskIntoConstraints =  false
        slider.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: safeG.topAnchor, constant: 0),
            mapView.leftAnchor.constraint(equalTo: safeG.leftAnchor, constant: 10),
            mapView.rightAnchor.constraint(equalTo: safeG.rightAnchor, constant: -10),
            mapView.bottomAnchor.constraint(equalTo: safeG.bottomAnchor, constant: -100),
            
            label.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 10),
            label.leftAnchor.constraint(equalTo: safeG.leftAnchor, constant: 10),
            label.rightAnchor.constraint(equalTo: safeG.rightAnchor, constant: -10.0),
            label.heightAnchor.constraint(equalToConstant: 20),
            
            
            slider.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 0),
            slider.leftAnchor.constraint(equalTo: safeG.leftAnchor, constant: 10),
            slider.rightAnchor.constraint(equalTo: safeG.rightAnchor, constant: -10),
            slider.bottomAnchor.constraint(equalTo: safeG.bottomAnchor)
        ])
        
        DispatchQueue.main.async { [self] in
            mapView.centerToLocation(location)
            mapView.addOverlay(MKCircle(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), radius: Double(slider.value)))
        }
        
    }

    @objc func SliderValueChange() {
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        //mapView.centerToLocation(location, regionRadius: Double(slider.value))
        label.text = "\(slider.value) mts"
        
        AddCustomPin(sucursales: sucursales)
        mapView.addOverlay(MKCircle(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), radius: Double(slider.value)))
    }

    private func AddCustomPin(sucursales : [Sucursal]) {
        
        for sucursal in sucursales {
            if location.distance(from: CLLocation(latitude: sucursal.latitude, longitude: sucursal.longitude)) <= Double(slider.value) {
                
                let pin = MKPointAnnotation()
                pin.coordinate = CLLocationCoordinate2D(latitude: sucursal.latitude, longitude: sucursal.longitude)
                pin.title = sucursal.nombre
                mapView.addAnnotation(pin)
            }
        }
    }
    
 
    func findMyLocation(_ sender: Any) {
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: center, span: span)
        self.mapView.setRegion(region, animated: true)
        
    }
    
    
}

private extension MKMapView {
    
    
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000){
        let coordinateRegion = MKCoordinateRegion(
          center: location.coordinate,
          latitudinalMeters: regionRadius,
          longitudinalMeters: regionRadius)
          setRegion(coordinateRegion, animated: true)
    }
    
    
}


extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations.last as CLLocation?
    }
    
}


extension ViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
         circleRenderer.strokeColor = UIColor.blue
         circleRenderer.lineWidth = 1.0
         return circleRenderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            annotationView?.canShowCallout = true
            
        } else {
            annotationView?.annotation = annotation
        }
        
//        let image = UIImageView(image: UIImage(systemName: "mappin")?.withRenderingMode(.alwaysTemplate))
//
//        image.tintColor = .red
        
        annotationView?.image = UIImage(systemName: "mappin")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        
        
        return annotationView
    }
    
    
}
