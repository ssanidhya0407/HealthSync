//
//  LoginSelectionViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit

class LoginSelectionViewController: UIViewController {
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "HealthSync"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Please select your account type"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .darkGray
        return label
    }()
    
    let patientButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Patient Login", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(patientLoginTapped), for: .touchUpInside)
        return button
    }()
    
    let doctorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Doctor Login", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(doctorLoginTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
    }
    
    func setupViews() {
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(patientButton)
        view.addSubview(doctorButton)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        patientButton.translatesAutoresizingMaskIntoConstraints = false
        doctorButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            logoImageView.widthAnchor.constraint(equalToConstant: 150),
            logoImageView.heightAnchor.constraint(equalToConstant: 150),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.widthAnchor.constraint(equalToConstant: 300),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            subtitleLabel.widthAnchor.constraint(equalToConstant: 300),
            
            patientButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            patientButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 50),
            patientButton.widthAnchor.constraint(equalToConstant: 250),
            patientButton.heightAnchor.constraint(equalToConstant: 60),
            
            doctorButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doctorButton.topAnchor.constraint(equalTo: patientButton.bottomAnchor, constant: 20),
            doctorButton.widthAnchor.constraint(equalToConstant: 250),
            doctorButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc func patientLoginTapped() {
        let loginVC = LoginViewController()
        loginVC.userType = .patient
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @objc func doctorLoginTapped() {
        let loginVC = LoginViewController()
        loginVC.userType = .doctor
        navigationController?.pushViewController(loginVC, animated: true)
    }
}
