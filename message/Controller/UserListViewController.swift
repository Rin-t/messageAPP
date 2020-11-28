//
//  UserListViewController.swift
//  message
//
//  Created by Rin on 2020/11/20.
//

import UIKit
import Firebase
import Nuke

class UserListViewController: UIViewController {
    
    private let cellId = "cellId"
    private var users = [User]()
    private var selectedUser: User?
    
    
    
    @IBOutlet weak var startChatButton: UIButton!
    @IBOutlet weak var userListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userListTableView.tableFooterView = UIView()
        userListTableView.delegate = self
        userListTableView.dataSource = self
        startChatButton.layer.cornerRadius = 10
        startChatButton.addTarget(self, action: #selector(tappedStartButton), for: .touchUpInside)
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 39, blue: 69)
        
        startChatButton.isEnabled = false
        fetchUserInfoFromFirestore()
    }
    
    @objc private func tappedStartButton() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let partnerUid = self.selectedUser?.uid else { return }
        let members = [uid,partnerUid]
        
        let docData = [
            "members": members,
            "latestMessageId": "",
            "creatAt": Timestamp()
        
        ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").addDocument(data: docData) { (err) in
            if let err = err {
                print("chatRoom failed")
                return
            }
            self.dismiss(animated: true, completion: nil)
            print("chatroom情報の保存に成功")
        }
    }
    
    
    private func fetchUserInfoFromFirestore() {
        Firestore.firestore().collection("users").getDocuments{ (snapshots, err) in
            if let err = err {
                print("user faild")
                return
            }
            
            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                user.uid = snapshot.documentID
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                if uid == snapshot.documentID {
                    print("同じ")
                    return
                }
                
                self.users.append(user)
                self.userListTableView.reloadData()
            })
        }
    }
}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserListTableViewCell
        cell.user = users[indexPath.row]
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        startChatButton.isEnabled = true
        self.selectedUser = user
        
        print(user.username)
    }
    
    
}


class UserListTableViewCell: UITableViewCell {
    
    var user: User? {
        didSet {
            usernameLabel.text = user?.username
            
            if let url = URL(string: user?.profileImageUrl ?? ""){
                Nuke.loadImage(with: url, into: userImageView)
            }
        }
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 25
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
