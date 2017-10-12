//
//  Question.swift
//  Meek_MVP
//
//  Created by Karlygash Zhuginissova on 8/1/17.
//  Copyright © 2017 Duvelop. All rights reserved.
//

import Foundation
import FirebaseDatabase
import CoreLocation

class Question {
    
    var key: String!
    var posterUID: String!
    var coordinate: CLLocationCoordinate2D!
    var passcode: String = "0000"
    var content: String!
    var yesCount = 0
    var noCount = 0
    var mehCount = 0
    var voteCount = 0
    var commentCount = 0
    var createdAt: Date!
    var expiresAt: Date!
    var responseByUser: String?
    var isExpired = false
    var chat: Chat?
    var backgroundColorIndex: Int!
    
    init(posterUID: String, coordinate: CLLocationCoordinate2D, content: String, createdAt: Date, withBackground background: Int) {
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: createdAt)
        self.posterUID = posterUID
        self.coordinate = coordinate
        self.content = content
        self.createdAt = createdAt
        self.expiresAt = nextDay
        self.backgroundColorIndex = background
    }
    
    init?(snapshot: DataSnapshot) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = TimeZone.current
        
        guard let dict = snapshot.value as? [String: Any],
            let posterUID = dict["poster"] as? String,
            let coordinate = dict["coordinate"] as? String,
            let latitude = coordinate.components(separatedBy: ", ")[0] as? String,
            let longitude = coordinate.components(separatedBy: ", ")[1] as? String,
            let passcode = dict["passcode"] as? String,
            let content = dict["content"] as? String,
            let createdAtString = dict["created_at"] as? String,
            let expiresAtString = dict["expires_at"] as? String,
            let createdAt = formatter.date(from: createdAtString),
            let expiresAt = formatter.date(from: expiresAtString),
            let yesCount = dict["yes_count"] as? Int,
            let noCount = dict["no_count"] as? Int,
            let mehCount = dict["meh_count"] as? Int,
            let voteCount: Int = yesCount + noCount + mehCount,
     //       let commentCount = dict["comment_count"] as? Int,
            let backgroundColorIndex = dict["background_index"] as? Int else {
                return nil
        }
        
        self.key = snapshot.key
        self.posterUID = posterUID
        self.content = content
        self.coordinate = CLLocationCoordinate2D(latitude: Double(latitude)!, longitude: Double(longitude)!)
        self.passcode = passcode
        self.yesCount = yesCount
        self.noCount = noCount
        self.mehCount = mehCount
        self.voteCount = voteCount
  //      self.commentCount = commentCount
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.backgroundColorIndex = backgroundColorIndex
        
    }
    
    var dictValue: [String: Any] {
        let coordinate = "\(self.coordinate.latitude), \(self.coordinate.longitude)"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let createdAtString = formatter.string(from: self.createdAt)
        let expiresAtString = formatter.string(from: self.expiresAt)
        return ["poster": self.posterUID,
                "content": self.content,
                "coordinate": coordinate,
                "passcode": self.passcode,
                "yes_count": self.yesCount,
                "no_count": self.noCount,
                "meh_count": self.mehCount,
    //            "vote_count": self.voteCount,
    //            "comment_count": self.commentCount,
                "created_at": createdAtString,
                "expires_at": expiresAtString,
                "background_index": self.backgroundColorIndex]
    }
    
    
    //MARK: - Singleton
    
    private static var _readyToPostQuestion: Question?
    static var readyToPostQuestion: Question {
        guard let question = _readyToPostQuestion else {
            fatalError("Error: readyToPostQuestion doesn't exist")
        }
        return question
    }
    
    static func prepareToPost(thisQuestion question: Question) {
        _readyToPostQuestion = question
    }
    
    
    
    
    
    
    
    
}
