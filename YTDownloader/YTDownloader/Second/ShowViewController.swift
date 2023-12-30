//
//  SecondVC.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 27.11.2023.
//

import Foundation
import UIKit
import Photos

final class ShowViewController: UIViewController {

    // MARK: - Private properties
    private var viewModel: ShowViewModel

    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        collection.register(HeaderForShowVC.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderForShowVC.identifier)
        collection.register(CellForShowVC.self, forCellWithReuseIdentifier: CellForShowVC.identifier)
        collection.delegate = self
        collection.dataSource = self
        return collection
    }()


    // MARK: - Init
    init(viewModel: ShowViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        layout()
        viewModel.makeVideosArrForUI()
    }

    // MARK: - Private methods
    private func setupView() {
        view.addSubview(collectionView)
        view.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
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

// MARK: - UICollectionViewDataSource
extension ShowViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.videos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellForShowVC.identifier, for: indexPath) as? CellForShowVC else { return  UICollectionViewCell() }
        cell.configure(with: viewModel.videos[indexPath.item])

        cell.didTapDeleteClosure = { [weak self] in
            guard let strongSelf = self else {return} //гарантируем, что код кложуры выполнится, даже если мы быстро вышли с экрана (как пример)
            strongSelf.viewModel.didTapDeleteVideoAt(indexPath) {
                collectionView.reloadData()
            }
        }

        cell.didTapPlayClosure = { [weak self] in
            guard let self else {return}
            self.viewModel.didTapPlay(video: self.viewModel.videos[indexPath.item])
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(
                            ofKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: HeaderForShowVC.identifier,
                            for: indexPath)
            return header
        default:
            return UICollectionReusableView()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ShowViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: Constants.headerHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - Constants.insetForCell * 2
        let height = collectionView.bounds.width * 0.55
        return CGSize(width: width, height: height)
    }
    //отступы по периметру дисплея
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: Constants.insetForCell , left: Constants.insetForCell, bottom: Constants.headerHeight, right: Constants.insetForCell)
    }
    //spacing между рядами/строками для вертикальной коллекции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
       2
    }

}
