//
//  RootViewController.swift
//  TableTop
//
//  Created by Andrew Liu on 5/25/15.
//  Copyright (c) 2015 Andrew Liu. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class RootViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MCManagerDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectingIndicator: UIActivityIndicatorView!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate.MCManager.delegate = self
        //start looking for nearby advertising peers
        self.appDelegate.MCManager.browser.startBrowsingForPeers()
        //start announcing presence to nearby browsing peers
        self.appDelegate.MCManager.advertiser.startAdvertisingPeer()
    }

}

extension RootViewController: MCManagerDelegate {
    func foundPeer() {
        self.tableView.reloadData()
    }
    
    func lostPeer() {
        self.tableView.reloadData()
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
            self.connectingIndicator.stopAnimating()
            self.performSegueWithIdentifier("sessionSegue", sender: self)
        }
    }
    
    func connectingWithPeer() {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.connectingIndicator.startAnimating()
        }
    }
    
    func disconnectedWithPeer() {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            
        }
    }
    
}

extension RootViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appDelegate.MCManager.foundPeers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        cell.textLabel?.text = self.appDelegate.MCManager.foundPeers[indexPath.row].displayName
        return cell
    }
}
    
extension RootViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedPeer = appDelegate.MCManager.foundPeers[indexPath.row] as MCPeerID
        self.appDelegate.MCManager.browser.invitePeer(selectedPeer, toSession: appDelegate.MCManager.session, withContext: nil, timeout: 30)
    }
}