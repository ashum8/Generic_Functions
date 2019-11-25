//
//  SearchView.swift
//  Mandoub Services Platform
//
//  Created by Ashutosh Mishra on 04/04/19.
//  Copyright © 2019 Ashutosh Mishra. All rights reserved.
//

import UIKit

class SearchView: UIXibView {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var tfSearch: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        tfSearch.addPaddingLeft(10.0)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tfSearch.textAlignment = self.isRTL ? .right : .left
    }
}
