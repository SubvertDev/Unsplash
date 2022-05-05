//
//  PhotoCell.swift
//  Unsplash
//
//  Created by  Subvert on 4/29/22.
//

import UIKit
import Nuke

final class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func setImage(with photo: Unsplash) {
        if let imageUrl = URL(string: photo.urls.thumb) {
            let placeholderImage = UIImage(blurHash: photo.blurHash, size: K.BlurSize.small)
            let options = ImageLoadingOptions(placeholder: placeholderImage,
                                              transition: .fadeIn(duration: 0.25,
                                                                  options: .transitionCrossDissolve))
            Nuke.loadImage(with: imageUrl, options: options, into: imageView)
        }
    }
}
