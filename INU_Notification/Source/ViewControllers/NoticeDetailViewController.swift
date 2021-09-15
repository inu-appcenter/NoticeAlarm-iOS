//
//  NoticeDetailViewController.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/09/04.
//

import UIKit
import WebKit

class NoticeDetailViewController: UIViewController {
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    @IBOutlet weak var lineIndicator: UIView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        lineIndicator.roundCorners(.allCorners, radius: 10)
        
        webView.load(URLRequest(url: URL(string: "https://www.naver.com/")!))
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // 사용자가 View를 위로 끌 수 없도록 함
        guard translation.y >= 0 else { return }
        
        // 사용자가 프레임을 옆으로 이동하지 않도록 x를 0으로 설정, 직선으로 위 또는 아래 방향으로만 사용하게 할 것임
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    @IBAction func goToBeforeView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
