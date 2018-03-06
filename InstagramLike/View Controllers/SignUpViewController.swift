//
//  SignUpViewController.swift
//  InstagramLike
//
//  Created by MacBookPro on 2018. 3. 5..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit
import Firebase
class SignUpViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var comPwField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    //사진 라이브러리 객체
    let picker = UIImagePickerController()
    //gs://instagramlikesystem.appspot.com
    let storage = Storage.storage()
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //firebase 데이터 베이스 초기화
        ref = Database.database().reference()
        picker.delegate = self
        
    }
    
    //사진 선택 버튼을 눌렀을 때
    @IBAction func selectImage(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    //사진 선택이 끝났을 때
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.imageView.image = image
            nextBtn.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //완료 버튼을 눌렀을 때
    @IBAction func nextPress(_ sender: Any) {
        // "" 값이 아니면 계속 실행
        guard nameField.text != "", emailField.text != "", password.text != "", comPwField.text != "" else {return}
        //사진이 저장될 경로
        let userRef = storage.reference().child("users")
        //비번이 맞을 때
        if password.text == comPwField.text {
            Auth.auth().createUser(withEmail: emailField.text!, password: password.text!) { (user, error) in
                
                //에러처리
                if let error = error {
                    print(error.localizedDescription)
                }
                //userr가 신규 생성이 되었으면 사진 넣기
                if let user = user{
                    
                    //인증부분에 user의 닉네임 넣어주기!
                    let ChangeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                    ChangeRequest.displayName = self.nameField.text!
                    ChangeRequest.commitChanges(completion: nil)
                    
                    //사진이 저장될 하위 경로
                    let imageRef = userRef.child("\(user.uid).jpg")
                    let data = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
                    
                    //URLSessoin연결
                    let uploadTask = imageRef.putData(data!, metadata: nil, completion: { (metadata, err) in
                        //에러 처리
                        if err != nil{
                            print(err!.localizedDescription)
                        }
                        //이미지 다운로드
                        imageRef.downloadURL(completion: { (url, err) in
                            if err != nil{
                                print(err!.localizedDescription)
                            }
                            //url이 존재하면
                            //json 객체 만들어서
                            if let url = url {
                                let userInfo: [String:Any] = ["uid" : user.uid,
                                                              "full name" : self.nameField.text!,
                                                              "urlToImage" : url.absoluteString]
                                //해당 경로에 삽입
                                self.ref.child("users").child(user.uid).setValue(userInfo)
                                
                                //다음에 띄울 스토리보드
                                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC")
                                //띄우기
                                self.present(vc, animated: true, completion: nil)
                            }
                        })
                    })
                    uploadTask.resume()
                }
            }
            //틀릴 때
        }else{
            print("비번이 틀렸습니다.")
        }
    }
}
