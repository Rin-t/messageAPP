//
//  ChatRoomViewController.swift
//  message
//
//  Created by Rin on 2020/11/15.
//

import UIKit

class ChatRoomViewController: UIViewController {
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    private let cellId = "cellId"
    private var messages = [String]()
    
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
}

extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    func tappedSendButton(text: String) {
        messages.append(text)
        chatInputAccessoryView.removeText()
//        chatInputAccessoryView.chatTextView.text = ""
        chatRoomTableView.reloadData()
        
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
        
        cell.messageText = messages[indexPath.row]
        return cell
    }
    
    
}
