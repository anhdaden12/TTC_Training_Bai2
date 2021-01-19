//
//  AlbumTableViewcell.swift
//  GCD_Bai_2
//
//  Created by Apple on 1/19/21.
//  Copyright © 2021 NgocNB. All rights reserved.
//

import UIKit

class AlbumTableViewcell: UITableViewCell {

    
    @IBOutlet weak var imageViewAlbum: UIImageView!
    @IBOutlet weak var albumIDLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var thumnaiLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func bindCell(obj: AlbumModel) {
        if let aData = obj.imageData {
            self.imageViewAlbum.image = UIImage(data: aData)
        } else {
            self.imageViewAlbum.image = nil
        }
        self.albumIDLabel.text = "\(obj.albumId)"
        self.idLabel.text = "\(obj.id)"
        self.titleLabel.text = obj.title
        self.urlLabel.text = obj.url
        self.thumnaiLabel.text = obj.thumbnailUrl
    }
    
}
