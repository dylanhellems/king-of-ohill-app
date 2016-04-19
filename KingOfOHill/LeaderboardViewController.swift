//
//  LeaderboardViewController.swift
//  KingOfOHill
//
//  Created by user116333 on 4/18/16.
//  Copyright © 2016 Dylan Hellems. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView?

    override func viewDidLoad() {
        super.viewDidLoad()

        webView?.loadRequest(NSURLRequest(URL: NSURL(string: "https://king-of-ohill-web.herokuapp.com/")!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction
    func backToMenu() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
