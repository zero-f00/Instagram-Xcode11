//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by Yuto Masamura on 2020/03/29.
//  Copyright © 2020 yuto.masamura. All rights reserved.
//

import UIKit
import FirebaseUI

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // PostDataの内容をセルに表示する
    func setPostData(_ postData: PostData) {
        
        // 画像の表示
        // sd_imageIndicatorプロパティは、Cloud Storageから画像をダウンロードしている間、ダウンロード中であることを示すインジケーターを表示する指定
        // 今回の場合は、グレーのくるくる回るアイコンを指定している
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        // sd_setImage(with:)メソッドの引数にCloud Storageの画像保存場所を指定するだけで自動的に指定場所から画像をダウンロードしてUIImageViewに表示してくれる
        // 一度ダウンロードした画像はローカルストレージにキャッシュされるので2回目以降の表示はキャッシュを使用して素早く表示される
        postImageView.sd_setImage(with: imageRef)
        
        // キャプションの表示
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"
        
        // 日付の表示
        self.dateLabel.text = ""
        if let date = postData.date {
            // Dateクラスに入っている日時情報を DateFormatterで文字列に変換する必要があるため、
            let formatter = DateFormatter()
            // dateFormatプロパティに "yyyy-MM-dd HH:mm"と指定すると、Dateクラスに格納されている日時情報が文字列に変換される
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateStrig = formatter.string(from: date)
            self.dateLabel.text = dateStrig
        }
        
        // いいね数の表示
        // postData.likesには、いいねを押した人のuidの一覧が配列で格納されているため、countプロパティで取得した配列数が、いいねを押した人の人数になる
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        // いいねボタンの表示
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
    }
    
}
