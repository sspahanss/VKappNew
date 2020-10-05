//
//  NeewsViewController.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit

class NewsViewController: UIViewController {
    var news : NewsItems?
    
    @IBOutlet weak var tableView: UITableView!
    private var photoService: PhotoService?
    var refreshControl : UIRefreshControl?
    var nextFrom = ""
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        photoService = PhotoService(container: tableView)
        DataService.getNewsfeed(
            completion: {
                [weak self] array in
                self?.news = array
                self?.tableView.reloadData()
            }
        )
        setupRefreshControl()
    }
    fileprivate func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Обновление...")
        refreshControl?.tintColor = UIColor(named: "#6689B3ff")
        refreshControl?.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
        tableView.addSubview(refreshControl!)
    }
    @objc func refreshNews() {
        refreshControl!.endRefreshing()
        self.refreshControl?.beginRefreshing()
        let mostFreshNewsDate = self.news!.items.first?.date ?? Int(Date().timeIntervalSince1970)
        DataService.getNewsfeed(startTime: String(mostFreshNewsDate + 1)) { [weak self] news in
            guard let self = self else { return }
            self.refreshControl?.endRefreshing()
            guard news!.items.count > 0 else { return }
            self.news?.addNewsToStart(new: news!)
            var indexPathes : [IndexPath] = []
            for i in 0..<(news?.items.count)! {
                indexPathes.append(IndexPath(row: i, section: 0))
            }
            self.tableView.insertRows(at: indexPathes, with: .automatic)
        }
    }
}

extension NewsViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let newsItems = news, !newsItems.items.isEmpty else {
            return 0
        }
        return newsItems.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsTableViewCell
        guard let newsItems = news, !newsItems.items.isEmpty else {
            return cell
        }
        let currentNews = newsItems.items[indexPath.row]
        let id = currentNews.sourceID
        var author : (name: String, photo: UIImage?) = ("", nil)
        if id > 0 {
            if let user = newsItems.profiles.first(where: {$0.id == abs(id)}), let photo = photoService?.getPhoto(atIndexPath: indexPath, byUrl: user.photo100) {
                author.name = user.getFullName()
                author.photo = photo
            }
        } else {
            if let group = newsItems.groups.first(where: {$0.id == abs(id)}), let photo = photoService?.getPhoto(atIndexPath: indexPath, byUrl: group.photo100) {
                author.name = group.name
                author.photo = photo
            }
        }
        
        cell.configure(for: currentNews, with: configurePhotoList(for: currentNews, with: indexPath), by: author)
        cell.delegate = self
        cell.photoDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsTableViewCell
        guard let newsItems = news, !newsItems.items.isEmpty else {
            return
        }
        let currentNews = newsItems.items[indexPath.row]
        cell.setLikeCounterControl(count: currentNews.getLikesInfo().0)
        cell.reloadInputViews()
    }
    
    private func configurePhotoList(for currentNews: News, with indexPath: IndexPath) -> [UIImage]{
        var cellPhotos = [UIImage]()
        if !currentNews.attachments.isEmpty {
            for attach in currentNews.attachments {
                var photo : Photo = Photo()
                if let photos = attach.photo {
                    photo = photos
                } else if let link = attach.link, let photos = link.photo{
                    photo = photos
                }
                
                if let url = photo.getPhotoBigSizeURL(), let bigPhoto = photoService?.getPhoto(atIndexPath: indexPath, byUrl: url) {
                    cellPhotos.append(bigPhoto)
                }
            }
        } else if currentNews.photos != nil{
            if let url = currentNews.photos!.items[0].getPhotoBigSizeURL(), let bigPhoto = photoService?.getPhoto(atIndexPath: indexPath, byUrl: url) {
                cellPhotos = [bigPhoto]
            }
        }
        if (cellPhotos.isEmpty){
            cellPhotos = [UIImage(systemName: "arrowtriangle.right.circle")!]
        }
        return cellPhotos
    }
}


extension Date {
    static func getFormattedDate(date: Date, format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: date)
    }
}

extension NewsViewController : CommentCounterDelegate {
    func onButtonTapped(){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "News", bundle:nil)
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        
        resultViewController.comments = news!.items[0].comments!.list
        navigationController?.pushViewController(resultViewController,
                                                 animated: true)
    }
}

extension NewsViewController : NewsPhotoCollectionViewDelegate {
    func onButtonTapped(_ data : UIImage) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Friends", bundle:nil)
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "FullPhoto") as! PhotoListViewController
        resultViewController.configureForNews(for: data)
        navigationController?.pushViewController(resultViewController,
                                                 animated: true)
    }
}

extension NewsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let maxSection = indexPaths.map({ $0.row }).max() else { return }
        if maxSection > news!.items.count - 15,
            !isLoading {
            isLoading = true
            DataService.getNewsfeed(startFrom: news!.nextFrom) { [weak self] news in
                guard let self = self else { return }
                guard news!.items.count > 0 else { return }
                let oldIndex = self.news?.items.count
                self.news?.addNewsToEnd(new: news!)
                var indexPathes : [IndexPath] = []
                for i in oldIndex!..<(self.news?.items.count)!{
                    indexPathes.append(IndexPath(row: i, section: 0))
                }
                self.tableView.insertRows(at: indexPathes, with: .automatic)
                self.isLoading = false
            }
        }
    }
}

extension TimeInterval {
    
    func toRelativeDateTime() -> String {
        
        let time = NSInteger(self)
        
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        if hours > 24{
            return "Давно"
        } else if hours > 1 {
            return "\(hours) часов назад"
        } else if minutes > 1 {
            return "\(minutes) минут назад"
        } else {
            return "\(seconds) секунд назад"
        }
    }
}
