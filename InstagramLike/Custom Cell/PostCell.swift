//
//  PostCell.swift
//  InstagramLike
//
//  Created by MacBookPro on 2018. 3. 7..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit
import Firebase
class PostCell: UICollectionViewCell {
    
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var likeBtn: UIButton!
    
    @IBOutlet weak var unlikeBtn: UIButton!
    
    var postID: String?
    
    
    
    //좋아요 버튼이 눌렀을 때
    @IBAction func likePressed(_ sender: Any) {
        self.likeBtn.isEnabled = false
        //위치
        let ref = Database.database().reference()
        //랜덤 키
        let keyToPost = ref.child("posts").childByAutoId().key
        
        //포스트-> 포스트 id 에서 데이터 가져오기
        ref.child("posts").child(self.postID!).observeSingleEvent(of: .value) { (snapshot) in
            //데이터가 존재하면
            if let posts = snapshot.value as? [String:AnyObject]{
                
                print("좋아요 posts: \(posts)")
                
                //peopleWhoLike 폴더에 타입이 key: value 인 데이터 넣기
                let updateLikes: [String:Any] = ["peopleWhoLike/\(keyToPost)": Auth.auth().currentUser?.uid as Any]
                
                print("updateLikes \(updateLikes)")
                
                //포스트 -> 포스트 id에 업데이트(클릭한 사람의 pk 값 넣어주기)
                ref.child("posts").child(self.postID!).updateChildValues(updateLikes, withCompletionBlock: { (error, reff) in
                    //업데이트 성공하면
                    if error == nil{
                        //포스트-> 포스트ID에서 데이터 가져오기
                        ref.child("posts").child(self.postID!).observeSingleEvent(of: .value, with: { (snap) in
                            //데이터가 존재하면
                            if let properties = snap.value as? [String:AnyObject]{
                                //peopleWhoLike 폴더에 있는 데이터들 담기
                                if let likes = properties["peopleWhoLike"] as? [String:AnyObject]{
                                    //배열 개수 파악
                                    let count = likes.count
                                    print("좋아요 개수 몇개 \(count)")
                                    //할당해주기
                                    self.likeLabel.text = "\(count) Likes"
                                    //최종개수 업데이트
                                    let update = ["likes" : count]
                                    ref.child("posts").child(self.postID!).updateChildValues(update)
                                    
                                    self.likeBtn.isHidden = true
                                    self.unlikeBtn.isHidden = false
                                    self.likeBtn.isEnabled = true
                                    
                                }
                            }
                        })
                    }
                })
            }
        }
        ref.removeAllObservers()
    }
    
    
    
    
    //싫어요 버튼 눌렀을 때
    @IBAction func unlikePressed(_ sender: Any) {
        self.unlikeBtn.isEnabled = false
        //위치
        let ref = Database.database().reference()
        //포스트-> 포스트id
        ref.child("posts").child(self.postID!).observeSingleEvent(of: .value) { (snapshot) in
            // 포스트 폴더에 데이터 가져오기
            if let properties = snapshot.value as? [String: AnyObject]{
                //포스트 -> peopleWhoLike
                if let peopleWhoLike = properties["peopleWhoLike"] as? [String:AnyObject]{
                    //키, 좋아요 누른 유저 id
                    for(id, person) in peopleWhoLike{
                        // 좋아요 누른 사람아이디 == 지금의 내 아이디
                        if person as? String == Auth.auth().currentUser?.uid{
                            //포스트 폴더 -> postId -> peopleWhoLike -> id 삭제
                            ref.child("posts").child(self.postID!).child("peopleWhoLike").child(id).removeValue(completionBlock: { (error, rer) in
                                //에러가 안나면
                                if error == nil{
                                    //포스트 폴더에서 데이터 가져오기
                                    ref.child("posts").child(self.postID!).observeSingleEvent(of: .value, with: { (snapshot) in
                                        //포스트 데이터 가져오기
                                        if let prop = snapshot.value as? [String:AnyObject]{
                                            //포스트 폴더에서 peopleWhoLike 키에 담긴 {key:value} 가져오기
                                            if let likes = prop["peopleWhoLike"] as? [String:AnyObject]{
                                                //개수 파악
                                                let count = likes.count
                                                //표시해주기
                                                self.likeLabel.text = "\(count) Likes"
                                                //포스트 -> 포스트 id -> likes 키 값만 바꾸기
                                                ref.child("posts").child(self.postID!).updateChildValues(["likes": count])
                                                
                                            }else{
                                                self.likeLabel.text = "0 Likes"
                                                ref.child("posts").child(self.postID!).updateChildValues(["likes" : 0])
                                            }
                                        }
                                    })
                                }
                            })
                            self.likeBtn.isHidden = false
                            self.unlikeBtn.isHidden = true
                            self.unlikeBtn.isEnabled = true
                            break
                        }
                    }
                }
            }
        }
         ref.removeAllObservers()
    }
}
