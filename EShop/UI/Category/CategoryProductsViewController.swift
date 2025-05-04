//
//  CategoryProductsViewController.swift
//  EShop
//
//  Created by ali cihan on 30.04.2025.
//


import UIKit
import SnapKit
import Combine

class CategoryProductsViewController: UIViewController {
    private let viewModel: CategoryProductsViewModel
    private var cancellables = Set<AnyCancellable>()
    
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
    
    init(viewModel: CategoryProductsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.category.rawValue
        view.backgroundColor = .white
        setupCollectionView()
        setupCartButton()
        viewModel.fetchReviews()
        reviewBinding()
    }
    
    private func reviewBinding() {
        viewModel.$reviews
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        // Use SnapKit to set constraints
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20)
            make.left.equalTo(view).offset(8)
            make.right.equalTo(view).offset(-8)
            make.bottom.equalTo(view)
        }
        
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: "ProductCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func setupCartButton() {
        let cartImage = UIImage(systemName: "cart.fill") 
        let cartButton = UIBarButtonItem(image: cartImage,
                                         style: .plain,
                                         target: self,
                                         action: #selector(cartButtonTapped))
        navigationItem.rightBarButtonItem = cartButton
    }

    @objc private func cartButtonTapped() {
        viewModel.didTapCart()
    }
}

extension CategoryProductsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let product = viewModel.products[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        cell.configure(with: product, ratingLabelText: viewModel.averageRatingStars(productName: product.name))
        cell.addToCartTapped = { [weak self] productName in
            self?.addToCart(productName: productName, from: cell)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = viewModel.products[indexPath.item]
        viewModel.didSelectProduct(product)
    }
    
    private func addToCart(productName: String, from: UICollectionViewCell) {
        viewModel.addToCart(productName: productName)
        animateAddToCart(from: from)
    }
}

extension CategoryProductsViewController {
    private func animateAddToCart(from cell: UICollectionViewCell) {
        guard let cartView = navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView,
              let superview = cartView.superview else { return }

        let boxImageView = UIImageView(image: UIImage(systemName: "shippingbox.fill"))
        boxImageView.tintColor = .systemOrange
        boxImageView.contentMode = .scaleAspectFit
        boxImageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)

        let startPoint = cell.superview?.convert(cell.center, to: view) ?? .zero
        let targetPoint = superview.convert(cartView.center, to: view)

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
