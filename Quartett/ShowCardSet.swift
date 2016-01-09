//
//  ShowCardSet.swift
//  Quartett
//
//  Created by Baschdi on 30.12.15.
//  Copyright © 2015 Moritz Martin. All rights reserved.
//

import UIKit
import CoreData

class ShowCardSet: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var cardSetImage: UIImageView!
    
    var cardSet = [NSManagedObject]()
    var cardArray = [NSManagedObject]()
    var attributeArray = [NSManagedObject]()
    var cardSetID = 0
    var cardSetImageString = ""
    var navigationBarTitle = "Kartenset"
    var count = 0
    var ids = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadCardArray()
        loadAttributes()
        
        self.cardSetImage.image = UIImage(named: cardSetImageString)
        navigationBarItem.title = self.navigationBarTitle
    }
    
    func loadCardArray(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Card")
        
        // filters cards from specific cardset
        let predicate = NSPredicate(format: "cardset == %d", cardSetID)
        fetchRequest.predicate = predicate
        
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            cardArray = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    func loadAttributes(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Attribute")
        
        // filters cards from specific cardset
        let predicate = NSPredicate(format: "cardset == %d", cardSetID)
        fetchRequest.predicate = predicate
        
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            attributeArray = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.collectionView){
            return self.cardArray.count
        }else{
            let values = self.cardArray[0].valueForKey("values")?.componentsSeparatedByString(",")
            return values!.count
        }
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if(collectionView == self.collectionView){
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CardCell", forIndexPath: indexPath) as! ShowCardSetCollectionViewCell
            
            let card = cardArray[indexPath.row]
            
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.blackColor().CGColor
            cell.layer.cornerRadius = 10
            
            cell.nameLabel?.text = card.valueForKey("name") as? String
            cell.cardSetImage?.image = UIImage(named: (card.valueForKey("image") as? String)!)
            cell.textview?.text = card.valueForKey("info") as? String
            cell.textview.selectable = false
            cell.textview.contentInset = UIEdgeInsetsMake(-7.0,0.0,0,0.0)
            ids.append(indexPath.row)
            
            return cell
        }else{
            // Attribute sind komischerweise bis zum ersten rechts-links scrollen noch vertauscht
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AttributeCell", forIndexPath: indexPath) as! ShowAttributeCollectionViewCell
            cell.layer.cornerRadius = 10
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.blackColor().CGColor
            let card = cardArray[ids[0]]
            let values = card.valueForKey("values")?.componentsSeparatedByString(",")
//            print(values)
            cell.attributeValueLabel?.text = values![indexPath.row]
            let attribute = attributeArray[indexPath.row]
            cell.attributeUnitLabel?.text = attribute.valueForKey("unit") as? String
            if attribute.valueForKey("condition") as! Int == 0 {
                cell.backgroundColor = UIColor.lightGrayColor()
            }else{
                cell.backgroundColor = UIColor.whiteColor()
            }
            cell.iconImage?.image = UIImage(named: (attribute.valueForKey("icon") as? String)!)
            cell.attributeNameLabel?.text = attribute.valueForKey("name") as? String
            
            
            if(count == (values?.count)!-1){
                count = 0
//                print(ids)
                ids.removeFirst()
            }else{
                count++
            }
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if(collectionView == self.collectionView){
            return CGSizeMake(collectionView.bounds.size.width-20, collectionView.bounds.size.height-20)
        }else{
            let cellsHeight = CGFloat(Int((cardArray[0].valueForKey("values")?.componentsSeparatedByString(",").count)!) / 2)
            return CGSizeMake(collectionView.bounds.size.width/2, collectionView.bounds.size.height/cellsHeight)
        }
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if(collectionView == self.collectionView){
            guard let showCardSetCollectionViewCell = cell as? ShowCardSetCollectionViewCell else { return }
            showCardSetCollectionViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        }
    }
    
    
}
