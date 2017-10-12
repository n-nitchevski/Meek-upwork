import UIKit
import CoreLocation

extension UIView {
    
    //adds gradient background to passcodelock
    func addBackground() {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "passcodeBackground")
        
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubview(toBack: imageViewBackground)
    }
    
}

open class PasscodeLockViewController: UIViewController, PasscodeLockTypeDelegate, isAbleToReceiveData, CLLocationManagerDelegate {
    
    
    public enum LockState {
        case enterPasscode
        case setPasscode
        
        func getState() -> PasscodeLockStateType {
            
            switch self {
            case .enterPasscode: return EnterPasscodeState()
            case .setPasscode: return SetPasscodeState()
            }
        }
    }
    
    
    @IBOutlet open weak var descriptionLabel: UILabel?
    @IBOutlet open var placeholders: [PasscodeSignPlaceholderView] = [PasscodeSignPlaceholderView]()
    @IBOutlet open weak var cancelButton: UIButton?
    @IBOutlet open weak var deleteSignButton: UIButton?
    @IBOutlet open weak var placeholdersX: NSLayoutConstraint?
    
    open var successCallback: ((_ lock: PasscodeLockType) -> Void)?
    open var dismissCompletionCallback: (()->Void)?
    open var animateOnDismiss: Bool
    
    internal let passcodeConfiguration: PasscodeLockConfigurationType
    internal var passcodeLock: PasscodeLockType
    internal var isPlaceholdersAnimationCompleted = true
    
    var questionAsked: Question?
    var cameFromPost = false
    //Location
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    // MARK: - Initializers
    
    public init(state: PasscodeLockStateType, configuration: PasscodeLockConfigurationType, animateOnDismiss: Bool = true) {
        
        self.animateOnDismiss = animateOnDismiss
        
        passcodeConfiguration = configuration
        passcodeLock = PasscodeLock(state: state, configuration: configuration)
        
        let nibName = "PasscodeLockView"
        let bundle: Bundle = bundleForResource(nibName, ofType: "nib")
        
        super.init(nibName: nibName, bundle: bundle)
        
        passcodeLock.delegate = self
        //notificationCenter = NotificationCenter.default
        
        self.view.addBackground()
        
        deleteSignButton?.imageView?.image = UIImage(named: "backspace.png")
        
        
        
    }
    
    
    public convenience init(state: LockState, configuration: PasscodeLockConfigurationType, animateOnDismiss: Bool = true) {
        self.init(state: state.getState(), configuration: configuration, animateOnDismiss: animateOnDismiss)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - View
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePasscodeView()
        deleteSignButton?.isEnabled = false
        
        locationManager.delegate = self
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    internal func updatePasscodeView() {
        
        descriptionLabel?.text = passcodeLock.state.description
        cancelButton?.isHidden = !passcodeLock.state.isCancellableAction
    }
    
    // MARK: - Actions
    
    @IBAction func passcodeSignButtonTap(_ sender: PasscodeSignButton) {
        
        guard isPlaceholdersAnimationCompleted else { return }
        passcodeLock.addSign(sender.passcodeSign)
    }
    
    @IBAction func cancelButtonTap(_ sender: UIButton) {
        
        dismissPasscodeLock(passcodeLock)
    }
    
    @IBAction func deleteSignButtonTap(_ sender: UIButton) {
        
        passcodeLock.removeSign()
    }
    
    
    internal func dismissPasscodeLock(_ lock: PasscodeLockType, completionHandler: (() -> Void)? = nil) {
        
        // if presented as modal
        if presentingViewController?.presentedViewController == self {
            
            dismiss(animated: animateOnDismiss, completion: { [weak self] _ in
                
                self?.dismissCompletionCallback?()
                
                completionHandler?()
            })
            
            return
            
            // if pushed in a navigation controller
        } else if navigationController != nil {
            
            navigationController?.popViewController(animated: animateOnDismiss)
        }
        
        dismissCompletionCallback?()
        
        completionHandler?()
    }
    
    // MARK: - Animations
    
    internal func animateWrongPassword() {
        
        deleteSignButton?.isEnabled = false
        isPlaceholdersAnimationCompleted = false
        
        animatePlaceholders(placeholders, toState: .error)
        
        placeholdersX?.constant = -40
        view.layoutIfNeeded()
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                
                self.placeholdersX?.constant = 0
                self.view.layoutIfNeeded()
        },
            completion: { completed in
                
                self.isPlaceholdersAnimationCompleted = true
                self.animatePlaceholders(self.placeholders, toState: .inactive)
        })
    }
    
    internal func animatePlaceholders(_ placeholders: [PasscodeSignPlaceholderView], toState state: PasscodeSignPlaceholderView.State) {
        
        for placeholder in placeholders {
            
            placeholder.animateState(state)
        }
    }
    
    fileprivate func animatePlacehodlerAtIndex(_ index: Int, toState state: PasscodeSignPlaceholderView.State) {
        
        guard index < placeholders.count && index >= 0 else { return }
        
        placeholders[index].animateState(state)
    }
    
    // MARK: - PasscodeLockDelegate
    
    open func passcodeLockDidSucceed(_ lock: PasscodeLockType) {
        
        deleteSignButton?.isEnabled = true
        animatePlaceholders(placeholders, toState: .inactive)
        dismissPasscodeLock(lock, completionHandler: { [weak self] _ in
            self?.successCallback?(lock)
        })
    }
    
    open func passcodeLockDidFail(_ lock: PasscodeLockType) {
        
        animateWrongPassword()
    }
    
    
    //check the password here
    
    open func passcodeLockDidChangeState(_ lock: PasscodeLockType) {
        print(lock.thePass)

        /*
        if(lock.state.title == "Enter Passcode"){
            //do stuff here
            print(lock.thePass)
        }

        */
        updatePasscodeView()
        animatePlaceholders(placeholders, toState: .inactive)
        deleteSignButton?.isEnabled = false
    }
    
    var successView = UIView()
    //relevant code pieces down here
    
    open func passcodeLock( _ lock: PasscodeLockType, addedSignAtIndex index: Int) {
        
        var lock = lock
        animatePlacehodlerAtIndex(index, toState: .active)
        deleteSignButton?.isEnabled = true
        
        
        if(index == 3){
            //user is setting passcode for new question
            if(lock.state.title == "Set a Passcode"){
                
                let questionPasscode = lock.thePass.joined()
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                Question.readyToPostQuestion.passcode = questionPasscode
                DataManager.postNewQuestion(thisQuestion: Question.readyToPostQuestion) { (postedQuestion, errorMessage) in
                    
                    guard let _ = postedQuestion else {
                        let alertController = UIAlertController(title: errorMessage, message: nil, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                        lock.delegate?.passcodeLockDidFail(lock)
                        return
                    }
                    dispatchGroup.leave()
                    print("Posted!: \(String(describing: postedQuestion?.content))")
                }
                
                
                dispatchGroup.notify(queue: .main, execute: { 
                    
                    self.successView = self.instantiateFromNib()
                   /*
                    view.alpha = 0
                    view.fadeIn(completion: {
                        (finished: Bool) -> Void in
                        //view.fadeOut()
                        //self.dismissPasscodeLock(self.passcodeLock)
                                            })
 */
                    self.view.addSubview(self.successView)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier :"Results") as! MeekResultVC
                    viewController.questionAnswered = self.questionAsked
                    self.present(viewController, animated: true)

                })

                
            }else{

                //the user wants to enter the shared question
                var question: Question?
                
                let thePass = lock.thePass.joined()
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                if currentLocation == nil {
                    currentLocation = self.locationManager.location
                    if currentLocation == nil
                    {
                        let alertController = UIAlertController(title: "Location does not exist.", message: nil, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                }
                DataManager.retrieveQuestion(withPasscode: thePass, atLocation: currentLocation!, completion: { (foundQuestion, errorMessage) in
                    guard let _ = foundQuestion else {
                        lock.delegate?.passcodeLockDidFail(lock)

                        let alertController = UIAlertController(title: "There is not question with passcode \(thePass), or it is expired. Try another passcode", message: nil, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    
                    question = foundQuestion
                    dispatchGroup.leave()
                    
                })
                
                dispatchGroup.notify(queue: .main, execute: {
                    if question != nil {
                        //JOINING A QUESTION
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "Pick") as! PickMeekVC
                        controller.pickDelegate = self
                        controller.showingResults = false
                        controller.fromTabVC = true
                        controller.questionJoined = question
                        self.present(controller, animated: true, completion: nil)
//                        lock.delegate?.passcodeLockDidSucceed(lock)

                    }
                    
                })
                

            }
        }
    }
    
    
    
    var delegate: isAbleToReceiveData?
    
    override open func viewDidDisappear(_ animated: Bool) {
        if(cameFromPost){
           successView.removeFromSuperview()
            cameFromPost = false
        }
        delegate?.pass(data: "") //sending empty data to PostQuestionsVC

    }
    
    override open func viewWillAppear(_ animated: Bool) {
        print(cameFromPost)
        if(!cameFromPost){
            self.dismissPasscodeLock(self.passcodeLock)
        }
    }
    
    func instantiateFromNib() -> UIView {
        return UINib(nibName: "ConfirmationScreen", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    open func passcodeLock(_ lock: PasscodeLockType, removedSignAtIndex index: Int) {
        
        animatePlacehodlerAtIndex(index, toState: .inactive)
        
        if index == 0 {
            
            deleteSignButton?.isEnabled = false
        }
    }
    
    
    //data is getting passed to this VC
    func pass(data: String) { //conforms to protocol
        // implement your own implementation
        print("data was passed and we're now dismissing")
        self.dismiss(animated: false, completion: nil)
    }
    
}
