//
//  ResponsesVC.swift
//  Meek_MVP
//
//  Created by Sara Du  on 7/26/17.
//  Copyright © 2017 Duvelop. All rights reserved.
//

import UIKit
import FirebaseAuth

class ResponsesVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let rowCount = 4
    var answeredQuestions = [Question]() {
        didSet {
            self.tableview.reloadData()
        }
    }
    
    var currentCell = 0
    @IBOutlet weak var tableview: UITableView!
    var cowImage = UIImageView()
    var createdEmptyView = false
    var messageLabel = UILabel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        let title = NSLocalizedString("PullToRefresh", comment: "Pull to refresh")
        refreshControl.attributedTitle = NSAttributedString(string: title)
        refreshControl.addTarget(self,
                                 action: #selector(refreshOptions(sender:)),
                                 for: .valueChanged)
        tableview.refreshControl = refreshControl

        self.tableview.register(UINib(nibName: "ResponsesCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableview.register(UINib(nibName: "BlankCell", bundle: nil), forCellReuseIdentifier: "blankcell")
        self.tableview.separatorStyle = .none
        self.tableview.backgroundColor = self.hexStringToUIColor(hex: "F6F6F9")


    }
    
    @objc private func refreshOptions(sender: UIRefreshControl) {
        // Perform actions to refresh the content
        // ...
        // and then dismiss the control
  
        sender.endRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                DataManager.retrieveAllAnsweredQuestions { (answeredQuestions) in
                    self.answeredQuestions = answeredQuestions
                    print(answeredQuestions)
                }
            }
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if answeredQuestions.count > 0 {
            cowImage.removeFromSuperview()
            return 1
        } else {
            EmptyMessage(message: "No Responses Yet", viewController: self)
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answeredQuestions.count + 1
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
            self.performSegue(withIdentifier: "detailedResult", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "detailedResult"){
            let vc = segue.destination as! MeekResultVC
            vc.segueFromTab = true
            vc.questionAnswered = answeredQuestions[currentCell-1]
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        messageLabel.isHidden = true
        let cell : ResponsesCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ResponsesCell
        cell.selectionStyle = .none
        let blankcell: BlankCell = tableView.dequeueReusableCell(withIdentifier: "blankcell") as! BlankCell
        
        var questionForCell: Question?
        
        if indexPath.row > 0 {
            questionForCell = answeredQuestions[indexPath.row-1]
        }
        
        if(indexPath.row == 0) {
            blankcell.selectionStyle = .none
            return blankcell
        } else {
            cell.contentLabel.text = questionForCell!.content
            //set the percentages and the result image here
            
            if(questionForCell?.responseByUser == "yes"){
                cell.decisionImage.image = UIImage(named: "cards_resultsYes")
            }else if(questionForCell?.responseByUser == "meh"){
                cell.decisionImage.image = UIImage(named: "cards_resultsMeh")
            }else{
                cell.decisionImage.image = UIImage(named: "cards_resultsNo")
            }
 
            DataManager.percentageVoted(forQuestion: questionForCell!, completion: { (no, meh, yes) in
                //HERE WE GET THE PERCENTAGE OF ALL THREE TYPES OF VOTES
                if no != nil {
                    cell.progressBar1.progress = CGFloat(yes!)
                    cell.progressBar2.progress = CGFloat(no!)
                    cell.progressBar3.progress = CGFloat(meh!)
                }
            })

  //          cell.alpha = 0
            
 //           UIView.animate(withDuration: 1, animations: { cell.alpha = 1 })
            return cell
        }
    }
    
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
    
    func EmptyMessage(message:String, viewController:ResponsesVC) {
        
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
