//
//  User.swift
//  Meek_MVP
//
//  Created by Karlygash Zhuginissova on 8/6/17.
//  Copyright © 2017 Duvelop. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User: NSObject {
    //MARK: - Singleton
    
    private static var _current: User?
    static var current: User {
        guard let currentUser = _current else {
            fatalError("Error: current user doesn't exist")
        }
        return currentUser
    }
    
    //MARK: - Properties
    
    let uid: String

    
    //MARK: - Init
    
    init(uid: String) {
        self.uid = uid
        super.init()
    }
    
    init?(snapshot: DataSnapshot) {
        guard let _ = snapshot.value as? Bool else {
                return nil
        }
        
        self.uid = snapshot.key

        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: Constants.UserDefaults.uid) as? String else {
                return nil
        }
        
        self.uid = uid
        
        super.init()
        
    }
    
    //MARK: - Class methods
    
    static func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        if writeToUserDefaults == true {
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            UserDefaults.standard.set(data, forKey: "currentUser")
        }
        _current = user
    }
}

extension User: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: "uid")
    }
}
