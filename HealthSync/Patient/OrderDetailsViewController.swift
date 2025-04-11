//
//  OrderDetailsViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  OrderDetailsViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class OrderDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var orders = [Order]()
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let noOrdersLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Orders"
        view.backgroundColor = .white
        setupNoOrdersLabel()
        setupTableView()
        setupActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchOrders()
    }
    
    private func setupNoOrdersLabel() {
        noOrdersLabel.text = "You don't have any orders yet."
        noOrdersLabel.textAlignment = .center
        noOrdersLabel.textColor = .darkGray
        noOrdersLabel.font = UIFont.systemFont(ofSize: 18)
        noOrdersLabel.isHidden = true
        noOrdersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(noOrdersLabel)
        
        NSLayoutConstraint.activate([
            noOrdersLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noOrdersLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noOrdersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            noOrdersLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OrderCell.self, forCellReuseIdentifier: "OrderCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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
    
    private func fetchOrders() {
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(message: "You must be logged in to view your orders")
            return
        }
        
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("orders")
            .whereField("userId", isEqualTo: currentUser.uid)
            .order(by: "orderDate", descending: true)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    self.showAlert(message: "Error fetching orders: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    self.noOrdersLabel.isHidden = false
                    return
                }
                
                self.noOrdersLabel.isHidden = true
                self.orders = documents.compactMap { document -> Order? in
                    return Order(document: document)
                }
                
                self.tableView.reloadData()
            }
    }
    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as? OrderCell else {
            return UITableViewCell()
        }
        
        let order = orders[indexPath.row]
        cell.configure(with: order)
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let order = orders[indexPath.row]
        let detailVC = OrderDetailViewController(order: order)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

class OrderCell: UITableViewCell {
    
    private let orderIdLabel = UILabel()
    private let dateLabel = UILabel()
    private let itemsLabel = UILabel()
    private let statusLabel = UILabel()
    private let priceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        orderIdLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = .darkGray
        itemsLabel.font = UIFont.systemFont(ofSize: 14)
        itemsLabel.numberOfLines = 2
        statusLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        priceLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        priceLabel.textColor = .systemGreen
        
        contentView.addSubview(orderIdLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(itemsLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(priceLabel)
        
        orderIdLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        itemsLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            orderIdLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            orderIdLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            orderIdLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: orderIdLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            itemsLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            itemsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            itemsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: itemsLabel.bottomAnchor, constant: 5),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            priceLabel.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            priceLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with order: Order) {
        orderIdLabel.text = "Order #\(order.id.prefix(8))"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateLabel.text = dateFormatter.string(from: order.orderDate)
        
        // Join items with commas for display
        itemsLabel.text = order.items.joined(separator: ", ")
        
        switch order.status {
        case .processing:
            statusLabel.text = "Processing"
            statusLabel.textColor = .systemOrange
        case .shipped:
            statusLabel.text = "Shipped"
            statusLabel.textColor = .systemBlue
        case .delivered:
            statusLabel.text = "Delivered"
            statusLabel.textColor = .systemGreen
        case .cancelled:
            statusLabel.text = "Cancelled"
            statusLabel.textColor = .systemRed
        }
        
        priceLabel.text = "₹\(order.totalAmount)"
    }
}