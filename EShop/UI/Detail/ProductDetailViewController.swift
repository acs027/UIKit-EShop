//
//  ProductDetailViewController.swift
//  EShop
//
//  Created by ali cihan on 27.04.2025.
//
import UIKit
import Combine
import FirebaseAuth

class ProductDetailViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: ProductDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let productInfoView = ProductInfoView()
    private let reviewButton = UIButton(type: .system)
    private let bottomBarView = BottomView()

    // MARK: - Lifecycle
    init(viewModel: ProductDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ürün Detayı"
        view.backgroundColor = .white
        setupViews()
        setupBindings()
        setupNavBar()
        configureWithProduct()
    }

    // MARK: - Setup Views
    private func setupViews() {
        [scrollView, bottomBarView].forEach(view.addSubview(_:))
        setupConstraints()
        setupContent()
        setupBottomBar()
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(bottomBarView.snp.top)
        }

        bottomBarView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
    }

    private func setupContent() {
        setupProductInfoView()
        setupReviewButton()
    }

    private func setupProductInfoView() {
        scrollView.addSubview(productInfoView)
        productInfoView.showReviewSheet = { [weak self] in
            self?.presentReviewsList()
        }
        productInfoView.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.top)
            $0.centerX.equalTo(scrollView)
        }
    }

    private func setupReviewButton() {
        scrollView.addSubview(reviewButton)
        reviewButton.applyFilledStyle(title: "Ürüne Yorum Yap", backgroundColor: .systemOrange)
        reviewButton.addTarget(self, action: #selector(reviewProductTapped), for: .touchUpInside)
        reviewButton.isHidden = !viewModel.isUserLoggedIn
        reviewButton.snp.makeConstraints {
            $0.top.equalTo(productInfoView.snp.bottom).offset(24)
            $0.centerX.equalTo(scrollView)
            $0.width.equalTo(scrollView).multipliedBy(0.8)
            $0.height.equalTo(50)
            $0.bottom.equalTo(scrollView).offset(-24)
        }
    }

    private func setupBottomBar() {
        bottomBarView.quantityValueChanged = { [weak self] newQuantity in
            self?.viewModel.quantity = newQuantity
        }
        bottomBarView.addToCartButtonTapped = { [weak self] in
            self?.addToCartTapped()
        }
    }

    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "cart.fill"),
            style: .plain,
            target: self,
            action: #selector(cartButtonTapped)
        )
    }

    // MARK: - Data Configuration
    private func configureWithProduct() {
        productInfoView.configure(
            brand: viewModel.product.brand,
            productName: viewModel.product.name,
            price: "₺\(viewModel.product.price.formatPrice())",
            productImageURL: viewModel.productImageURL,
            rating: viewModel.averageRatingStars(),
            reviewCount: "\(viewModel.reviews.count)"
        )
        bottomBarView.configure(totalPrice: viewModel.totalPriceText)
    }

    // MARK: - Bindings
    private func setupBindings() {
        viewModel.fetchReviews()

        viewModel.$reviews
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateReviewUI()
            }
            .store(in: &cancellables)

        viewModel.$quantity
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.bottomBarView.configure(totalPrice: self?.viewModel.totalPriceText ?? "")
            }
            .store(in: &cancellables)
    }

    private func updateReviewUI() {
        productInfoView.updateRating(
            rating: viewModel.averageRatingStars(),
            reviewCount: "\(viewModel.reviews.count)"
        )
    }

    // MARK: - Actions
    @objc private func addToCartTapped() {
        viewModel.addToCart()
        animateAddToCart()
    }

    @objc private func cartButtonTapped() {
        viewModel.didTapCart()
    }

    @objc private func reviewProductTapped() {
        presentReviewSheet()
    }
}

extension ProductDetailViewController {
    private func presentReviewSheet() {
        let reviewVC = ReviewViewController()
        reviewVC.modalPresentationStyle = .pageSheet
        reviewVC.sheetPresentationController?.detents = [.medium()]
        
        reviewVC.onSubmit = { [weak self, weak reviewVC] rating, text in
            guard let self = self else { return }
            self.viewModel.writeReview(rating: rating, text: text)
            reviewVC?.dismiss(animated: true) {
                self.showReviewSubmittedAlert()
            }
        }
        present(reviewVC, animated: true)
    }

    private func presentReviewsList() {
        let sheetVC = ReviewListViewController(reviews: viewModel.reviews)
        sheetVC.modalPresentationStyle = .pageSheet
        sheetVC.sheetPresentationController?.detents = [.medium(), .large()]
        present(sheetVC, animated: true)
    }

    private func showReviewSubmittedAlert() {
        let alert = UIAlertController(title: "Teşekkürler", message: "Yorumun alındı.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}



extension ProductDetailViewController {
    private func animateAddToCart() {
        guard let cartView = navigationItem.rightBarButtonItem?.value(forKey: "view") as? UIView,
              let superview = cartView.superview else { return }

        let boxImageView = UIImageView(image: UIImage(systemName: "shippingbox.fill"))
        boxImageView.tintColor = .systemOrange
        boxImageView.contentMode = .scaleAspectFit
        boxImageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)

        let startPoint = bottomBarView.superview?.convert(bottomBarView.center, to: view) ?? .zero
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



