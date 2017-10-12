//
//  ChatVC.swift
//  Meek_MVP
//
//  Created by Karlygash Zhuginissova on 8/14/17.
//  Copyright © 2017 Duvelop. All rights reserved.
//

import UIKit
import FirebaseDatabase
import JSQMessagesViewController

class ChatVC: JSQMessagesViewController {
    
    var question: Question!
    var messages = [Message]()
    var chat: Chat!
    
    var messagesHandle: DatabaseHandle = 0
    var messagesRef: DatabaseReference?
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage = {
        guard let bubbleImageFactory = JSQMessagesBubbleImageFactory() else {
            fatalError("Error creating bubble image factory.")
        }
        
        let color = UIColor.jsq_messageBubbleBlue()
        return bubbleImageFactory.outgoingMessagesBubbleImage(with: color)
    }()
    
    var incomingBubbleImageView: JSQMessagesBubbleImage = {
        guard let bubbleImageFactory = JSQMessagesBubbleImageFactory() else {
            fatalError("Error creating bubble image factory.")
        }
        
        let color = UIColor.jsq_messageBubbleLightGray()
        return bubbleImageFactory.incomingMessagesBubbleImage(with: color)
    }()

    func addNavBar() {
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height:54)) // Offset by 20 pixels vertically to take the status bar into account
        
        navigationBar.barTintColor = self.hexStringToUIColor(hex: "FBFBFB")
        navigationBar.tintColor = UIColor.black
        
        //navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.black]
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        //navigationItem.title = "NavBarAppears!"
        
        let backImage = UIImage(named: "backBtn")
        let imgWidth = backImage?.size.width
        let imgHeight = backImage?.size.height
        let button:UIButton = UIButton(frame: CGRect(x: 0,y: 0,width: imgWidth!, height: imgHeight!))
        button.setBackgroundImage(backImage, for: .normal)
        button.addTarget(self, action: #selector(btn_clicked(_:)), for: UIControlEvents.touchUpInside)
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        // Create left and right button for navigation item
        let leftButton = UIBarButtonItem(title: "Back", style:  .plain, target: self, action: #selector(btn_clicked(_:)))
        navigationItem.leftBarButtonItem = leftButton

        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.navigationItem.leftBarButtonItem = leftButton
        self.view.addSubview(navigationBar)
        
    //    collectionView.frame = CGRect(x: 0, y: 54, width: view.frame.size.width, height:view.frame.size.height - 54)
        
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.row == 0 {
            return 54
        }
        else {
            return 0
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

    
    func btn_clicked(_ sender: UIBarButtonItem) {
        // Do something
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addNavBar()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupJSQMessagesViewController()
        self.tryObservingMessages()
    }
    
    deinit {
        messagesRef?.removeObserver(withHandle: messagesHandle)
    }
    
    func tryObservingMessages() {
        guard let chatKey = self.chat?.key else { return }
        
        messagesHandle = DataManager.observeMessages(forChatKey: chatKey, completion: { [weak self] (ref, message) in
            self?.messagesRef = ref
            
            if let message = message {
                self?.messages.append(message)
                self?.finishSendingMessage()
            }
        })

    }
    
    func setupJSQMessagesViewController() {
        // 1. identify current user
        senderId = User.current.uid
        senderDisplayName = User.current.uid

        
        // 2. remove attachment button
        inputToolbar.contentView.leftBarButtonItem = nil
        
        // 3. remove avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
       // collectionView.frame = collectionView.frame.offsetBy(dx: 0, dy: 44)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension ChatVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item].jsqMessageValue
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        let sender = message.sender
        
        if sender.uid == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.item]
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView?.textColor = (message.sender.uid == senderId) ? .white : .black
        return cell
    }
}

// MARK: - Send Message

extension ChatVC {
    func sendMessage(_ message: Message) {
        if chat?.key == nil {
            DataManager.createChat(fromMessage: message, forQuestion: question!, completion: { [weak self] (chat) in
                guard let chat = chat else { return }
                
                self?.chat = chat
                
                self?.tryObservingMessages()
            })
        } else {
            DataManager.sendMessage(message, forChat: chat!)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = Message(content: text)
        sendMessage(message)
        finishSendingMessage()
        
        JSQSystemSoundPlayer.jsq_playMessageSentAlert()
    }
}
