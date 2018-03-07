//
//  UploadViewController.swift
//  InstagramLike
//
//  Created by MacBookPro on 2018. 3. 7..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit
import Firebase
//이미지 피커 관련 클래스 상속
class UploadViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var previewImage: UIImageView!
    
    //이미지 피커
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        
    }
    
    //이미지 선택이 끝났을 때
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.previewImage.image = image
            //선택버튼 숨기고 포스트 버튼 보이기
            selectBtn.isHidden = true
            postBtn.isHidden = false
        }
        //종료
        self.dismiss(animated: true, completion: nil)
    }
    
    //사진 선택 버튼 클릭
    @IBAction func selectPressed(_ sender: Any) {
        //편집허용, 포토라이브러리 타입
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        //사진 라이브러리 호출
        self.present(picker,animated: true, completion: nil)
    }
    
    //포스트 버튼 클릭
    @IBAction func postPressed(_ sender: Any) {
        //엑티비티 시작
        AppDelegate.instance().showActivityIndicator()
        let uid = Auth.auth().currentUser?.uid // 내 pk
        let ref = Database.database().reference() //firebase 위치
        let storage = Storage.storage().reference() //내 파일 저장소 위치
        
        let key = ref.child("posts").childByAutoId().key //랜덤 key 추출
        
        let imageRef = storage.child("posts").child(uid!).child("\(key).jpg") //내 파일 저장소 ->posts -> uid -> 사진.jpg
    
        let data = UIImageJPEGRepresentation(self.previewImage.image!, 0.6)//이미지 퀄러티 조정
        
        //firebase 사진 업로드
        let uploadTask = imageRef.putData(data!, metadata: nil) { (metadata, error) in
            //에러처리
            if error != nil{
                print(error!.localizedDescription)
                //엑티비티 종료
                AppDelegate.instance().dissmissActivityIndicator()
                return
            }
            //저장후 사진이 저장된 위치 url을 다운로드 후 firebase 데이터 베이스에 추가
            imageRef.downloadURL { (url, error) in
                //url 언래핑
                if let url = url {
                    //데이터 저장 객체 생성
                    let feed = ["userId":uid,
                                "pathToImage":url.absoluteString,
                                "likes": 0,
                                "author": Auth.auth().currentUser!.displayName,
                                "postID":key] as [String:Any]
                    let postFeed = ["\(key)" : feed]
                    //firebase insert
                    ref.child("posts").updateChildValues(postFeed)
                    //엑티비티 종료
                    AppDelegate.instance().dissmissActivityIndicator()
                    //창 종료
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        }
        uploadTask.resume()
    }
    
    @IBAction func show(_ sender: Any) {
        //엑티비티 시작
        AppDelegate.instance().showActivityIndicator()
        print("스따뚜 엑티비티")
    }
    
    @IBAction func end(_ sender: Any) {
        //엑티비티 종료
        AppDelegate.instance().dissmissActivityIndicator()
        print("엔드 엑티비티")
    }
    
    
    
}
