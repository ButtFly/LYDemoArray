//
//  LYRootNavigationController.swift
//  LYPhoto
//
//  Created by 余河川 on 2018/11/15.
//  Copyright © 2018 余河川. All rights reserved.
//

import UIKit

class LYRootNavigationController: LYNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.isHidden = true
        self.view.backgroundColor = UIColor.white
    }
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = [LYPhotoLibraryViewController.init()];
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
