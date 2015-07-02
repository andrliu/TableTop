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
        let player = "\(self.currentPlayer.order)"
        let diceNumber = "\(arc4random_uniform(6) + 1)"
        self.currentPlayer.score = self.currentPlayer.score + diceNumber.toInt()!
        self.players[self.currentPlayer.order].score = self.currentPlayer.score
        let nextPlayer : String
        if self.currentPlayer.order + 1 == self.players.count {
            nextPlayer = "0"
        } else {
            nextPlayer = "\(self.currentPlayer.order + 1)"
        }
        let resultDictionary: [String: String] = ["lastPlayer": player,
                                                  "scroe": diceNumber,
                                                  "nextPlayer": nextPlayer]
        self.appDelegate.MCManager.sendData(dictionaryWithData: resultDictionary)
        self.button.enabled = false
        self.tableView.reloadData()
    }
    
    func handleMPCReceivedDataWithNotification(notification: NSNotification) {
        // Get the dictionary containing the data and the source peer from the notification.
        let receivedDataDictionary = notification.object as! Dictionary<String, AnyObject>
        
        // "Extract" the data and the source peer from the received dictionary.
        let data = receivedDataDictionary["data"] as? NSData
        let fromPeer = receivedDataDictionary["fromPeer"] as! MCPeerID
        
        // Convert the data (NSData) into a Dictionary object.
        let dataDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as! Dictionary<String, String>
        
        // Check if there's an entry with the "lastPlayer" key.
        if let player = dataDictionary["lastPlayer"] {
            if let score = dataDictionary["scroe"] {
                NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                    self.players[player.toInt()!].score = self.players[player.toInt()!].score + score.toInt()!
                    self.tableView.reloadData()
                }
            }
        }
        
        // Check if there's an entry with the "nextPlayer" key.
        if let nextPlayer = dataDictionary["nextPlayer"] {
            if nextPlayer.toInt()! == self.currentPlayer.order {
                NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                 self.button.enabled = true
                }
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

