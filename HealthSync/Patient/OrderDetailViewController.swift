//
//  OrderDetailViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  OrderDetailViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseFirestore
import MapKit

class OrderDetailViewController: UIViewController {
    
    private let order: Order
    
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
    
    private let orderIdLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let itemsHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Items"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let itemsTableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let totalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let deliveryAddressHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Delivery Address"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let deliveryAddressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.layer.cornerRadius = 10
        mapView.clipsToBounds = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel Order", for: .normal)
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelOrderTapped), for: .touchUpInside)
        return button
    }()
    
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    init(order: Order) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Order Details"
        
        setupTableView()
        setupViews()
        configureOrderDetails()
    }
    
    private func setupTableView() {
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
        itemsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ItemCell")
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(orderIdLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(itemsHeaderLabel)
        contentView.addSubview(itemsTableView)
        contentView.addSubview(totalPriceLabel)
        
        if let deliveryAddress = order.deliveryAddress {
            contentView.addSubview(deliveryAddressHeaderLabel)
            contentView.addSubview(deliveryAddressLabel)
            contentView.addSubview(mapView)
        }
        
        if order.status == .processing {
            contentView.addSubview(cancelButton)
        }
        
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
            
            orderIdLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            orderIdLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            orderIdLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: orderIdLabel.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            itemsHeaderLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            itemsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            itemsHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            itemsTableView.topAnchor.constraint(equalTo: itemsHeaderLabel.bottomAnchor, constant: 10),
            itemsTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            itemsTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            totalPriceLabel.topAnchor.constraint(equalTo: itemsTableView.bottomAnchor, constant: 20),
            totalPriceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // Set the TableView height dynamically based on content
        tableViewHeightConstraint = itemsTableView.heightAnchor.constraint(equalToConstant: CGFloat(order.items.count * 44))
        tableViewHeightConstraint?.isActive = true
        
        if let deliveryAddress = order.deliveryAddress {
            NSLayoutConstraint.activate([
                deliveryAddressHeaderLabel.topAnchor.constraint(equalTo: totalPriceLabel.bottomAnchor, constant: 20),
                deliveryAddressHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                deliveryAddressHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                
                deliveryAddressLabel.topAnchor.constraint(equalTo: deliveryAddressHeaderLabel.bottomAnchor, constant: 10),
                deliveryAddressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                deliveryAddressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                
                mapView.topAnchor.constraint(equalTo: deliveryAddressLabel.bottomAnchor, constant: 20),
                mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                mapView.heightAnchor.constraint(equalToConstant: 200)
            ])
            
            if order.status == .processing {
                NSLayoutConstraint.activate([
                    cancelButton.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 30),
                    cancelButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                    cancelButton.widthAnchor.constraint(equalToConstant: 200),
                    cancelButton.heightAnchor.constraint(equalToConstant: 50),
                    cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
                ])
            } else {
                NSLayoutConstraint.activate([
                    mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
                ])
            }
        } else {
            if order.status == .processing {
                NSLayoutConstraint.activate([
                    cancelButton.topAnchor.constraint(equalTo: totalPriceLabel.bottomAnchor, constant: 30),
                    cancelButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                    cancelButton.widthAnchor.constraint(equalToConstant: 200),
                    cancelButton.heightAnchor.constraint(equalToConstant: 50),
                    cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
                ])
            } else {
                NSLayoutConstraint.activate([
                    totalPriceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
                ])
            }
        }
    }
    
    private func configureOrderDetails() {
        orderIdLabel.text = "Order #\(order.id)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        dateLabel.text = "Placed on: \(dateFormatter.string(from: order.orderDate))"
        
        switch order.status {
        case .processing:
            statusLabel.text = "Status: Processing"
            statusLabel.textColor = .systemOrange
        case .shipped:
            statusLabel.text = "Status: Shipped"
            statusLabel.textColor = .systemBlue
        case .delivered:
            statusLabel.text = "Status: Delivered"
            statusLabel.textColor = .systemGreen
        case .cancelled:
            statusLabel.text = "Status: Cancelled"
            statusLabel.textColor = .systemRed
        }
        
        totalPriceLabel.text = "Total: ₹\(order.totalAmount)"
        
        if let deliveryAddress = order.deliveryAddress {
            deliveryAddressLabel.text = deliveryAddress
            
            // In a real app, we would geocode the address to get coordinates
            // For this example, we're just using a static location
            let coordinate = CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707)  // Example: Chennai coordinates
            let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Delivery Location"
            mapView.addAnnotation(annotation)
        }
    }
    
    @objc private func cancelOrderTapped() {
        let alert = UIAlertController(title: "Cancel Order", message: "Are you sure you want to cancel this order?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.cancelOrder()
        })
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func cancelOrder() {
        let db = Firestore.firestore()
        db.collection("orders").document(order.id).updateData([
            "status": OrderStatus.cancelled.rawValue
        ]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(message: "Error cancelling order: \(error.localizedDescription)")
                return
            }
            
            self.showAlert(message: "Order cancelled successfully", isSuccess: true) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func showAlert(message: String, isSuccess: Bool = false, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: isSuccess ? "Success" : "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - TableView Delegate & Data Source
extension OrderDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        cell.textLabel?.text = order.items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}