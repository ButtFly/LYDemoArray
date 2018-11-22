//
//  LYNNViewController.swift
//  LYPhoto
//
//  Created by 余河川 on 2018/11/15.
//  Copyright © 2018 余河川. All rights reserved.
//

import UIKit


class LYNNVCSimilarNavigationBar: UIView {
    
    private(set) var leftButton: UIButton
    private(set) var titleLabel: UILabel
    private(set) var bottomLine: UIView
    
    override init(frame: CGRect) {
        self.leftButton = UIButton.init(frame: CGRect.zero)
        self.titleLabel = UILabel.init(frame: CGRect.zero)
        self.bottomLine = UIView.init(frame: CGRect.zero)
        super.init(frame: frame)
        _ly_initSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func _ly_initSubViews() -> Void {
        
        self.addSubview(leftButton)
        leftButton.setImage(_ly_leftButtonSnapshoot(), for: .normal)
        leftButton.isHidden = true
        
        self.addSubview(titleLabel)
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor.init(red: 34 / 255.0, green: 34 / 255.0, blue: 34 / 255.0, alpha: 1.0)
        
        self.addSubview(bottomLine)
        bottomLine.backgroundColor = UIColor.init(red: 0xd5 / 255.0, green: 0xd5 / 255.0, blue: 0xd5 / 255.0, alpha: 1.0)
        
        _ly_addConstains();
    }
    
    func _ly_addConstains() -> Void {
        leftButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.snp.bottom).offset(-22)
            make.left.equalTo(0)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self.snp.bottom).offset(-22)
        }
        bottomLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(1 / UIScreen.main.scale)
        }
    }
    
    func _ly_leftButtonSnapshoot() -> UIImage? {
        let viewT = UIView.init(frame: CGRect.zero)
        
        let leftIV = UIImageView.init(image: UIImage.init(named: "LYNNViewController_left_arrow"))
        viewT.addSubview(leftIV)
        
        
        let rightLbl = UILabel.init(frame: CGRect.zero)
        viewT.addSubview(rightLbl)
        rightLbl.text = "返回"
        rightLbl.font = UIFont.systemFont(ofSize: 15)
        rightLbl.textColor = UIColor.black
        
        viewT.snp.makeConstraints { (make) in
            make.size.greaterThanOrEqualTo(CGSize.init(width: 44, height: 44))
        }
        leftIV.snp.makeConstraints { (make) in
            make.centerY.equalTo(viewT)
            make.left.equalTo(10)
            make.top.greaterThanOrEqualTo(0)
            make.bottom.lessThanOrEqualTo(0)
        }
        rightLbl.snp.makeConstraints { (make) in
            make.centerY.equalTo(leftIV)
            make.left.equalTo(leftIV.snp.right).offset(4)
            make.right.lessThanOrEqualTo(0)
        }
        leftIV.sizeToFit()
        rightLbl.sizeToFit()
        leftIV.layoutIfNeeded()
        rightLbl.layoutIfNeeded()
        viewT.layoutIfNeeded()
        return viewT.ly_snapshootImage()
        
    }
    
}

/// 没有 navigation bar 的 view controller
class LYNNViewController: LYViewController {

    private(set) var containerView: UIView
    private(set) var similarNavigationBar: LYNNVCSimilarNavigationBar
    
    override var title: String?{
        didSet {
            similarNavigationBar.titleLabel.text = title
        }
    }
    
    var hideSimilarNavigationBar = false {
        didSet {
            if oldValue == hideSimilarNavigationBar {
                return
            }
            similarNavigationBar.isHidden = hideSimilarNavigationBar
            _ly_viewUpdateConstrains()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ly_viewInitSubviews()
        
        self.similarNavigationBar.leftButton.isHidden = self.navigationController?.viewControllers.count ?? 0 <= 1
        // Do any additional setup after loading the view.
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        self.containerView = UIView.init(frame: CGRect.zero)
        self.similarNavigationBar = LYNNVCSimilarNavigationBar.init(frame: CGRect.zero)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        self.containerView = UIView.init(frame: CGRect.zero)
        self.similarNavigationBar = LYNNVCSimilarNavigationBar.init(frame: CGRect.zero)
        super.init(coder: aDecoder)
        
    }
    
    init() {
        
        self.containerView = UIView.init(frame: CGRect.zero)
        self.similarNavigationBar = LYNNVCSimilarNavigationBar.init(frame: CGRect.zero)
        super.init(nibName: nil, bundle: nil)
        
    }
    
    
    fileprivate func _ly_viewInitSubviews() -> Void {
        
        self.view.addSubview(self.similarNavigationBar)
        self.similarNavigationBar.leftButton.addTarget(self, action: #selector(_ly_similarNavigationBarleftButtonTouchUpInside(sender:)), for: .touchUpInside)
        
        self.view.addSubview(self.containerView)
        self.containerView.backgroundColor = UIColor.white
        
        _ly_viewUpdateConstrains()
        
    }
    
    fileprivate func _ly_viewUpdateConstrains() -> Void {
        
        let similarNBHeight:CGFloat = self.hideSimilarNavigationBar ? 0 : 44
        self.similarNavigationBar.snp.remakeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(similarNBHeight)
            } else {
                make.bottom.equalTo(self.topLayoutGuide.snp.bottom).offset(similarNBHeight)
            }
            make.top.left.right.equalTo(self.view)
        }
        
        self.containerView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(self.bottomLayoutGuide.snp.top)
            }
            make.top.equalTo(self.similarNavigationBar.snp.bottom)
            make.left.right.equalTo(self.view)
        }
        
    }
    
    @objc func _ly_similarNavigationBarleftButtonTouchUpInside(sender: UIButton) -> Void {
        
        if self.parent == nil {
            return
        }
        
        if self.parent! is UINavigationController {
            let nav = self.parent as! UINavigationController
            nav.popViewController(animated: true)
        } else {
            self.parent!.dismiss(animated: true, completion: nil)
        }
        
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
