//
//  Post.swift
//  InstagramLike
//
//  Created by MacBookPro on 2018. 3. 7..
//  Copyright © 2018년 MacBookPro. All rights reserved.
//

import UIKit

class Post: NSObject {

    var author: String!
    var likes: Int!
    var pathToImage: String!
    var userID: String!
    var postID: String!
    
    //누가 이 포스트를 좋아하는지 담기
    var peopleWhoLike: [String] = [String]()
}
