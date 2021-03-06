//
//  ForecastViewController.swift
//  BeyondViewControllers
//
//  Created by Joshua Sullivan on 11/19/16.
//  Copyright © 2016 Josh Sullivan. All rights reserved.
//

import UIKit

protocol ForecastViewControllerDataSource: class {
    /// This does not use a Result enum because the request cannot fail. (It has a sane default of "Unknown".
    func getLocation(completion: @escaping (String) -> Void)
    
    /// In a real app, this would be an API call, which can fail, so we use the Result type.
    func getForecast(completion: @escaping (Result<[ForecastDay], Error>) -> Void)
}

protocol ForecastViewControllerDelegate: class {
    /// Triggered when the user taps a day for more details.
    func forecastViewController(_ forecastViewController: ForecastViewController, detailsFor day: ForecastDay)
    
    /// Triggered when the user taps the help button.
    func forecastViewController(didTapHelp forecastViewController: ForecastViewController)
}

class ForecastViewController: UIViewController {
    
    /// Default cell size.
    private let cellSize = CGSize(width: 100.0, height: 150.0)
    
    /// 10pt between cells.
    private let minSpacing: CGFloat = 10.0
    
    weak var dataSource: ForecastViewControllerDataSource?
    weak var delegate: ForecastViewControllerDelegate?
    
    fileprivate var forecasts: [ForecastDay] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource?.getForecast(completion: {
            [weak self] result in
            guard let strongSelf = self else { return }
            guard case .success(let forecasts) = result else {
                return
            }
            strongSelf.forecasts = forecasts
            strongSelf.collectionView.reloadData()
        })
        
        dataSource?.getLocation {
            [weak self]
            location in
            guard let strongSelf = self else { return }
            strongSelf.navigationItem.title = location
        }
        
        self.navigationItem.title = "Forecast"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let screenWidth = UIScreen.main.bounds.width
        let availableWidth = screenWidth - minSpacing
        let columns = floor(availableWidth / (cellSize.width + minSpacing))
        let paddingSpace = screenWidth - (cellSize.width * columns)
        let padding = floor(paddingSpace / (columns + 1))
        let insetSpace = floor((paddingSpace - padding * columns) / 2.0)
        self.collectionView?.contentInset = UIEdgeInsets(top: insetSpace, left: insetSpace, bottom: insetSpace, right: insetSpace)
        if let flow = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.minimumInteritemSpacing = padding
            flow.minimumLineSpacing = padding
        }
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
    }

    @IBAction func helpTapped(_ sender: Any?) {
        delegate?.forecastViewController(didTapHelp: self)
    }
}

extension ForecastViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastCollectionViewCell.Identifier, for: indexPath)
        if let forecastCell = cell as? ForecastCollectionViewCell {
            let forecast = forecasts[indexPath.item]
            forecastCell.imageView?.image = UIImage(named: forecast.iconName)
            forecastCell.label?.text = forecast.conditions.displayable
            forecastCell.dateLabel?.text = forecastDateFormatter.string(from: forecast.date)
        }
        return cell
    }
}

extension ForecastViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let forecast = forecasts[indexPath.item]
        delegate?.forecastViewController(self, detailsFor: forecast)
    }
}
