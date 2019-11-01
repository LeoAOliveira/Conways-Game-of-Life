//
//  Cube.swift
//  Leo's Game of Life
//
//  Created by Leonardo Oliveira on 31/10/19.
//  Copyright © 2019 Leonardo Oliveira. All rights reserved.
//

import UIKit
import SceneKit

class Cell: SCNNode {
    
    var cellState: CellStateEnum = .dead
    
    init(sizeOfCube width: Float = 1, height: Float = 1, lenght: Float = 1) {
        super.init()
        
        let box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        self.geometry = box
        
        self.cellState = .dead
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeState() {
        
        if cellState == .dead {
            cellState = .alive
            changeColor(to: .red)
            self.runAction(SCNAction.move(to: SCNVector3(CGFloat(self.position.x), CGFloat(0.5), CGFloat(self.position.z)), duration: 0.5))
            
        } else if cellState == .alive {
            cellState = .dead
            changeColor(to: .white)
            self.runAction(SCNAction.move(to: SCNVector3(CGFloat(self.position.x), CGFloat(0.0), CGFloat(self.position.z)), duration: 0.5))
            
        }
    }
    
    func changeColor(to color: UIColor) {
        
        guard let material = self.geometry?.firstMaterial else {
            return
        }
        material.diffuse.contents = color
    }
    
}
