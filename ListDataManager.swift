//
//  ListDataManager.swift
//  News
//
//  Created by Xiaolu Tian on 3/28/19.
//

import Foundation
import UIKit


protocol ListDataManagerDelegate : class{
    func dataHasUpdated(needRefresh: Bool)
}

class ListDataManager {
    static let shared = ListDataManager()
    let listLoader = NewsListLoader.shared
    let imageLoader = ImageLoader.shared
    private var newsMap : [String: News]
    private var newsViewModel : [String: NewsViewModel]
    private var moreNews : [NewsID]
    private var thumbnailCache = NSCache<NSString, UIImage>()
    
    var sortedList : [NewsViewModel]{
        didSet{
            delegate?.dataHasUpdated(needRefresh: true)
        }
    }
    
    weak var delegate : ListDataManagerDelegate?
    private init(){
        newsMap = [String: News]()
        newsViewModel = [String: NewsViewModel]()
        sortedList = [NewsViewModel]()
        moreNews = [NewsID]()
    }
}

// MARK:  load list
extension ListDataManager{
    func fetchNewList(){
        listLoader.loadNewList(20) { (result) in
            if case .success(let res) = result{
                //加入现有list
            }
        }
    }
    
    func fetchMoreData(){
        var i = 0
        var ids = [String]()
        while i < moreNews.count && i < 10{
            ids.append(moreNews.removeFirst().uuid)
            i += 1
        }
        listLoader.fetchMore(ids) { (result) in
            if case .success(let res) = result {
//                self.mergeNewList(res.items.result)
                //加入现有的list
            }
        }
    }
    
    func getNewViewModelFor(_ index: IndexPath) -> NewsViewModel {
        return sortedList[index.row]  //这个是为了Push新的detail
    }
    
}

// MARK: - Fetch Image
extension ListDataManager{
    func getImageFor(_ index : IndexPath, completion: @escaping (UIImage? ) -> Void){
        guard let urlString = sortedList[index.row].thumbnailURL, let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        //Find in cache
        if let image = thumbnailCache.object(forKey: urlString as NSString){
            print("find at cache")
            DispatchQueue.main.async {
                completion(image)
            }
            return
        }
        
        //download
        imageLoader.downloadImage(url) { [weak self] (result) in
            if case .success(let image) = result {
                DispatchQueue.main.async {
                    completion(image)
                }
                self?.thumbnailCache.setObject(image, forKey: urlString as NSString)
            }else {
                completion(nil)
            }
        }
    }
    
    func cancelTask(_ index: IndexPath){
        guard sortedList.count > index.row ,let url = sortedList[index.row].thumbnailURL else {
            return
        }
        imageLoader.cancelTask(imageURL: url)
    }
    
    
}

