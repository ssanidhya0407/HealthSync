//
//  AppointmentDetailViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//

//
//  AppointmentDetailViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseFirestore

protocol AppointmentDetailViewControllerDelegate: AnyObject {
    func appointmentStatusDidUpdate()
}

class AppointmentDetailViewController: UIViewController {
    
    private let appointment: Appointment
    weak var delegate: AppointmentDetailViewControllerDelegate?
    
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
    
    private let patientNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let appointmentDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let reasonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reason:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let reasonLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Status:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let notesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Notes:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let notesTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm Appointment", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return button
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Mark as Completed", for: .normal)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel Appointment", for: .normal)
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()
    
    private let createPrescriptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Prescription", for: .normal)
        button.backgroundColor = .systemPurple
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createPrescriptionTapped), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    init(appointment: Appointment) {
        self.appointment = appointment
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Appointment Details"
        
        setupViews()
        setupActivityIndicator()
        configureAppointmentDetails()
        setupButtons()
        setupTapGesture()
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
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(patientNameLabel)
        contentView.addSubview(appointmentDateLabel)
        contentView.addSubview(reasonTitleLabel)
        contentView.addSubview(reasonLabel)
        contentView.addSubview(statusTitleLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(notesTitleLabel)
        contentView.addSubview(notesTextView)
        
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
            
            patientNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            patientNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            patientNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            appointmentDateLabel.topAnchor.constraint(equalTo: patientNameLabel.bottomAnchor, constant: 10),
            appointmentDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            appointmentDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            reasonTitleLabel.topAnchor.constraint(equalTo: appointmentDateLabel.bottomAnchor, constant: 20),
            reasonTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            reasonTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            reasonLabel.topAnchor.constraint(equalTo: reasonTitleLabel.bottomAnchor, constant: 10),
            reasonLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            reasonLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statusTitleLabel.topAnchor.constraint(equalTo: reasonLabel.bottomAnchor, constant: 20),
            statusTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: statusTitleLabel.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            notesTitleLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            notesTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notesTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            notesTextView.topAnchor.constraint(equalTo: notesTitleLabel.bottomAnchor, constant: 10),
            notesTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            notesTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            notesTextView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupButtons() {
        // Show different buttons depending on appointment status
        switch appointment.status {
        case .pending:
            // For pending appointments, show confirm and cancel buttons
            contentView.addSubview(confirmButton)
            contentView.addSubview(cancelButton)
            
            NSLayoutConstraint.activate([
                confirmButton.topAnchor.constraint(equalTo: notesTextView.bottomAnchor, constant: 30),
                confirmButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                confirmButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                confirmButton.heightAnchor.constraint(equalToConstant: 50),
                
                cancelButton.topAnchor.constraint(equalTo: confirmButton.bottomAnchor, constant: 20),
                cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                cancelButton.heightAnchor.constraint(equalToConstant: 50),
                cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
            ])
            
        case .confirmed:
            // For confirmed appointments, show complete and cancel buttons
            contentView.addSubview(completeButton)
            contentView.addSubview(cancelButton)
            
            NSLayoutConstraint.activate([
                completeButton.topAnchor.constraint(equalTo: notesTextView.bottomAnchor, constant: 30),
                completeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                completeButton.heightAnchor.constraint(equalToConstant: 50),
                
                cancelButton.topAnchor.constraint(equalTo: completeButton.bottomAnchor, constant: 20),
                cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                cancelButton.heightAnchor.constraint(equalToConstant: 50),
                cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
            ])
            
        case .completed:
            // For completed appointments, show create prescription button
            contentView.addSubview(createPrescriptionButton)
            
            NSLayoutConstraint.activate([
                createPrescriptionButton.topAnchor.constraint(equalTo: notesTextView.bottomAnchor, constant: 30),
                createPrescriptionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                createPrescriptionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                createPrescriptionButton.heightAnchor.constraint(equalToConstant: 50),
                createPrescriptionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
            ])
            
        case .cancelled:
            // For cancelled appointments, no buttons needed
            NSLayoutConstraint.activate([
                notesTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
            ])
        }
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func configureAppointmentDetails() {
        patientNameLabel.text = appointment.patientName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        appointmentDateLabel.text = dateFormatter.string(from: appointment.date)
        
        reasonLabel.text = appointment.reason
        
        switch appointment.status {
        case .pending:
            statusLabel.text = "Pending"
            statusLabel.textColor = .systemOrange
        case .confirmed:
            statusLabel.text = "Confirmed"
            statusLabel.textColor = .systemBlue
        case .completed:
            statusLabel.text = "Completed"
            statusLabel.textColor = .systemGreen
        case .cancelled:
            statusLabel.text = "Cancelled"
            statusLabel.textColor = .systemRed
        }
        
        notesTextView.text = appointment.notes ?? ""
    }
    
    @objc private func confirmTapped() {
        updateAppointmentStatus(.confirmed)
    }
    
    @objc private func completeTapped() {
        updateAppointmentStatus(.completed)
    }
    
    @objc private func cancelTapped() {
        let alert = UIAlertController(title: "Cancel Appointment", message: "Are you sure you want to cancel this appointment?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.updateAppointmentStatus(.cancelled)
        })
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func createPrescriptionTapped() {
        let newPrescriptionVC = NewPrescriptionViewController(patientId: appointment.patientId, patientName: appointment.patientName)
        navigationController?.pushViewController(newPrescriptionVC, animated: true)
    }
    
    private func updateAppointmentStatus(_ status: AppointmentStatus) {
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        
        var updatedData: [String: Any] = [
            "status": status.rawValue,
            "updatedAt": Timestamp(date: Date())
        ]
        
        // Save any notes the doctor has entered
        if let notes = notesTextView.text, !notes.isEmpty {
            updatedData["notes"] = notes
        }
        
        db.collection("appointments").document(appointment.id).updateData(updatedData) { [weak self] error in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(message: "Error updating appointment: \(error.localizedDescription)")
                return
            }
            
            self.showAlert(message: "Appointment status updated successfully") {
                self.delegate?.appointmentStatusDidUpdate()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
        
