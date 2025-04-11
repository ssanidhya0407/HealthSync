//
//  CartViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    typealias CartItem = (id: String, type: String, name: String, price: Double, requiresPrescription: Bool)
    private var cartItems: [CartItem] = []
    private var totalPrice: Double = 0.0
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CartItemCell.self, forCellReuseIdentifier: "CartItemCell")
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.backgroundColor = .systemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        return tableView
    }()
    
    private let emptyCartView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyCartImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "cart")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyCartLabel: UILabel = {
        let label = UILabel()
        label.text = "Your cart is empty"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyCartSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add medicines or lab tests to your cart"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemGray2
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let browseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Browse Items", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(browseTapped), for: .touchUpInside)
        return button
    }()
    
    private let summaryView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let totalItemsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtotalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Checkout", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Cart"
        
        setupViews()
        setupTableView()
        setupActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCartItems()
    }
    
    private func setupViews() {
        // Empty cart view
        view.addSubview(emptyCartView)
        emptyCartView.addSubview(emptyCartImageView)
        emptyCartView.addSubview(emptyCartLabel)
        emptyCartView.addSubview(emptyCartSubtitleLabel)
        emptyCartView.addSubview(browseButton)
        
        // Main cart view
        view.addSubview(tableView)
        view.addSubview(summaryView)
        
        // Summary view contents
        summaryView.addSubview(totalItemsLabel)
        summaryView.addSubview(subtotalLabel)
        summaryView.addSubview(totalLabel)
        summaryView.addSubview(checkoutButton)
        
        NSLayoutConstraint.activate([
            // Empty cart view
            emptyCartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            emptyCartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            emptyCartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyCartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emptyCartImageView.centerXAnchor.constraint(equalTo: emptyCartView.centerXAnchor),
            emptyCartImageView.centerYAnchor.constraint(equalTo: emptyCartView.centerYAnchor, constant: -50),
            emptyCartImageView.widthAnchor.constraint(equalToConstant: 100),
            emptyCartImageView.heightAnchor.constraint(equalToConstant: 100),
            
            emptyCartLabel.topAnchor.constraint(equalTo: emptyCartImageView.bottomAnchor, constant: 20),
            emptyCartLabel.centerXAnchor.constraint(equalTo: emptyCartView.centerXAnchor),
            emptyCartLabel.leadingAnchor.constraint(equalTo: emptyCartView.leadingAnchor),
            emptyCartLabel.trailingAnchor.constraint(equalTo: emptyCartView.trailingAnchor),
            
            emptyCartSubtitleLabel.topAnchor.constraint(equalTo: emptyCartLabel.bottomAnchor, constant: 10),
            emptyCartSubtitleLabel.centerXAnchor.constraint(equalTo: emptyCartView.centerXAnchor),
            emptyCartSubtitleLabel.leadingAnchor.constraint(equalTo: emptyCartView.leadingAnchor, constant: 20),
            emptyCartSubtitleLabel.trailingAnchor.constraint(equalTo: emptyCartView.trailingAnchor, constant: -20),
            
            browseButton.topAnchor.constraint(equalTo: emptyCartSubtitleLabel.bottomAnchor, constant: 30),
            browseButton.centerXAnchor.constraint(equalTo: emptyCartView.centerXAnchor),
            browseButton.widthAnchor.constraint(equalToConstant: 160),
            browseButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Table view
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: summaryView.topAnchor, constant: -10),
            
            // Summary view
            summaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            summaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            summaryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Summary view contents
            totalItemsLabel.topAnchor.constraint(equalTo: summaryView.topAnchor, constant: 15),
            totalItemsLabel.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: 20),
            totalItemsLabel.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor, constant: -20),
            
            subtotalLabel.topAnchor.constraint(equalTo: totalItemsLabel.bottomAnchor, constant: 5),
            subtotalLabel.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: 20),
            subtotalLabel.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor, constant: -20),
            
            totalLabel.topAnchor.constraint(equalTo: subtotalLabel.bottomAnchor, constant: 10),
            totalLabel.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: 20),
            totalLabel.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor, constant: -20),
            
            checkoutButton.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 15),
            checkoutButton.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: 20),
            checkoutButton.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor, constant: -20),
            checkoutButton.heightAnchor.constraint(equalToConstant: 50),
            checkoutButton.bottomAnchor.constraint(equalTo: summaryView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func fetchCartItems() {
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(message: "You must be logged in to view your cart")
            return
        }
        
        activityIndicator.startAnimating()
        cartItems.removeAll()
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("cart").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(message: "Error retrieving cart items: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                self.updateUI()
                return
            }
            
            for document in documents {
                let data = document.data()
                
                guard let type = data["type"] as? String,
                      let name = data["name"] as? String,
                      let price = data["price"] as? Double else {
                    continue
                }
                
                let requiresPrescription = (data["requiresPrescription"] as? Bool) ?? false
                
                self.cartItems.append((
                    id: document.documentID,
                    type: type,
                    name: name,
                    price: price,
                    requiresPrescription: requiresPrescription
                ))
            }
            
            self.calculateTotal()
            self.updateUI()
        }
    }
    
    private func calculateTotal() {
        totalPrice = cartItems.reduce(0) { $0 + $1.price }
    }
    
    private func updateUI() {
        // Toggle visibility of empty cart or items view
        emptyCartView.isHidden = !cartItems.isEmpty
        tableView.isHidden = cartItems.isEmpty
        summaryView.isHidden = cartItems.isEmpty
        
        tableView.reloadData()
        
        // Update summary labels
        let itemCount = cartItems.count
        totalItemsLabel.text = "\(itemCount) \(itemCount == 1 ? "item" : "items")"
        
        // Format currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        let subtotalString = formatter.string(from: NSNumber(value: totalPrice)) ?? "$0.00"
        let totalString = formatter.string(from: NSNumber(value: totalPrice)) ?? "$0.00"
        
        subtotalLabel.text = "Subtotal: \(subtotalString)"
        totalLabel.text = "Total: \(totalString)"
    }
    
    private func removeFromCart(at indexPath: IndexPath) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let item = cartItems[indexPath.row]
        let db = Firestore.firestore()
        let cartRef = db.collection("users").document(userId).collection("cart").document(item.id)
        
        activityIndicator.startAnimating()
        
        cartRef.delete { [weak self] error in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(message: "Error removing item: \(error.localizedDescription)")
                return
            }
            
            self.cartItems.remove(at: indexPath.row)
            self.calculateTotal()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.updateUI()
        }
    }
    
    @objc private func browseTapped() {
        tabBarController?.selectedIndex = 0 // Switch to Home tab
    }
    
    @objc private func checkoutTapped() {
        guard !cartItems.isEmpty else { return }
        
        let prescriptionRequired = cartItems.contains { $0.requiresPrescription }
        
        if prescriptionRequired {
            showPrescriptionRequiredAlert()
        } else {
            proceedToCheckout()
        }
    }
    
    private func showPrescriptionRequiredAlert() {
        let alert = UIAlertController(
            title: "Prescription Required",
            message: "Some items in your cart require a valid prescription. Do you want to upload a prescription?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Upload Prescription", style: .default) { [weak self] _ in
            self?.uploadPrescription()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func uploadPrescription() {
        // Simplified prescription upload - in a real app, this would use document picker or camera
        let alert = UIAlertController(
            title: "Upload Prescription",
            message: "Enter your prescription ID:",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Prescription ID"
            textField.keyboardType = .default
        }
        
        alert.addAction(UIAlertAction(title: "Submit", style: .default) { [weak self, weak alert] _ in
            guard let prescriptionId = alert?.textFields?.first?.text, !prescriptionId.isEmpty else {
                self?.showAlert(message: "Please enter a valid prescription ID")
                return
            }
            
            self?.verifyPrescription(prescriptionId)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func verifyPrescription(_ prescriptionId: String) {
        // Simulated prescription verification
        activityIndicator.startAnimating()
        
        // Simulate network delay for prescription verification
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.activityIndicator.stopAnimating()
            
            // For demonstration, we'll accept any non-empty ID
            if !prescriptionId.isEmpty {
                self?.proceedToCheckout(withPrescription: prescriptionId)
            } else {
                self?.showAlert(message: "Invalid prescription ID")
            }
        }
    }
    
    private func proceedToCheckout(withPrescription prescriptionId: String? = nil) {
        // In a real app, this would navigate to a checkout screen
        let alert = UIAlertController(
            title: "Proceeding to Checkout",
            message: "Total amount: ₹\(String(format: "%.2f", totalPrice))",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Confirm Order", style: .default) { [weak self] _ in
            self?.placeOrder(withPrescription: prescriptionId)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func placeOrder(withPrescription prescriptionId: String? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(message: "You must be logged in to place an order")
            return
        }
        
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        
        // Create order object
        let orderItems = cartItems.map { ["id": $0.id, "type": $0.type, "name": $0.name, "price": $0.price] }
        var orderData: [String: Any] = [
            "userId": userId,
            "orderDate": Timestamp(date: Date()),
            "items": orderItems,
            "totalAmount": totalPrice,
            "status": "processing"
        ]
        
        if let prescriptionId = prescriptionId {
            orderData["prescriptionId"] = prescriptionId
        }
        
        // Add order to Firestore
        db.collection("orders").addDocument(data: orderData) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.activityIndicator.stopAnimating()
                self.showAlert(message: "Error placing order: \(error.localizedDescription)")
                return
            }
            
            // Clear cart after successful order placement
            self.clearCart(userId: userId)
        }
    }
    
    private func clearCart(userId: String) {
        let db = Firestore.firestore()
        let batch = db.batch()
        
        // Remove each item from the cart
        for item in cartItems {
            let cartItemRef = db.collection("users").document(userId).collection("cart").document(item.id)
            batch.deleteDocument(cartItemRef)
        }
        
        // Execute the batch delete
        batch.commit { [weak self] error in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(message: "Error clearing cart: \(error.localizedDescription)")
                return
            }
            
            // Show success message
            self.showAlert(
                message: "Order placed successfully! You'll receive a confirmation shortly.",
                isSuccess: true
            ) {
                self.cartItems.removeAll()
                self.updateUI()
            }
        }
    }
    
    // MARK: - UITableViewDataSource & UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as? CartItemCell else {
            return UITableViewCell()
        }
        
        let item = cartItems[indexPath.row]
        cell.configure(
            name: item.name,
            type: item.type,
            price: item.price,
            requiresPrescription: item.requiresPrescription
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeFromCart(at: indexPath)
        }
    }
    
    private func showAlert(message: String, isSuccess: Bool = false, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: isSuccess ? "Success" : "Alert",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - Cart Item Cell
class CartItemCell: UITableViewCell {
    
    private let itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let prescriptionBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .systemOrange
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let prescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Rx"
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(itemImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(typeLabel)
        contentView.addSubview(priceLabel)
        
        prescriptionBadge.addSubview(prescriptionLabel)
        contentView.addSubview(prescriptionBadge)
        
        NSLayoutConstraint.activate([
            itemImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            itemImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            itemImageView.widthAnchor.constraint(equalToConstant: 60),
            itemImageView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            nameLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -10),
            
            typeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            typeLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 15),
            typeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            priceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            prescriptionBadge.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 5),
            prescriptionBadge.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor, constant: 15),
            prescriptionBadge.widthAnchor.constraint(equalToConstant: 26),
            prescriptionBadge.heightAnchor.constraint(equalToConstant: 18),
            
            prescriptionLabel.centerXAnchor.constraint(equalTo: prescriptionBadge.centerXAnchor),
            prescriptionLabel.centerYAnchor.constraint(equalTo: prescriptionBadge.centerYAnchor)
        ])
    }
    
    func configure(name: String, type: String, price: Double, requiresPrescription: Bool) {
        nameLabel.text = name
        
        if type == "medicine" {
            typeLabel.text = "Medicine"
            itemImageView.image = UIImage(systemName: "pills")
            itemImageView.tintColor = .systemBlue
        } else if type == "labTest" {
            typeLabel.text = "Lab Test"
            itemImageView.image = UIImage(systemName: "cross.case")
            itemImageView.tintColor = .systemGreen
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")  // Indian Rupee
        priceLabel.text = formatter.string(from: NSNumber(value: price))
        
        prescriptionBadge.isHidden = !requiresPrescription
    }
}
