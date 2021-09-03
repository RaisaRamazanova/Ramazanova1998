//
//  Extentions.swift
//  Ramazanova1998
//
//  Created by Раисат Рамазанова on 03.09.2021.
//

import UIKit

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {

    // удаляем ячейку
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, complete in
            CitiesJson.shared.removeCity(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            complete(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    // размер ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    //функция запускается при нажатии на ячейку и открывает подробный экран
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            lastTimeSelectedRowIndexPath = indexPath
            let city = cities.list[indexPath.row]
            let vc = DetailViewController(forCity: city)
            navigationController?.pushViewController(vc, animated: true)
        } else if tableView.indexPathsForSelectedRows != nil {
            navigationItem.leftBarButtonItem?.isEnabled = true
        }
    }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    // количество ячеек
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }

    // создание ячейки и наполнение
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CustomCell.self), for: indexPath) as? CustomCell else { return CustomCell() }
        let city = cities.list[indexPath.row]
        cell.city = city
        if let weather = cities.listWithWeather[city] {
            cell.weather = weather
        }
        return cell
    }
}

// MARK: - UIView

extension UIView {
    
    func toAutoLayout() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func anchor (top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat, enableInsets: Bool) {
        var topInset = CGFloat(0)
        var bottomInset = CGFloat(0)
        
        if #available(iOS 11, *), enableInsets {
        let insets = self.safeAreaInsets
        topInset = insets.top
        bottomInset = insets.bottom
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
        self.topAnchor.constraint(equalTo: top, constant: paddingTop+topInset).isActive = true
        }
        if let left = left {
        self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let right = right {
        rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if let bottom = bottom {
        bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom-bottomInset).isActive = true
        }
        if height != 0 {
        heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if width != 0 {
        widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
}

// MARK: - UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    
    // вызывает функцию поиска города и открывает детальный экран
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let city = searchBar.text?.capitalized, !city.isEmpty {
            showDetailWeatherFor(city: city)
        }
    }
}
