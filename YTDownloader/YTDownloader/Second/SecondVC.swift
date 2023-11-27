//
//  SecondVC.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 27.11.2023.
//

import Foundation
import UIKit

final class SecondVC: UIViewController {

    // MARK: - Private properties
    private var viewModel: SecondViewModel

    private lazy var inset: CGFloat = {
        return 2
    }()
    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: collectionView.bounds.width, height: 60)
        layout.itemSize = CGSize(width: collectionView.bounds.width, height: 128)
        layout.minimumLineSpacing = inset
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        collection.register(HeaderForSecondVC.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderForSecondVC.identifier)
        collection.register(CellForSecondVC.self, forCellWithReuseIdentifier: CellForSecondVC.identifier)

        collection.delegate = self
        collection.dataSource = self
        return collection
    }()


    // MARK: - Init
    init(viewModel: SecondViewModel) {
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        layout()
    }

    // MARK: - Private methods
    private func setupView() {
        view.addSubview(collectionView)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - Extensions
extension SecondVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.ytModel.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    }


}

extension SecondVC: UICollectionViewDelegate {

}
