//
//  HomeViewController.swift
//  SRMHealthApp
//
//  Updated to include a personalized greeting for the logged-in user
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var userName: String? // To store the user's name

    // Data for the settings-like table view
    private let sections = [
        ("Health Services", [
            ("🧪 Lab Tests", UIColor.systemGreen, #selector(labTestsTapped)),
            ("💊 Buy Medicines", UIColor.systemBlue, #selector(medicinesTapped)),
            ("👨‍⚕️ Find Doctor", UIColor.systemOrange, #selector(findDocTapped)),
            ("📰 Health Articles", UIColor.systemPurple, #selector(healthArticlesTapped)),
        ]),
        ("Orders", [
            ("📦 Order Details", UIColor.systemRed, #selector(orderDetailsTapped)),
            ("🛒 Cart", UIColor.systemTeal, #selector(cartTapped)),
        ]),
        ("Account", [
            ("Profile", UIColor.systemBlue, #selector(profileTapped)),
            ("Logout", UIColor.systemRed, #selector(logoutTapped))
        ])
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        fetchUserName()
    }

    // MARK: - Setup Functions

    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Home"
        navigationItem.hidesBackButton = true
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func fetchUserName() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self, error == nil, let data = snapshot?.data() else { return }
            self.userName = data["name"] as? String
            self.title = "Hi, \(self.userName ?? "User")!" // Update the greeting
        }
    }

    // MARK: - UITableView DataSource & Delegate

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].1.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = sections[indexPath.section].1[indexPath.row]

        // Configure cell appearance
        cell.textLabel?.text = item.0
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.textColor = item.1
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selector = sections[indexPath.section].1[indexPath.row].2
        performSelector(onMainThread: selector, with: nil, waitUntilDone: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Button Actions

    @objc private func profileTapped() {
        let profileVC = ProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }

    @objc private func labTestsTapped() {
        let labTestsVC = LabTestsViewController()
        navigationController?.pushViewController(labTestsVC, animated: true)
    }

    @objc private func medicinesTapped() {
        let medicinesVC = MedicinesViewController()
        navigationController?.pushViewController(medicinesVC, animated: true)
    }

    @objc private func findDocTapped() {
        let doctorsVC = DoctorsViewController()
        navigationController?.pushViewController(doctorsVC, animated: true)
    }

    @objc private func healthArticlesTapped() {
        let healthArticlesVC = HealthArticlesViewController()
        navigationController?.pushViewController(healthArticlesVC, animated: true)
    }

    @objc private func orderDetailsTapped() {
        let orderDetailsVC = OrderDetailsViewController()
        navigationController?.pushViewController(orderDetailsVC, animated: true)
    }

    @objc private func cartTapped() {
        let cartVC = CartViewController()
        navigationController?.pushViewController(cartVC, animated: true)
    }

    @objc private func logoutTapped() {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            presentErrorAlert(message: "Error signing out. Please try again.")
        }
    }

    private func presentErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
