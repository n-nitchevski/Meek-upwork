//
//  QuestionsVC.swift
//  Meek_MVP
//
//  Created by Sara Du  on 7/26/17.
//  Copyright © 2017 Duvelop. All rights reserved.
//

import UIKit
import FirebaseAuth

class QuestionsVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var allQuestions = [Question]() {
        didSet {
            tableview.reloadData()
        }
    }
    
    var currentCell = 0
    var createdEmptyView = false
    @IBOutlet weak var tableview: UITableView!
    var cowImage = UIImageView()
    var refreshControl: UIRefreshControl!
    var messageLabel = UILabel()
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        let title = NSLocalizedString("PullToRefresh", comment: "Pull to refresh")
        refreshControl.attributedTitle = NSAttributedString(string: title)
        refreshControl.addTarget(self,
                                 action: #selector(refreshOptions(sender:)),
                                 for: .valueChanged)
        tableview.refreshControl = refreshControl
        
        self.tableview.register(UINib(nibName: "QuestionsCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableview.register(UINib(nibName: "BlankCell", bundle: nil), forCellReuseIdentifier: "blankcell")
        self.tableview.separatorStyle = .none
        self.tableview.backgroundColor = self.hexStringToUIColor(hex: "F6F6F9")

    }
    
    func timerAction() {
        var i = 0
        for question in self.allQuestions {
            
            tableview.reloadRows(at: [IndexPath(row: i+1, section: 0)], with: .none)
            i += 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    @objc private func refreshOptions(sender: UIRefreshControl) {
        // Perform actions to refresh the content
        // ...
        // and then dismiss the control
        sender.endRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                DataManager.timeline { (unAnsweredQuestions) in
                    self.allQuestions = unAnsweredQuestions
                }
            }
        }
        timer.invalidate() // just in case this button is tapped multiple times
        
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if allQuestions.count > 0 {
            cowImage.removeFromSuperview()
            return 1
        } else {
            EmptyMessage(message: "No Responses Yet", viewController: self)
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allQuestions.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 25
        }else{
            return 165
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentCell = indexPath.row
        if(indexPath.row != 0){
            let temp = allQuestions[currentCell-1]
            print(temp.isExpired)
            self.performSegue(withIdentifier: "detailedQuestion", sender: self)

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "detailedQuestion"){
            let vc = segue.destination as! PickMeekVC
            vc.fromTabVC = true
            vc.questionJoined = allQuestions[currentCell-1]
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        messageLabel.isHidden = true

        let cell : QuestionsCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! QuestionsCell
        cell.selectionStyle = .none
        let blankcell: BlankCell = tableView.dequeueReusableCell(withIdentifier: "blankcell") as! BlankCell
        
        var questionForCell: Question?
        
        if indexPath.row > 0 {
            questionForCell = allQuestions[indexPath.row-1]
        }
        
        if(indexPath.row == 0){
            blankcell.selectionStyle = .none
            return blankcell
        }
        
        
        if questionForCell?.backgroundColorIndex == 1 {
            cell.background?.image = UIImage(named: "questionBackground1")
        }else if(questionForCell?.backgroundColorIndex == 2) {
            cell.background.image = UIImage(named: "questionBackground2")
        }else if(questionForCell?.backgroundColorIndex == 3) {
            cell.background.image = UIImage(named: "questionBackground3")
        }else if(questionForCell?.backgroundColorIndex == 4) {
            cell.background.image = UIImage(named: "questionBackground4")
        }else if(questionForCell?.backgroundColorIndex == 5) {
            cell.background.image = UIImage(named: "questionBackground5")
        }else if(questionForCell?.backgroundColorIndex == 6) {
            cell.background.image = UIImage(named: "questionBackground6")
        }else if(questionForCell?.backgroundColorIndex == 7) {
            cell.background.image = UIImage(named: "questionBackground7")
        }else if(questionForCell?.backgroundColorIndex == 8) {
            cell.background.image = UIImage(named: "questionBackground8")
        }else if(questionForCell?.backgroundColorIndex == 9) {
            cell.background.image = UIImage(named: "questionBackground9")
        }else if(questionForCell?.backgroundColorIndex == 10) {
            cell.background.image = UIImage(named: "questionBackground10")
        }else if(questionForCell?.backgroundColorIndex == 11) {
            cell.background.image = UIImage(named: "questionBackground11")
        }else if(questionForCell?.backgroundColorIndex == 2) {
            cell.background.image = UIImage(named: "questionBackground12")
        }else{
            cell.background.image = UIImage(named: "questionBackground13")
        }
        
        cell.contentLabel.text = questionForCell!.content
        let votesCount = questionForCell!.yesCount + questionForCell!.noCount + questionForCell!.mehCount
        cell.votesCountLabel.text = String(votesCount)
        
        let timeStamp = createTimerString(date: questionForCell!.expiresAt)
        
        cell.timeLeftLabel.text = timeStamp
    //    cell.alpha = 0
        
     //   UIView.animate(withDuration: 1, animations: { cell.alpha = 1 })
        return cell

    }
    
    func createTimerString(date: Date) -> String {
        let timeLeftComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: date)
        let hoursLeft = timeLeftComponents.hour
        let minutesLeft = timeLeftComponents.minute
        let secondsLeft = timeLeftComponents.second
        let timeStamp = String(format:"%02d:%02d:%02d", hoursLeft!, minutesLeft!, secondsLeft!)
        return timeStamp
    }
    
    // color helper function
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func EmptyMessage(message:String, viewController:QuestionsVC) {
        
        if(!createdEmptyView){
            
            messageLabel = UILabel(frame: CGRect(x: 0, y: 100, width: 173, height: 16))
            messageLabel.text = message
            messageLabel.textColor = self.hexStringToUIColor(hex: "9B99A9")
            messageLabel.numberOfLines = 1;
            messageLabel.textAlignment = .center;
            messageLabel.font = .systemFont(ofSize: 20.0)
            messageLabel.sizeToFit()
            
            cowImage = UIImageView(frame: CGRect(x: self.tableview.frame.width/2 - 121/2, y: self.tableview.frame.height/2 - 119/2 - 110, width: 121, height: 119))
            cowImage.image = UIImage(named: "emptyTable")
            self.view.addSubview(cowImage)
            
            tableview.backgroundView = messageLabel;
            tableview.separatorStyle = .none;
        }
        createdEmptyView = true
        
        
    }
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {
    }
    
}
