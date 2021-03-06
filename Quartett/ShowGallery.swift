//
//  ShowGallery.swift
//  Quartett
//
//  Created by Baschdi on 30.12.15.
//  Copyright © 2015 Moritz Martin. All rights reserved.
//

import UIKit
import CoreData

class ShowGallery: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var editGalleryButton: UIBarButtonItem!
    
    var cardsetArray = [NSManagedObject]()
    @IBOutlet weak var addGalleryView: UIView!
    
    var editable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.layer.borderWidth = 1
        collectionView.layer.borderColor = UIColor.blackColor().CGColor
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cardsetArray = Data().loadCardSets()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cardsetArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CardSetsCell", forIndexPath: indexPath) as! ShowGalleryCollectionViewCell
        
        let cardset = cardsetArray[indexPath.row]
        
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.blackColor().CGColor
        
        cell.galleryImage?.image = Data().stringToImage((cardset.valueForKey("image") as? String)!)
        
        cell.galleryTitle?.text = cardset.valueForKey("name") as? String
        
        cell.deleteGalleryButton.tag = (cardset.valueForKey("id") as? Int)!
        
        if(editable){
            cell.deleteGalleryButton.hidden = false
        }else{
            cell.deleteGalleryButton.hidden = true
        }
        
        return cell
    }
    
    
    
    //*******************************
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showCardSet", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showCardSet"){
            
            let indexPaths = self.collectionView!.indexPathsForSelectedItems()!
            let indexPath = indexPaths[0] as NSIndexPath
            let vc = segue.destinationViewController as! ShowCardSet
            vc.cardSetID = (self.cardsetArray[indexPath.row].valueForKey("id") as? Int)!
            vc.navigationBarTitle = (self.cardsetArray[indexPath.row].valueForKey("name") as? String)!
            vc.cardSetImageString = (self.cardsetArray[indexPath.row].valueForKey("image") as? String)!
            
        }
    }
    
    
    @IBAction func editGalleryButton(sender: AnyObject) {
        if(editable){
            editGalleryButton.title = "Editieren"
            editable = false
            collectionView.reloadData()
        }else{
            editGalleryButton.title = "Fertig"
            editable = true
            collectionView.reloadData()
        }
    }
    
    @IBAction func deleteGalleryButton(sender: AnyObject) {
        let alertController = UIAlertController(title: "Löschen", message: "Wollen Sie das Kartenset wirklich löschen?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .Cancel) { (action) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Löschen", style: .Destructive) { (action) in
            let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let dataPath = documentsURL.URLByAppendingPathComponent(String(sender.tag))
            do{
                try NSFileManager.defaultManager().removeItemAtURL(dataPath)
                print("Image folder deleted")
            } catch  {
                print("No image folder found")
            }
            Data().deleteCardSet(sender.tag)
            self.cardsetArray = Data().loadCardSets()
            self.collectionView.reloadData()
        }
        alertController.addAction(deleteAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    

    
    //****************************
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
