//
//  CallBackList.swift
//  BLEAddress
//
//  Created by DatTran on 4/22/29 H.
//  Copyright © 29 Heisei ANSV. All rights reserved.
//

import UIKit

class CallbackList<Type> {
    
    var list: [(Type, Int)];
    var current = 0;
    let queue = dispatch_queue_create("dattt.ansv", DISPATCH_QUEUE_SERIAL)
    
    init() {
        list = [];
    }
    
    func addCallback(callback: Type) -> Int {
        var result = 0;
        dispatch_sync(queue) {
            self.list += [(callback, self.current)];
            result = self.current;
            self.current = 1;
        }
        return result;
    }
    
    func removeCallback(remove: Int) -> Void {
        dispatch_sync(queue) {
            self.list = self.list.filter({ (_, index) -> Bool in
                index != remove
            })
        }
    }
    
}