//
//  HaruSettingViewController.swift
//  Haru_read
//
//  Created by 전서현 on 5/6/24.
//

import UIKit

class HaruSettingViewController: UIViewController {
    private var selectedGender: String?
    private var selectedAgeGroup: String?
    private var selectedSpeakingStyle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // UI 설정 함수
    private func setupUI() {
        view.backgroundColor = UIColor(red: 255/255, green: 250/255, blue: 242/255, alpha: 1.0)  // 배경색 변경
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scrollView)

        var lastView: UIView? = nil
        let sections = [
            ("성별", ["남자", "여자"]),
            ("연령대", ["유년층", "청소년층", "성인층", "노년층"]),
            ("발화스타일", ["구연체", "낭독체", "대화체", "독백체", "애니체", "중계체", "친절체"])
        ]

        for (index, (title, options)) in sections.enumerated() {
            let sectionView = createSection(title: title, options: options, yOffset: CGFloat(index) * 100)
            scrollView.addSubview(sectionView)
            sectionView.frame.origin.y = lastView?.frame.maxY ?? 130
            lastView = sectionView
        }

        // "변경 완료" 버튼 추가
        let completeButton = UIButton(type: .system)
        completeButton.setTitle("변경 완료", for: .normal)
        completeButton.setTitleColor(.white, for: .normal)
        completeButton.backgroundColor = UIColor(red: 0.5059, green: 0.7176, blue: 0.5294, alpha: 1.0)
        completeButton.layer.cornerRadius = 5
        completeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        completeButton.frame = CGRect(x: 20, y: (lastView?.frame.maxY ?? 0) + 100, width: view.frame.width - 40, height: 44)
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        scrollView.addSubview(completeButton)

        // 스크롤 뷰의 콘텐츠 크기를 버튼까지 포함하도록 조정
        scrollView.contentSize = CGSize(width: view.frame.width, height: completeButton.frame.maxY + 20)
    }

    // 섹션 생성 함수
    private func createSection(title: String, options: [String], yOffset: CGFloat) -> UIView {
        let sectionView = UIView(frame: CGRect(x: 0, y: yOffset, width: view.frame.width, height: 50 + CGFloat(options.count/2) * 35))
        sectionView.autoresizingMask = [.flexibleWidth]

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = UIColor(red: 119/255, green: 78/255, blue: 61/255, alpha: 1)  // 텍스트 색상 변경
        titleLabel.frame = CGRect(x: 20, y: 5, width: view.frame.width - 40, height: 20)
        sectionView.addSubview(titleLabel)

        let buttonHeight: CGFloat = 30
        let buttonSpacing: CGFloat = 10
        let buttonWidth = (view.frame.width - 60) / 2

        for (index, option) in options.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.setTitleColor(UIColor(red: 119/255, green: 78/255, blue: 61/255, alpha: 1), for: .normal)  // 버튼 텍스트 색상 변경
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.cornerRadius = 5
            button.titleLabel?.font = UIFont(name: "HakgyoansimWoojuR", size: 14)
            let row = index / 2
            let column = index % 2
            button.frame = CGRect(
                x: 20 + CGFloat(column) * (buttonWidth + 20),
                y: titleLabel.frame.maxY + 5 + CGFloat(row) * (buttonHeight + buttonSpacing),
                width: buttonWidth,
                height: buttonHeight)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            sectionView.addSubview(button)
        }

        return sectionView
    }

    // 버튼을 눌렀을 때 동작하는 함수
    @objc func buttonTapped(_ sender: UIButton) {
        // 모든 버튼을 초기 상태로 되돌립니다.
        if let buttons = sender.superview?.subviews.compactMap({ $0 as? UIButton }) {
            for button in buttons {
                button.backgroundColor = UIColor(red: 255/255, green: 250/255, blue: 242/255, alpha: 1.0) // 초기 배경색 설정
                button.setTitleColor(UIColor(red: 119/255, green: 78/255, blue: 61/255, alpha: 1), for: .normal) // 초기 텍스트 색상 설정
            }
        }

        // 선택된 버튼의 스타일을 변경합니다.
        sender.backgroundColor = UIColor(red: 0.5059, green: 0.7176, blue: 0.5294, alpha: 1.0) // 버튼 눌렀을 때의 색상 변경
        sender.setTitleColor(.white, for: .normal)
        
        // 섹션 제목에 따라 적절한 변수에 값을 저장합니다.
                let title = (sender.superview?.subviews.first as? UILabel)?.text
                let value = sender.title(for: .normal) ?? ""
                
                switch title {
                case "성별":
                    selectedGender = value
                case "연령대":
                    selectedAgeGroup = value
                case "발화스타일":
                    selectedSpeakingStyle = value
                default:
                    break
                }
        
    
    }

    // "변경 완료" 버튼을 눌렀을 때의 동작
    @objc private func completeButtonTapped() {
        
        User.instance.change_haru_setting(old: selectedAgeGroup, style: selectedSpeakingStyle, gender: selectedGender){
            
            //onsuccess
            User.instance.get_profile{
                // Storyboard와 ViewController의 Identifier 확인 필요
                let mystoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                let HaruSettingViewController = mystoryboard.instantiateViewController(withIdentifier: "MypageViewController")
                
                
                // 모달 전환 스타일 설정
                HaruSettingViewController.modalTransitionStyle = .crossDissolve
                HaruSettingViewController.modalPresentationStyle = .overFullScreen
                
                // 모달 방식으로 뷰 컨트롤러를 표시
                self.present(HaruSettingViewController, animated: true, completion: nil)
            } onfailure: {}
        } onfailure:
        {
            print("HaruSettingViewController(change haru setting failed): Not implemented")
        }
    }

}
