//
//  SignUpViewController.swift
//  message
//
//  Created by Rin on 2020/11/17.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwardTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageButton.layer.cornerRadius = 85
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240
        ).cgColor
        registerButton.layer.cornerRadius = 12
        
        profileImageButton.addTarget(self, action: #selector(tappedProfileImageButton), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(tappedRegisterButton), for: .touchUpInside)
        
        emailTextField.delegate = self
        passwardTextField.delegate = self
        usernameTextField.delegate = self
        registerButton.isEnabled = false
        registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
    }
    
    @objc private func tappedProfileImageButton() {
        
        let imagePickerControlelr = UIImagePickerController()
        imagePickerControlelr.delegate = self
        imagePickerControlelr.allowsEditing = true
        
        self.present(imagePickerControlelr, animated: true, completion: nil)
        
    }
    
    @objc private func tappedRegisterButton() {
        guard let image = profileImageButton.imageView?.image else { return }
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }

        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)

        storageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("err", err)
                print(err)
                return
            }

            storageRef.downloadURL{ (url, err) in
                if let err = err {
                    print("err2")
                    return
                }

                guard let urlString = url?.absoluteString else { return }
                self.createUserToFireStore(profileImageUrl: urlString)
            }
        }
    }
    
    private func createUserToFireStore(profileImageUrl: String) {
      
        guard let email = emailTextField.text else { return }
        guard let password = passwardTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) {  (res, err) in
            if let err = err {
                print(err)
                print("err3")
                return
            }
            print("ok")
            
            guard let uid = res?.user.uid else { return }
            guard let username = self.usernameTextField.text else { return }
            let docData = [
                "email": email,
                "username": username,
                "createdAt": Timestamp(),
                "profileImageUrl": profileImageUrl
            ] as [String : Any]
            
            Firestore.firestore().collection("users").document(uid).setData(docData) {
                (err) in
                if let err = err {
                    print("err4")
                    return
                }
                print("保存成功")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        profileImageButton.setTitle("", for:  .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
    
}


extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwardTextField.text?.isEmpty ??  false
        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? false
        
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty {
            registerButton.isEnabled = false
            registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        } else {
            registerButton.isEnabled = true
            registerButton.backgroundColor = .rgb(red: 0, green: 185, blue: 0)
        }
        
    }
}
