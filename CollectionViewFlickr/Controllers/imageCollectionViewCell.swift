//
//  imageCollectionViewCell.swift
//  CollectionViewFlickr
//
//  Created by phonestop on 9/24/22.
//

import UIKit

class imageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageDisplayView: UIImageView!
    
    
    func configure(with urlString: String){
        guard let url = URL(string: urlString) else{
            return
        }
        //using networkTask to download the byte image
        URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
            guard let data = data, error == nil else{
                return
            }
            //we'll be loading the image on the main thread as it's part of the UI
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self?.imageDisplayView.image = image
            }
        }.resume()
       
    }
}
