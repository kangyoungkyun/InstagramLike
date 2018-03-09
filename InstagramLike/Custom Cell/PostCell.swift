//
//  PostCell.swift
//  InstagramLike
//
//  Created by MacBookPro on 2018. 3. 7..
//  Copyright © 2018년 MacBookPro. All rights reserved.
// 좋아요를 눌렀을때 PostCell에서는 정확한 개수가 반영이된다

//cell for row at -> postcell에 좋아요 버튼 클릭함수 안에 delegate구현 -> 다시 컨트롤러에 extension POstdelegate 안에 actoin 함수

//*델리게이트 작동 순서
//post cell에서 delegate?.likeAction 작동
//FeedViewController - likAction 함수

//위임을 받으려면 controller 부분에서 이 메서드를 반드시 구현
protocol PostCellDelegate: class {
    func likeActoin(cell:PostCell)
    func unlikeAction(cell:PostCell)
}

import UIKit
import Firebase
class PostCell: UICollectionViewCell {
    //델리게이트 변수
    weak var delegate: PostCellDelegate?
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var likeBtn: UIButton!
    
    @IBOutlet weak var unlikeBtn: UIButton!
    
    var postID: String?
    

    //좋아요 버튼이 눌렀을 때
    @IBAction func likePressed(_ sender: Any) {
        
        print("post cell에서 delegate?.likeAction 작동")
        //델리게이트 이용 - cell에 있는 likeAction 함수를 눌렀는데 controller에 있는 likeActoin 함수가 작동한다 이유는  delegate를 통해서 위임을 했기때문!
        delegate?.likeActoin(cell: self)
    }
    
    
    //싫어요 버튼 눌렀을 때
    @IBAction func unlikePressed(_ sender: Any) {
         print("post cell에서 delegate?.unlikeAction 작동")
        //델리게이트 이용
        delegate?.unlikeAction(cell: self)
    }
}
