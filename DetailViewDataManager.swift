//
//  DetailViewDataManager.swift
//  News
//
//  Created by Xiaolu Tian on 3/28/19.
//

import Foundation
import UIKit
class DetailViewDataManager {
    let imageloader = ImageLoader.shared
    static let shared = DetailViewDataManager()
    private var largeImageCache = NSCache<NSString, UIImage>()
    private init() {}
    
    func getImagefor(_ viewModel: NewsViewModel, _ completion: @escaping (Result<UIImage, NewsError>) -> Void){
        if let imageURL = viewModel.imageURL, let url = URL(string: imageURL){
            
            //Check cache
            if let image = largeImageCache.object(forKey: imageURL as NSString){
                completion(.success(image))
                return
            }

            //download
            imageloader.downloadImage(url){[weak self](res) in
                if case .success( let pic) = res {
                    //save to disk
                    self?.largeImageCache.setObject(pic, forKey: imageURL as NSString)
                    DispatchQueue.main.async {
                        completion(.success(pic))
                    }
                }else{
                    completion(.failure(.noDATA))
                }
            }
        }else{
            completion(.failure(.badURL))
        }

    }
}
