//
//  FeedViewController.swift
//  InstagramLike
//
//  Created by MacBookPro on 2018. 3. 7..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit
import Firebase
//스토리보드에서 collectionview를 viewcontroller에. datasource, delegate 해주고 아래 클래스 상속받는다.
//그리고 필수 메소드를 구현해준다.
class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //내가 following 하고 있는 유저들 담을 배열
    var following = [String]()
    //내가 following 하고 있는 유저들의 post 데이타 담을 배열
    var posts = [Post]()
    
    @IBOutlet weak var collectionview: UICollectionView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("feedViewController viewdidload")
        //post 가져오기
        fetchPosts()
    }
    
    //내가 팔로우 하고 있는 유저들의 포스트 가져오기
    func fetchPosts(){
        print("fetchPosts 진입")
        let ref = Database.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            
            //print("users 스넵샵정보: \(snapshot)") // user 아래에 모든 users를 포함한 key: {key:value} 값을 다 가져온다.
            
            let users = snapshot.value as? [String : AnyObject] //users를 포함하지 않는 key: {key:value}
            
            //print("snapshot.value 정보: \(users)")
            
            //여기서 value 타입은 {key: val}
            for(_ , value) in users!{
                //users의 value 값중에 uid가 있으면
                if let uid = value["uid"] as? String {
                    //유저들의 uid 중 내가 접속한 uid와 같은게 있다면 즉,  나와 같다면
                    if uid == Auth.auth().currentUser?.uid{
                        //내가 팔로잉 하는 사람들의 {key: value} 데이터 가져온다.
                        if let followingUsers = value["following"] as? [String:String]{
                            //for문으로 value 만 빼낸다.
                            for(_,user) in followingUsers{
                                //배열 값에 넣어준다.
                                self.following.append(user)
                            }
                        }
                        //내 post도 봐야 하니깐 내 id도 넣어준다.
                        self.following.append((Auth.auth().currentUser?.uid)!)
                        
                        //포스트가 저장되어 있는 위치로 가서
                        ref.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
                            //print("posts snap: \(snap)")
                            let postsSnapt = snap.value as? [String: AnyObject] //포스트의 전체 데이터를 가져온다.
                            //print("postsSnapt snap.value: \(postsSnapt)")
                            
                            for(_, post) in postsSnapt!{
                                
                                print("post 나와랏: \(post)")
                                print("post[userID] 나와랏: \(post["userId"])")
                                //post에서 userId에 값이 있다면
                                if let userID = post["userId"] as? String{
                                    //following 배열에 저장된 uid들을 가져온다.
                                    for each in self.following {
                                        print("each 나와랏: \(each)")
                                        //같은 값이 있다면
                                        if each == userID{
                                            print("each == userID 나와랏: \(userID)")
                                            //데이터를 담을 객체 생성
                                            let posst = Post()
                                            //nil 확인
                                            if let author = post["author"] as? String, let likes = post["likes"] as? Int, let pathToImage = post["pathToImage"] as? String, let postID = post["postID"] as? String {
                                                //할당해 준다.
                                                posst.author = author
                                                posst.likes = likes
                                                posst.userID = userID
                                                posst.postID = postID
                                                posst.pathToImage = pathToImage
                                                
                                                //좋아요 버튼 누른 사람 담아주기
                                                if let people = post["peopleWhoLike"] as? [String:AnyObject]{
                                                    for(_,person) in people{
                                                        posst.peopleWhoLike.append(person as! String)
                                                    }
                                                }
                                                
                                                //객체를 배열에 하나씩 담아준다.
                                                self.posts.append(posst)
                                                print("posts 하나 넣었따 개수는? \(self.posts.count)")
                                            }
                                        }
                                    }
                                   
                                     //DispatchQueue.main.async(execute: {
                                       self.collectionview.reloadData()
                                    //})
                                }
                            }
                        })
                    }
                }
            }
           // DispatchQueue.main.async(execute: {
            //   self.collectionview.reloadData()
            //})
        }
        ref.removeAllObservers()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    //컬랙션 뷰 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("컬렉션 뷰 개수 : \(posts.count)")
        return posts.count
    }
    
    //셀 구성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //self.collectionview.reloadData()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        // 셀만들어 주기
        cell.postImage.downloadImage(from: self.posts[indexPath.row].pathToImage)
        cell.authorLabel.text = self.posts[indexPath.row].author
        cell.likeLabel.text = "\(self.posts[indexPath.row].likes!) Likes"
        
        print("좋아요개수 좋아요 개수 cell for row at : \(String(describing: cell.likeLabel.text))")
        
        //cell에 포스트 아이디 넣어주기
        cell.postID = self.posts[indexPath.row].postID
        
        //Post 데이터 모델에서 peopleWhoLike 변수 배열에서 user 가져와서 있으면 like 버튼 hidden
        for person in self.posts[indexPath.row].peopleWhoLike{
            if person == Auth.auth().currentUser?.uid{
                cell.likeBtn.isHidden = true
                cell.unlikeBtn.isHidden = false
                break
            }
        }
        
        return cell
        
    }
    
}
