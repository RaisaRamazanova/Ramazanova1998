//
//  ViewController.swift
//  Ramazanova1998
//
//  Created by Раисат Рамазанова on 31.08.2021.
//

import UIKit

class MainViewController: UIViewController {

    // MARK: - properties
    
    var cities = CitiesJson.shared
    let screenSize = UIScreen.main.bounds
    var lastTimeSelectedRowIndexPath: IndexPath?
    private lazy var tableView = UITableView(frame: .zero)
    private lazy var searchBar = UISearchBar()
    
    // MARK: - override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = .black
        
        // добавим заголовок в navigationBar и добавим под ним searchBar
        initNavigation()
        initSearchBar()
        initTableView()
        setupLayout()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.updateUI()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Делаем так, чтобы строка гасла после появления вью контроллера на экране:
        if let indexPath = lastTimeSelectedRowIndexPath {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - functions

    // инициализируем  tableView
    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(#colorLiteral(red: 0.8956577182, green: 0.8958080411, blue: 0.8956379294, alpha: 1))
        tableView.register(CustomCell.self, forCellReuseIdentifier: String(describing: CustomCell.self))
        view.addSubview(tableView)
    }

    // задаем имя navigationBar и другие параметры
    private func initNavigation() {
        title = "Прогноз погоды"
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(#colorLiteral(red: 0.6922695637, green: 0.9417296052, blue: 1, alpha: 1))
    }
    
    // инициализируем  searchBar
    private func initSearchBar() {
        searchBar.placeholder = "Поиск"
        searchBar.barStyle = .default
        searchBar.isTranslucent = false
        searchBar.delegate = self
        searchBar.barTintColor = UIColor.white
        view.addSubview(searchBar)
    }
    
    // задаем сonstraint для searchBar и tableView
    private func setupLayout() {
        [tableView,
         searchBar].forEach { $0.toAutoLayout() }
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: tableView.topAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // обновляем данные tableView из сети
    private func updateUI() {
        let networkService: NetworkService = Service()
        cities.list.forEach { [weak self] city in
            guard let self = self else { return }
            networkService.getWeather(for: city) { result in
                switch result {
                case .success(let weather):
                    DispatchQueue.main.async {
                        self.cities.addWeatherFor(city: city, weather: weather)
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print(type(of: self), #function, error.localizedDescription)
                }
            }
        }
    }

    // открываем детальный контроллер после ввода города в searchBar
    func showDetailWeatherFor(city: String) {
        let detailVC = DetailViewController(forCity: city)
        
        // Передадим вью контроллеру задачу по остановке активити индикатора и презентации самого себя поверх всех окон:
        detailVC.callback = { [weak self] (view, weather) in
            guard let self = self else { return }
            
            // Настраиваем navigationVC, в котором будут две кнопки
            let navigationVC = UINavigationController(rootViewController: detailVC)
            let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(self.hideDetailVC))
            let addButton = UIBarButtonItem(title: "Добавить", style: .done, target: self, action: #selector(self.addSearchedCity))
            detailVC.navigationItem.leftBarButtonItem = cancelButton
            detailVC.navigationItem.rightBarButtonItem = addButton
            
            // Презентуем то, что получилось
            self.present(navigationVC, animated: true, completion: nil)
        }
    }
    
    // кнопка отмены в детальном контроллере
    @objc private func hideDetailVC() {
        dismiss(animated: true, completion: nil)
    }
    
    // кнопка добпаления города в основной список из детального контроллера при нажатии на город из searchBar
    @objc private func addSearchedCity() {
        guard let searchedCity = searchBar.text?.capitalized else { return }
        cities.add(city: searchedCity)
        dismiss(animated: true, completion: nil)
        tableView.reloadData()
    }
    
    // если потянуть ячейку влево, то можно удать ее
    @objc private func deleteRows() {
        guard let selectedRows = tableView.indexPathsForSelectedRows else { return }
        var selectedCities: [String] = []
        for indexPath in selectedRows  {
            selectedCities.append(cities.list[indexPath.row])
        }
        for city in selectedCities {
            if let index = cities.list.firstIndex(of: city) {
                cities.removeCity(at: index)
            }
        }
        tableView.beginUpdates()
        tableView.deleteRows(at: selectedRows, with: .automatic)
        tableView.endUpdates()
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
}
