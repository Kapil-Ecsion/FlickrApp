//
//  ViewController.swift
//  CollectionViewFlickr
//
//  Created by phonestop on 9/24/22.
//

import UIKit

class TimeLineVC: UIViewController {
    
    var thumbnail: UIImage?
    var largeImage: UIImage?
    var imageID: String = ""
    var farm: Int = 0
    var server: String = ""
    var secret: String = ""
    
    var searchImageText = ""
    
    @IBOutlet weak var imageGroupLabel: UILabel!
    
    @IBOutlet weak var searchImage: UISearchBar!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    
    
//    var baseImgURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=dfe31db996ea7d8e3f9995539b593972&format=json&nojsoncallback=1&safe_search=1&per_page=5&text=kittens&page="
    
    private var _photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        
        searchImage.delegate = self
        fetchImageList(imageText: FlickrAPI.imageText)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //To dismiss the searchBar keyboard
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func fetchImageList(imageText: String){
        //converting URL sting to URL object
        imageGroupLabel.text = imageText
        
        let defaultEndPoint = "/rest/?method=flickr.photos.search&api_key=\(FlickrAPI.apiKey)&format=json&nojsoncallback=1&safe_search=1&per_page=\(FlickrAPI.photosPerRequest)&text=\(imageText)&page=1"
        
        let constructedURL = "\(FlickrAPI.baseURL)\(defaultEndPoint)"
        
        print("Api:- ", constructedURL)
        
        guard let url = URL(string: constructedURL) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
            guard let data = data, error == nil else{
                return
            }
            print("Got  Data")
            
            do {
                
                let jsonResult = try JSONDecoder().decode(APIResponse.self, from: data)
                print(jsonResult.photos?.perpage as Any)
                DispatchQueue.main.async {
                    
                    self?._photos = (jsonResult.photos?.photo)!
                    print(self?._photos.count as Any)
                    
                    for list in self!._photos{
                        print("farm ",list.farm as Any)
                        print("Image ID ",list.id as Any)
                        print("Server ID ",list.server as Any)
                        print("Secret key ID ",list.secret as Any)
                        
                        self?.farm = list.farm!
                        self?.imageID = list.id!
                        self?.server = list.server!
                        self?.secret = list.secret!
                    }
                    
                    self?.imageCollectionView.reloadData()
                    
                }
                
            }
            catch{
                print(error)
            }
            
        }
        task.resume()
    }
    
}
extension TimeLineVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //defines number of items/Images to be displayed
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _photos.count
    }
    
    // It contains what data needs to be displayed
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! imageCollectionViewCell
        
        self.farm = _photos[indexPath.row].farm!
        self.imageID = _photos[indexPath.row].id!
        self.server = _photos[indexPath.row].server!
        self.secret = _photos[indexPath.row].secret!
        
        cell.configure(with: "https://farm\(farm).staticflickr.com/\(server)/\(imageID)_\(secret)_m.jpg")
        
        return cell
    }
    
    //To set the two rows of a cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
            let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
            let size:CGFloat = (imageCollectionView.frame.size.width - space) / 2.0
            return CGSize(width: size, height: size)
        }
    
    //To navigate to ImageDetailVC on Clicking of Cell/Image
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ImageDetailVC") as? ImageDetailVC{
    
            self.navigationController?.pushViewController(vc, animated: true)
            
            let _photoFiltered = _photos[indexPath.item]
            
            vc.server = _photoFiltered.server!
            vc.imageID = _photoFiltered.id!
            vc.secret = _photoFiltered.secret!
            vc.farm = _photoFiltered.farm!
            
        }
        print("Clicked on item at: \(indexPath.item) ")
        
       
    }
    
}

extension TimeLineVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Searched text: \(searchText)")
        
        
        
        
    }
    
    //To dismiss the keyboard by pressing search Button
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchImage.resignFirstResponder()
        
        if checkTextFieldIsNotEmpty(text: searchBar.text!) == true{
            print("searchBar is not empty, text: \(searchBar.text ?? "random")")
            
            FlickrAPI.imageText = searchBar.text!
            fetchImageList(imageText: searchBar.text ?? "random")
        }
        else{
            print("search Bar is empty")
        }
    }
    
    func checkTextFieldIsNotEmpty(text:String) -> Bool
    {
        if (text.trimmingCharacters(in: .whitespaces).isEmpty)
        {
            print("Please Enter text\(text)")
            
            let alert = UIAlertController(title: "Error!", message: "Please Enter text", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK!", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return false

        }else{
            print("True block \(text)")
            return true
        }
    }
}


