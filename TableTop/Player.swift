//
//  Player.swift
//  TableTop
//
//  Created by Andrew Liu on 6/3/15.
//  Copyright (c) 2015 Andrew Liu. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Player: NSObject {

    var order: Int!
    var score: Int!
    var peer: MCPeerID!

    init(peer: MCPeerID, order: Int) {
        self.peer = peer
        self.order = order
        self.score = 0
    }
}
