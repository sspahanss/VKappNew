//
//  FriendsListController.swift
//  VKappNew
//
//  Created by Павел on 02.10.2020.
//

import UIKit
import Alamofire
import RealmSwift

typealias ResultsForUser = Results<User>

class FriendsController: UIViewController, UINavigationControllerDelegate {
    private var users : ResultsForUser? {
        didSet{
            if users != nil {
                initSorterControl()
                pairTableAndRealm()
            }
        }
    }
    private var photoService: PhotoService?
    
    private var usersToken: NotificationToken?
    private var sorterControl: SorterBarControl!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var friendSearchBar: FriendsSearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = CGFloat(70)
        tableView.register(HeaderViewForCell.self, forHeaderFooterViewReuseIdentifier: HeaderViewForCell.identifier)
        photoService = PhotoService(container: tableView)
        sorterControl = SorterBarControl()
        sorterControl.addTarget(self, action: #selector(sorterBarWasChanged), for: .valueChanged)
        view.addSubview(sorterControl)
        users = RealmService.getData()?.sorted(byKeyPath: "lastName")
        DataService.updateAllFriends()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoAlbumSegue" {
            let photoAlbumVC = segue.destination as! PhotoListViewController
            if let index = tableView.indexPathForSelectedRow, let user = users?.getUserForIndexPathAndLetter(letter: sorterControl.getLetter(for: index.section), row: index.row) {
                photoAlbumVC.configure(for: user.id, with: "\(user.firstName) \(user.lastName)")
            }
        }
    }
    
    @objc func sorterBarWasChanged(_ sender: SorterBarControl) {
        let indexPath = IndexPath(row: 0, section: sender.getIndexForChoosedLetter())
        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func initSorterControl(){
        sorterControl.configure(users: users)
        sorterControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sorterControl.widthAnchor.constraint(equalToConstant: CGFloat(20)),      sorterControl.heightAnchor.constraint(equalToConstant: CGFloat(30*sorterControl.getLettersCount())), sorterControl.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            sorterControl.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
    }
    
    func pairTableAndRealm() {
        usersToken = users?.observe { (changes: RealmCollectionChange) in
            guard let tableView = self.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_,_,_,_):
                self.initSorterControl()
                tableView.reloadData()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
}

extension FriendsController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { self.sorterControl.getLettersCount() }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users!.filter(NSPredicate(for: sorterControl.getLetter(for: section))).count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderViewForCell.identifier) as! HeaderViewForCell
        headerView.configure(with: sorterControl.getLetter(for: section))
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendTableViewCell.identifier, for: indexPath) as! FriendTableViewCell
        if let user = users?.getUserForIndexPathAndLetter(letter: sorterControl.getLetter(for: indexPath.section), row: indexPath.row) {
            cell.configure(with: user, image: photoService?.getPhoto(atIndexPath: indexPath, byUrl: user.photo100))
        }
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.8,
                       animations: {
                        cell.alpha = 1
        })
    }
}
extension FriendsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        users = RealmService.getSearchedFriends(for: searchText)
        tableView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        friendSearchBar.endEditing(true)
    }
}

extension ResultsForUser {
    
    func getUserForIndexPathAndLetter(letter: String, row: Int) -> User? {
        return self.filter(NSPredicate(for: letter))[row]
    }
}

extension NSPredicate {
    public convenience init(for letter: String) {
        self.init(format: letter == "" ? "lastName == ''" : "lastName BEGINSWITH[c] '\(letter)'")
    }
}
