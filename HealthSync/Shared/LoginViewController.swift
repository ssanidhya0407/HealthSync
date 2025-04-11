//
//  LoginViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//

//
//  LoginViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

enum UserType {
    case patient
    case doctor
}

class LoginViewController: UIViewController {
    
    var userType: UserType = .patient
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let userTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    let usernameTextField: UITextField = {
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
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .blue
        button.tintColor = .white
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.tintColor = .blue
        button.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        return button
    }()
    
    let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.tintColor = .red
        button.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        return button
    }()
    
    let switchUserTypeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .darkGray
        button.addTarget(self, action: #selector(switchUserTypeTapped), for: .touchUpInside)
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
            userTypeLabel.text = "Patient Login"
            loginButton.backgroundColor = .systemBlue
            switchUserTypeButton.setTitle("Login as Doctor Instead", for: .normal)
        case .doctor:
            userTypeLabel.text = "Doctor Login"
            loginButton.backgroundColor = .systemGreen
            switchUserTypeButton.setTitle("Login as Patient Instead", for: .normal)
        }
    }
    
    func setupViews() {
        view.addSubview(logoImageView)
        view.addSubview(userTypeLabel)
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        view.addSubview(forgotPasswordButton)
        view.addSubview(switchUserTypeButton)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        userTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        switchUserTypeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            userTypeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userTypeLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            
            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.topAnchor.constraint(equalTo: userTypeLabel.bottomAnchor, constant: 20),
            usernameTextField.widthAnchor.constraint(equalToConstant: 250),
            
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 250),
            
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.widthAnchor.constraint(equalToConstant: 250),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forgotPasswordButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 10),
            
            switchUserTypeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            switchUserTypeButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 20)
        ])
    }
    
    @objc func loginTapped() {
        guard let email = usernameTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter email and password")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            guard let userId = authResult?.user.uid else { return }
            
            switch self.userType {
            case .patient:
                self.navigateToPatientHome(userId: userId)
            case .doctor:
                self.verifyAndNavigateToDoctorDashboard(userId: userId)
            }
        }
    }
    
    private func navigateToPatientHome(userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                let homeVC = HomeViewController()
                self.navigationController?.pushViewController(homeVC, animated: true)
            } else {
                self.showAlert(title: "Error", message: "User account not found. Please sign up first.")
                try? Auth.auth().signOut()
            }
        }
    }
    
    private func verifyAndNavigateToDoctorDashboard(userId: String) {
        let db = Firestore.firestore()
        db.collection("doctors").document(userId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                let doctorDashboardVC = DoctorDashboardViewController()
                let navController = UINavigationController(rootViewController: doctorDashboardVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true)
            } else {
                self.showAlert(title: "Access Denied", message: "This account is not registered as a doctor. Please register as a doctor or login as a patient.")
                try? Auth.auth().signOut()
            }
        }
    }
    
    @objc func signUpTapped() {
        switch userType {
        case .patient:
            let signUpVC = SignUpViewController()
            signUpVC.userType = .patient
            navigationController?.pushViewController(signUpVC, animated: true)
        case .doctor:
            let doctorRegistrationVC = DoctorRegistrationViewController()
            navigationController?.pushViewController(doctorRegistrationVC, animated: true)
        }
    }
    
    @objc func forgotPasswordTapped() {
        guard let email = usernameTextField.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Please enter your email address")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            self.showAlert(title: "Success", message: "Password reset email sent successfully")
        }
    }
    
    @objc func switchUserTypeTapped() {
        switch userType {
        case .patient:
            userType = .doctor
        case .doctor:
            userType = .patient
        }
        updateForUserType()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
