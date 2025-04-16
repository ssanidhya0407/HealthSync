//
//  EditProfileViewController.swift
//  HealthSync
//
//  Created by Sanidhya's MacBook Pro on 13/04/25.
//


//
//  EditProfileViewController.swift
//  SRMHealthApp
//
//  Edit profile page with HIG-compliant design.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - UI Components

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Photo", for: .normal)
        button.tintColor = .systemBlue
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        return button
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your name"
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Changes", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveChangesTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        loadUserProfile()
    }

    // MARK: - Setup Functions

    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Edit Profile"

        view.addSubview(profileImageView)
        view.addSubview(changePhotoButton)
        view.addSubview(nameTextField)
        view.addSubview(saveButton)

        // Add tap gesture to profileImageView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped))
        profileImageView.addGestureRecognizer(tapGesture)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            changePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameTextField.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            saveButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Load User Profile

    private func loadUserProfile() {
        guard let user = Auth.auth().currentUser else { return }

        // Load current name
        Firestore.firestore().collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            guard let self = self, error == nil, let data = snapshot?.data() else { return }
            self.nameTextField.text = data["name"] as? String
        }

        // Load profile picture
        if let photoURL = user.photoURL {
            URLSession.shared.dataTask(with: photoURL) { data, _, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.profileImageView.image = UIImage(data: data)
                }
            }.resume()
        }
    }

    // MARK: - Actions

    @objc private func changePhotoTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }

    @objc private func saveChangesTapped() {
        guard let user = Auth.auth().currentUser,
              let newName = nameTextField.text, !newName.isEmpty else {
            presentErrorAlert(message: "Please enter your name.")
            return
        }

        // Save name to Firestore
        Firestore.firestore().collection("users").document(user.uid).updateData(["name": newName]) { [weak self] error in
            if let error = error {
                self?.presentErrorAlert(message: "Failed to update profile: \(error.localizedDescription)")
            } else {
                self?.presentSuccessAlert()
            }
        }

        // Save profile picture to Firebase Storage
        if let imageData = profileImageView.image?.jpegData(compressionQuality: 0.8) {
            let storageRef = Storage.storage().reference().child("profile_pictures/\(user.uid).jpg")
            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Failed to upload profile picture: \(error.localizedDescription)")
                } else {
                    storageRef.downloadURL { url, _ in
                        guard let url = url else { return }
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.photoURL = url
                        changeRequest.commitChanges { error in
                            if let error = error {
                                print("Failed to update photo URL: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - UIImagePickerController Delegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageView.image = selectedImage
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    // MARK: - Alerts

    private func presentErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func presentSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Your profile has been updated.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
