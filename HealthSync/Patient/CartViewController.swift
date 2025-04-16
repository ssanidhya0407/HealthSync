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
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(CartItemCell.self, forCellReuseIdentifier: "CartItemCell")
        tableView.backgroundColor = .systemGroupedBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "cart.badge.minus")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemIndigo
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 80)
        return imageView
    }()
    
    private let emptyStateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your cart is empty"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Looks like you haven't added any medicines or lab tests to your cart yet"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let browseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Browse Items", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        // Create a filled button appearance
        let buttonConfig = UIButton.Configuration.filled()
        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        var config = buttonConfig
        config.cornerStyle = .large
        config.attributedTitle = AttributedString("Browse Items", attributes: container)
        config.baseBackgroundColor = .systemIndigo
        config.baseForegroundColor = .white
        config.buttonSize = .large
        
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(browseTapped), for: .touchUpInside)
        return button
    }()
    
    private let summaryCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Subtle shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 0.07
        view.layer.masksToBounds = false
        
        return view
    }()
    
    private let summaryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let totalItemsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let totalItemsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalItemsValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtotalView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let subtotalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.text = "Subtotal"
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtotalValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let totalView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.text = "Total"
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkoutButton: UIButton = {
        let button = UIButton(type: .system)
        
        // Create a filled button appearance with SF Symbol
        let buttonConfig = UIButton.Configuration.filled()
        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        var config = buttonConfig
        config.cornerStyle = .large
        config.attributedTitle = AttributedString("Checkout", attributes: container)
        config.baseBackgroundColor = .systemGreen
        config.baseForegroundColor = .white
        config.buttonSize = .large
        
        // Add trailing SF Symbol
        config.image = UIImage(systemName: "arrow.right")
        config.imagePlacement = .trailing
        config.imagePadding = 8
        
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .systemIndigo
        return indicator
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupTableView()
        setupComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCartItems()
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        view.backgroundColor = .systemGroupedBackground
        title = "Cart"
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add edit button if needed
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearAllTapped)
        )
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupComponents() {
        // Setup Empty State View
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateTitleLabel)
        emptyStateView.addSubview(emptyStateDescriptionLabel)
        emptyStateView.addSubview(browseButton)
        
        // Setup Summary Card
        view.addSubview(summaryCard)
        summaryCard.addSubview(summaryStackView)
        
        // Setup Total Items View
        totalItemsView.addSubview(totalItemsLabel)
        totalItemsView.addSubview(totalItemsValueLabel)
        
        // Setup Subtotal View
        subtotalView.addSubview(subtotalLabel)
        subtotalView.addSubview(subtotalValueLabel)
        
        // Setup Total View
        totalView.addSubview(totalLabel)
        totalView.addSubview(totalValueLabel)
        
        // Add components to stack view
        summaryStackView.addArrangedSubview(totalItemsView)
        summaryStackView.addArrangedSubview(subtotalView)
        summaryStackView.addArrangedSubview(dividerView)
        summaryStackView.addArrangedSubview(totalView)
        summaryStackView.addArrangedSubview(checkoutButton)
        
        // Setup Activity Indicator
        view.addSubview(activityIndicator)
        
        // Empty State View Constraints
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor, constant: 30),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 120),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 120),
            
            emptyStateTitleLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 24),
            emptyStateTitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 20),
            emptyStateTitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -20),
            
            emptyStateDescriptionLabel.topAnchor.constraint(equalTo: emptyStateTitleLabel.bottomAnchor, constant: 8),
            emptyStateDescriptionLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 20),
            emptyStateDescriptionLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -20),
            
            browseButton.topAnchor.constraint(equalTo: emptyStateDescriptionLabel.bottomAnchor, constant: 30),
            browseButton.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            browseButton.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 30),
            browseButton.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -30),
            browseButton.heightAnchor.constraint(equalToConstant: 50),
            browseButton.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor, constant: -30)
        ])
        
        // Summary Card Constraints
        NSLayoutConstraint.activate([
            summaryCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            summaryCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            summaryCard.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            summaryStackView.topAnchor.constraint(equalTo: summaryCard.topAnchor, constant: 20),
            summaryStackView.leadingAnchor.constraint(equalTo: summaryCard.leadingAnchor, constant: 20),
            summaryStackView.trailingAnchor.constraint(equalTo: summaryCard.trailingAnchor, constant: -20),
            summaryStackView.bottomAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: -20),
            
            // Total Items View
            totalItemsLabel.leadingAnchor.constraint(equalTo: totalItemsView.leadingAnchor),
            totalItemsLabel.topAnchor.constraint(equalTo: totalItemsView.topAnchor),
            totalItemsLabel.bottomAnchor.constraint(equalTo: totalItemsView.bottomAnchor),
            
            totalItemsValueLabel.trailingAnchor.constraint(equalTo: totalItemsView.trailingAnchor),
            totalItemsValueLabel.topAnchor.constraint(equalTo: totalItemsView.topAnchor),
            totalItemsValueLabel.bottomAnchor.constraint(equalTo: totalItemsView.bottomAnchor),
            totalItemsValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: totalItemsLabel.trailingAnchor, constant: 10),
            totalItemsView.heightAnchor.constraint(equalToConstant: 24),
            
            // Subtotal View
            subtotalLabel.leadingAnchor.constraint(equalTo: subtotalView.leadingAnchor),
            subtotalLabel.topAnchor.constraint(equalTo: subtotalView.topAnchor),
            subtotalLabel.bottomAnchor.constraint(equalTo: subtotalView.bottomAnchor),
            
            subtotalValueLabel.trailingAnchor.constraint(equalTo: subtotalView.trailingAnchor),
            subtotalValueLabel.topAnchor.constraint(equalTo: subtotalView.topAnchor),
            subtotalValueLabel.bottomAnchor.constraint(equalTo: subtotalView.bottomAnchor),
            subtotalValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: subtotalLabel.trailingAnchor, constant: 10),
            subtotalView.heightAnchor.constraint(equalToConstant: 24),
            
            // Divider View
            dividerView.heightAnchor.constraint(equalToConstant: 1),
            
            // Total View
            totalLabel.leadingAnchor.constraint(equalTo: totalView.leadingAnchor),
            totalLabel.topAnchor.constraint(equalTo: totalView.topAnchor),
            totalLabel.bottomAnchor.constraint(equalTo: totalView.bottomAnchor),
            
            totalValueLabel.trailingAnchor.constraint(equalTo: totalView.trailingAnchor),
            totalValueLabel.topAnchor.constraint(equalTo: totalView.topAnchor),
            totalValueLabel.bottomAnchor.constraint(equalTo: totalView.bottomAnchor),
            totalValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: totalLabel.trailingAnchor, constant: 10),
            totalView.heightAnchor.constraint(equalToConstant: 30),
            
            // Checkout Button
            checkoutButton.heightAnchor.constraint(equalToConstant: 54),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Data Methods
    
    private func fetchCartItems() {
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(title: "Sign In Required", message: "Please sign in to view your cart")
            return
        }
        
        activityIndicator.startAnimating()
        cartItems.removeAll()
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("cart").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(title: "Error", message: "Unable to retrieve cart items: \(error.localizedDescription)")
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
        // Update visibility
        let isEmpty = cartItems.isEmpty
        emptyStateView.isHidden = !isEmpty
        summaryCard.isHidden = isEmpty
        
        // Adjust table view insets when summary card is visible
        if !isEmpty {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: summaryCard.frame.height + 30, right: 0)
        } else {
            tableView.contentInset = .zero
        }
        
        tableView.reloadData()
        
        // Update summary labels
        let itemCount = cartItems.count
        totalItemsLabel.text = "Items"
        totalItemsValueLabel.text = "\(itemCount) \(itemCount == 1 ? "item" : "items")"
        
        // Format currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")  // Indian Rupee
        
        let subtotalString = formatter.string(from: NSNumber(value: totalPrice)) ?? "₹0.00"
        let totalString = formatter.string(from: NSNumber(value: totalPrice)) ?? "₹0.00"
        
        subtotalValueLabel.text = subtotalString
        totalValueLabel.text = totalString
        
        // Disable checkout button if cart is empty
        checkoutButton.isEnabled = !isEmpty
        
        // Update navigation item
        navigationItem.rightBarButtonItem?.isEnabled = !isEmpty
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
                self.showAlert(title: "Error", message: "Unable to remove item: \(error.localizedDescription)")
                return
            }
            
            // Show feedback using haptics
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Remove item and update UI
            self.cartItems.remove(at: indexPath.row)
            self.calculateTotal()
            
            // Use animation to remove the row
            self.tableView.performBatchUpdates({
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }, completion: { _ in
                self.updateUI()
            })
        }
    }
    
    // MARK: - Action Methods
    
    @objc private func browseTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        tabBarController?.selectedIndex = 0 // Switch to Home tab
    }
    
    @objc private func clearAllTapped() {
        guard !cartItems.isEmpty else { return }
        
        let alert = UIAlertController(
            title: "Clear Cart",
            message: "Are you sure you want to remove all items from your cart?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear All", style: .destructive) { [weak self] _ in
            self?.clearCart()
        })
        
        present(alert, animated: true)
    }
    
    private func clearCart() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        // Add all items to a batch delete
        for item in cartItems {
            let docRef = db.collection("users").document(userId).collection("cart").document(item.id)
            batch.deleteDocument(docRef)
        }
        
        batch.commit { [weak self] error in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to clear cart: \(error.localizedDescription)")
                return
            }
            
            // Show feedback using haptics
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Update data and UI
            self.cartItems.removeAll()
            self.totalPrice = 0
            self.updateUI()
        }
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
            message: "Some items in your cart require a valid prescription. Would you like to upload a prescription now?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Upload Prescription", style: .default) { [weak self] _ in
            self?.uploadPrescription()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func uploadPrescription() {
        // In a real app, this would use document picker or camera
        let alert = UIAlertController(
            title: "Upload Prescription",
            message: "Please enter your prescription ID or upload a photo of your prescription",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Prescription ID"
            textField.keyboardType = .default
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Submit", style: .default) { [weak self, weak alert] _ in
            guard let prescriptionId = alert?.textFields?.first?.text, !prescriptionId.isEmpty else {
                self?.showAlert(title: "Invalid Input", message: "Please enter a valid prescription ID")
                return
            }
            
            self?.verifyPrescription(prescriptionId)
        })
        
        alert.addAction(UIAlertAction(title: "Upload Photo", style: .default) { [weak self] _ in
            // In a real app, this would open a camera or photo picker
            self?.simulatePrescriptionPhotoUpload()
        })
        
        present(alert, animated: true)
    }
    
    private func simulatePrescriptionPhotoUpload() {
        // Simulate the photo upload process
        activityIndicator.startAnimating()
        
        // Simulate processing time
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.activityIndicator.stopAnimating()
            // Generate a random prescription ID for demonstration
            let randomId = "RX" + String(Int.random(in: 10000...99999))
            self?.verifyPrescription(randomId)
        }
    }
    
    private func verifyPrescription(_ prescriptionId: String) {
        // Simulate prescription verification
        activityIndicator.startAnimating()
        
        // Simulate network delay for prescription verification
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.activityIndicator.stopAnimating()
            
            // For demonstration, accept any non-empty ID
            if !prescriptionId.isEmpty {
                self?.proceedToCheckout(withPrescription: prescriptionId)
            } else {
                self?.showAlert(title: "Verification Failed", message: "The prescription ID you entered is invalid")
            }
        }
    }
    
    private func proceedToCheckout(withPrescription prescriptionId: String? = nil) {
        // Create a custom checkout sheet
        let checkoutSheet = UIAlertController(
            title: "Checkout",
            message: "Please confirm your order details",
            preferredStyle: .actionSheet
        )
        
        // Format the total price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        let totalFormatted = formatter.string(from: NSNumber(value: totalPrice)) ?? "₹0.00"
        
        // Add details to the sheet
        let detailsAction = UIAlertAction(title: "Total: \(totalFormatted)", style: .default) { _ in }
        detailsAction.isEnabled = false
        checkoutSheet.addAction(detailsAction)
        
        if let prescriptionId = prescriptionId {
            let prescriptionAction = UIAlertAction(title: "Prescription ID: \(prescriptionId)", style: .default) { _ in }
            prescriptionAction.isEnabled = false
            checkoutSheet.addAction(prescriptionAction)
        }
        
        checkoutSheet.addAction(UIAlertAction(title: "Confirm Order", style: .default) { [weak self] _ in
            self?.placeOrder(withPrescription: prescriptionId)
        })
        
        checkoutSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
        if let popoverController = checkoutSheet.popoverPresentationController {
            popoverController.sourceView = checkoutButton
            popoverController.sourceRect = checkoutButton.bounds
        }
        
        present(checkoutSheet, animated: true)
    }
    
    private func placeOrder(withPrescription prescriptionId: String? = nil) {
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(title: "Sign In Required", message: "Please sign in to place an order")
            return
        }
        
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        
        // Create order object
        let orderItems = cartItems.map { [
            "id": $0.id,
            "type": $0.type,
            "name": $0.name,
            "price": $0.price,
            "requiresPrescription": $0.requiresPrescription
        ] }
        
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
                            self.showAlert(title: "Order Failed", message: "Unable to place order: \(error.localizedDescription)")
                            return
                        }
                        
                        // Clear cart after successful order placement
                        self.clearCartAfterOrder(userId: userId)
                    }
                }
                
                private func clearCartAfterOrder(userId: String) {
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
                            self.showAlert(title: "Error", message: "Order placed but unable to clear cart: \(error.localizedDescription)")
                            return
                        }
                        
                        // Show success animation and message
                        self.showOrderSuccessAnimation()
                    }
                }
                
                private func showOrderSuccessAnimation() {
                    // Create and configure success animation view
                    let successView = UIView()
                    successView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                    successView.translatesAutoresizingMaskIntoConstraints = false
                    successView.alpha = 0
                    successView.layer.cornerRadius = 20
                    
                    let checkmarkImage = UIImageView()
                    checkmarkImage.image = UIImage(systemName: "checkmark.circle.fill")
                    checkmarkImage.contentMode = .scaleAspectFit
                    checkmarkImage.tintColor = .white
                    checkmarkImage.translatesAutoresizingMaskIntoConstraints = false
                    checkmarkImage.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 60)
                    
                    let successLabel = UILabel()
                    successLabel.text = "Order Placed!"
                    successLabel.textAlignment = .center
                    successLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
                    successLabel.textColor = .white
                    successLabel.translatesAutoresizingMaskIntoConstraints = false
                    
                    // Add to view hierarchy
                    view.addSubview(successView)
                    successView.addSubview(checkmarkImage)
                    successView.addSubview(successLabel)
                    
                    // Setup constraints
                    NSLayoutConstraint.activate([
                        successView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                        successView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                        successView.widthAnchor.constraint(equalToConstant: 220),
                        successView.heightAnchor.constraint(equalToConstant: 180),
                        
                        checkmarkImage.centerXAnchor.constraint(equalTo: successView.centerXAnchor),
                        checkmarkImage.topAnchor.constraint(equalTo: successView.topAnchor, constant: 30),
                        checkmarkImage.widthAnchor.constraint(equalToConstant: 70),
                        checkmarkImage.heightAnchor.constraint(equalToConstant: 70),
                        
                        successLabel.centerXAnchor.constraint(equalTo: successView.centerXAnchor),
                        successLabel.topAnchor.constraint(equalTo: checkmarkImage.bottomAnchor, constant: 20),
                        successLabel.leadingAnchor.constraint(equalTo: successView.leadingAnchor, constant: 10),
                        successLabel.trailingAnchor.constraint(equalTo: successView.trailingAnchor, constant: -10)
                    ])
                    
                    // Trigger haptic feedback
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    // Animate success view
                    UIView.animate(withDuration: 0.3, animations: {
                        successView.alpha = 1
                    }, completion: { _ in
                        // Wait and then fade out
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            UIView.animate(withDuration: 0.3, animations: {
                                successView.alpha = 0
                            }, completion: { _ in
                                successView.removeFromSuperview()
                                
                                // Clear cart items array and update UI
                                self.cartItems.removeAll()
                                self.totalPrice = 0
                                self.updateUI()
                                
                                // Show confirmation alert
                                self.showAlert(
                                    title: "Order Confirmed",
                                    message: "Your order has been placed successfully! You'll receive a confirmation shortly.",
                                    isSuccess: true
                                )
                            })
                        }
                    })
                }
                
                // MARK: - UITableViewDataSource & UITableViewDelegate
                
                func numberOfSections(in tableView: UITableView) -> Int {
                    return 1
                }
                
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
                    return 110
                }
                
                func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
                    let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] (_, _, completion) in
                        self?.removeFromCart(at: indexPath)
                        completion(true)
                    }
                    
                    deleteAction.image = UIImage(systemName: "trash")
                    deleteAction.backgroundColor = .systemRed
                    
                    let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
                    configuration.performsFirstActionWithFullSwipe = true
                    return configuration
                }
                
                // MARK: - Utility Methods
                
                private func showAlert(title: String, message: String, isSuccess: Bool = false, completion: (() -> Void)? = nil) {
                    let alert = UIAlertController(
                        title: title,
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
                
                private let containerView: UIView = {
                    let view = UIView()
                    view.backgroundColor = .systemBackground
                    view.layer.cornerRadius = 12
                    view.layer.shadowColor = UIColor.black.cgColor
                    view.layer.shadowOffset = CGSize(width: 0, height: 1)
                    view.layer.shadowRadius = 3
                    view.layer.shadowOpacity = 0.1
                    view.translatesAutoresizingMaskIntoConstraints = false
                    return view
                }()
                
                private let itemImageContainer: UIView = {
                    let view = UIView()
                    view.backgroundColor = .secondarySystemBackground
                    view.layer.cornerRadius = 10
                    view.translatesAutoresizingMaskIntoConstraints = false
                    return view
                }()
                
                private let itemImageView: UIImageView = {
                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFit
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    return imageView
                }()
                
                private let nameLabel: UILabel = {
                    let label = UILabel()
                    label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                    label.numberOfLines = 2
                    label.translatesAutoresizingMaskIntoConstraints = false
                    return label
                }()
                
                private let typeLabel: UILabel = {
                    let label = UILabel()
                    label.font = UIFont.systemFont(ofSize: 14)
                    label.textColor = .secondaryLabel
                    label.translatesAutoresizingMaskIntoConstraints = false
                    return label
                }()
                
                private let priceLabel: UILabel = {
                    let label = UILabel()
                    label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                    label.textColor = .systemGreen
                    label.translatesAutoresizingMaskIntoConstraints = false
                    return label
                }()
                
                private let prescriptionBadge: UIView = {
                    let view = UIView()
                    view.backgroundColor = .systemOrange
                    view.layer.cornerRadius = 8
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.isHidden = true
                    return view
                }()
                
                private let prescriptionLabel: UILabel = {
                    let label = UILabel()
                    label.text = "Rx Required"
                    label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
                    label.textColor = .white
                    label.translatesAutoresizingMaskIntoConstraints = false
                    return label
                }()
                
                private let prescriptionIcon: UIImageView = {
                    let imageView = UIImageView()
                    imageView.image = UIImage(systemName: "doc.text")
                    imageView.contentMode = .scaleAspectFit
                    imageView.tintColor = .white
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    return imageView
                }()
                
                override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                    super.init(style: style, reuseIdentifier: reuseIdentifier)
                    setupCell()
                }
                
                required init?(coder: NSCoder) {
                    fatalError("init(coder:) has not been implemented")
                }
                
                override func layoutSubviews() {
                    super.layoutSubviews()
                    // Add some spacing between cells
                    contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
                }
                
                private func setupCell() {
                    backgroundColor = .clear
                    selectionStyle = .none
                    
                    contentView.addSubview(containerView)
                    
                    containerView.addSubview(itemImageContainer)
                    itemImageContainer.addSubview(itemImageView)
                    
                    containerView.addSubview(nameLabel)
                    containerView.addSubview(typeLabel)
                    containerView.addSubview(priceLabel)
                    
                    prescriptionBadge.addSubview(prescriptionIcon)
                    prescriptionBadge.addSubview(prescriptionLabel)
                    containerView.addSubview(prescriptionBadge)
                    
                    NSLayoutConstraint.activate([
                        // Container view
                        containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
                        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                        
                        // Image container
                        itemImageContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
                        itemImageContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                        itemImageContainer.widthAnchor.constraint(equalToConstant: 60),
                        itemImageContainer.heightAnchor.constraint(equalToConstant: 60),
                        
                        // Image view
                        itemImageView.centerXAnchor.constraint(equalTo: itemImageContainer.centerXAnchor),
                        itemImageView.centerYAnchor.constraint(equalTo: itemImageContainer.centerYAnchor),
                        itemImageView.widthAnchor.constraint(equalToConstant: 36),
                        itemImageView.heightAnchor.constraint(equalToConstant: 36),
                        
                        // Name label
                        nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
                        nameLabel.leadingAnchor.constraint(equalTo: itemImageContainer.trailingAnchor, constant: 15),
                        nameLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor, constant: -15),
                        
                        // Type label
                        typeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
                        typeLabel.leadingAnchor.constraint(equalTo: itemImageContainer.trailingAnchor, constant: 15),
                        typeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
                        
                        // Price label
                        priceLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                        priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
                        priceLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
                        
                        // Prescription badge
                        prescriptionBadge.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 8),
                        prescriptionBadge.leadingAnchor.constraint(equalTo: itemImageContainer.trailingAnchor, constant: 15),
                        prescriptionBadge.heightAnchor.constraint(equalToConstant: 24),
                        prescriptionBadge.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -15),
                        
                        // Prescription icon
                        prescriptionIcon.leadingAnchor.constraint(equalTo: prescriptionBadge.leadingAnchor, constant: 6),
                        prescriptionIcon.centerYAnchor.constraint(equalTo: prescriptionBadge.centerYAnchor),
                        prescriptionIcon.widthAnchor.constraint(equalToConstant: 12),
                        prescriptionIcon.heightAnchor.constraint(equalToConstant: 12),
                        
                        // Prescription label
                        prescriptionLabel.leadingAnchor.constraint(equalTo: prescriptionIcon.trailingAnchor, constant: 4),
                        prescriptionLabel.trailingAnchor.constraint(equalTo: prescriptionBadge.trailingAnchor, constant: -6),
                        prescriptionLabel.centerYAnchor.constraint(equalTo: prescriptionBadge.centerYAnchor)
                    ])
                }
                
                func configure(name: String, type: String, price: Double, requiresPrescription: Bool) {
                    nameLabel.text = name
                    
                    // Configure image and type label based on item type
                    if type == "medicine" {
                        typeLabel.text = "Medicine"
                        itemImageView.image = UIImage(systemName: "pill")
                        itemImageView.tintColor = .systemIndigo
                        itemImageContainer.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.1)
                    } else if type == "labTest" {
                        typeLabel.text = "Lab Test"
                        itemImageView.image = UIImage(systemName: "cross.case.fill")
                        itemImageView.tintColor = .systemGreen
                        itemImageContainer.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
                    }
                    
                    // Format currency with Indian Rupee
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    formatter.locale = Locale(identifier: "en_IN")
                    priceLabel.text = formatter.string(from: NSNumber(value: price))
                    
                    // Show prescription badge if required
                    prescriptionBadge.isHidden = !requiresPrescription
                }
                
                override func prepareForReuse() {
                    super.prepareForReuse()
                    nameLabel.text = nil
                    typeLabel.text = nil
                    priceLabel.text = nil
                    itemImageView.image = nil
                    prescriptionBadge.isHidden = true
                }
            }
