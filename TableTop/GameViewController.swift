//
//  GameViewController.swift
//  TableTop
//
//  Created by Andrew Liu on 6/3/15.
//  Copyright (c) 2015 Andrew Liu. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var players = [Player]()
    var currentPlayer: Player!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleMPCReceivedDataWithNotification:", name: "receivedMPCDataNotification", object: nil)
        //stop looking for nearby advertising peers
        self.appDelegate.MCManager.browser.stopBrowsingForPeers()
        //stop announcing presence to nearby browsing peers
        self.appDelegate.MCManager.advertiser.stopAdvertisingPeer()

        if (self.currentPlayer.order == 0) {
            self.button.enabled = true
        }
        else {
            self.button.enabled = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    @IBAction func rollOnButtonPressed(sender: UIButton) {
        
        let initDictionary: [String: String] = ["action": "_start_game_"]
        self.appDelegate.MCManager.sendData(dictionaryWithData: initDictionary)
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
                
                
            }
        }
    }
}

extension GameViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.players.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        cell.textLabel?.text = self.players[indexPath.row].peer.displayName
        cell.detailTextLabel?.text = String(self.players[indexPath.row].score)
        return cell
    }
}

