//
//  DoctorProfileViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DoctorProfileViewController: UIViewController {
    
    private let doctor: Doctor
    private var isEditingProfile = false  // Renamed from isEditing to avoid conflicts
    
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
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let specializationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Email:"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let licenseTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "License Number:"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let licenseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let availabilityTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Availability:"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let availabilityTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isEnabled = false
        return textField
    }()
    
    private let registrationDateTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Registration Date:"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let registrationDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rating:"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let patientsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Patients:"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let patientsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    init(doctor: Doctor) {
        self.doctor = doctor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Profile"
        
        setupViews()
        setupActivityIndicator()
        configureDoctorDetails()
        setupTapGesture()
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(specializationLabel)
        
        contentView.addSubview(emailTitleLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(licenseTitleLabel)
        contentView.addSubview(licenseLabel)
        contentView.addSubview(availabilityTitleLabel)
        contentView.addSubview(availabilityTextField)
        contentView.addSubview(registrationDateTitleLabel)
        contentView.addSubview(registrationDateLabel)
        contentView.addSubview(ratingTitleLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(patientsTitleLabel)
        contentView.addSubview(patientsLabel)
        
        contentView.addSubview(editButton)
        
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
            
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            specializationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            specializationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            specializationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            emailTitleLabel.topAnchor.constraint(equalTo: specializationLabel.bottomAnchor, constant: 30),
            emailTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTitleLabel.widthAnchor.constraint(equalToConstant: 120),
            
            emailLabel.centerYAnchor.constraint(equalTo: emailTitleLabel.centerYAnchor),
            emailLabel.leadingAnchor.constraint(equalTo: emailTitleLabel.trailingAnchor, constant: 10),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            licenseTitleLabel.topAnchor.constraint(equalTo: emailTitleLabel.bottomAnchor, constant: 20),
            licenseTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            licenseTitleLabel.widthAnchor.constraint(equalToConstant: 120),
            
            licenseLabel.centerYAnchor.constraint(equalTo: licenseTitleLabel.centerYAnchor),
            licenseLabel.leadingAnchor.constraint(equalTo: licenseTitleLabel.trailingAnchor, constant: 10),
            licenseLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            availabilityTitleLabel.topAnchor.constraint(equalTo: licenseTitleLabel.bottomAnchor, constant: 20),
            availabilityTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            availabilityTitleLabel.widthAnchor.constraint(equalToConstant: 120),
            
            availabilityTextField.centerYAnchor.constraint(equalTo: availabilityTitleLabel.centerYAnchor),
            availabilityTextField.leadingAnchor.constraint(equalTo: availabilityTitleLabel.trailingAnchor, constant: 10),
            availabilityTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            registrationDateTitleLabel.topAnchor.constraint(equalTo: availabilityTitleLabel.bottomAnchor, constant: 20),
            registrationDateTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            registrationDateTitleLabel.widthAnchor.constraint(equalToConstant: 140),
            
            registrationDateLabel.centerYAnchor.constraint(equalTo: registrationDateTitleLabel.centerYAnchor),
            registrationDateLabel.leadingAnchor.constraint(equalTo: registrationDateTitleLabel.trailingAnchor, constant: 10),
            registrationDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            ratingTitleLabel.topAnchor.constraint(equalTo: registrationDateTitleLabel.bottomAnchor, constant: 20),
            ratingTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ratingTitleLabel.widthAnchor.constraint(equalToConstant: 120),
            
            ratingLabel.centerYAnchor.constraint(equalTo: ratingTitleLabel.centerYAnchor),
            ratingLabel.leadingAnchor.constraint(equalTo: ratingTitleLabel.trailingAnchor, constant: 10),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            patientsTitleLabel.topAnchor.constraint(equalTo: ratingTitleLabel.bottomAnchor, constant: 20),
            patientsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            patientsTitleLabel.widthAnchor.constraint(equalToConstant: 120),
            
            patientsLabel.centerYAnchor.constraint(equalTo: patientsTitleLabel.centerYAnchor),
            patientsLabel.leadingAnchor.constraint(equalTo: patientsTitleLabel.trailingAnchor, constant: 10),
            patientsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            editButton.topAnchor.constraint(equalTo: patientsTitleLabel.bottomAnchor, constant: 40),
            editButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 200),
            editButton.heightAnchor.constraint(equalToConstant: 50),
            editButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
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
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func configureDoctorDetails() {
        nameLabel.text = "Dr. \(doctor.name)"
        specializationLabel.text = doctor.specialization
        emailLabel.text = doctor.email
        licenseLabel.text = doctor.license
        availabilityTextField.text = doctor.availability
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        registrationDateLabel.text = dateFormatter.string(from: doctor.registrationDate)
        
        // Format rating with stars
        let fullStars = Int(doctor.avgRating)
        let hasHalfStar = doctor.avgRating.truncatingRemainder(dividingBy: 1) >= 0.5
        
        var ratingStars = String(repeating: "★", count: fullStars)
        
        if hasHalfStar {
            ratingStars += "½"
        }
        
        let emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0)
        ratingStars += String(repeating: "☆", count: emptyStars)
        
        ratingLabel.text = "\(ratingStars) (\(doctor.avgRating)/5)"
        patientsLabel.text = "\(doctor.totalPatients)"
    }
    
    @objc private func editButtonTapped() {
        if isEditingProfile {  // Changed from isEditing to isEditingProfile
            // Save changes
            saveChanges()
        } else {
            // Enter edit mode
            isEditingProfile = true  // Changed from isEditing to isEditingProfile
            availabilityTextField.isEnabled = true
            availabilityTextField.becomeFirstResponder()
            editButton.setTitle("Save Changes", for: .normal)
            editButton.backgroundColor = .systemGreen
        }
    }
    
    private func saveChanges() {
        guard let availability = availabilityTextField.text, !availability.isEmpty else {
            showAlert(message: "Please enter your availability")
            return
        }
        
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("doctors").document(doctor.id).updateData([
            "availability": availability
        ]) { [weak self] error in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(message: "Error updating profile: \(error.localizedDescription)")
                return
            }
            
            self.isEditingProfile = false  // Changed from isEditing to isEditingProfile
            self.availabilityTextField.isEnabled = false
            self.editButton.setTitle("Edit Profile", for: .normal)
            self.editButton.backgroundColor = .systemBlue
            self.showAlert(message: "Profile updated successfully", isSuccess: true)
        }
    }
    
    private func showAlert(message: String, isSuccess: Bool = false) {
        let alert = UIAlertController(title: isSuccess ? "Success" : "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
