//
//  UIView+Snapshoot.swift
//  LYPhoto
//
//  Created by 余河川 on 2018/11/15.
//  Copyright © 2018 余河川. All rights reserved.
//

import UIKit

extension UIView {
    
    func ly_snapshootImage() -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        if let ctx = UIGraphicsGetCurrentContext() {
            self.layer.render(in: ctx)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
        
    }
    
}
