//
//  TabVC.swift
//  Meek_MVP
//
//  Created by Sara Du  on 7/26/17.
//  Copyright © 2017 Duvelop. All rights reserved.
//

import Tabman
import Pageboy
import PureLayout

class TabVC: TabmanViewController, PageboyViewControllerDataSource {
    
    
    @IBOutlet weak var imgView: UIImageView!
    override func viewWillAppear(_ animated: Bool) {
        let logo = UIImage(named: "meek")
        let imageView = UIImageView(frame: CGRect(x: 142, y: 27, width: 80, height: 25)); // set as you want
        imageView.image = logo
        imageView.contentMode = .scaleAspectFit // set imageview's content mode
        self.navigationController?.navigationBar.topItem?.titleView = imageView
        self.navigationController?.navigationBar.barTintColor = UIColor.white


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        self.bar.style = .buttonBar
        
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            
            appearance.style.background = .solid(color: UIColor.white)
            appearance.style.bottomSeparatorColor = UIColor.lightGray
            appearance.layout.height = TabmanBar.Height.explicit(value: 61.0)
            appearance.indicator.color = self.hexStringToUIColor(hex: "02D3A4")
            appearance.state.selectedColor = self.hexStringToUIColor(hex: "02D3A4")
            appearance.indicator.lineWeight = .thick
            appearance.indicator.compresses = false
            appearance.indicator.useRoundedCorners = true
            appearance.text.font = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightThin)
            
        })
        
        
    }
    
    func viewControllers(forPageboyViewController pageboyViewController: PageboyViewController) -> [UIViewController]? {
        // return array of view controllers
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController1 = storyboard.instantiateViewController(withIdentifier: "Responses")
        //viewController1.index = 1
        let viewController2 = storyboard.instantiateViewController(withIdentifier: "Questions")
        //viewController2.index = 2
        let viewControllers = [viewController1, viewController2]
        // configure the bar
        
        self.bar.items = [Item(title: "RESPONSES"),
                          Item(title: "QUESTIONS")]
        
        return viewControllers
    }
    
    func defaultPageIndex(forPageboyViewController pageboyViewController: PageboyViewController) -> PageboyViewController.PageIndex? {
        // use default index
        return nil
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
    
    
    @IBAction func askPressed(_ sender: Any) {
        imgView.image = UIImage(named: "askPressed")
    }
    @IBAction func joinPressed(_ sender: Any) {
        let passcodeVC: PasscodeLockViewController
        
        passcodeVC = PasscodeLockViewController(state: .enterPasscode, configuration: configuration, animateOnDismiss: true)
        passcodeVC.cameFromPost = true
        
        present(passcodeVC, animated: true, completion: nil)
        imgView.image = UIImage(named: "joinPressed")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        imgView.image = UIImage(named: "askjoinBtn")
    }
    @IBAction func unwindHome(_ segue: UIStoryboardSegue) {
        // this is intentionally blank
    }
    
}
