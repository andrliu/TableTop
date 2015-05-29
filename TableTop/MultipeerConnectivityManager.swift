//
//  MultipeerConnectivityManager.swift
//  TableTop
//
//  Created by Andrew Liu on 5/20/15.
//  Copyright (c) 2015 Andrew Liu. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MCManagerDelegate {
    func foundPeer()
    func lostPeer()
    func invitationWasReceived(fromPeer: String)
    func connectedWithPeer()
    func connectingWithPeer()
    func disconnectedWithPeer()
}

class MultipeerConnectivityManager: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate
 {
    var serviceType: String = "Game"
    var peer: MCPeerID!
    var session: MCSession!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!
    
    var foundPeers = [MCPeerID]()
    var invitationHandler: ((Bool, MCSession!)->Void)!
    
    var delegate: MCManagerDelegate?
    
    override init() {
        super.init()
        
        if (NSUserDefaults.standardUserDefaults().dataForKey("displayNameKey") == nil) {
            peer = MCPeerID(displayName: UIDevice.currentDevice().name)
            NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(peer), forKey: "displayNameKey")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        else {
            peer = NSKeyedUnarchiver.unarchiveObjectWithData(NSUserDefaults.standardUserDefaults().dataForKey("displayNameKey")!) as! MCPeerID
        }
        
        self.session = MCSession(peer: peer)
        self.session.delegate = self
        
        self.browser = MCNearbyServiceBrowser(peer: peer, serviceType: serviceType)
        self.browser.delegate = self
        
        self.advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: serviceType)
        self.advertiser.delegate = self
    }
    
    func sendData(dictionaryWithData dictionary: Dictionary<String, String>, toPeer targetPeer: MCPeerID) -> Bool {
        let dataToSend = NSKeyedArchiver.archivedDataWithRootObject(dictionary)
        let peersArray = NSArray(object: targetPeer)
        var error: NSError?
        
        if !session.sendData(dataToSend, toPeers: peersArray as! [MCPeerID], withMode: MCSessionSendDataMode.Reliable, error: &error) {
            println(error?.localizedDescription)
            return false
        }
        
        return true
    }
}

extension MultipeerConnectivityManager: MCSessionDelegate {
    // Remote peer changed state
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        switch state{
        case MCSessionState.Connected:
            println("Connected to session: \(session)")
            delegate?.connectedWithPeer()
            
        case MCSessionState.Connecting:
            println("Connecting to session: \(session)")
            delegate?.connectingWithPeer()

        default:
            println("Did not connect to session: \(session)")
            delegate?.disconnectedWithPeer()
        }
    }
    
    // Received data from remote peer
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
    }
    
    // Received a byte stream from remote peer
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    // Start receiving a resource from remote peer
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
}

extension MultipeerConnectivityManager: MCNearbyServiceBrowserDelegate {
    // Found a nearby advertising peer
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        println("found peer: \(peerID)")
        for (index, aPeer) in enumerate(foundPeers) {
            if aPeer == peerID {
                foundPeers.removeAtIndex(index)
            }
        }
        foundPeers.append(peerID)
        delegate?.foundPeer()
    }

    // A nearby peer has stopped advertising
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        println("lost peer: \(peerID)")
        for (index, aPeer) in enumerate(foundPeers) {
            if aPeer == peerID {
                foundPeers.removeAtIndex(index)
                break
            }
        }
        delegate?.lostPeer()
    }
    
    // Browsing did not start due to an error
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        println(error.localizedDescription)
    }
}

extension MultipeerConnectivityManager: MCNearbyServiceAdvertiserDelegate {
    // Incoming invitation request.  Call the invitationHandler block with YES and a valid session to connect the inviting peer to the session.
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        println("received invitation from peer: \(peerID)")
        self.invitationHandler = invitationHandler
        delegate?.invitationWasReceived(peerID.displayName)
    }
    
    // Advertising did not start due to an error
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
        println(error.localizedDescription)
    }
}

