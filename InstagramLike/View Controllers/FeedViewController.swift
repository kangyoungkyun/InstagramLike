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
                                
                                //print("post 나와랏: \(post)")
                                //print("post[userID] 나와랏: \(post["userId"])")
                                //post에서 userId에 값이 있다면
                                if let userID = post["userId"] as? String{
                                    //following 배열에 저장된 uid들을 가져온다.
                                    for each in self.following {
                                        //print("each 나와랏: \(each)")
                                        //같은 값이 있다면
                                        if each == userID{
                                            //print("each == userID 나와랏: \(userID)")
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
                                                
                                                //좋아요 버튼 누른 사람 배열에 담아주기
                                                print("fetchPosts- 좋아요 버튼 누른 사람 배열에 담아주기")
                                                if let people = post["peopleWhoLike"] as? [String:AnyObject]{
                                                    for(_,person) in people{
                                                        print("fetchPosts- 좋아요 누른 사람의 아이디는? \(person)")
                                                         print("fetchPosts- 좋아요 누른 사람의 개수는? \(posst.peopleWhoLike.count)")
                                                        posst.peopleWhoLike.append(person as! String)
                                                    }
                                                }
                                                
                                                //객체를 배열에 하나씩 담아준다.
                                                self.posts.append(posst)
                                                print("fetchPosts -posts 하나 넣었다 개수는? \(self.posts.count)")
                                            }
                                        }
                                    }
                                   
                                     DispatchQueue.main.async(execute: {
                                       self.collectionview.reloadData()
                                    })
                                }
                            }
                        })
                    }
                }
            }
        }
        ref.removeAllObservers()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    //컬랙션 뷰 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("컬렉션 뷰 개수 : \(posts.count)")
        print("컬렉션 뷰 section : \(section)")
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
        //print(" cell for row at 좋아요개수 : \(self.posts[indexPath.row].likes!)")
        
        //cell에 포스트 아이디 넣어주기
        cell.postID = self.posts[indexPath.row].postID
        
        //controller가 cell의 델리게이트가 되고 싶어한다. 그래서 PostCell에서 구현한 prototype 메서드를 구현해줘야 한다.!!
        cell.delegate = self
        
         print("cellForItemAt - cell.delegate = self")
        
         print("cellForItemAt- 좋아요 누른 사람의 배열 개수는? \(self.posts[indexPath.row].peopleWhoLike.count)")
        
        //Post 데이터 모델에서 peopleWhoLike 변수 배열에서 user 가져와서 있으면 like 버튼 hidden
        for person in self.posts[indexPath.row].peopleWhoLike{
            //print("cell for row at 좋아요 누른 사람: \(person)")
            if person == Auth.auth().currentUser?.uid{
                cell.likeBtn.isHidden = true
                cell.unlikeBtn.isHidden = false
                break
            }
        }
        
        return cell
        
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt \(indexPath.row) 번째 cell이 선택되었습니다")
    }
}


extension FeedViewController : PostCellDelegate{
    //좋아요 버튼 눌렀을 때
    func likeActoin(cell: PostCell) {
        print("FeedViewController - likAction 함수")
        
        //1. 파이어 베이스에서 좋아요 숫자 삽입
        cell.likeBtn.isEnabled = false
        //위치
        let ref = Database.database().reference()
        //랜덤 키
        let keyToPost = ref.child("posts").childByAutoId().key
        
        //포스트-> 포스트 id 에서 데이터 가져오기
        ref.child("posts").child(cell.postID!).observeSingleEvent(of: .value) { (snapshot) in
            //데이터가 존재하면
            if let posts = snapshot.value as? [String:AnyObject]{
                
                print("좋아요 posts: \(posts)")
                
                //peopleWhoLike 폴더에 타입이 key: value 인 데이터 넣기
                let updateLikes: [String:Any] = ["peopleWhoLike/\(keyToPost)": Auth.auth().currentUser?.uid as Any]
                
                print("updateLikes \(updateLikes)")
                
                //포스트 -> 포스트 id에 업데이트(클릭한 사람의 pk 값 넣어주기)
                ref.child("posts").child(cell.postID!).updateChildValues(updateLikes, withCompletionBlock: { (error, reff) in
                    //업데이트 성공하면
                    if error == nil{
                        //포스트-> 포스트ID에서 데이터 가져오기
                        ref.child("posts").child(cell.postID!).observeSingleEvent(of: .value, with: { (snap) in
                            //데이터가 존재하면
                            if let properties = snap.value as? [String:AnyObject]{
                                //peopleWhoLike 폴더에 있는 데이터들 담기
                                if let likes = properties["peopleWhoLike"] as? [String:AnyObject]{
                                    //배열 개수 파악
                                    let count = likes.count
                                    //print("좋아요 개수 몇개 \(count)")
                                    
                                    
                                    //버튼이 눌려진 cell의 index를 위치를 이용해서 구하는 방법!
                                    let point : CGPoint = cell.likeBtn.convert(CGPoint.zero, to:self.collectionview)
                                    let indexPath = self.collectionview!.indexPathForItem(at: point)
                                    
                                    let index = indexPath?.row as! Int
                                
                                    //print("과연4 \(indexPath?.row as! Int)")
                                    
                                    //좋아요 누른 해당 배열 인덱스에 접근해서 likes 변수를 바꿔준다. 그래야
                                    //collection view를 스크롤 해도 그대로 표시가 된다.!
                                    self.posts[index].likes = count
                                    
                                    //할당해주기
                                    cell.likeLabel.text = "\(count) Likes"
                                    //최종개수 업데이트
                                    let update = ["likes" : count]
                                    ref.child("posts").child(cell.postID!).updateChildValues(update)
                                    cell.likeBtn.isHidden = true
                                    cell.unlikeBtn.isHidden = false
                                    cell.likeBtn.isEnabled = true
                                    
                                }
                            }
                        })
                    }
                })
            }
        }
        ref.removeAllObservers()

        //2. 컬렉션뷰 수정
        //self.collectionview.reloadData()
        
    }
    
    
    //안좋아요 버튼 눌렀을 때
    func unlikeAction(cell: PostCell) {
        
        //버튼이 눌려진 cell의 index를 위치를 이용해서 구하는 방법!
        let point : CGPoint = cell.likeBtn.convert(CGPoint.zero, to:self.collectionview)
        let indexPath = self.collectionview!.indexPathForItem(at: point)
        let index = indexPath?.row as! Int
        
         print("FeedViewController - unlikeAction 함수")
        //1. 파이어 베이스에서 좋아요 숫자 삽입
        cell.unlikeBtn.isEnabled = false
        //위치
        let ref = Database.database().reference()
        //포스트-> 포스트id
        ref.child("posts").child(cell.postID!).observeSingleEvent(of: .value) { (snapshot) in
            // 포스트 폴더에 데이터 가져오기
            if let properties = snapshot.value as? [String: AnyObject]{
                //포스트 -> peopleWhoLike
                if let peopleWhoLike = properties["peopleWhoLike"] as? [String:AnyObject]{
                    //키, 좋아요 누른 유저 id
                    for(id, person) in peopleWhoLike{
                        // 좋아요 누른 사람아이디 == 지금의 내 아이디
                        if person as? String == Auth.auth().currentUser?.uid{
                            //포스트 폴더 -> postId -> peopleWhoLike -> id 삭제
                            ref.child("posts").child(cell.postID!).child("peopleWhoLike").child(id).removeValue(completionBlock: { (error, rer) in
                                //에러가 안나면
                                if error == nil{
                                    //포스트 폴더에서 데이터 가져오기
                                    ref.child("posts").child(cell.postID!).observeSingleEvent(of: .value, with: { (snapshot) in
                                        //포스트 데이터 가져오기
                                        if let prop = snapshot.value as? [String:AnyObject]{
                                            //포스트 폴더에서 peopleWhoLike 키에 담긴 {key:value} 가져오기
                                            if let likes = prop["peopleWhoLike"] as? [String:AnyObject]{
                                                //개수 파악
                                                let count = likes.count
                                                
          
                                                
                                                //좋아요 누른 해당 배열 인덱스에 접근해서 likes 변수를 바꿔준다. 그래야
                                                //collection view를 스크롤 해도 그대로 표시가 된다.!
                                                self.posts[index].likes = count
 
                                                
                                                //표시해주기
                                                cell.likeLabel.text = "\(count) Likes"
                                                //포스트 -> 포스트 id -> likes 키 값만 바꾸기
                                                ref.child("posts").child(cell.postID!).updateChildValues(["likes": count])
                                                
                                            }else{
                                                self.posts[index].likes = 0
                                                cell.likeLabel.text = "0 Likes"
                                                ref.child("posts").child(cell.postID!).updateChildValues(["likes" : 0])
                                            }
                                        }
                                    })
                                }
                            })
                            cell.likeBtn.isHidden = false
                            cell.unlikeBtn.isHidden = true
                            cell.unlikeBtn.isEnabled = true
                            break
                        }
                    }
                }
            }
        }
        ref.removeAllObservers()
        
        //2. 컬렉션뷰 수정
         //self.collectionview.reloadData()
    }
    
    
    
    
}


extension UICollectionView {
    
    var centerPoint : CGPoint {
        
        get {
            return CGPoint(x: self.center.x + self.contentOffset.x, y: self.center.y + self.contentOffset.y);
        }
    }
    
    var centerCellIndexPath: IndexPath? {
        
        if let centerIndexPath = self.indexPathForItem(at: self.centerPoint) {
            return centerIndexPath
        }
        return nil
    }
}
