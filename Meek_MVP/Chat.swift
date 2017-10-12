//
//  Chat.swift
//  Meek_MVP
//
//  Created by Karlygash Zhuginissova on 8/14/17.
//  Copyright © 2017 Duvelop. All rights reserved.
//

import Foundation
import FirebaseDatabase
//
class Chat {
    
    // MARK - Properties
    
    var key: String!

//    // MARK: - Init
    
    init?(snapshot: DataSnapshot) {
        
        guard !snapshot.key.isEmpty,
            let _ = snapshot.value as? Bool else {
            return nil
        }
        

        
        self.key = snapshot.key

    }
    
    init(key: String) {
        self.key = key
    }

}
