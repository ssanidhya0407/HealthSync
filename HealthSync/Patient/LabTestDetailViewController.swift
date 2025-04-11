//
//  LabTestDetailViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  LabTestDetailViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LabTestDetailViewController: UIViewController {
    
    private let labTest: LabTest
    
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
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .systemGreen
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Description:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let preparationTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Preparation Instructions:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let preparationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to Cart", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        return button
    }()
    
    init(labTest: LabTest) {
        self.labTest = labTest
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Lab Test Details"
        setupViews()
        configureLabTestDetails()
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(descriptionTitleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(preparationTitleLabel)
        contentView.addSubview(preparationLabel)
        contentView.addSubview(addToCartButton)
        
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
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionTitleLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 20),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            preparationTitleLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            preparationTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            preparationTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            preparationLabel.topAnchor.constraint(equalTo: preparationTitleLabel.bottomAnchor, constant: 10),
            preparationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            preparationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            addToCartButton.topAnchor.constraint(equalTo: preparationLabel.bottomAnchor, constant: 30),
            addToCartButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addToCartButton.widthAnchor.constraint(equalToConstant: 200),
            addToCartButton.heightAnchor.constraint(equalToConstant: 50),
            addToCartButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func configureLabTestDetails() {
        nameLabel.text = labTest.name
        priceLabel.text = "₹\(labTest.price)"
        descriptionLabel.text = labTest.description
        
        if let preparationInstructions = labTest.preparationInstructions {
            preparationLabel.text = preparationInstructions
        } else {
            preparationLabel.text = "No special preparation required for this test."
        }
    }
    
    @objc private func addToCartTapped() {
        // In a real app, this would add the lab test to the user's cart in Firebase
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(message: "You must be logged in to add items to your cart")
            return
        }
        
        let cartItem = [
            "type": "labTest",
            "id": labTest.id,
            "name": labTest.name,
            "price": labTest.price
        ] as [String: Any]
        
        let db = Firestore.firestore()
        db.collection("users").document(currentUser.uid).collection("cart").addDocument(data: cartItem) { error in
            if let error = error {
                self.showAlert(message: "Error adding to cart: \(error.localizedDescription)")
                return
            }
            
            self.showAlert(message: "Added to cart successfully!", isSuccess: true)
        }
    }
    
    private func showAlert(message: String, isSuccess: Bool = false) {
        let alert = UIAlertController(title: isSuccess ? "Success" : "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
        
