//
//  ChatListViewController.swift
//  message
//
//  Created by Rin on 2020/11/14.
//

import UIKit
import Firebase
import Nuke

class ChatListViewController: UIViewController {
    @IBOutlet weak var chatListTableView: UITableView!
    
    private let cellId = "cellId"
    private var chatrooms = [ChatRoom]()
    private var user: User? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let storyborad = UIStoryboard(name: "SignUp", bundle: nil)
//        let signUpViewController = storyborad.instantiateViewController(withIdentifier: "SignUpViewController")
//        self.present(signUpViewController, animated: true, completion: nil)

        setupViews()
        confirmLoggedInUser()
        fetchLoginUserInfo()
        fetchChatRoomInfoFromFirestore()
    }
    
    private func fetchChatRoomInfoFromFirestore() {
        Firestore.firestore().collection("chatRooms")
            .addSnapshotListener { (snapshot, err) in
                
                //.getDocuments { (snapshot, err) in
                if let err = err {
                    print("err")
                    return
                }
                
                snapshot?.documentChanges.forEach({ (documentChange) in
                    switch documentChange.type{
                    case .added:
                        self.handleAddedDocumentChange(documentChange: documentChange)
                        print("added")
                    case .modified, .removed:
                        print("nothing to do")
                        
                    }
                })
            }
    }
    
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        let dic = documentChange.document.data()
        let chatroom = ChatRoom(dic: dic)
        chatroom.documentId = documentChange.document.documentID
        
        
        
        guard let uid = Auth.auth().currentUser?.uid  else { return }
        let isContsin = chatroom.members.contains(uid)
        
        if !isContsin { return }
        
        chatroom.members.forEach { (memberUid) in
            if memberUid != uid {
                Firestore.firestore().collection("users").document(memberUid).getDocument { (snapshot, err) in
                    if let err = err {
                        print("ユーザーの取得失敗")
                        return
                    }
                    guard let dic = snapshot?.data() else { return }
                    let user = User(dic: dic)
                    user.uid = documentChange.document.documentID
                    chatroom.partnerUser = user
                    self.chatrooms.append(chatroom)
                    print(self.chatrooms[0].members)
                    self.chatListTableView.reloadData()
                    
                }
            }
        }
    }
    
    private func setupViews() {
        chatListTableView.tableFooterView = UIView()
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        
        
        let rightBarButton = UIBarButtonItem(title: "新規チャット", style: .plain, target: self, action: #selector(tappedNavRightBarButton))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        
    }
    
    private func confirmLoggedInUser() {
        if Auth.auth().currentUser?.uid == nil {
            let storyborad = UIStoryboard(name: "SignUp", bundle: nil)
            let signupViewController = storyborad.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            signupViewController.modalPresentationStyle = .fullScreen
            self.present(signupViewController, animated: true, completion: nil)
        }
    }
    
    @objc private func tappedNavRightBarButton() {
        let storyborad = UIStoryboard.init(name: "UserList", bundle: nil)
        let userListViewController = storyborad.instantiateViewController(withIdentifier: "UserListViewController")
        let nav = UINavigationController(rootViewController: userListViewController)
      
        self.present(nav, animated: true, completion: nil)
    }
    
    private func fetchLoginUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("couldnt get user information")
                return
            }
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            
            let user = User(dic: dic)
            self.user = user
        }
    }
}


//MARK: - TableViewDelegate, UITableViewDataSource
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell
        print("tableViewだよ")
        cell.chatroom = chatrooms[indexPath.row]
        print(cell.chatroom?.members)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController") as! ChatRoomViewController
        chatRoomViewController.chatroom = chatrooms[indexPath.row]
        chatRoomViewController.user = user
        navigationController?.pushViewController(chatRoomViewController, animated: true)
        
    }
}

class ChatListTableViewCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //    var user: User? {
    //        didSet {
    //            if let user = user {
    //                partnerLabel.text = user.username
    //
    //                //userImageView.image = user?.profileImageUrl
    //
    //                dateLabel.text = dateForematterForDateLabel(date: user.createdAt.dateValue())
    //                latestMessageLabel.text = user.email
    //            }
    //        }
    //    }
    
    var chatroom: ChatRoom? {
        didSet {
            if let chatroom = chatroom {
                partnerLabel.text = chatroom.partnerUser?.username
                
                guard let url = URL(string: chatroom.partnerUser?.profileImageUrl ?? "") else { return }
                Nuke.loadImage(with: url, into: userImageView)
                
                dateLabel.text = dateForematterForDateLabel(date: chatroom.creatAt.dateValue())
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 30
    
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func dateForematterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
