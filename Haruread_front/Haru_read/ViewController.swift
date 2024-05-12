//
//  ViewController.swift
//  Haru_read
//
//  Created by 전서현 on 5/5/24.
//

import UIKit
import AudioKit

class ViewController: UIViewController {
    let mystoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

    @IBAction func Start(_ sender: Any) {
        let LoginViewController = mystoryboard.instantiateViewController(withIdentifier: "LoginViewController")
        // 모달 전환 스타일 설정
        LoginViewController.modalTransitionStyle = .crossDissolve
        LoginViewController.modalPresentationStyle = .overFullScreen
        
        // 모달 방식으로 뷰 컨트롤러를 표시
        self.present(LoginViewController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let label = UILabel()
        label.frame = CGRect(x: 50, y: 100, width: 200, height: 50)
        label.text = "안녕!"
        label.font = UIFont(name: "HakgyoansimWoojuR", size: 24)
        self.view.addSubview(label)

    }

}



