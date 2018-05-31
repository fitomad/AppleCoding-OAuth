//
//  TraktTVClient+Show.swift
//  CoreTraktTV
//
//  Created by Adolfo Vera Blasco on 28/5/18.
//  Copyright © 2018 desappstre {eStudio}. All rights reserved.
//

import Foundation

//
// Shows Operations
//

extension TraktTVClient
{
    /**

    */
    public func trendingShows(filteringBy filters: [FilterValue]? = nil, pagination: [FilterValue]? = nil, handler: @escaping TraktPaginatedCompletionHandler<TrendyShow>) -> Void
    {
        let trendingURL = "https://api.trakt.tv/shows/trending"

        guard let request = self.makeURLRequest(string: trendingURL, withFilters: filters, paginationOptions: pagination) else
        {
            handler(nil, nil, .preconditionFailed)
            return 
        }

        self.processRequest(request) { (result: HttpResult) -> Void in
            switch result
            {
                case .success(let data, let pagination):
                    if let shows = try? self.decoder.decode([TrendyShow].self, from: data)
                    {
                        handler(shows, pagination, nil)
                    }
                case .requestError(let code, let message):
                    #if targetEnvironment(simulator)
                        print(message)
                    #endif

                    let error = TraktError(httpCode: code)
                    handler(nil, nil, error)

                case .connectionError:
                    handler(nil, nil, TraktError.serverIsDown)
            }
        }
    }

    /**

    */
    public func popularShows(filteringBy filters: [FilterValue]? = nil, pagination: [FilterValue]? = nil, handler: @escaping TraktPaginatedCompletionHandler<Show>) -> Void
    {
        let trendingURL = "https://api.trakt.tv/shows/popular"

        guard let request = self.makeURLRequest(string: trendingURL, withFilters: filters, paginationOptions: pagination) else
        {
            handler(nil, nil, .preconditionFailed)
            return 
        }

        self.processRequest(request) { (result: HttpResult) -> Void in
            switch result
            {
            case .success(let data, let pagination):
                if let shows = try? self.decoder.decode([Show].self, from: data)
                {
                    handler(shows, pagination, nil)
                }
            case .requestError(let code, let message):
                #if targetEnvironment(simulator)
                    print(message)
                #endif
                
                let error = TraktError(httpCode: code)
                handler(nil, nil, error)

            case .connectionError:
                handler(nil, nil, TraktError.serverIsDown)
            }
        }
    }
}
