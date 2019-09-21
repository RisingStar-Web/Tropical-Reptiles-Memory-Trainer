//
//  RoundedButton.swift
//  AudioBooks
//
//  Created by Роман Кабиров on 17.10.2018.
//  Copyright © 2018 Logical Mind. All rights reserved.
//

import UIKit

class LightButton: UIButton {
    private let defaultBackgroundColor = UIColor.init(white: 0.98, alpha: 0.7)
    // private let defaultSelectedColor = UIColor.init(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.35)
    private let defaultSelectedColor = UIColor.init(red: 199/255, green: 200/255, blue: 198/255, alpha: 1.0)

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setBeautifully()
    }
    
    func setBeautifully() {
        layer.cornerRadius = 12.0
        backgroundColor = defaultBackgroundColor
        layer.borderWidth = 0.5
        // layer.borderColor = UIColor.init(white: 0.0, alpha: 0.2).cgColor
        layer.borderColor = UIColor.init(white: 1.0, alpha: 1.0).cgColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = defaultSelectedColor
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = defaultBackgroundColor
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = defaultBackgroundColor
        super.touchesCancelled(touches, with: event)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
