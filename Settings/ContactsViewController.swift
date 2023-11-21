//
//  ContactsViewController.swift
//  TumTumCha
//
//  Created by Marco Di Fiandra on 07/06/2019.
//  Copyright © 2019 Apple Academy. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController {

    @IBOutlet weak var facebookButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = ""
        
    }
 
    @IBAction func facebookButton(_ sender: Any) {
        openUrl(urlStr: "https://www.facebook.com/Rhitme-617359375339076/?modal=admin_todo_tour")
    }
    
    func openUrl(urlStr: String!) {
        if let url = URL(string:urlStr), !url.absoluteString.isEmpty {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }    
}
