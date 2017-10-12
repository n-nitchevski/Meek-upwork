//
//  ConfirmationVC.swift
//  Meek_MVP
//
//  Created by Andrew  on 7/29/17.
//  Copyright © 2017 Duvelop. All rights reserved.
//

import UIKit

class ConfirmationVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidLayoutSubviews() {
        print("Confirmation showing")
        print(2)
        self.performSegue(withIdentifier: "returnToTab", sender: self)
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

}
