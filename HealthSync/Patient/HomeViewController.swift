//
//  HomeViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  HomeViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import FirebaseAuth
import UIKit

class HomeViewController: UIViewController {

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let labTestsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🧪 Lab Tests", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(labTestsTapped), for: .touchUpInside)
        return button
    }()
    
    let medicinesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("💊 Buy Medicines", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(medicinesTapped), for: .touchUpInside)
        return button
    }()
    
    let findDocButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("👨‍⚕️ Find Doctor", for: .normal)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(findDocTapped), for: .touchUpInside)
        return button
    }()
    
    let healthArticlesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📰 Health Articles", for: .normal)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(healthArticlesTapped), for: .touchUpInside)
        return button
    }()
    
    let orderDetailsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📦 Order Details", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(orderDetailsTapped), for: .touchUpInside)
        return button
    }()
    
    let cartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🛒 Cart", for: .normal)
        button.backgroundColor = .systemTeal
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
        return button
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.tintColor = .blue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        title = "Home"
        navigationItem.hidesBackButton = true
    }
    
    func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(labTestsButton)
        contentView.addSubview(medicinesButton)
        contentView.addSubview(findDocButton)
        contentView.addSubview(healthArticlesButton)
        contentView.addSubview(orderDetailsButton)
        contentView.addSubview(cartButton)
        contentView.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            labTestsButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            labTestsButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            labTestsButton.widthAnchor.constraint(equalToConstant: 250),
            labTestsButton.heightAnchor.constraint(equalToConstant: 50),
            
            medicinesButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            medicinesButton.topAnchor.constraint(equalTo: labTestsButton.bottomAnchor, constant: 20),
            medicinesButton.widthAnchor.constraint(equalToConstant: 250),
            medicinesButton.heightAnchor.constraint(equalToConstant: 50),
            
            findDocButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            findDocButton.topAnchor.constraint(equalTo: medicinesButton.bottomAnchor, constant: 20),
            findDocButton.widthAnchor.constraint(equalToConstant: 250),
            findDocButton.heightAnchor.constraint(equalToConstant: 50),
            
            healthArticlesButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            healthArticlesButton.topAnchor.constraint(equalTo: findDocButton.bottomAnchor, constant: 20),
            healthArticlesButton.widthAnchor.constraint(equalToConstant: 250),
            healthArticlesButton.heightAnchor.constraint(equalToConstant: 50),
            
            orderDetailsButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            orderDetailsButton.topAnchor.constraint(equalTo: healthArticlesButton.bottomAnchor, constant: 20),
            orderDetailsButton.widthAnchor.constraint(equalToConstant: 250),
            orderDetailsButton.heightAnchor.constraint(equalToConstant: 50),
            
            cartButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cartButton.topAnchor.constraint(equalTo: orderDetailsButton.bottomAnchor, constant: 20),
            cartButton.widthAnchor.constraint(equalToConstant: 250),
            cartButton.heightAnchor.constraint(equalToConstant: 50),
            
            logoutButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: cartButton.bottomAnchor, constant: 20),
            logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50)
        ])
    }
    
    @objc func labTestsTapped() {
        let labTestsVC = LabTestsViewController()
        navigationController?.pushViewController(labTestsVC, animated: true)
    }
    
    @objc func medicinesTapped() {
        let medicinesVC = MedicinesViewController()
        navigationController?.pushViewController(medicinesVC, animated: true)
    }
    
    @objc func findDocTapped() {
        let doctorsVC = DoctorsViewController()
        navigationController?.pushViewController(doctorsVC, animated: true)
    }
    
    @objc func healthArticlesTapped() {
        let healthArticlesVC = HealthArticlesViewController()
        navigationController?.pushViewController(healthArticlesVC, animated: true)
    }
    
    @objc func orderDetailsTapped() {
        let orderDetailsVC = OrderDetailsViewController()
        navigationController?.pushViewController(orderDetailsVC, animated: true)
    }
    
    @objc func cartTapped() {
        let cartVC = CartViewController()
        navigationController?.pushViewController(cartVC, animated: true)
    }
    
    @objc func logoutTapped() {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            showAlert(message: "Error signing out. Please try again.")
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}