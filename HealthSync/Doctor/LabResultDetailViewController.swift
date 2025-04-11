//
//  LabResultDetailViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  LabResultDetailViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseFirestore

class LabResultDetailViewController: UIViewController {
    
    private let labResult: LabTestResult
    
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
    
    private let testNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let patientNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let resultsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Results:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let resultsTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let markAsCompletedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Mark as Completed", for: .normal)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(markAsCompletedTapped), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    init(labResult: LabTestResult) {
        self.labResult = labResult
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Lab Result Details"
        
        setupViews()
        setupActivityIndicator()
        configureLabResultDetails()
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(testNameLabel)
        contentView.addSubview(patientNameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(resultsTitleLabel)
        contentView.addSubview(resultsTextView)
        
        // Only show the complete button for pending results
        if labResult.status == .pending {
            contentView.addSubview(markAsCompletedButton)
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
            
            testNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            testNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            patientNameLabel.topAnchor.constraint(equalTo: testNameLabel.bottomAnchor, constant: 10),
            patientNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            patientNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: patientNameLabel.bottomAnchor, constant: 10),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            resultsTitleLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            resultsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            resultsTextView.topAnchor.constraint(equalTo: resultsTitleLabel.bottomAnchor, constant: 10),
            resultsTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            resultsTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            resultsTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150)
        ])
        
        if labResult.status == .pending {
            NSLayoutConstraint.activate([
                markAsCompletedButton.topAnchor.constraint(equalTo: resultsTextView.bottomAnchor, constant: 30),
                markAsCompletedButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                markAsCompletedButton.widthAnchor.constraint(equalToConstant: 200),
                markAsCompletedButton.heightAnchor.constraint(equalToConstant: 50),
                markAsCompletedButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
            ])
        } else {
            NSLayoutConstraint.activate([
                resultsTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
            ])
        }
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
    
    private func configureLabResultDetails() {
        testNameLabel.text = labResult.labTest.name
        patientNameLabel.text = "Patient: \(labResult.patientName)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        dateLabel.text = "Test Date: \(dateFormatter.string(from: labResult.testDate))"
        
        switch labResult.status {
        case .pending:
            statusLabel.text = "Status: Pending"
            statusLabel.textColor = .systemOrange
        case .completed:
            statusLabel.text = "Status: Completed"
            statusLabel.textColor = .systemGreen
        }
        
        resultsTextView.text = labResult.results
    }
    
    @objc private func markAsCompletedTapped() {
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("labResults").document(labResult.id).updateData([
            "status": LabResultStatus.completed.rawValue
        ]) { [weak self] error in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(message: "Error updating status: \(error.localizedDescription)")
                return
            }
            
            self.showAlert(message: "Lab result marked as completed", isSuccess: true) {
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