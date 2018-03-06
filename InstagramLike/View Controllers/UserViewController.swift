//
//  UserViewController.swift
//  InstagramLike
//
//  Created by MacBookPro on 2018. 3. 6..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//
import Firebase
import UIKit
//테이블뷰의 메소드를 사용하기위해서 delegate 클래스를 상속해준다.
class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    var user = [User]()
    
    //스토리 보드로 만든 테이블 뷰 객체
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableview.delegate = self 스토리 보드에서 해줬음
        //self.tableview.dataSource = self
        
        retrieveUser()
    }


            /*let users = snapshot.value as! [String:AnyObject]
            ["moXNamlojlNmJ69UOgnYtpmhuXz2": {
                "full name" = enjoy;
                uid = moXNamlojlNmJ69UOgnYtpmhuXz2;
                urlToImage = "https://firebasestorage.googleapis.com/v0/b/instagramlikesystem.appspot.com/o/users%2FmoXNamlojlNmJ69UOgnYtpmhuXz2.jpg?alt=media&token=f51bf7d1-474a-49dd-a131-ebff449620d8";
                },
             
             "CSVaSvCLydTPfvjMnkGHbq8JoKj1": {
                "full name" = test2;
                uid = CSVaSvCLydTPfvjMnkGHbq8JoKj1;
                urlToImage = "https://firebasestorage.googleapis.com/v0/b/instagramlikesystem.appspot.com/o/users%2FCSVaSvCLydTPfvjMnkGHbq8JoKj1.jpg?alt=media&token=55f8bda3-af0d-43f3-9603-8d2c3836b399";
                },
             
             "N34eS8bicgOzRxxacJzmc0uyNFI3": {
                "full name" = kangyoung;
                uid = N34eS8bicgOzRxxacJzmc0uyNFI3;
                urlToImage = "https://firebasestorage.googleapis.com/v0/b/instagramlikesystem.appspot.com/o/users%2FN34eS8bicgOzRxxacJzmc0uyNFI3.jpg?alt=media&token=ab5529f0-92fb-46d3-aa18-0bd96d5d36cb";
                }]
*/
    //사용자 조회 함수
    func retrieveUser(){
        let ref = Database.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value) { (snapshot) in
            let users = snapshot.value as! [String:AnyObject]
            let usersKey = snapshot.key // 키는 "users"
            self.user.removeAll()
            
            //여기서 value는 full name = kangyoung ~~~ 이하 key:value
            for(_,value) in users{
                if let uid = value["uid"] as? String{
                    //나 말고 다른 유저 보이기
                    if uid != Auth.auth().currentUser!.uid{
                        let userToShow = User()
                        //nil 값 확인
                        if let fullName = value["full name"] as? String, let imagePath = value["urlToImage"] as? String{
                            userToShow.fullName = fullName
                            userToShow.imagePath = imagePath
                            userToShow.userID = uid
                            //배열에 넣기
                            self.user.append(userToShow)
                        }
                    }
                }
            }
            self.tableview.reloadData()
        }
        ref.removeAllObservers()
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //테이블 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.count
    }
    
    //테이블 cell 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        //배열에 들어 있는 값 cell에 할당~
        cell.userID = user[indexPath.row].userID
        cell.nameLabel.text = user[indexPath.row].fullName
        cell.userImage.downloadImage(from: user[indexPath.row].imagePath)
        
        //follwing 체크하는 함수 호출
        checkFollowing(indexPath: indexPath)
        return cell
    }
    
    //유저 목록을 클릭했을 때 팔로잉 항목에 추가 or 삭제
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let uid = Auth.auth().currentUser!.uid //내꺼 아이디
        let ref = Database.database().reference()
        let key = ref.child("users").childByAutoId().key //랜덤키
        print("1.아마 랜덤 키 \(key)")
        
        var isFollower = false
        //내가 팔로잉하고 있는 사람들의 uid 값을 가져와서 이미 follwing에 존재하면 삭제
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            
            if let following = snapshot.value as? [String:AnyObject]{
                print("follwing은 \(following)")
                for(ke,value) in following{
                    
                    print("follwing 을 파해쳐보자 ke : \(ke) value: \(value)")
                    
                    //내가 클릭한 유저가 id가 following 폴더에 있으면
                    if value as! String == self.user[indexPath.row].userID {
                        isFollower = true
                        //있으면 내가 follwing 하는 사람에서 해당 key 값 삭제
                        ref.child("users").child(uid).child("following/\(ke)").removeValue()
                        //있으면 내가 클릭한 사람의 follwers 폴더에서 해당 key 값 삭제
                        ref.child("users").child(self.user[indexPath.row].userID).child("follower/\(ke)").removeValue()
                        //테이블 셀에서 체크 해제
                        self.tableview.cellForRow(at: indexPath)?.accessoryType = .none
                    }
                }
            }
            
            //팔로우잉 하기, 내가 팔로우잉 하는 사람의 팔로워 폴더에 나의 uid 추가
            if (!isFollower) {
                //follwing 폴더에 없으면 following 폴더에 랜덤key : 내가 클릭한 사람의 uid 추가
                let following = ["following/\(key)" : self.user[indexPath.row].userID]
                
                //follwer 폴더에 랜덤key: 나의 id 추가
                let follower = ["follower/\(key)" : uid]
                //isFollower = false
                ref.child("users").child(uid).updateChildValues(following)
                ref.child("users").child(self.user[indexPath.row].userID).updateChildValues(follower)
                
                // 테이블 셀에 체크 표시
                self.tableview.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        })
        
        ref.removeAllObservers()
    }
    
    
    
    //내가 팔로잉 하고 있는 사람 조회
    func checkFollowing(indexPath: IndexPath){
        let uid = Auth.auth().currentUser!.uid //내꺼 아이디
        let ref = Database.database().reference()
        //내가 following 하고 있는 user id를 가지고 온다.
        ref.child("users").child(uid).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with: {snapshot in
            
            
            if let following = snapshot.value as? [String: AnyObject]{
                for(_ , value) in following {
                    //내가 follwing 하고 있는 userid와 talbleview에 담겨 있는 userID가 일치 한다면 즉, 내가 follwing 하는 유저라면
                    if value as! String == self.user[indexPath.row].userID{
                        //체크해준다.
                        self.tableview.cellForRow(at: indexPath)?.accessoryType = .checkmark
                    }
                }
            }
        })
        ref.removeAllObservers()
    }
    
    
    
    //로그아웃
    @IBAction func logOutPressed(_ sender: Any) {
    }
}





//이미지뷰 확장
extension UIImageView {
    func downloadImage(from imgURL: String!){
        let url = URLRequest(url: URL(string: imgURL)!)
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            //에러가 있으면
            if error != nil{
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data:data!)
            }
        }
        task.resume()
    }
}



