//
//  RoomViewController.swift
//  TableTop
//
//  Created by Andrew Liu on 5/28/15.
//  Copyright (c) 2015 Andrew Liu. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class RoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MCManagerDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate.MCManager.delegate = self
    }
}

extension RoomViewController: MCManagerDelegate {
    func foundPeer() {
        
    }
    
    func lostPeer() {
        
    }
    
    func invitationWasReceived(fromPeer: String) {
        let alert = UIAlertController(title: "", message: "\(fromPeer) wants to chat with you.", preferredStyle: UIAlertControllerStyle.Alert)
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            self.appDelegate.MCManager.invitationHandler(true, self.appDelegate.MCManager.session)
        }
        let declineAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            self.appDelegate.MCManager.invitationHandler(false, nil)
        }
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func connectedWithPeer() {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    func connectingWithPeer() {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            
        }
    }
    
    func disconnectedWithPeer() {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            
        }
    }
    
}

extension RoomViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell

        return cell
    }
}
