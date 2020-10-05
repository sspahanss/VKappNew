//
//  Comment.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit

class CommentsViewController: UIViewController {
    var comments : [CommentsList] = []
    @IBOutlet weak var newCommentTextField: UITextField!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var commentsTableView: UITableView!{
        didSet{
            commentsTableView.dataSource = self
            commentsTableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func buttonIsTapped(_ sender: Any) {
        self.commentsTableView.beginUpdates()
        self.commentsTableView.insertRows(at: [IndexPath.init(row: self.comments.count-1, section: 0)], with: .automatic)
        self.commentsTableView.endUpdates()
        newCommentTextField.text?.removeAll()
    }
    
}
extension CommentsViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {  self.comments.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        
        cell.textLabel?.text = comments[indexPath.row].text
        DataService.getUserById(userId: comments[indexPath.row].fromID,
                   completion: {
                       array in
                    cell.detailTextLabel?.text = array!.getFullName()
                   }
               )
        return cell
    }
}

