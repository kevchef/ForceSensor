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
    var index = 0
    var good = true;
    @IBOutlet weak var SessionPlotCirclular: CrankBinPlot!
    @IBOutlet weak var BarChart: BarChart!
    @IBOutlet weak var Histo: Histogramm!
    @IBOutlet weak var ProgressB: ProgressBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var maxPoints : [Int] = [140,170,200,130,70,40,60,80]
        var avgPoints : [Int] = [120,140,180,110,60,35,55,60]
        var minPoints : [Int] = [100,110,150,105,55,30,53,55]
        var stdPoints : [Int] = [10,15,10,15,25,30,13,20]
        SessionPlotCirclular.setup(minP: minPoints.map{CGFloat($0)}, avgP: avgPoints.map{CGFloat($0)}, maxP: maxPoints.map{CGFloat($0)}, stdP: stdPoints.map{CGFloat($0)})
        var barentries = [100, 80, 60, 40 , 20, 40, 80, 20]
        BarChart.setup(barentries: barentries.map{CGFloat($0)})
        var histoentries = [10, 20, 30, 60 , 80, 70, 30, 30, 20, 10]
        Histo.setup(barentries: histoentries.map{CGFloat($0)})
        ProgressB.setup()
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            self.index += 1
            if (self.index % 30 == 0){
                self.good = !self.good
                print(self.good)
            }
            self.ProgressB.update(good: self.good)
        }
        timer.fire()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func ShowForcesView(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ForceView") as? ForceViewController
        present(vc!, animated: true, completion: nil)

    }
    

}
