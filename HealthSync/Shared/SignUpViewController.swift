//
//  SignUpViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  SignUpViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {

    var userType: UserType = .patient
    
    let userTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .blue
        button.tintColor = .white
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        updateForUserType()
        setupViews()
    }
    
    func updateForUserType() {
        switch userType {
        case .patient:
            userTypeLabel.text = "Patient Registration"
            signUpButton.backgroundColor = .systemBlue
        case .doctor:
            userTypeLabel.text = "Doctor Registration"
            signUpButton.backgroundColor = .systemGreen
        }
    }
    
    func setupViews() {
        view.addSubview(userTypeLabel)
        view.addSubview(usernameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signUpButton)
        
        userTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userTypeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userTypeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.topAnchor.constraint(equalTo: userTypeLabel.bottomAnchor, constant: 40),
            usernameTextField.widthAnchor.constraint(equalToConstant: 250),
            
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            emailTextField.widthAnchor.constraint(equalToConstant: 250),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 250),
            
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            signUpButton.widthAnchor.constraint(equalToConstant: 250),
            signUpButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func signUpTapped() {
        guard let name = usernameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Please fill in all fields")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
            
            guard let uid = authResult?.user.uid else { return }
            let db = Firestore.firestore()
            
            switch self.userType {
            case .patient:
                db.collection("users").document(uid).setData([
                    "name": name,
                    "email": email,
                    "userType": "patient",
                    "registrationDate": Timestamp(date: Date())
                ]) { error in
                    if let error = error {
                        self.showAlert(message: error.localizedDescription)
                        return
                    }
                    self.showAlert(message: "Patient registration successful!") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
            case .doctor:
                // Note: For doctors we should use DoctorRegistrationViewController instead
                db.collection("doctors").document(uid).setData([
                    "name": name,
                    "email": email,
                    "registrationDate": Timestamp(date: Date()),
                    "isActive": true,
                    "avgRating": 5.0,
                    "totalPatients": 0
                ]) { error in
                    if let error = error {
                        self.showAlert(message: error.localizedDescription)
                        return
                    }
                    self.showAlert(message: "Doctor registration successful!") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}