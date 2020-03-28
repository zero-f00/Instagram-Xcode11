//
//  LoginViewController.swift
//  Instagram
//
//  Created by Yuto Masamura on 2020/03/26.
//  Copyright © 2020 yuto.masamura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    // ログインボタンをタップした時に呼ばれるメソッド
    @IBAction func handleLoginButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            // アドレスとパスワードのいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty {
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    return
                }
                print("DEBUG_PRINT: ログインに成功しました。")
                
                // HUDを消す
                SVProgressHUD.dismiss()
                
                // 画面を閉じてタブ画面に戻る
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // アカウント作成ボタンをタップした時に呼ばれるメソッド
    @IBAction func handleCreateAccountButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text, let displayName = displayNameTextField.text {
                
        // アドレスとパスワードと表示名のいずれかでも入力されていないときは何もしない
        if address.isEmpty || password.isEmpty || displayName.isEmpty {
            print("DEBUG_PRINT: 何かが空文字です。")
            return
        }
                    
        // HUDで処理中を表示
        SVProgressHUD.show()
                
        // アドレスとパスワードでユーザー作成。ユーザ作成すると、自動的にログインする
        // createUserメソッドのクロージャの場合、第一引数(authResult)に認証結果情報が渡され、第二引数(error)には、エラー発生時のエラー情報が渡される
        Auth.auth().createUser(withEmail: address, password: password) { authResult, error in
            if let error = error {
            // クロージャ内の処理
            // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                print("DEBUG_PRINT: " + error.localizedDescription)
                return
            }
            
            print("DEBUG_PRINT: ユーザー作成に成功しました。")
                    
            // 表示名を設定する
            // User は displayName プロパティを持っているため、Firebaseにユーザープロフィールとして保存することができる
            let user = Auth.auth().currentUser
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { error in
                    if let error = error {
                        // プロフィールの更新でエラーが発生
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                        
                    }
                    
                    print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                    
                    // HUDを消す
                    SVProgressHUD.dismiss()
                                    
                    // 画面を閉じてタブ画面に戻る
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
            }
        }
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
