//
//  ChatRoomViewController.swift
//  message
//
//  Created by Rin on 2020/11/15.
//

import UIKit
import Firebase

class ChatRoomViewController: UIViewController {
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    var user: User?
    var chatroom: ChatRoom?
    
    private let cellId = "cellId"
    private var messages = [Message]()
    
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        chatRoomTableView.register(UINib(nibName: "ChatViewTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        fetchMessages()
        
    }
    //メッセージのinputtextviewを自動で上げ下げしてくれる
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func fetchMessages() {
        guard let chatroomDocId = chatroom?.documentId else { return }
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").addSnapshotListener { (snapshot, err) in
            if let err = err {
                print("メッセージの取得に失敗")
                return
            }
            
            snapshot?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let message = Message(dic: dic)
                    message.partnerUser = self.chatroom?.partnerUser
                    self.messages.append(message)
                    self.chatRoomTableView.reloadData()
                    print(dic)
                case .modified, .removed:
                    print("nothing to do")
                }
            })
        }
    }
}

extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    func tappedSendButton(text: String) {
//        messages.append(text)
//        chatInputAccessoryView.removeText()
////        chatInputAccessoryView.chatTextView.text = ""
//        chatRoomTableView.reloadData()
        
        guard let chatroomDocId = chatroom?.documentId else { return }
        guard let name = user?.username else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        chatInputAccessoryView.removeText()
        
        let docData = [
            "name": name,
            "createdAt": Timestamp(),
            "uid": uid,
            "message": text
        ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").document().setData(docData) { (err) in
            if let err = err {
                print("メッセージ情報の保存に失敗")
                return
            }
            
            print("メッセージの保存に成功")
        }
        
    }
    
    
}
 
extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        //自動で高さを決めてくれる
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
        
        cell.message = messages[indexPath.row]
        return cell
    }
    
    
}
