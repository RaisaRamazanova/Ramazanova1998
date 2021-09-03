//
//  CityModel.swift
//  Ramazanova1998
//
//  Created by Раисат Рамазанова on 03.09.2021.
//

import Foundation

protocol Cities {
    
    var list: [String] { get }
    var listWithWeather: [String: Weather] { get }
    var count: Int { get }
    mutating func add(city: String)
    mutating func removeCity(at index: Int)
    mutating func addWeatherFor(city: String, weather: Weather)
    
}

class CitiesJson: Cities {
    
    static var shared: Cities = CitiesJson()
    
    var list: [String] { return arrayOfCities }
    var listWithWeather: [String: Weather] { return  dictionaryOfCitiesWithWeather }
    var count: Int { return arrayOfCities.count }
    
    var arrayOfCities: [String] = [
        "Moscow",
        "Tokyo",
        "New-York",
        "Delhi",
        "Shanghai",
        "Sao Paulo",
        "Mexico City",
        "Beijing",
        "Mumbai",
        "Osaka"
    ]
    
    private var dictionaryOfCitiesWithWeather: [String: Weather] = [:]
    
    init() {}
    
    func add(city: String) {
        arrayOfCities.append(city.capitalized)
    }
    
    func removeCity(at index: Int) {
        arrayOfCities.remove(at: index)
    }
    
    func addWeatherFor(city: String, weather: Weather) {
        dictionaryOfCitiesWithWeather[city.capitalized] = weather
    }
}
