//
//  HealthArticlesViewController.swift
//  SRMHealthApp
//
//  Created by Sanidhya's MacBook Pro on 10/04/25.
//


//
//  HealthArticlesViewController.swift
//  SRMHealthApp
//
//  Created on 2025-04-10.
//

import UIKit
import FirebaseFirestore

class HealthArticlesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var articles = [HealthArticle]()
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    struct HealthArticle {
        let id: String
        let title: String
        let content: String
        let category: String
        let publishDate: Date
        let author: String?
        let imageUrl: URL?
        
        init?(document: DocumentSnapshot) {
            guard let data = document.data(),
                  let title = data["title"] as? String,
                  let content = data["content"] as? String,
                  let category = data["category"] as? String,
                  let publishDate = (data["publishDate"] as? Timestamp)?.dateValue() else {
                return nil
            }
            
            self.id = document.documentID
            self.title = title
            self.content = content
            self.category = category
            self.publishDate = publishDate
            self.author = data["author"] as? String
            if let imageUrlString = data["imageUrl"] as? String {
                self.imageUrl = URL(string: imageUrlString)
            } else {
                self.imageUrl = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Health Articles"
        view.backgroundColor = .white
        setupTableView()
        setupActivityIndicator()
        fetchHealthArticles()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ArticleCell.self, forCellReuseIdentifier: "ArticleCell")
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
    
    private func fetchHealthArticles() {
        activityIndicator.startAnimating()
        
        let db = Firestore.firestore()
        db.collection("healthArticles").order(by: "publishDate", descending: true).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                self.showAlert(message: "Error fetching health articles: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                self.showAlert(message: "No health articles available")
                return
            }
            
            self.articles = documents.compactMap { HealthArticle(document: $0) }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as? ArticleCell else {
            return UITableViewCell()
        }
        
        let article = articles[indexPath.row]
        cell.configure(with: article)
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = articles[indexPath.row]
        let detailVC = HealthArticleDetailViewController(article: article)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

class ArticleCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let categoryLabel = UILabel()
    private let dateLabel = UILabel()
    private let authorLabel = UILabel()
    private let articleImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.numberOfLines = 2
        categoryLabel.font = UIFont.systemFont(ofSize: 14)
        categoryLabel.textColor = .systemBlue
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .darkGray
        authorLabel.font = UIFont.systemFont(ofSize: 12)
        authorLabel.textColor = .darkGray
        
        articleImageView.contentMode = .scaleAspectFill
        articleImageView.clipsToBounds = true
        articleImageView.layer.cornerRadius = 8
        articleImageView.backgroundColor = .systemGray6
        
        contentView.addSubview(articleImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(authorLabel)
        
        articleImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            articleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            articleImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            articleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            articleImageView.widthAnchor.constraint(equalToConstant: 80),
            
            titleLabel.leadingAnchor.constraint(equalTo: articleImageView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            categoryLabel.leadingAnchor.constraint(equalTo: articleImageView.trailingAnchor, constant: 10),
            categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            dateLabel.leadingAnchor.constraint(equalTo: articleImageView.trailingAnchor, constant: 10),
            dateLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 5),
            
            authorLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 10),
            authorLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            authorLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func configure(with article: HealthArticlesViewController.HealthArticle) {
        titleLabel.text = article.title
        categoryLabel.text = article.category
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateLabel.text = dateFormatter.string(from: article.publishDate)
        
        authorLabel.text = article.author != nil ? "by \(article.author!)" : ""
        
        // In a real app, you'd use a proper image loading library like Kingfisher or SDWebImage
        if let imageUrl = article.imageUrl {
            // Simulate loading an image
            articleImageView.image = UIImage(systemName: "newspaper")
            URLSession.shared.dataTask(with: imageUrl) { [weak self] data, _, error in
                guard let self = self, let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.articleImageView.image = UIImage(data: data)
                }
            }.resume()
        } else {
            articleImageView.image = UIImage(systemName: "newspaper")
        }
    }
}