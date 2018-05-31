//
//  SearchViewController.swift
//  AppleCoding OAuth
//
//  Created by Adolfo Vera Blasco on 28/5/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import UIKit
import Foundation
import SafariServices

import CoreTraktTV

internal class SearchViewController: UIViewController
{
    ///
    @IBOutlet private weak var collectionViewShows: UICollectionView!

    ///
    private var shows: [Show]?
    ///
    private var paginationDetails: Pagination?
    
    //
    // MARK: - Life Cycle
    //

    /**

    */
    override internal func viewDidLoad()
    {
        super.viewDidLoad()

        self.shows = [Show]()
        self.prepareCollectionView()
        
        self.loadShows()
    }
    
    /**
     
     */
    override internal func viewWillAppear(_ animated: Bool) -> Void
    {
        super.viewWillAppear(animated)
        
        self.applyTheme()
        self.localizeText()
    }
    
    //
    // MARK: - Prepare UI
    //
    
    /**
     
     */
    private func prepareCollectionView() -> Void
    {
        self.collectionViewShows.delegate = self
        self.collectionViewShows.dataSource = self
        self.collectionViewShows.prefetchDataSource = self
    }
    
    /**
     
     */
    private func applyTheme() -> Void
    {
        self.view.backgroundColor = Theme.current.backgroundColor
        self.collectionViewShows.backgroundColor = Theme.current.backgroundColor
    }
    
    /**
     
     */
    private func localizeText() -> Void
    {
        self.title = NSLocalizedString("SEARCH_TITLE", comment: "")
    }

    //
    // MARK: - Data
    //

    private func loadShows() -> Void
    {
        TraktTVClient.shared.trendingShows() { (trendyShows: [TrendyShow]?, pagination: Pagination?, error: TraktError?) -> Void in
            guard let trendyShows = trendyShows else
            {
                return
            }
            
            let shows = trendyShows.map({ $0.show })
            
            self.paginationDetails = pagination
            self.shows?.append(contentsOf: shows)
            
            DispatchQueue.main.async
            {
                self.collectionViewShows.reloadData()
            }
        }
    }
}


//
// MARK: - UICollectionViewDataSource Protocol
//

extension SearchViewController: UICollectionViewDataSource
{
    /**
     
     */
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    /**
     
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        guard let shows = self.shows else 
        {
            return 0
        }

        return shows.count
    }
    
    /**
     
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        guard let shows = self.shows, !shows.isEmpty else
        {
            return UICollectionViewCell()
        }

        guard let showCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowCell", for: indexPath) as? ShowCell else
        {
            fatalError("Unable to dequeue a TaskCell")
        }

        showCell.showInformation = shows[indexPath.item]
        showCell.delegate = self
        
        return showCell
    }
}

//
// MARK: - UICollectionViewDelegate Protocol
//

extension SearchViewController: UICollectionViewDelegate
{
    /**
     
     */
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) -> Void
    {
        cell.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        cell.alpha = 0.85
        
        let animator = UIViewPropertyAnimator(duration: 0.65, curve: .easeOut)
        
        animator.addAnimations()
        {
            cell.transform = CGAffineTransform.identity
            cell.alpha = 1.0
        }
        
        animator.startAnimation()
    }
}

//
// MARK: - UICollectionViewDataSourcePrefetching Protocol
//

extension SearchViewController: UICollectionViewDataSourcePrefetching
{
    /**
     
     */
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) -> Void
    {
        print("prefetch...")
    }
}

//
// MARK: - ShowCellDelegate Protocol
//

extension SearchViewController: ShowCellDelegate
{
    /**

    */
    func showCell(_ cell: ShowCell, didSelectShow trackID: Int) -> Void 
    {
        guard let show = self.shows?.filter({ $0.identifiers.trakt == trackID }).first else
        {
            return
        }
        
        TraktTVClient.shared.appendToWatchlist(show, handler: { (validOperation: Bool, error: TraktError?) -> Void in
            if validOperation
            {
                DispatchQueue.main.async
                {
                    cell.toogleButton(toStatus: ShowCell.Status.added)
                }
            }
            else if let error = error
            {
                if case .unauthorized = error
                {
                    // No estamos autorizados a acceder a los datos del usuarios
                    // Vamos a pedirle que nos autorize 
                    if let oauthURL = TraktTVClient.shared.authorizationURL()
                    {
                        let safariController = SFSafariViewController(url: oauthURL)
                        
                        DispatchQueue.main.async
                        {
                            self.present(safariController, animated: true, completion: nil)
                        }
                    }
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        cell.toogleButton(toStatus: ShowCell.Status.error)
                    }
                }
            }
        })
    }
}



