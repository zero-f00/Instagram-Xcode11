//
//  PostViewController.swift
//  Instagram
//
//  Created by Yuto Masamura on 2020/03/26.
//  Copyright © 2020 yuto.masamura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class PostViewController: UIViewController {
    
    var image: UIImage!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!

    // 投稿ボタンをタップした時に呼ばれるメソッド
    @IBAction func handlePostButton(_ sender: Any) {
        // 画像をファイルとしてアップロードするために、JPEG形式に変換する
        // 下記のメソッドで、imageに入っている画像(UIImage型)をJPEG形式の画像データ(Data型)に変換できる
        // compressionQualityで指定しているのは、JPEG形式に変換する時の圧縮率で、値が小さいほど圧縮率が高い（画像が荒い）
        let imageData = image.jpegData(compressionQuality: 0.75)
        
        
        // 画像と投稿データの保存場所を定義する
        // postRefは、Firestoreに保存する投稿データの保存場所を定義している
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        // imageRefは、Storageに保存する画像の保存場所を定義している
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
        
        // HUDで投稿処理中の表示を開始
        SVProgressHUD.show()
        
        // Storageに画像をアップロードする
        // metadataは、画像を保存する際のファイル形式を表す。
        let metadata = StorageMetadata()
        // 今回はJPEG画像ファイルを保存するので image/jpegをmetadataに指定
        metadata.contentType = "image/jpeg"
        // 画像のアップロードが完了すると呼び出してもらえるクロージャを最終引数に指定している
        imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
            if error != nil {
                // 画像のアップロード失敗
                print(error!)
                SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました。")
                
                // 投稿処理をキャンセルし、先頭画面に戻る
                // 下記のコードは一気に先頭画面に戻ることができ
                UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                return
            }
            
            // Storageに画像のアップロードができたら、FireStoreに投稿データ(投稿者名、キャプション、投稿日時)を保存する
            // 保存するデータを辞書の形にまとめて、setData(_:)メソッドを実行することで
            let name = Auth.auth().currentUser?.displayName
            let postDic = [
                "name": name!,
                "caption": self.textField!.text!,
                // 保存日時は FieldValue.serverTimestamp()
                "date": FieldValue.serverTimestamp(),
                ] as [String : Any]
            // Firestoreにデータを保存するには、setData(_:)メソッドを使用
            postRef.setData(postDic)
            
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            
            // 投稿処理が完了したので先頭画面に戻る
            UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // キャンセルボタンをタップした時に呼ばれるメソッド
    @IBAction func handleCancelButton(_ sender: Any) {
        // 加工画面に戻る
        // 先頭画面に戻るのではなく、加工画面に戻って追加編集できるようにすることを意図して実装
        self.dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 受け取った画像をImageViewに設定する
        imageView.image = image

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
