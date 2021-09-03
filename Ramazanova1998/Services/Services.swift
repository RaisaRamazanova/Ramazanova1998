//
//  Services.swift
//  Ramazanova1998
//
//  Created by Раисат Рамазанова on 31.08.2021.
//

import Foundation
import CoreLocation

protocol NetworkService {
    
    func getWeather(for city: String, completion: @escaping (Result<Weather, Error>) -> Void)
    
}

struct Service: NetworkService {

    private let sharedSession = URLSession.shared
    
    func getWeather(for city: String, completion: @escaping (Result<Weather, Error>) -> Void) {
        guard let request = getWeatherRequest(for: city) else {
            return
        }
        switch request {
        case .failure(let error):
            completion(.failure(error))
        case .success(let request):
            let dataTask = sharedSession.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("http status code: \(httpResponse.statusCode)")
                }
                
                guard let data = data else {
                    print("no data received")
                    completion(.failure(URLError(.dataNotAllowed)))
                    return
                }
                
                let decoder = JSONDecoder()
                if let weather = try? decoder.decode(Weather.self, from: data)   {
                    completion(.success(weather))
                }
            }
            dataTask.resume()
        }
    }
    
    private func getWeatherRequest(for city: String) -> Result<URLRequest, CLError>? {
        var locationCoordinate: Result<CLLocationCoordinate2D, CLError>?
        let group = DispatchGroup()
        group.enter()
        getCoordinatesOfCity(city) { result in
            switch result {
            case .success(let coordinate):
                locationCoordinate = .success(coordinate)
            case .failure(let error):
                print(type(of: self), #function, "\(error.localizedDescription)")
                locationCoordinate = .failure(error)
            }
            group.leave()
        }
        
        group.wait()
        guard let coordinate = locationCoordinate else { return nil }
        switch coordinate {
        case .failure(let error):
            return Result.failure(error)
        case .success(let coordinate):
            let urlComponents: URLComponents = {
                var urlComponents = URLComponents()
                urlComponents.scheme = "https"
                urlComponents.host = "api.weather.yandex.ru"
                urlComponents.path = "/v2/forecast"
                urlComponents.queryItems = [
                    URLQueryItem(name: "lat", value: "\(coordinate.latitude)"),
                    URLQueryItem(name: "lon", value: "\(coordinate.longitude)"),
                    URLQueryItem(name: "lang", value: "ru_RU")]
                return urlComponents
            }()
            
            guard let url = urlComponents.url else { return nil }
            var urlRequest = URLRequest(url: url)
            urlRequest.allHTTPHeaderFields = ["X-Yandex-API-Key": "f8515c29-9058-47a5-94b0-7d32a74aec46"]
            return Result.success(urlRequest)
        }
    }
    
    private func getCoordinatesOfCity(_ city: String, completion: @escaping (Result<CLLocationCoordinate2D, CLError>) -> Void) {
        CLGeocoder().geocodeAddressString(city) { (placemarks, error) in
            if let coordinates = placemarks?.first?.location?.coordinate {
                completion(.success(coordinates))
            } else if let error = error as? CLError {
                completion(.failure(error))
            }
        }
    }
}
