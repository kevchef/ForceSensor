//
//  EnterFilenameViewController.swift
//  ForceSensor
//
//  Created by Kevin Schneider on 05.06.19.
//  Copyright © 2019 Kevin Schneider. All rights reserved.
//

import UIKit

class EnterFilenameViewController: UIViewController {

    @IBOutlet weak var EnterFilename: UITextField!
    var RecordButton: RecordButton!
    var filename = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func Done(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ForceView") as? ForceViewController
        vc?.writeToCSV = true
        filename = EnterFilename.text ?? "test"
        filename += ".csv"
        vc?.filename = filename
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        vc?.path = path! as NSURL
        vc?.RecordButton = RecordButton
        vc?.recordStartTime = Date()
        present(vc!, animated: true, completion: nil)
        
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ForceView") as? ForceViewController
        RecordButton.switchState()
        vc?.RecordButton = RecordButton
        vc?.writeToCSV = false
        present(vc!, animated: true, completion: nil)
        
    }
    
}
