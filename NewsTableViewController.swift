//
//  NewsTableViewController.swift
//  News
//
//  Created by Xiaolu Tian on 3/28/19.
//

import UIKit

class NewsTableViewController: UITableViewController{
    let dataManager : ListDataManager
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        dataManager = ListDataManager.shared
        super.init(nibName: nil, bundle: nil)
        dataManager.delegate = self
        tableView.prefetchDataSource = self
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if dataManager.sortedList.count == 0 {
            dataManager.fetchNewList()
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.sortedList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  NewsTableViewCell.reuseIdentifier, for: indexPath)
        assert(cell is NewsTableViewCell, "cell not valid")
        let dequeCell = cell as! NewsTableViewCell
        dequeCell.setData(dataManager.getNewViewModelFor(indexPath))
        return dequeCell
    }
    
    var isWaiting = false
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        assert(cell is NewsTableViewCell, "cell not valid")
        dataManager.getImageFor(indexPath) { [weak tableView] (image) in
            if let image = image, let tableCell = tableView?.cellForRow(at: indexPath) as? NewsTableViewCell{
                tableCell.newsImage.image = image
            }
        }
        
        if indexPath.row == dataManager.sortedList.count - 10{
            dataManager.fetchMoreData()
            isWaiting = true
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         dataManager.cancelTask(indexPath)
    }
    
    
    
    // MARK:  Incremental loading
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offseY = scrollView.contentOffset.y
//        let contentH = scrollView.contentSize.height
//        if offseY + scrollView.frame.height + 10 > contentH{
//            dataManager.fetchMoreData()
//        }
//    }
    
    // MARK:  Nevigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = YHDetailViewController(dataManager.getNewViewModelFor(indexPath))
        navigationController?.pushViewController(detailVC, animated: true)
    }

}


extension NewsTableViewController : UITableViewDataSourcePrefetching{
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for ip  in indexPaths{
            print("prefetchin --- \(ip)")
            dataManager.getImageFor(ip, completion: { result in
            })
        }
        
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for ip in indexPaths{
            dataManager.cancelTask(ip)
        }
    }
}


// MARK: ListDataManagerDelegate
extension NewsTableViewController : ListDataManagerDelegate{
    func dataHasUpdated(needRefresh: Bool){
        DispatchQueue.main.async {
            if needRefresh{
                self.tableView.reloadData()
            }
        }
        isWaiting = false
    }
}


