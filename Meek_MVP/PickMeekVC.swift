//
//  PickMeekVC.swift
//  Meek_MVP
//
//  Created by Sara Du  on 7/30/17.
//  Copyright © 2017 Duvelop. All rights reserved.
//

import UIKit

class PickMeekVC: UIViewController {
    
    @IBOutlet weak var meekText: UILabel!
    @IBOutlet weak var meekTimer: UILabel!

    @IBOutlet weak var meekNoBtn: UIButton!
    @IBOutlet weak var meekMehBtn: UIButton!
    @IBOutlet weak var meekYesBtn: UIButton!
    var state = 0
    var pickDelegate: isAbleToReceiveData?
    var showingResults = true //if it is true we will dismiss all the way back to TabVC
    var fromTabVC = false
    var timer = Timer()
    var questionJoined: Question?
    
    override open func viewWillDisappear(_ animated: Bool) {
        if(showingResults){ //This means that it is being dismissed to its root, not the resultsVC
            pickDelegate?.pass(data: "")
        }
        showingResults = true
        
        fromTabVC = false
        timer.invalidate()
    }
    
    func timerAction() {
        if questionJoined != nil {
            meekTimer.text = self.createTimerString(date: questionJoined!.expiresAt)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(!fromTabVC){
            self.dismiss(animated: true, completion: nil)
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        meekNoBtn.setImage(UIImage(named:"cards_noBtn_h"), for: .highlighted)
        meekMehBtn.setImage(UIImage(named:"cards_mehBtn_h"), for: .highlighted)
        meekYesBtn.setImage(UIImage(named:"cards_yesBtn_h"), for: .highlighted)

        if questionJoined != nil {
            DataManager.percentageVoted(forQuestion: questionJoined!, completion: { (no, meh, yes) in
                //HERE WE GET THE PERCENTAGE OF ALL THREE TYPES OF VOTES
                if no != nil {
                    print(no!, yes!, meh!)
                }
            })
            meekText.text = questionJoined!.content
            meekTimer.text = self.createTimerString(date: questionJoined!.expiresAt)
        }
        timer.invalidate() // just in case this button is tapped multiple times
        
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    func createTimerString(date: Date) -> String {
        let timeLeftComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: date)
        let hoursLeft = timeLeftComponents.hour
        let minutesLeft = timeLeftComponents.minute
        let secondsLeft = timeLeftComponents.second
        let timeStamp = String(format:"%02d:%02d:%02d", hoursLeft!, minutesLeft!, secondsLeft!)
        return timeStamp
    }
    
    @IBAction func yesPressed(_ sender: Any) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        DataManager.addYes(for: questionJoined!) { (success) in
            if success {
                print("success")
                dispatchGroup.leave()
            } else {
                print("error")
            }
            
        }
        questionJoined?.yesCount += 1
        questionJoined?.voteCount += 1
        dispatchGroup.notify(queue: .main) {
            self.state = 0
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Results") as! MeekResultVC
            controller.resultState = 0
            controller.questionAnswered = self.questionJoined
            controller.modalTransitionStyle = .flipHorizontal
            
            self.present(controller, animated: true, completion: nil)
        }
    }
    @IBAction func noPressed(_ sender: Any) {
        print("no pressed")
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        DataManager.addNo(for: questionJoined!) { (success) in
            if success {
                //not sure if this is right
                print("success")
                self.state = 2
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "Results") as! MeekResultVC
                controller.resultState = 2
                controller.questionAnswered = self.questionJoined
                controller.modalTransitionStyle = .flipHorizontal
                
                self.present(controller, animated: true, completion: nil)
            } else {
                print("error")
            }
        }
        questionJoined?.noCount += 1
        questionJoined?.voteCount += 1
        dispatchGroup.notify(queue: .main) {
            self.state = 2
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Results") as! MeekResultVC
            controller.resultState = 2
            controller.questionAnswered = self.questionJoined
            controller.modalTransitionStyle = .flipHorizontal
            
            self.present(controller, animated: true, completion: nil)
        }
    }
    @IBAction func mehPressed(_ sender: Any) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        DataManager.addMeh(for: questionJoined!) { (success) in
            if success {
                //not sure if this is right
                print("success")
                self.state = 1
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "Results") as! MeekResultVC
                controller.resultState = 1
                controller.questionAnswered = self.questionJoined
                controller.modalTransitionStyle = .flipHorizontal
                
                self.present(controller, animated: true, completion: nil)
            } else {
                print("error")
            }
        }
        questionJoined?.mehCount += 1
        questionJoined?.voteCount += 1
        dispatchGroup.notify(queue: .main) {
            self.state = 1
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Results") as! MeekResultVC
            controller.resultState = 1
            controller.questionAnswered = self.questionJoined
            controller.modalTransitionStyle = .flipHorizontal
            
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        if(showingResults){
            print("showing results")
            self.dismiss(animated: false, completion: nil)
            
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
