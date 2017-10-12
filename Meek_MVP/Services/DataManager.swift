//
//  DataManager.swift
//  Meek_MVP
//
//  Created by Karlygash Zhuginissova on 8/1/17.
//  Copyright © 2017 Duvelop. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import CoreLocation
import MapKit


class DataManager {
    typealias FIRUser = FirebaseAuth.User

    
    //MARK: - RETRIEVE ALL QUESTIONS/TIMELINE

    
    static func timeline(completion: @escaping ([Question]) -> Void) {
        let currentUser = User.current
        
        let timelineRef = Database.database().reference().child("Timelines").child(currentUser.uid)
        
        timelineRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            
            let dispatchGroup = DispatchGroup()
            
            var questions = [Question]()
            
            for questionSnap in snapshot {
                guard let posterUID = questionSnap.value as? String else {
                        continue
                }
                
                dispatchGroup.enter()
                
                DataManager.showQuestion(forUserUID: posterUID, andQuestionKey: questionSnap.key, completion: { (question) in
                    if question != nil && question?.responseByUser == nil && question?.isExpired == false {
                        questions.append(question!)
                    }
                    dispatchGroup.leave()
                })

            }
            
            dispatchGroup.notify(queue: .main, execute: { 
                completion(questions.reversed())
            })
        })
        
    }
    
    static func showQuestion(forUserUID userUID: String, andQuestionKey questionKey: String, completion: @escaping (Question?) -> Void) {
        
        let questionRef = Database.database().reference().child("Questions").child(userUID).child(questionKey)
        questionRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let isExpired = DataManager.isExpired(snapshot) else {
                return completion(nil)
            }
            
            guard let question = Question(snapshot: snapshot) else {
                return completion(nil)
            }
            question.isExpired = isExpired

            DataManager.isQuestionAnswered(question, byCurrentUserWithCompletion: { (response) in
                question.responseByUser = response
                completion(question)

            })
            
        })
      
        
    }
    
    //Helper to check if question is expired 
    static func isExpired(_ snapshot: DataSnapshot) -> Bool? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = TimeZone.current
        
        
        let dates = Date()
        guard let dict = snapshot.value as? [String: Any],
            let expiresAtString = dict["expires_at"] as? String,
            let expiresAt = formatter.date(from: expiresAtString),
            expiresAt > Date() else {
                return true
        }
        
        return false
    }
    
    //Helper to check if question is answered
    static func isQuestionAnswered(_ question: Question, byCurrentUserWithCompletion completionHandler: @escaping (String?) -> Void) {
        guard let questionKey = question.key else {
            return completionHandler(nil)
        }
        
        let responsesRef = Database.database().reference().child("Responses").child(questionKey)
        
        responsesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                guard let response = dict[User.current.uid] as? String else {
                    return completionHandler(nil)
                }
                completionHandler(response)
            } else {
                completionHandler(nil)
            }
        })
    }
    
    
    //MARK: - RETRIEVE ALL ANSWERED QUESTIONS
    static func retrieveAllAnsweredQuestions(completionHandler: @escaping ([Question]) -> Void) {
        
        var questions = [Question]()
        let ref = Database.database().reference().child("Questions")
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshotArray = snapshot.children.allObjects as? [DataSnapshot] {
                let outerDispatchGroup = DispatchGroup()

                for snapshot in snapshotArray {
                    if snapshot.isEqual(snapshotArray[snapshotArray.count-1]) {
                        outerDispatchGroup.enter()           
                    }
                    
                    guard let snapshotValues = snapshot.children.allObjects as? [DataSnapshot] else {
                        return completionHandler([])
                    }
                    
                    let innerDispatchGroup = DispatchGroup()

                    let _: [Question] = snapshotValues.reversed().flatMap ({
                        guard let question = Question(snapshot: $0) else {
                            return nil
                        }
                        innerDispatchGroup.enter()
                        DataManager.isQuestionAnswered(question) { (response) in
                            question.responseByUser = response
                            questions.append(question)
                            innerDispatchGroup.leave()
                            
                        }
                        return question

                    })
                    
                    
                    innerDispatchGroup.notify(queue: .main, execute: {
                        if snapshot.isEqual(snapshotArray[snapshotArray.count-1]) {
                            outerDispatchGroup.leave()
                        }
                    })

                    
                }
                outerDispatchGroup.notify(queue: .main, execute: {
                    print("returned \(questions)")
                    completionHandler(questions.filter({ $0.responseByUser != nil }))
                })
 
            } else {
                completionHandler([])
            }
        })
        
    }
    
    
    
    
    
    //MARK: - RETRIEVE A QUESTION
    static func retrieveQuestion(withPasscode passcode: String, atLocation currentLocation: CLLocation, completion: @escaping (Question?, String?) -> Void) {
        let currentUser = User.current
        
        let timelineRef = Database.database().reference().child("Timelines").child(currentUser.uid)
        
        timelineRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion(nil, "Cannot retrieve array of snapshots.")
            }
            
            let dispatchGroup = DispatchGroup()
            
            var foundQuestions = [Question]()
            
            var errorMessage: String?
            
            for questionSnap in snapshot {
                guard let posterUID = questionSnap.value as? String else {
                        errorMessage = "Failed to retrieve json."
                        continue
                }
                
                dispatchGroup.enter()
                
                DataManager.showQuestion(forUserUID: posterUID, andQuestionKey: questionSnap.key, completion: { (question) in
                    if question != nil && question?.responseByUser == nil && question?.passcode == passcode {
                        foundQuestions.append(question!)
                    } else if question == nil && question?.passcode != passcode {
                        errorMessage = "This question never existed or expired."
                    } else if question?.responseByUser != nil {
                        errorMessage = "You already answered this question."
                    }
                    
                    dispatchGroup.leave()
                })
                
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                var foundQuestion: Question?
                var distances = [CLLocationDistance]()
                
                for question in foundQuestions {
                    let questionLocation = CLLocation(latitude: question.coordinate.latitude, longitude: question.coordinate.longitude)
                    
                    let distanceInMeters = currentLocation.distance(from: questionLocation)
                    
                    distances.append(distanceInMeters)
                }
                guard let min = distances.min() else {
                    return completion(foundQuestion, errorMessage)
                }
                
                let index = distances.index(of: min)
                
                foundQuestion = foundQuestions[index!]
                completion(foundQuestion, errorMessage)
            })
        })
        
    }
    

    
    
    //MARK: - POST A QUESTION
    static func postNewQuestion(thisQuestion question: Question, completionHandler: @escaping (Question?, String?) -> Void) {
        let currentUser = User.current

        var errorMessage: String?
        
        
        let ref = Database.database().reference().child("Questions")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var canPost = true
            
            guard let snapshotArray = snapshot.children.allObjects as? [DataSnapshot] else {
                return completionHandler(nil, "Cannot retrieve array of snapshots.")
            }
            
            for snapshot in snapshotArray {
                guard let snapshotValues = snapshot.children.allObjects as? [DataSnapshot] else {
                    continue
                }
                for oneValue in snapshotValues {
                    guard let questionToCheck = Question(snapshot: oneValue) else {
                        errorMessage = "Failed to serialize json."
                        continue
                    }
                    
                    canPost = DataManager.checkIfThereIsQuestionInThatRegion(question: question, existingQuestion: questionToCheck)
                    if canPost == false {
                        errorMessage = "A question with the same password was already posted in your area, choose another password."
                        return completionHandler(nil, errorMessage)
                    }
                }


            }
            
            
            let rootRef = Database.database().reference()

            
            
            let newQuestionRef = ref.child(currentUser.uid).childByAutoId()
            let newQuestionKey = newQuestionRef.key
            
            
            DataManager.allUsersUIDs(completion: { (usersUIDs) in
//                let timelinePosterDict = ["poster_uid": currentUser.uid]
                var updatedData: [String: Any] = ["Timelines/\(currentUser.uid)/\(newQuestionKey)" : currentUser.uid]
                
                for uid in usersUIDs {
                    updatedData["Timelines/\(uid)/\(newQuestionKey)"] = currentUser.uid
                }
                
                let newQuestionDict = question.dictValue
                updatedData["Questions/\(currentUser.uid)/\(newQuestionKey)"] = newQuestionDict
                rootRef.updateChildValues(updatedData, withCompletionBlock: { (error, ref) in
                    
                    if error == nil {
                        question.key = newQuestionKey
                        return completionHandler(question, nil)
                    }
                    
                    return completionHandler(nil, error?.localizedDescription)

                    
                })
                
                
            })
            
        })
        
        
        
    }

    
    
    private static func checkIfThereIsQuestionInThatRegion(question: Question, existingQuestion: Question) -> Bool {
        var canPost = true
        
        if existingQuestion.passcode == question.passcode {
            let newQuestionLocation = CLLocation(latitude: question.coordinate.latitude, longitude: question.coordinate.longitude)
            let existingQuestionLocation = CLLocation(latitude: existingQuestion.coordinate.latitude, longitude: existingQuestion.coordinate.longitude)
            
            let distanceInMeters = newQuestionLocation.distance(from: existingQuestionLocation)
            
            
            if distanceInMeters <= 100 {
                print("The same password")
                canPost = false
            }
            
        }
        
        return canPost
        
    }
    
    
    //MARK: - RECORD RESPONSES
    static func addYes(for question: Question, success: @escaping (Bool) -> Void) {
        guard let questionKey = question.key else {
            return success(false)
        }
        
        let currentUser = User.current
        
        let responsesRef = Database.database().reference().child("Responses").child(questionKey).child(currentUser.uid)
        responsesRef.setValue("yes") { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            var yesCountRef = Database.database().reference().child("Questions").child(question.posterUID).child(questionKey).child("yes_count")
            yesCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                let currentCount = mutableData.value as? Int ?? 0
                
                mutableData.value = currentCount + 1
                
                return TransactionResult.success(withValue: mutableData)
            }, andCompletionBlock: { (error, _, _) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    success(false)
                } else {
                    
                    let timelineRef = Database.database().reference().child("Timelines").child(currentUser.uid).child(questionKey)
                    timelineRef.removeValue()
                    success(true)
                }
            })

        }
        
        
        
    }
    
    
    static func addNo(for question: Question, success: @escaping (Bool) -> Void) {
        guard let questionKey = question.key else {
            return success(false)
        }
        
        
        let currentUser = User.current
        
        let responsesRef = Database.database().reference().child("Responses").child(questionKey).child(currentUser.uid)
        responsesRef.setValue("no") { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            var noCountRef = Database.database().reference().child("Questions").child(question.posterUID).child(questionKey).child("no_count")
            noCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                let currentCount = mutableData.value as? Int ?? 0
                
                mutableData.value = currentCount + 1
                
                return TransactionResult.success(withValue: mutableData)
            }, andCompletionBlock: { (error, _, _) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    success(false)
                } else {
                    let timelineRef = Database.database().reference().child("Timelines").child(currentUser.uid).child(questionKey)
                    timelineRef.removeValue()
                    success(true)
                }
            })

        }
        
    }
    
    static func addMeh(for question: Question, success: @escaping (Bool) -> Void) {
        guard let questionKey = question.key else {
            return success(false)
        }
        
        let currentUser = User.current
        
        let responsesRef = Database.database().reference().child("Responses").child(questionKey).child(currentUser.uid)
        responsesRef.setValue("meh") { (error, _) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            var mehCountRef = Database.database().reference().child("Questions").child(question.posterUID).child(questionKey).child("meh_count")
            mehCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                let currentCount = mutableData.value as? Int ?? 0
                
                mutableData.value = currentCount + 1
                
                return TransactionResult.success(withValue: mutableData)
            }, andCompletionBlock: { (error, _, _) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    success(false)
                } else {
                    let timelineRef = Database.database().reference().child("Timelines").child(currentUser.uid).child(questionKey)
                    timelineRef.removeValue()
                    success(true)
                }
            })

        }
        
    }
    
    //MARK: - USER SERVICES
    static func createUser(_ firUser: FIRUser, completion: @escaping (User?) -> Void) {

        
        let ref = Database.database().reference().child("Users").child(firUser.uid)
        
        ref.setValue(true) {(error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
            
            DataManager.allUsersUIDs(completion: { (userUIDs) in
                for uid in userUIDs {
                    let questionsRef = Database.database().reference().child("Questions").child(uid)
                    questionsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let questionsArray = snapshot.children.allObjects as? [DataSnapshot] else {
                            return
                        }

                        for question in questionsArray {
                            let questionKey = question.key
                            let posterUID = uid
                            let newTimeline = Database.database().reference().child("Timelines").child(firUser.uid).child(questionKey)
                            newTimeline.setValue(posterUID)
                        }

                    })
                }
            })

        }
    }
    

    
    static func allUsersUIDs(completion: @escaping ([String]) -> Void) {
        let usersRef = Database.database().reference().child("Users")
        
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let usersDict = snapshot.value as? [String: Bool] else {
                return completion([])
            }
            
            let usersUIDs = Array(usersDict.keys)
            completion(usersUIDs)
        })
    }
    
    
    static func checkForExistingChat(forQuestion question: Question, completion: @escaping (Chat?) -> Void) {
        
        let chatRef = Database.database().reference().child("Chats").child(question.key)
//        let query = chatRef.queryEqual(toValue: question.key)
        chatRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let chatSnap = snapshot.children.allObjects.first as? DataSnapshot,
                let chat = Chat(snapshot: chatSnap) else {
                    return completion(nil)
            }
            completion(chat)
        })
    }
    
    static func createChat(fromMessage message: Message, forQuestion question: Question, completion: @escaping (Chat?) -> Void) {


        let chatRef = Database.database().reference().child("Chats").child(question.key).childByAutoId()
        chatRef.setValue(true) { (err, ref) in
            if err == nil {
                let chat = Chat(key: chatRef.key)

                var multiUpdateValue = [String : Any]()

                
                let messagesRef = Database.database().reference().child("Messages").child(chatRef.key).childByAutoId()
                let messageKey = messagesRef.key
                
                // 8
                multiUpdateValue["Messages/\(chatRef.key)/\(messageKey)"] = message.dictValue
                
                // 9
                let rootRef = Database.database().reference()
                rootRef.updateChildValues(multiUpdateValue) { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                        return completion(nil)
                    }
                    
                    return completion(chat)
                }
            }
            completion(nil)
        }


    }
    
    static func sendMessage(_ message: Message, forChat chat: Chat, success: ((Bool) -> Void)? = nil) {
        guard let chatKey = chat.key else {
            success?(false)
            return
        }
        
        var multiUpdateValue = [String : Any]()

        
        let messagesRef = Database.database().reference().child("Messages").child(chatKey).childByAutoId()
        let messageKey = messagesRef.key
        multiUpdateValue["Messages/\(chatKey)/\(messageKey)"] = message.dictValue
        
        let rootRef = Database.database().reference()
        rootRef.updateChildValues(multiUpdateValue, withCompletionBlock: { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success?(false)
                return
            }
            
            success?(true)
        })
    }
    
    static func observeMessages(forChatKey chatKey: String, completion: @escaping (DatabaseReference, Message?) -> Void) -> DatabaseHandle {
        let messagesRef = Database.database().reference().child("Messages").child(chatKey)
        
        return messagesRef.observe(.childAdded, with: { snapshot in
            guard let message = Message(snapshot: snapshot) else {
                return completion(messagesRef, nil)
            }
            
            completion(messagesRef, message)
        })
    }
 

    static func percentageVoted(forQuestion question: Question, completion: @escaping (Double?, Double?, Double?) -> Void) {
        guard let questionKey = question.key else {
            return completion(nil, nil, nil)
        }
        
        let responsesRef = Database.database().reference().child("Responses").child(questionKey)
        responsesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let responsesArray = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion(nil, nil, nil)
            }
            var yesCount = 0
            var noCount = 0
            var mehCount = 0
            var voteCount = 0
            for one in responsesArray {
                guard let response = one.value as? String else {
                    return completion(nil, nil, nil)
                }
                
                if response == "yes" {
                    yesCount += 1
                    voteCount += 1
                } else if response == "no" {
                    noCount += 1
                    voteCount += 1
                } else if response == "meh" {
                    mehCount += 1
                    voteCount += 1
                }
                
                
            }
            
            DataManager.allUsersUIDs(completion: { (userUIDs) in
                let allAmount = userUIDs.count
                let yes = Double(yesCount)/Double(allAmount) * 100
                let meh = Double(mehCount)/Double(allAmount) * 100
                let no = Double(noCount)/Double(allAmount) * 100
                
                completion(no, meh, yes)
            })
        })
    }
    
    
    
    
}


