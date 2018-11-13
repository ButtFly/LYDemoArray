//
//  ViewController.swift
//  HelloMetal
//
//  Created by 余河川 on 2018/11/6.
//  Copyright © 2018 余河川. All rights reserved.
//

import UIKit
import SnapKit
import Photos

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    fileprivate var collectionView: UICollectionView!
    var fetchResult: PHFetchResult<PHAsset>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        _ly_initData()
        _ly_initSubviews()
        
    }
    
    func _ly_initData() -> Void {
        
        fetchResult = LYPhotoTool().ly_requestAllPhotos()
        let collections = LYPhotoTool.init().ly_requestColletions()
        collections.enumerateObjects { (collection, idx, stop) in
            print("xxxxxx\(collection.localizedTitle ?? "xx")")
        }
        
    }
    
    func _ly_initSubviews() -> Void {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 300, height: 300)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.left.right.equalTo(0)
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.top.equalTo(topLayoutGuide.snp.bottom)
                make.bottom.equalTo(bottomLayoutGuide.snp.top)
            }
            make.left.right.equalTo(0)
        }
        collectionView.backgroundColor = UIColor.yellow
        collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "UICollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchResult.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        LYPhotoTool.init().ly_getImage(fetchResult.object(at: indexPath.item)) { (image, info) in
            
            print(self.fetchResult[indexPath.item])
            cell.backgroundColor = UIColor(patternImage: image ?? UIImage())
            
        }
        return cell
    }

}

