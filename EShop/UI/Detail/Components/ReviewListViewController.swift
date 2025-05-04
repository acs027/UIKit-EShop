//
//  ReviewListViewController.swift
//  EShop
//
//  Created by ali cihan on 1.05.2025.
//

import UIKit

final class ReviewListViewController: UIViewController {
    private let reviews: [Review]
    private let tableView = UITableView()

    init(reviews: [Review]) {
        self.reviews = reviews
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Reviews"
        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReviewCell")

        let headerLabel = UILabel()
        headerLabel.text = "Kullanıcı Yorumları"
        headerLabel.font = .boldSystemFont(ofSize: 24)
        headerLabel.textAlignment = .center
        headerLabel.numberOfLines = 0
        headerLabel.backgroundColor = .systemGroupedBackground
        headerLabel.layer.cornerRadius = 12
        headerLabel.layer.masksToBounds = true

        let headerContainer = UIView()
        headerContainer.addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        headerContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
        tableView.tableHeaderView = headerContainer
    }
}

extension ReviewListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let review = reviews[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath)
        
        cell.textLabel?.text = String(repeating: "⭐", count: review.rating)+" - \(review.text)"
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
