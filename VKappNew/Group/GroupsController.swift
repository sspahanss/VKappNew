//
//  GroupsController.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit
import WebKit
import Alamofire
import RealmSwift

class GroupsController: UITableViewController {
    
    @IBOutlet weak var groupsSearchBar: GroupsSearchBar!
    private var photoService: PhotoService?
    
    private var groups : Results<Group>?{
        didSet{
            pairTableAndRealm()
        }
    }
    private var userGroups : Results<Group>?
    private var isUserGroups : Bool = true
    private var groupsToken : NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoService = PhotoService(container: tableView)
        groups = RealmService.getGroups()
        isUserGroups = true
        DataService.updateAllGroups()
      
    }
    
    @objc
    func refresh() {
        DataService.updateAllGroups()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups?.count ?? 0
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupTableViewCell
        let group = groups![indexPath.row]
        cell.configure(with: group, image: photoService?.getPhoto(atIndexPath: indexPath, byUrl: group.photo100))
        return cell
    }
    
    func pairTableAndRealm() {
        groupsToken = groups?.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var buttonsArray : [UIContextualAction] = []
        if isUserGroups {
            let leaveButton = UIContextualAction(style: .normal, title: "Выйти") {  (contextualAction, view, boolValue) in
                let item = self.groups![indexPath.row]
               
                DataService.postDataToServer(for: item, method: .leaveGroup)
            
                self.groupsSearchBar.searchTextField.text = nil
                self.groupsSearchBar.endEditing(true)
                boolValue(true)
            }
            leaveButton.backgroundColor = .red
            buttonsArray.append(leaveButton)
        } else {
            let joinButton = UIContextualAction(style: .normal, title: "Вступить") {  (contextualAction, view, boolValue) in
                let item = self.groups![indexPath.row]
             
                self.groups = RealmService.getGroups()
                self.isUserGroups = true
                tableView.reloadData()
            
                DataService.postDataToServer(for: item, method: .joinGroup)
               
                self.groupsSearchBar.searchTextField.text = nil
                self.groupsSearchBar.endEditing(true)
                boolValue(true)
            }
            joinButton.backgroundColor = .green
            buttonsArray.append(joinButton)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: buttonsArray)
        return swipeActions
    }
}

extension GroupsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (!searchText.isEmpty){
            DataService.getSearchedGroups(
                searchText: searchText,
                completion: {
                    [weak self] array in
                    self?.groups = array
                    self?.isUserGroups = false
                    self?.tableView.reloadData()
                }
            )
        } else {
            groups = RealmService.getData(for: ("isMember", "==", "Int"), with: 1)?.sorted(byKeyPath: "name")
            tableView.reloadData()
        }
        
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        groupsSearchBar.endEditing(true)
    }
}

