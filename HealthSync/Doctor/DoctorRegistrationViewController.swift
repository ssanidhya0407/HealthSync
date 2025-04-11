//
//  DoctorRegistrationViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  DoctorRegistrationViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DoctorRegistrationViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Doctor Registration"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Full Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let specializationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Specialization (e.g., Cardiology)"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let licenseTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Medical License Number"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let availabilityTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Availability (e.g., Mon-Fri, 9AM-5PM)"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Doctor Registration"
        setupViews()
        setupTapGesture()
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(specializationTextField)
        contentView.addSubview(licenseTextField)
        contentView.addSubview(availabilityTextField)
        contentView.addSubview(registerButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            specializationTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            specializationTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            specializationTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            licenseTextField.topAnchor.constraint(equalTo: specializationTextField.bottomAnchor, constant: 20),
            licenseTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            licenseTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            availabilityTextField.topAnchor.constraint(equalTo: licenseTextField.bottomAnchor, constant: 20),
            availabilityTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            availabilityTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            registerButton.topAnchor.constraint(equalTo: availabilityTextField.bottomAnchor, constant: 40),
            registerButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            registerButton.widthAnchor.constraint(equalToConstant: 200),
            registerButton.heightAnchor.constraint(equalToConstant: 50),
            registerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func registerButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let specialization = specializationTextField.text, !specialization.isEmpty,
              let license = licenseTextField.text, !license.isEmpty,
              let availability = availabilityTextField.text, !availability.isEmpty else {
            showAlert(message: "Please fill in all fields")
            return
        }
        
        // Create user account in Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(message: "Registration failed: \(error.localizedDescription)")
                return
            }
            
            guard let uid = authResult?.user.uid else {
                self.showAlert(message: "Failed to get user ID")
                return
            }
            
            // Create doctor record in Firestore
            let db = Firestore.firestore()
            let doctorData: [String: Any] = [
                "id": uid,
                "name": name,
                "email": email,
                "specialization": specialization,
                "license": license,
                "availability": availability,
                "registrationDate": Timestamp(date: Date()),
                "isActive": true,
                "avgRating": 5.0,
                "totalPatients": 0
            ]
            
            db.collection("doctors").document(uid).setData(doctorData) { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    // If Firestore record creation fails, delete the auth account
                    authResult?.user.delete { _ in }
                    self.showAlert(message: "Registration failed: \(error.localizedDescription)")
                    return
                }
                
                self.showAlert(message: "Registration successful! Please log in with your new credentials.", isSuccess: true) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func showAlert(message: String, isSuccess: Bool = false, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: isSuccess ? "Success" : "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}