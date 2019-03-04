/*
 * 下記のソースをお借りしています
 * https://qiita.com/mshrwtnb/items/48fec048f55ad87121a7
 */

import MapKit

struct Map {
    enum Result<T> {
        case success(T)
        case failure(Error)
    }

    static func search(query: String, region: MKCoordinateRegion? = nil, completionHandler: @escaping (Result<[MKMapItem]>) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        if let region = region {
            request.region = region
        }

        MKLocalSearch(request: request).start { (response, error) in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            completionHandler(.success(response?.mapItems ?? []))
        }
    }
}
