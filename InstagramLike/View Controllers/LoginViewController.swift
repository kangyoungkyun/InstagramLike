//
//  LoginViewController.swift
//  InstagramLike
//
//  Created by MacBookPro on 2018. 3. 5..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit
import Firebase
class LoginViewController: UIViewController {

    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()

    }

    //로그인 버튼 눌렀을때
    @IBAction func loginPressed(_ sender: Any) {
        //nil 값 확인 후 값이 존재하면
        guard emailField.text != "" , pwField.text != "" else{return}
        //파이어베이스 로그인 함수
        Auth.auth().signIn(withEmail: emailField.text!, password: pwField.text!) { (user, error) in
            //에러 처리
            if let error = error{
                print(error.localizedDescription)
            }
            // 유저가 존재하면 -> 다른 페이지로 넘겨주기
            if let _ = user{
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC")
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}
extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
