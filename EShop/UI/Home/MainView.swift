//
//  ViewController.swift
//  EShop
//
//  Created by ali cihan on 25.04.2025.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    private let viewModel: MainViewModel
    private let searchBar = UISearchBar()
    private let cartButton = UIButton()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var cancellables = Set<AnyCancellable>()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 8
        let itemWidth = (UIScreen.main.bounds.width - 32) / 2
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 50)

        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 40)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupActivityIndicator()
        bindViewModel()
        viewModel.fetchProducts()
        setupTableView()
        setupTopBar()
        navigationItem.backButtonTitle = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupTopBar() {
        let cartImage = UIImage(systemName: "cart.fill")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        )
        cartButton.setImage(cartImage, for: .normal)
        cartButton.imageView?.contentMode = .scaleAspectFit
        cartButton.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }
        cartButton.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)

        searchBar.placeholder = "Ürün, kategori veya marka ara"
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()

        let stackView = UIStackView(arrangedSubviews: [searchBar, cartButton])
        view.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center

        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(56)
        }
    }
    

    private func setupTableView() {
        view.addSubview(collectionView)
        collectionView.register(CategoryHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CategoryHeaderView.identifier)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(65)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().inset(8)
            make.bottom.equalToSuperview()
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
        collectionView.isHidden = true
    }

    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        activityIndicator.startAnimating()
    }

    private func bindViewModel() {
        viewModel.onProductsFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.collectionView.isHidden = false
                self?.collectionView.reloadData()
            }
        }

        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yeniden Dene", style: .default) { [weak self] _ in
                       self?.fetchProducts()
                   })
                self?.present(alert, animated: true)
            }
        }
        
        viewModel.$reviews
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func fetchProducts() {
        activityIndicator.startAnimating()
        viewModel.fetchProducts()
    }

    @objc private func cartButtonTapped() {
        viewModel.didTapCart()
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Category.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = Category.allCases[section]
        return viewModel.filteredProducts(for: category).count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = Category.allCases[indexPath.section]
        let product = viewModel.filteredProducts(for: category)[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        cell.configure(with: product, ratingLabelText: viewModel.averageRatingStars(productName: product.name))
        cell.addToCartTapped = { [weak self] productName in
            self?.addToCart(productName: productName, from: cell)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = Category.allCases[indexPath.section]
        let product = viewModel.filteredProducts(for: category)[indexPath.item]
        viewModel.didSelectProduct(product)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CategoryHeaderView.identifier,
            for: indexPath
        ) as! CategoryHeaderView

        let category = Category.allCases[indexPath.section]
        header.configure(with: category)
        header.delegate = self
        return header
    }

    private func addToCart(productName: String, from: UICollectionViewCell) {
        viewModel.addToCart(productName: productName)
        animateAddToCart(from: from)
    }

}

extension MainViewController: CategoryHeaderViewDelegate {
    func didTapSeeAll(for category: Category) {
        viewModel.didTapSeeAll(for: category)
    }
}

extension MainViewController {
    private func animateAddToCart(from cell: UICollectionViewCell) {
        
        let boxImageView = UIImageView(image: UIImage(systemName: "shippingbox.fill"))
        boxImageView.tintColor = .systemOrange
        boxImageView.contentMode = .scaleAspectFit
        boxImageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)

        let startPoint = cell.superview?.convert(cell.center, to: view) ?? .zero
        let targetPoint = cartButton.superview?.convert(cartButton.center, to: view) ?? .zero

        boxImageView.center = startPoint
        view.addSubview(boxImageView)

        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseInOut, animations: {
            boxImageView.center = targetPoint
            boxImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            boxImageView.alpha = 0.0
        }) { _ in
            boxImageView.removeFromSuperview()
        }
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        viewModel.didTapSearch()
    }
}

