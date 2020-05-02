//
//  HomeViewController.swift
//  Instagram
//
//  Created by Yuto Masamura on 2020/03/26.
//  Copyright © 2020 yuto.masamura. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    
    // Firestoreのデータ更新の監視を行うためのFirestoreのリスナー(firestoreのデータの変更を検知して、実行するためのリスナー)
    // リスナーとは、なんらかの動作がありイベントが発生した際に、自動的に実行されるように設定されたサブルーチンや関数、メソッドなど
    // (何らかの条件を元に、実行されるような機能のこと)
    var listener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // カスタムセルを登録する
        // カスタムセルを登録するには、UINib(nibName:bundle)を使ってxibファイルを読み込み、それをregister(_:forCellReuseIdentifier:)メソッドで登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")

        // Do any additional setup after loading the view.
    }
    
    
    // viewWillAppear(_:)はホーム画面を再表示するたびに何度も呼ばれるため、既にリスナーを登録している場合は、リスナー登録を追加しないよにする
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            // ログイン済み
            // ログイン済みの場合はデータの読み込み(監視)を開始
            if listener == nil {
                // listener未登録なら、登録してスナップショットを受信する
                // データを読み込むために、データベースの参照場所と取得順序をしていしたクエリを作成する
                // Firestoreの postsフォルダに格納されているドキュメントを投稿日時の新しい順に取得できる
                let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
                // postRefで取得できるドキュメントを addSnapshotListenerメソッドで監視
                // addSnapshotListenerメソッドに指定したクロージャは、 ドキュメントが追加されたり更新されたりするたびに何度も呼び出される
                // クロージャの引数のquerySnapshotに最新のデータが入っている
                listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    }
                    
                    // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                    // documentsプロパティにドキュメント(addSnapshotListenerメソッドで取得したQueryDocumentSnapshot)の一覧が配列の形で入っている
                    // mapメソッドは配列の要素を変換して新しい配列を作成するメソッドで、mapメソッドのクロージャの引数(document)で変換元の配列要素を受け取り、変換した要素をクロージャの戻り値(return postData)で返却することで、配列を変換できる
                    self.postArray = querySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        // ドキュメントをPostDataに変換して、postArrayの配列に格納する
                        let postData = PostData(document: document)
                        // 変換した要素をクロージャの戻り値(return postData)で返却する
                        return postData
                    }
                    
                    // TableViewの表示を更新する
                    self.tableView.reloadData()
                }
            }
        } else {
            // 未ログイン(またはログアウト済み)
            // ログイン未(またはログアウト済み)の場合は、データの読み込み(監視)を停止
            if listener != nil {
                // listener登録済みなら削除してpostArrayをクリアする(表示データをクリア)
                listener.remove()
                listener = nil
                postArray = []
                tableView.reloadData()
            }
        }
    }
    
    // postArrayの配列の要素数を返すデリゲートメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    // dequeueReusableCell(withIdentifier:for:)メソッドを使ってセルを取得し、setPostDataメソッドを呼び出してindexPathに対応するPostDataをセルに表示するようにする
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        //setPostDataメソッドを呼び出してindexPathに対応するPostDataをセルに表示
        cell.setPostData(postArray[indexPath.row])
        
        // セル内のボタンのアクションをソースコードで設定する
        // addTargetの第一引数に selfを設定することで、自分自身(HomeViewController)を呼び出し対象とし、第二引数(action:)の #selectorで指定したメソッドが呼び出すメソッドになる
        cell.likeButton.addTarget(self, action: #selector(handleButton(_:forEvent:)), for: .touchUpInside)
        
        cell.commentButton.addTarget(self, action: #selector(handleCommentButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    // selector指定で呼び出されるメソッドは、先頭に @objcを付与してメソッドを宣言する
    @objc func handleButton(_ sender:UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // 最初にタップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        // 第二引数に指定されたUIEvent型の event引数から UITouch型のタッチ情報を取り出し、タッチした座標(TableView内の座標)を割り出す
        let point = touch!.location(in: self.tableView)
        // タッチした座標がtableView内のどのindexPath位置になるのかを取得
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // Firestoreに格納されているlikesの配列データを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためのmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    
    @objc func handleCommentButton(_ sender:UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: コメントボタンがタップされました。遷移する。")
            
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
            
        let postData = postArray[indexPath!.row]
        
        let commentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Comment") as! CommentViewController
        commentViewController.postData = postData
        
        self.present(commentViewController, animated: false, completion: nil)
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
