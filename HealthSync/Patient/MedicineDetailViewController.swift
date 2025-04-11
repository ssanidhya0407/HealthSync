//
//  MedicineDetailViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  MedicineDetailViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MedicineDetailViewController: UIViewController {
    
    private let medicine: Medicine
    
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
    
    private let manufacturerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemBlue
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
    
    private let prescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stockStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
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
    
    init(medicine: Medicine) {
        self.medicine = medicine
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Medicine Details"
        setupViews()
        configureMedicineDetails()
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(manufacturerLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(descriptionTitleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(prescriptionLabel)
        contentView.addSubview(stockStatusLabel)
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
            
            manufacturerLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
            manufacturerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            manufacturerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            categoryLabel.topAnchor.constraint(equalTo: manufacturerLabel.bottomAnchor, constant: 10),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionTitleLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            prescriptionLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            prescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            prescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            stockStatusLabel.topAnchor.constraint(equalTo: prescriptionLabel.bottomAnchor, constant: 10),
            stockStatusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stockStatusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            addToCartButton.topAnchor.constraint(equalTo: stockStatusLabel.bottomAnchor, constant: 30),
            addToCartButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            addToCartButton.widthAnchor.constraint(equalToConstant: 200),
            addToCartButton.heightAnchor.constraint(equalToConstant: 50),
            addToCartButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    private func configureMedicineDetails() {
        nameLabel.text = medicine.name
        priceLabel.text = "₹\(medicine.price)"
        descriptionLabel.text = medicine.description
        
        if let manufacturer = medicine.manufacturer {
            manufacturerLabel.text = "Manufacturer: \(manufacturer)"
        } else {
            manufacturerLabel.text = ""
            manufacturerLabel.isHidden = true
        }
        
        if let category = medicine.category {
            categoryLabel.text = "Category: \(category)"
        } else {
            categoryLabel.text = ""
            categoryLabel.isHidden = true
        }
        
        prescriptionLabel.text = medicine.requiresPrescription ? "⚠️ Prescription Required" : "No Prescription Required"
        prescriptionLabel.textColor = medicine.requiresPrescription ? .systemRed : .systemGreen
        
        stockStatusLabel.text = medicine.inStock ? "✅ In Stock" : "❌ Out of Stock"
        stockStatusLabel.textColor = medicine.inStock ? .systemGreen : .systemRed
        
        addToCartButton.isEnabled = medicine.inStock
        addToCartButton.backgroundColor = medicine.inStock ? .systemBlue : .lightGray
    }
    
    @objc private func addToCartTapped() {
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(message: "You must be logged in to add items to your cart")
            return
        }
        
        if medicine.requiresPrescription {
            checkForPrescription(userId: currentUser.uid)
        } else {
            addToCart(userId: currentUser.uid)
        }
    }
    
    private func checkForPrescription(userId: String) {
        let db = Firestore.firestore()
        
        // This is a simplified check. In a real app, you would verify the medicine against 
        // actual prescriptions in the database
        db.collection("prescriptions")
            .whereField("patientId", isEqualTo: userId)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.showAlert(message: "Error checking prescriptions: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    self.showAlert(message: "This medication requires a prescription. Please consult with a doctor.")
                    return
                }
                
                // In a real app, you would check if any prescription contains this specific medicine
                // For this example, we'll simply check if the user has any prescription
                self.addToCart(userId: userId)
            }
    }
    
    private func addToCart(userId: String) {
        let cartItem = [
            "type": "medicine",
            "id": medicine.id,
            "name": medicine.name,
            "price": medicine.price,
            "requiresPrescription": medicine.requiresPrescription
        ] as [String: Any]
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("cart").addDocument(data: cartItem) { [weak self] error in
            guard let self = self else { return }
            
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