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
    var avgPoints: [CGFloat]!
    @IBOutlet weak var SessionPlotCirclular: CirclularPlot!
    @IBOutlet weak var ProfileDevelopmentPlot: DevelopmentPlot!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var maxPoints : [Int] = [140,170,200,130,70,40,60,80]
        var avgPoints : [Int] = [120,140,180,110,60,35,55,60]
        var minPoints : [Int] = [100,110,150,105,55,30,53,55]
        SessionPlotCirclular.setup(minP: minPoints.map{CGFloat($0)}, avgP: avgPoints.map{CGFloat($0)}, maxP: maxPoints.map{CGFloat($0)})
        ProfileDevelopmentPlot.setup()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func ShowForcesView(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ForceView") as? ForceViewController
        present(vc!, animated: true, completion: nil)

    }
    

}
