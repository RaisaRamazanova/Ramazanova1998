//
//  DetailViewController.swift
//  Ramazanova1998
//
//  Created by Раисат Рамазанова on 03.09.2021.
//

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: - properties
    var callback: ((UIView, Weather) -> Void)?
    private var cities = CitiesJson.shared
    
    // Переменная, которая нужна для определения способа загрузки контроллера
    private var isLoadedFromSearchBar = false
    
    private lazy var cityNameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var conditionLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tempLabel: UILabel = {
        let label = UILabel()
        label.text = "?°"
        label.font = UIFont.systemFont(ofSize: 100)
        return label
    }()
    
    private lazy var tempFeelsLikeLabel: UILabel = {
        let label = UILabel()
        label.text = "Feels like ?℃"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private lazy var weatherConditionView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - init
    
    init(forCity: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.cityNameLabel.text = forCity.capitalized
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.setupUI(city: forCity.capitalized)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubviewsAndSetToAutoLayout()
        setupLayout()
    }
    
    // MARK: - function
    
    // добавляем Subviews в view
    private func addSubviewsAndSetToAutoLayout() {
        [cityNameLabel,
         conditionLabel,
         tempLabel,
         tempFeelsLikeLabel,
         weatherConditionView].forEach {
            view.addSubview($0)
            $0.toAutoLayout()
         }
    }
    
    // создаем constraint для лейблов
    private func setupLayout() {
        NSLayoutConstraint.activate([
            cityNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45),
            cityNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cityNameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cityNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            conditionLabel.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor, constant: 10),
            conditionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            conditionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            conditionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                        
            tempLabel.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor, constant: 100),
            tempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tempFeelsLikeLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor),
            tempFeelsLikeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            weatherConditionView.topAnchor.constraint(equalTo: tempFeelsLikeLabel.bottomAnchor, constant: 10),
            weatherConditionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherConditionView.widthAnchor.constraint(equalToConstant: 250),
            weatherConditionView.heightAnchor.constraint(equalTo: weatherConditionView.widthAnchor)
        ])
    }
    
    // присваиваем значения лейблам
    private func setupUI(city: String) {
        guard let weather = fetchWeather(city: city) else {
            Alert.showUknownLocation()
            return
        }
        // Определяем подробные условия
        let condition = weather.fact.condition
        let temp = weather.fact.temp
        let tempIsFelt = weather.fact.feelsLike
        // асинхронная загрузка данных
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.conditionLabel.text = condition
            self.tempLabel.text = temp > 0 ? "+\(temp)°" : "\(temp)°"
            self.tempFeelsLikeLabel.text = tempIsFelt > 0 ? "Feels like  +\(tempIsFelt)℃" : "Feels like \(tempIsFelt)℃"
            self.setConditionImage(from: weather)
            if let callback = self.callback {
                self.isLoadedFromSearchBar = true
                callback(self.weatherConditionView, weather)
            }
        }
    }
    
    // Метод проверяет, есть ли погода в словаре Cities. Если нет, то должен запустить getWeather из NetworkService.
    private func fetchWeather(city: String) -> Weather? {
        var cityWeather: Weather?
        if let weatherFromList = cities.listWithWeather[city] {
            cityWeather = weatherFromList
        } else {
            let networkService: NetworkService = Service()
            let group = DispatchGroup()
            group.enter()
            networkService.getWeather(for: city) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let fetchedWeather):
                    cityWeather = fetchedWeather
                    // Сохраняем полученную погоду (на всякий случай, на будущее)
                    self.cities.addWeatherFor(city: city, weather: fetchedWeather)
                case .failure(let error):
                    print(type(of: self), #function, "\(error.localizedDescription)")
                }
                group.leave()
            }
            group.wait()
        }
        return cityWeather
    }
    
    // загружаем картинку
    private func setConditionImage(from weather: Weather) {
        DispatchQueue.main.async {  [weak self] in
            guard let self = self else { return }
            let conditionIconName = weather.fact.icon
            if let url = URL(string: "https://yastatic.net/weather/i/icons/blueye/color/svg/\(conditionIconName).svg") {
                let conditionImage = UIView(SVGURL: url) { image in
                    image.resizeToFit(self.weatherConditionView.bounds)
                }
                DispatchQueue.main.async {  [weak self] in
                    guard let self = self else { return }
                    self.weatherConditionView.addSubview(conditionImage)
                }
            }
        }
    }
}
