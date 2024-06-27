//
//  ShoppingTableCellTableViewCell.swift
//  FridgeBuddy
//
//  Created by Priyansh Parekh on 6/22/24.
//

import UIKit

protocol ShoppingCellDelegate {
    func boughtTapped(tableViewCell: UITableViewCell)
}

class ShoppingTableCell: UITableViewCell {
    
    static let identifier = "ShoppingTableCell"
    
    var delegate: ShoppingCellDelegate?
    
    private var bought = false
    
    static func nib() -> UINib {
        return UINib(nibName: "ShoppingTableCell", bundle: nil)
    }
    
    @IBOutlet var button: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var qtyLabel: UILabel!
    
    @IBAction func didTapButton() {
        print("didTapButton")
        delegate?.boughtTapped(tableViewCell: self)
    }
    
    func configure(title: String, qty: String, bought: Bool) {
        self.bought = bought
        nameLabel.text = title
        qtyLabel.text = qty
        
        if bought {
            button.setImage(UIImage.selected, for: .normal)
        } else {
            button.setImage(UIImage.unselected, for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
}
