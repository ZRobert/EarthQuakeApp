//
//  ViewController.swift
//  EarthQuakeApp
//
//  Created by Robert Payne on 12/15/15.
//  Copyright © 2015 Robert Payne. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AudioToolbox

class ViewController: UIViewController, MKMapViewDelegate, USGSDataRequestDelegate {
    //Properties
    @IBOutlet weak var mapView: MKMapView!
    var dataRequester = USGSDataRequest.init()
    
    //Functions
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpMapView()
        self.setUpDataRequester()
    }
    
    //MapView Delegate Methods
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "earthQuakeNode"
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView!.image = UIImage(named:"rift")!
            annotationView!.canShowCallout = true
        }
        else {
            
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for view in views {
            let scaleDown = CGAffineTransformMakeScale(0.0, 0.8)
            let scaleUp = CGAffineTransformMakeScale(1.0, 1.0)
            
            view.transform = scaleDown
            UIView.animateWithDuration(1.5, delay: 0.2, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                view.transform = scaleUp
                }, completion: nil)
            
        }
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        let randomNumber = rand() % 4
        if (randomNumber == 0) {
            self.shakeAnimation(mapView)
        }    }
    
    func mapViewWillStartLoadingMap(mapView: MKMapView) {
        let randomNumber = rand() % 4
        if (randomNumber == 0) {
            self.shakeAnimation(mapView)
        }
    }
    
    //USGSDataRequest Delegate Methods
    func dataRequestSuccess(data: [EarthquakePoint]!) {
        for point in data {
            
            point.title = "Magnitude: " + point.magnitude.stringValue
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                self.mapView.addAnnotation(point)
            })
        }
    }
    
    func dataRequestError() {
        //popup an alert
    }
    
    //Convience Methods
    func setUpMapView() {
        mapView.mapType = MKMapType.Satellite;
        mapView.delegate = self
    }
    
    func setUpDataRequester() {
        dataRequester.delegate = self
        dataRequester.requestDataWithRect(mapView.visibleMapRect)
    }
    
    func shakeAnimation(view: UIView) {
        
        let animation = CABasicAnimation(keyPath: "bounds")
        animation.duration = 0.025
        animation.repeatCount = 15
        animation.autoreverses = true
        
        let offsetPoint = CGPointMake(view.bounds.origin.x - 10, view.bounds.origin.y)
        animation.fromValue = NSValue(CGRect:view.layer.bounds)
        animation.toValue = NSValue(CGRect: CGRectMake(offsetPoint.x, offsetPoint.y, view.bounds.width, view.bounds.height))
        view.layer.addAnimation(animation, forKey: "bounds")
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
