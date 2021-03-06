//
//  DetailViewController.swift
//  Events-NearBy
//
//  Created by kavita patel on 5/23/16.
//  Copyright © 2016 kavita patel. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UIApplicationDelegate
{
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var venuePlaceLbl: UILabel!
    @IBOutlet weak var favoBtn: UIBarButtonItem!
    @IBOutlet weak var venueAddLbl: UILabel!
    @IBOutlet weak var ticketBtn: UIButton!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var descText: UITextView!
    @IBOutlet weak var venueCityLbl: UILabel!
    @IBOutlet weak var venueStateLbl: UILabel!
    var eventIndex: Int = 0
    let alertObj = AlertViewController()
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        if EventDetails.events.count > 0
        {
                titleLbl.text = EventDetails.events[eventIndex].title
                dateLbl.text = EventDetails.events[eventIndex].start_time
                venuePlaceLbl.text = EventDetails.events[eventIndex].venue_name
                venueAddLbl.text = EventDetails.events[eventIndex].venue_address
                venueCityLbl.text = EventDetails.events[eventIndex].city_name
                venueStateLbl.text = EventDetails.events[eventIndex].region_name
            // Description has html format
            let htmlString = EventDetails.events[eventIndex].desc
            if htmlString != nil
            {
                let htmlStringData = htmlString!.dataUsingEncoding(NSUTF8StringEncoding)!
                let options: [String: AnyObject] = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding]
                let attributedHTMLString = try! NSAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
                descText.text = attributedHTMLString.string
            }
            // Get image from URL
                let imgURL = EventDetails.events[eventIndex].imageURL
                if imgURL != nil
                {
                    let url = NSURL(string: imgURL!)
                    let data = NSData(contentsOfURL: url!)
                    dispatch_async(dispatch_get_main_queue())
                    {
                        if data != nil
                        {
                            self.img.image = UIImage(data: data!)!
                        }
                    }
                }
                if EventDetails.events[eventIndex].ticketURL != nil
                {
                    ticketBtn.enabled = true
                    ticketBtn.hidden = false
                }
                else
                {
                    ticketBtn.hidden = true
                }
        }
    }
    @IBAction func ticketBtnPressed(sender: AnyObject)
    {
        let urlStr = EventDetails.events[eventIndex].ticketURL
        if urlStr != nil
        {
            let url = NSURL(string: (urlStr)!)
            if UIApplication.sharedApplication().canOpenURL(url!)
            {
                UIApplication.sharedApplication().openURL(url!)
            }
            else
            {
                print("Ticket Link is Not InValid" )
            }
 
        }
        
    }
    @IBAction func doneBtnPresed(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func addToFavoBtn(sender: AnyObject)
    {
        if EventDetails.events.count > 0
        {
            favoBtn.enabled = true
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = appDelegate.managedObjectContext
            let entity = NSEntityDescription.entityForName("Event", inManagedObjectContext: context)
            let entityObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
            entityObject.setValue(titleLbl.text, forKey: "title")
            entityObject.setValue(EventDetails.events[eventIndex].ticketURL, forKey: "ticketURL")
            
            
            if let data = UIImagePNGRepresentation(img.image!)
            {
                let paths = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                let filename = paths.URLByAppendingPathComponent("file\(eventIndex).png")
                let result = data.writeToFile(filename.path!, atomically: true)
                if result
                {
                    entityObject.setValue("file\(eventIndex).png", forKey: "image")
                }
            }
            
            entityObject.setValue(venuePlaceLbl.text, forKey: "venuePlace")
            do{
                
                try context.save()
                alertObj.alertMsg("saved", msg: "Added to Favourite",VC: self)
            }
            catch
            {
                alertObj.alertMsg("Saved Error", msg: "Not Added to Favourite",VC: self)
            }

        }
        else
        {
            favoBtn.enabled = false
        }
    }
   
}
