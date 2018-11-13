//
//  LYPhotoTool.swift
//  HelloMetal
//
//  Created by 余河川 on 2018/11/7.
//  Copyright © 2018 余河川. All rights reserved.
//

import UIKit
import Photos

class LYPhotoTool: NSObject {
    
    override init() {
        super.init()
        _ly_checkStatus()
    }
    
    open func ly_requestAllPhotos() -> PHFetchResult<PHAsset> {
        let fetchOptions = PHFetchOptions.init()
        var assetSourceType = PHAssetSourceType.init()
        assetSourceType.insert(.typeCloudShared)
        assetSourceType.insert(.typeiTunesSynced)
        assetSourceType.insert(.typeUserLibrary)
        fetchOptions.includeAssetSourceTypes = assetSourceType
        return PHAsset.fetchAssets(with: fetchOptions)
    }
    
    open func ly_requestColletions() -> PHFetchResult<PHCollection> {
        
        let fetchOptions = PHFetchOptions.init()
        var assetSourceType = PHAssetSourceType.init()
        assetSourceType.insert(.typeCloudShared)
        assetSourceType.insert(.typeiTunesSynced)
        assetSourceType.insert(.typeUserLibrary)
        fetchOptions.includeAssetSourceTypes = assetSourceType
        return PHCollectionList.fetchTopLevelUserCollections(with: fetchOptions)
        
    }
    
    open func ly_getImage(_ asset: PHAsset, resultHandle: @escaping (UIImage?, [AnyHashable : Any]?) -> Void) -> Void {
        
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil, resultHandler: resultHandle)
        
    }
    
    fileprivate func _ly_checkStatus() -> Void {
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized: do {
            
            print("已经获得权限")
            
            }
        case .notDetermined:
            print("用户还没决定权限")
        case .restricted:
            print("受到限制的")
        case .denied:
            print("用户拒绝了")
        }
    }
    
    fileprivate func _ly_photoLibraryAuthorized() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }

}
