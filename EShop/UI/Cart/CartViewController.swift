//
//  CartViewController.swift
//  EShop
//
//  Created by ali cihan on 27.04.2025.
//
import UIKit
import Combine
import SnapKit

class CartViewController: UIViewController {
    private let viewModel: CartViewModel
    private let tableView = UITableView()
    private let totalLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let checkoutButton = UIButton(type: .system)
    private let footerView = UIView()
    
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: CartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sepetim"
        view.backgroundColor = .white
        setupTableView()
        setupFooter()
        setupActivityIndicator()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.fetchProductsInCart()
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.backButtonTitle = ""
        navigationItem.leftBarButtonItem = backButton
        footerView.isHidden = isCartEmpty()
    }
    
    @objc func backButtonTapped() {
        viewModel.backButtonTapped()
    }

    //MARK: Table View Setup
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CartItemCell.self, forCellReuseIdentifier: "CartItemCell")

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-60)
        }
    }
    
    //MARK: Total Label Setup
    private func setupFooter() {
        
        view.addSubview(footerView)

        footerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }

        totalLabel.font = .boldSystemFont(ofSize: 18)
        totalLabel.text = "₺0.00"

        checkoutButton.setTitle("Alışverişi Tamamla", for: .normal)
        checkoutButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        checkoutButton.backgroundColor = .systemBlue
        checkoutButton.tintColor = .white
        checkoutButton.layer.cornerRadius = 8
        checkoutButton.addTarget(self, action: #selector(checkoutButtonTapped), for: .touchUpInside)

        footerView.addSubview(totalLabel)
        footerView.addSubview(checkoutButton)

        totalLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        checkoutButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(200)
        }
    }

    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    //MARK: Binding
    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.tableView.isHidden = true
                    self?.totalLabel.isHidden = true
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.tableView.isHidden = false
                    self?.totalLabel.isHidden = false
                }
            }
            .store(in: &cancellables)
        
        viewModel.$cartProducts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateTotalLabel()
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func updateTotalLabel() {
        let total = viewModel.cartProducts.reduce(0) { result, product in
            result + (product.price * product.count)
        }
        debugPrint(total)
        if total == 0 {
            footerView.isHidden = true
        } else {
            footerView.isHidden = false
        }
        totalLabel.text = "₺"+total.formatPrice()
        viewModel.setUniqueProducts()
    }
    
    @objc private func checkoutButtonTapped() {
        viewModel.removeAll()
    }
    
    private func isCartEmpty() -> Bool {
        viewModel.cartProducts.isEmpty
    }
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.uniqueProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as? CartItemCell else {
            return UITableViewCell()
        }

        let productNames = Array(viewModel.uniqueProducts.keys).sorted()
        let productName = productNames[indexPath.row]
        let productCount = viewModel.uniqueProducts[productName] ?? 1

        let product = viewModel.cartProducts.first(where: { $0.name == productName })
        let urlString = "http://kasimadalan.pe.hu/urunler/resimler/" + product!.image
        let imageURL = URL(string: urlString) 
        let price = product!.price * productCount

        cell.configure(name: productName, count: productCount, price: Double(price), imageURL: imageURL)

        cell.onStepperValueChanged = { [weak self] newValue in
            self?.viewModel.updateProductQuantity(productName: productName, quantity: Int(newValue))
        }

        return cell
    }
}

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let productNames = Array(viewModel.uniqueProducts.keys).sorted()
            let productName = productNames[indexPath.row]
            viewModel.updateProductQuantity(productName: productName, quantity: 0)
        }
    }
}
