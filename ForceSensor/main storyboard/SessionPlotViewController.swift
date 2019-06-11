//
//  SessionPlotViewController.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 10.06.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import UIKit

class SessionPlotViewController: UIViewController {
    
    var data = outputData()
    @IBOutlet weak var SessionPlotCirclular: CirclularPlot!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func ShowForcesView(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ForceView") as? ForceViewController
        present(vc!, animated: true, completion: nil)

    }
    

}
