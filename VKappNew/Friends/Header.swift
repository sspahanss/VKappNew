//
//  Header.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit

class HeaderViewForCell: UITableViewHeaderFooterView {
    static let identifier = "headerViewCell"
    private let color = UIColor(named: "#6689B3ff")
    
    func configure(with text: String) {
        self.tintColor = color
        textLabel!.backgroundColor = color
        textLabel!.text = text
    }
    
}
