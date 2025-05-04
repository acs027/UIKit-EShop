//
//  SearchViewController.swift
//  EShop
//
//  Created by ali cihan on 4.05.2025.
//

import UIKit
import Combine
import SnapKit


class SearchViewController: UIViewController {
    private let viewModel: SearchViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let searchBar = UISearchBar()
    private let cartButton = UIButton()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 8
        let itemWidth = (UIScreen.main.bounds.width - 32) / 2
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 50)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
        viewModel.fetchReviews()
        reviewBinding()
        setupTopBar()
        filteredProductsBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: UI Setup
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
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(65)
            make.left.equalTo(view).offset(8)
            make.right.equalTo(view).offset(-8)
            make.bottom.equalTo(view)
        }
        
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    //MARK: Bindings
    private func reviewBinding() {
        viewModel.$reviews
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func filteredProductsBinding() {
        viewModel.$filteredProducts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    //MARK: Functions
    @objc private func cartButtonTapped() {
        viewModel.didTapCart()
    }
}

//MARK: Cell
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.filteredProducts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let product = viewModel.filteredProducts[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        cell.configure(with: product, ratingLabelText: viewModel.averageRatingStars(productName: product.name))
        cell.addToCartTapped = { [weak self] productName in
            self?.addToCart(productName: productName, from: cell)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = viewModel.filteredProducts[indexPath.item]
        viewModel.didSelectProduct(product)
    }
    
    private func addToCart(productName: String, from: UICollectionViewCell) {
        viewModel.addToCart(productName: productName)
        animateAddToCart(from: from)
    }
}

//MARK: Animation
extension SearchViewController {
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

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(query: searchText)
    }
}
