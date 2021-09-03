//
//  TableViewCell.swift
//  Ramazanova1998
//
//  Created by Раисат Рамазанова on 31.08.2021.
//

import UIKit
import SwiftSVG

class CustomCell: UITableViewCell {

    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    var city: String? {
        didSet {
            guard let city = city else { return }
            setupViews(for: city)
            setupLayout()
        }
    }
    
    var weather: Weather? {
        didSet {
            guard let city = city else { return }
            setupViews(for: city)
        }
    }

     private let nameLabel : UILabel = {
     let lbl = UILabel()
     lbl.textColor = .black
     lbl.font = UIFont.boldSystemFont(ofSize: 25)
     lbl.textAlignment = .left
     return lbl
     }()
     
     private let conditionLabel : UILabel = {
     let lbl = UILabel()
     lbl.textColor = .black
     lbl.font = UIFont.systemFont(ofSize: 15)
     lbl.textAlignment = .left
     lbl.numberOfLines = 0
     return lbl
     }()
    
     var tempLabel : UILabel = {
     let label = UILabel()
     label.font = UIFont.boldSystemFont(ofSize: 35)
     label.textAlignment = .left
     label.text = ""
     label.textColor = .black
     return label
     }()
    
    // MARK: - override function
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        conditionLabel.text = nil
        tempLabel.text = nil
    }
    
    // MARK: - function
    
    private func initView() {
        preservesSuperviewLayoutMargins = false
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
    }

    // Настраиваем погоду
    private func setupViews(for city: String) {
        nameLabel.text = city
        guard let weather = weather else { return }
        conditionLabel.text = weather.fact.condition
        let temp = weather.fact.temp
        if temp > 0 {
            tempLabel.text = "+\(temp)℃"
        } else {
            tempLabel.text = "\(temp)℃"
        }
        tempLabel.isHidden = false
    }
    
    // создаем constraint и добавляем Subview
    private func setupLayout() {
        addSubview(nameLabel)
        addSubview(conditionLabel)
        addSubview(tempLabel)

        nameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width / 2 + 50, height: 0, enableInsets: false)
        conditionLabel.anchor(top: nameLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: frame.size.width / 2, height: 0, enableInsets: false)
        tempLabel.anchor(top: topAnchor, left: nameLabel.rightAnchor, bottom: nil, right: nil, paddingTop: 15, paddingLeft: 5, paddingBottom: 15, paddingRight: 10, width: 0, height: 70, enableInsets: false)
    }
}
