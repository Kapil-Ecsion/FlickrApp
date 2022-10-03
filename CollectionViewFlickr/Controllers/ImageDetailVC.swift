//
//  ImageDetailVC.swift
//  CollectionViewFlickr
//
//  Created by phonestop on 9/24/22.
//

import UIKit

class ImageDetailVC: UIViewController {

    @IBOutlet weak var bigImageView: UIImageView!
    
    var farm:Int = 0
    var imageID = ""
    var server = ""
    var secret = ""
    override func viewDidLoad() {
        super.viewDidLoad()
//https://farm66.staticflickr.com/65535/52365927874_5ae16c7b1a_m.jpg
      configure(with: "https://farm\(farm).staticflickr.com/\(server)/\(imageID)_\(secret).jpg")
    }
    
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
                self?.bigImageView.image = image
            }
        }.resume()
       
    }


}
