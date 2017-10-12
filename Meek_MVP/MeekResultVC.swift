//
//  MeekResultVC.swift
//  Meek_MVP
//
//  Created by Sara Du  on 7/30/17.
//  Copyright © 2017 Duvelop. All rights reserved.
//

import UIKit

class MeekResultVC: UIViewController {
    
    var ourdelegate: isAbleToReceiveData?
    @IBOutlet weak var votesCountLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    
    @IBOutlet weak var noProLabel: UILabel!
    @IBOutlet weak var yesProLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var mehProLabel: UILabel!
    @IBOutlet weak var proMehView: UIView!
    @IBOutlet weak var proNoView: UIView!
    @IBOutlet weak var proYesView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    //@IBOutlet weak var noImageView: UIImageView!
    @IBOutlet weak var resultImage: UIImageView!
    //@IBOutlet weak var mehImageView: UIImageView!
    //@IBOutlet weak var yesImageView: UIImageView!
    @IBOutlet weak var msgBtn: UIButton!
    var resultState = 0
    
    var questionAnswered: Question?
    var existingChat: Chat?
    var segueFromTab = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //temporary
        votesCountLabel.text = "0"
        commentsCountLabel.text = "0"
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if(segueFromTab){
            msgBtn.isEnabled = true
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        msgBtn.isEnabled = true
    }
    override func viewWillLayoutSubviews() {
        if(resultState == 0){
            resultImage.image = UIImage(named:"cards_resultsYes")
            //yesImageView.image = UIImage(named:"cards_yesBtn_h")
        }else if(resultState == 1){
            resultImage.image = UIImage(named:"cards_resultsMeh")
            //mehImageView.image = UIImage(named:"cards_mehBtn_h")
            
        }else{
            resultImage.image = UIImage(named:"cards_resultsNo")
            //noImageView.image = UIImage(named:"cards_noBtn_h")
        }
        
        if questionAnswered != nil {
            contentLabel.text = questionAnswered!.content
            timerLabel.text = self.createTimerString(date: questionAnswered!.expiresAt)
            votesCountLabel.text = String(questionAnswered!.voteCount)
            commentsCountLabel.text = String(questionAnswered!.commentCount)
            
    //        DataManager.percentageVoted(forQuestion: questionAnswered!, completion: { (no, meh, yes) in
                //HERE WE GET THE PERCENTAGE OF ALL THREE TYPES OF VOTES
       //         if no != nil {
            
      //          }
      //      })
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        let rt = self.progressView.frame
        var yes = 0.0
        var no = 0.0
        var meh = 0.0
        if(questionAnswered?.voteCount != 0){
            yes = (Double)((questionAnswered?.yesCount)!) / (Double)((questionAnswered?.voteCount)!)
            no = (Double)((questionAnswered?.noCount)!) / (Double)((questionAnswered?.voteCount)!)
            meh = (Double)((questionAnswered?.mehCount)!) / (Double)((questionAnswered?.voteCount)!)
        }
        self.noProLabel.isHidden = false
        self.yesProLabel.isHidden = false
        self.mehProLabel.isHidden = false
        
        self.proNoView.backgroundColor = UIColor(red: 45 / 255, green: 130 / 255, blue: 190 / 255, alpha: 1)
        self.proNoView.frame = CGRect(x: 0, y: 0, width: rt.width * (CGFloat(no)), height: rt.height)
        
        self.noProLabel.frame = self.proNoView.frame
        self.noProLabel.textAlignment = .left
        self.noProLabel.backgroundColor = UIColor(white: 0, alpha: 0)
        self.noProLabel.text = String(Int(no * 100)) + "% No"
        if no == 0 {
            self.noProLabel.isHidden = true
        }
        
        self.proYesView.frame = CGRect(x: rt.width - rt.width * (CGFloat(yes)), y: 0, width: rt.width * (CGFloat(yes)), height: rt.height)
        self.proYesView.backgroundColor = UIColor(red: 118 / 255, green: 221 / 255, blue: 251 / 255, alpha: 1)
        self.yesProLabel.frame = self.proYesView.frame
        
        self.yesProLabel.textAlignment = .right
        self.yesProLabel.text = String(Int(yes * 100)) + "% Yes"
        self.yesProLabel.backgroundColor = UIColor(white: 0, alpha: 0)
        if yes == 0 {
            self.yesProLabel.isHidden = true
        }
 
        
        self.proMehView.frame = CGRect(x: rt.width * (CGFloat(no)), y: 0, width: rt.width * (CGFloat(meh)), height: rt.height)
        self.proMehView.backgroundColor = UIColor(red: 219 / 255, green: 236 / 255, blue: 248 / 255, alpha: 1)
        self.mehProLabel.frame = self.proMehView.frame
        self.mehProLabel.textAlignment = .center
        self.mehProLabel.text = String(Int(meh * 100)) + "%"
        self.mehProLabel.backgroundColor = UIColor(white: 0, alpha: 0)
        if meh == 0 {
            self.mehProLabel.isHidden = true
        }
        self.view.bringSubview(toFront: progressView)
    }
    
    func createTimerString(date: Date) -> String {
        let timeLeftComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: date)
        let hoursLeft = timeLeftComponents.hour
        let minutesLeft = timeLeftComponents.minute
        let secondsLeft = timeLeftComponents.second
        let timeStamp = String(format:"%02d:%02d:%02d", hoursLeft!, minutesLeft!, secondsLeft!)
        return timeStamp
    }
    
    
    @IBAction func chatTapped(_ sender: Any) {
        DataManager.checkForExistingChat(forQuestion: questionAnswered!) { (chat) in
            self.existingChat = chat
            self.performSegue(withIdentifier: "toChat", sender: self)
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("disappearing")
        //ourdelegate?.pass(data: "someData") //call the func in the previous vc
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "toChat", let destinationVC = segue.destination as? ChatVC {

            destinationVC.chat = existingChat
            destinationVC.question = questionAnswered

        }
    }
}
