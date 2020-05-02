//
//  CommentViewController.swift
//  Instagram
//
//  Created by Yuto Masamura on 2020/04/28.
//  Copyright © 2020 yuto.masamura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CommentViewController: UIViewController {
    
    @IBOutlet weak var TextField: UITextField!
    
    var postData: PostData!
    
    @IBAction func handlePostButton(_ sender: Any) {
        
        let commentTextField = TextField.text!
        
        // commentsを更新する
        if let myid = Auth.auth().currentUser?.displayName {
            
            if commentTextField.isEmpty {
                SVProgressHUD.showError(withStatus: "コメントを入力してください。")
            } else {
                
                // 更新データを作成する
                var updateValueComment: FieldValue
                updateValueComment = FieldValue.arrayUnion([myid + "：" + commentTextField])
                
                // commentsに更新データを書き込む
                // commentTextに更新データを書き込む
                let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
                postRef.updateData(["commentsText": updateValueComment])
                
                SVProgressHUD.showSuccess(withStatus: "投稿しました")
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func hundleCancelButton(_ sender: Any) {
        print("DEBUG_PRINT: キャンセルしました。")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
