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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleMPCReceivedDataWithNotification:", name: "receivedMPCDataNotification", object: nil)
        self.appDelegate.MCManager.delegate = self
        //start looking for nearby advertising peers
        self.appDelegate.MCManager.browser.startBrowsingForPeers()
        //start announcing presence to nearby browsing peers
        self.appDelegate.MCManager.advertiser.startAdvertisingPeer()
        self.tableView.reloadData()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop listening for keyboard notifications
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func startGameOnButtonPressed(sender: UIBarButtonItem) {
        let initDictionary: [String: String] = ["action": "_start_game_"]
        self.appDelegate.MCManager.sendData(dictionaryWithData: initDictionary)
        self.performSegueWithIdentifier("gameSegue", sender: self)
    }
    
    func handleMPCReceivedDataWithNotification(notification: NSNotification) {
        // Get the dictionary containing the data and the source peer from the notification.
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        // "Extract" the data and the source peer from the received dictionary.
        let data = receivedDataDictionary["data"] as? NSData
        let fromPeer = receivedDataDictionary["fromPeer"] as! MCPeerID
        
        // Convert the data (NSData) into a Dictionary object.
        let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! Dictionary<String, String>
        
        // Check if there's an entry with the "message" key.
        if let message = dataDictionary["action"] {
            // Make sure that the message is other than "_end_chat_".
            if message == "_start_game_"{

                let alert = UIAlertController(title: "", message: "\(fromPeer.displayName) wants to start a new game.", preferredStyle: UIAlertControllerStyle.Alert)
                let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                    self.performSegueWithIdentifier("gameSegue", sender: self)
                }
                alert.addAction(acceptAction)
                NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                    self.presentViewController(alert, animated: true, completion: nil)

                }
            }
        }
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
            self.tableView.reloadData()
        }
    }
    
    func connectingWithPeer() {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.connectingIndicator.startAnimating()
        }
    }
    
    func disconnectedWithPeer() {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.connectingIndicator.stopAnimating()
            let alert = UIAlertController(title: "", message: "Connection Failed", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
                self.tableView.reloadData()
            }
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}

extension RootViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Coneected Devices"
        }
        else {
            return "Nearby Devices"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return self.appDelegate.MCManager.connectedPeers.count
        }
        else {
            return self.appDelegate.MCManager.foundPeers.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        if (indexPath.section == 0) {
            cell.textLabel?.text = self.appDelegate.MCManager.connectedPeers[indexPath.row].displayName
            cell.selectionStyle = .None
        }
        else {
            cell.textLabel?.text = self.appDelegate.MCManager.foundPeers[indexPath.row].displayName
        }
        return cell
    }
}

extension RootViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1) {
            let selectedPeer = appDelegate.MCManager.foundPeers[indexPath.row] as MCPeerID
            self.appDelegate.MCManager.browser.invitePeer(selectedPeer, toSession: appDelegate.MCManager.session, withContext: nil, timeout: 30)
        }
    }
}