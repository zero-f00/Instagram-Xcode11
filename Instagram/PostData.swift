//
//  PostData.swift
//  Instagram
//
//  Created by Yuto Masamura on 2020/03/29.
//  Copyright © 2020 yuto.masamura. All rights reserved.
//

import UIKit
import Firebase

// NSObjectクラスを継承したクラス
class PostData: NSObject {
    
    // 投稿ID（保存する際に作られたユニークなID）
    var id: String
    
    // 投稿者名
    var name: String?
    
    // キャプション
    var caption: String?
    
    // 日付
    var date: Date?
    
    // いいねをした人のIDの配列
    var likes: [String] = []
    
    // 自分がいいねしたかどうかのフラグ
    // isLikedプロパティはQueryDocumentSnapshotクラスから取り出すのではなく、likesというキーで取り出したString型の配列の中にユーザ自身のIDが入っているかで値をtureかfalseのどちらかで設定
    var isLiked: Bool = false
    
    // コメントの内容
    var commentText: [String] = []
    
    // 上記のプロパティを初期化するメソッド
    init(document: QueryDocumentSnapshot) {
        // Firestoreからデータを取得すると、QueryDocumentSnapshotクラスのデータが渡されてくる
        // このクラスのdocumentIDプロパティがこのドキュメントのID（ユニークなIDとして生成された投稿ID）となる
        self.id = document.documentID
        
        // data()メソッドで辞書形式のデータを取り出すことができる
        let postDic = document.data()
        
        // 辞書形式になっているため、postDic["name"]のようにして取り出す
        self.name = postDic["name"] as? String
        
        self.caption = postDic["caption"] as? String
        
        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        
        // このキーは「いいね」したユーザのIDを保持する配列を保存する
        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }

        if let myid = Auth.auth().currentUser?.uid {
            // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                // myidがあれば、いいねを押していると認識する。
                self.isLiked = true
            }
        }
        
        // このキーはコメントの内容を保持する配列を保存する
        if let commentText = postDic["commentsText"] as? [String] {
            self.commentText = commentText
        }
    }
}
