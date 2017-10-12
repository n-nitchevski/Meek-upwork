//
//  PostQuestionsVC.swift
//  Meek_MVP
//
//  Created by Sara Du  on 7/26/17.
//  Copyright © 2017 Duvelop. All rights reserved.
//

import UIKit
import CoreLocation

protocol isAbleToReceiveData {
    func pass(data: String)  //data: string is an example parameter
}

class PostQuestionsVC: UIViewController, UITextViewDelegate, isAbleToReceiveData, CLLocationManagerDelegate {
    
    func pass(data: String) { //data given by PasscodeLockViewController
        //data is not needed because we will always need to pop view controller
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBOutlet weak var questionBackground: UIImageView!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var characterCount: UILabel!
    
    var backgroundColorIndex = 1
    
    let locationManager = CLLocationManager()
    var currentLocationCoordinate: CLLocationCoordinate2D?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = self.hexStringToUIColor(hex: "F4F4F4")
        textview.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
        
        self.navigationItem.title = "Ask a Question"
        
        textview.delegate = self
        textview.text = "Write your question here..."
        textview.textColor = UIColor.white
        textview.font = UIFont.systemFont(ofSize: 18.0, weight: 0.15)
        questionBackground.image = UIImage(named: "postQuestion1")
    
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let current = locations.last
        currentLocationCoordinate = current?.coordinate
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let len: Int = textview.text.characters.count
        characterCount.text = "\(len)/140 characters"
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == "Write your question here...")
        {
            textView.text = ""
            textView.textColor = .white
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textview.text == "")
        {
            textview.text = "Write your question here..."
            textview.textColor = .white
        }
        textview.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let isBackSpace = strcmp(text, "\\b")
        
        if(isBackSpace == -92){
            print("backspace")
        }else if textView.text.characters.count == 0 {
            if textView.text.characters.count != 0 {
                return true
            }
        }
        else if textView.text.characters.count > 139 {
            return false
        }
        
        if (textView.text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    let configuration: PasscodeLockConfigurationType
    
    init(configuration: PasscodeLockConfigurationType) {
        
        self.configuration = configuration
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        let repository = UserDefaultsPasscodeRepository()
        configuration = PasscodeLockConfiguration(repository: repository)
        
        super.init(coder: aDecoder)
    }
    
    @IBAction func postPressed(_ sender: Any) {
        if textview.text == "" {
            let alertController = UIAlertController(title: "A question content can't be empty", message: nil, preferredStyle: .alert)
            let tryAgain = UIAlertAction(title: "Try again", style: .default, handler: nil)
            alertController.addAction(tryAgain)
            present(alertController, animated: true, completion: nil)
        } else {
            let content = textview.text
            
            if currentLocationCoordinate == nil {
                self.locationManager.requestWhenInUseAuthorization()
                currentLocationCoordinate = self.locationManager.location?.coordinate
            }
            
            locationManager.startUpdatingLocation()
            
            let newQuestion = Question(posterUID: User.current.uid, coordinate: currentLocationCoordinate!, content: content!, createdAt: Date(), withBackground: backgroundColorIndex)
            
            Question.prepareToPost(thisQuestion: newQuestion)
            
            let passcodeVC: PasscodeLockViewController
            
            passcodeVC = PasscodeLockViewController(state: .setPasscode, configuration: configuration, animateOnDismiss: true)
            
            passcodeVC.delegate = self
            passcodeVC.cameFromPost = true
            passcodeVC.questionAsked = newQuestion
            present(passcodeVC, animated: true, completion: nil)
        }

    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
    
    @IBOutlet weak var horizontalView: PagedHorizontalView!
    
    let items = ["colorPallet1", "colorPallet2"]
    

}

extension PostQuestionsVC : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        cell.imageView.image = UIImage(named: items[indexPath.row])
        if(indexPath.row == 0){
            cell.btn1.tag = 1
            cell.btn2.tag = 2
            cell.btn3.tag = 3
            cell.btn4.tag = 4
            cell.btn5.tag = 5
            cell.btn6.tag = 6
            cell.btn7.isEnabled = false
        }else{
            cell.btn1.tag = 7
            cell.btn2.tag = 8
            cell.btn3.tag = 9
            cell.btn4.tag = 10
            cell.btn5.tag = 11
            cell.btn6.tag = 12
            cell.btn7.tag = 13
           
        }
        cell.btn1.addTarget(self, action: #selector(self.yourButtonClicked), for: .touchUpInside)
        cell.btn2.addTarget(self, action: #selector(self.yourButtonClicked), for: .touchUpInside)
        cell.btn3.addTarget(self, action: #selector(self.yourButtonClicked), for: .touchUpInside)
        cell.btn4.addTarget(self, action: #selector(self.yourButtonClicked), for: .touchUpInside)
        cell.btn5.addTarget(self, action: #selector(self.yourButtonClicked), for: .touchUpInside)
        cell.btn6.addTarget(self, action: #selector(self.yourButtonClicked), for: .touchUpInside)
        cell.btn7.addTarget(self, action: #selector(self.yourButtonClicked), for: .touchUpInside)

        return cell
    }
    
    func yourButtonClicked(_ sender: UIButton) {
        if sender.tag == 1 {
            backgroundColorIndex = 1
            questionBackground.image = UIImage(named: "postQuestion1")
        }else if(sender.tag == 2) {
            backgroundColorIndex = 2
            questionBackground.image = UIImage(named: "postQuestion2")
        }else if(sender.tag == 3) {
            backgroundColorIndex = 3
            questionBackground.image = UIImage(named: "postQuestion3")
        }else if(sender.tag == 4) {
            backgroundColorIndex = 4
            questionBackground.image = UIImage(named: "postQuestion4")
        }else if(sender.tag == 5) {
            backgroundColorIndex = 5
            questionBackground.image = UIImage(named: "postQuestion5")
        }else if(sender.tag == 6) {
            backgroundColorIndex = 6
            questionBackground.image = UIImage(named: "postQuestion6")
        }else if(sender.tag == 7) {
            backgroundColorIndex = 7
            questionBackground.image = UIImage(named: "postQuestion7")
        }else if(sender.tag == 8) {
            backgroundColorIndex = 8
            questionBackground.image = UIImage(named: "postQuestion8")
        }else if(sender.tag == 9) {
            backgroundColorIndex = 9
            questionBackground.image = UIImage(named: "postQuestion9")
        }else if(sender.tag == 10) {
            backgroundColorIndex = 10
            questionBackground.image = UIImage(named: "postQuestion10")
        }else if(sender.tag == 11) {
            backgroundColorIndex = 11
            questionBackground.image = UIImage(named: "postQuestion11")
        }else if(sender.tag == 12) {
            backgroundColorIndex = 12
            questionBackground.image = UIImage(named: "postQuestion12")
        }else{
            backgroundColorIndex = 13
            questionBackground.image = UIImage(named: "postQuestion13")
        }
    }

}
