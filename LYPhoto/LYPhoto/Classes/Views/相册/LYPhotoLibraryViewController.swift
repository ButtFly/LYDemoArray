//
//  LYPhotoLibraryViewController.swift
//  LYPhoto
//
//  Created by 余河川 on 2018/11/15.
//  Copyright © 2018 余河川. All rights reserved.
//

import UIKit
import Photos
import MetalKit

class LYPhotoLibraryViewController: LYNNViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title  = "相册"
        
        let options = PHFetchOptions.init()
        options.includeAssetSourceTypes = [.typeCloudShared, .typeiTunesSynced, .typeUserLibrary]
        PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: options).enumerateObjects { (collection, idx, stop) in
            
            print(collection.localizedTitle ?? "xxxx")
            print(PHAsset.fetchAssets(in: collection, options: options).count)
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(touches.first?.location(in: self.view) ?? CGPoint.init(x: NSNotFound, y: NSNotFound))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(touches.first?.location(in: self.view) ?? CGPoint.init(x: NSNotFound, y: NSNotFound))
        
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
