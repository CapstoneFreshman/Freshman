//
//  LaunchViewController.swift
//  Haru_read
//
//  Created by 전서현 on 5/7/24.
//

import UIKit

class LaunchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 새 UIView 객체 생성
                let view = UIView()
                // UIView의 프레임 설정
        
                view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)
                // UIView의 배경색 설정
                view.layer.backgroundColor = UIColor(red: 1, green: 0.98, blue: 0.949, alpha: 1).cgColor
                // UIView의 모서리 둥글게 처리
                view.layer.cornerRadius = 46
                
                // 현재 뷰 컨트롤러의 메인 뷰에 추가
                self.view.addSubview(view)
    }
    
}
