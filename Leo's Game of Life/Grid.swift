//
//  Grid.swift
//  Leo's Game of Life
//
//  Created by Leonardo Oliveira on 01/11/19.
//  Copyright © 2019 Leonardo Oliveira. All rights reserved.
//

import Foundation
import SceneKit

class Grid {
    
    var gridOfCells: [Array<Cell>] = []
    var cellsPositions: [Array<SCNVector3>] = []
    var nextStates: [Array<CellStateEnum>] = []
    var generation: Int = 0
    
    init(sceneView: SCNView) {
        createGrid(onScene: sceneView, isFirstGeneration: true)
    }
    
    func createGrid(onScene sceneView: SCNView, isFirstGeneration: Bool) {
        
        if isFirstGeneration == false {
            checkGeneration()
        }
        
        for x in -10 ..< 10 {
            
            var groupOfCells: [Cell] = []
            var groupOfPositions: [SCNVector3] = []
            
            for z in -10 ..< 10 {
                let cell = Cell()
                cell.position.x = (Float(x) * 1.1) + 0.5
                cell.position.z = (Float(z) * 1.1) + 0.5
                cell.position.y = (Float(generation) * 1.1) + 0.5
                groupOfCells.append(cell)
                groupOfPositions.append(SCNVector3(cell.position.x, 0.0, cell.position.z))
                
                if isFirstGeneration == false {
                    
                    if gridOfCells[x+10][z+10].cellState != nextStates[x+10][z+10] {
                        let lastCell = gridOfCells[x+10][z+10]
                        lastCell.changeState()
                    }
                    
                    if nextStates[x+10][z+10] == .alive {
                        cell.changeColor(to: .red)
                        sceneView.scene?.rootNode.addChildNode(cell)
                    }
                    
                } else {
                    sceneView.scene?.rootNode.addChildNode(cell)
                }
            }
            
            if isFirstGeneration == true {
                gridOfCells.append(groupOfCells)
                cellsPositions.append(groupOfPositions)
            }
        }
        
        nextStates.removeAll()
        generation += 1
    }
    
    func checkGeneration() {
        
        for x in 0 ..< gridOfCells.count {
            
            var groupOfStates: [CellStateEnum] = []
            
            for z in 0 ..< gridOfCells.count {
                
                let newState = applyRules(toCellOnIndex: (x, z))
                groupOfStates.append(newState)
            }
            
            nextStates.append(groupOfStates)
        }
    }
    
    func applyRules(toCellOnIndex index: (Int, Int)) -> CellStateEnum {
        
        let cell = gridOfCells[index.0][index.1]
        
        let aliveNeighbors = getAliveNeighbors(ofCellOnIndex: (index.0, index.1))
        
        var nextState: CellStateEnum = .dead
        
        switch cell.cellState {

        case .alive:
            
            nextState = .alive
            
            if aliveNeighbors.count != 2 && aliveNeighbors.count != 3 {
                nextState = .dead
            }

        case .dead:
            
            nextState = .dead
            
            if aliveNeighbors.count == 3 {
                nextState = .alive
            }
            
        }
        
        return nextState
    }
    
    func getAliveNeighbors(ofCellOnIndex index: (Int, Int)) -> [Cell] {
        
        let neighbors = getNeighbors(toCellOnIndex: (index.0, index.1))
        
        var aliveNeighbors: [Cell] = []
        
        for i in 0 ..< neighbors.count {
            
            let neighborCell: Cell = neighbors[i]
            
            if neighborCell.cellState == .alive {
                aliveNeighbors.append(neighborCell)
            }
        }
        
        return aliveNeighbors
    }
    
    func getNeighbors(toCellOnIndex index: (Int, Int)) -> [Cell] {
        
        var neighbors: [Cell] = []
        
        // Top
        if index.1 - 1 >= 0 {
            neighbors.append(gridOfCells[index.0][index.1 - 1])
        }
        
        // Bottom
        if index.1 + 1 < gridOfCells.count {
            neighbors.append(gridOfCells[index.0][index.1 + 1])
        }
        
        // Right
        if index.0 + 1 < gridOfCells.count {
            neighbors.append(gridOfCells[index.0 + 1][index.1])
        }
        
        // Left
        if index.0 - 1 >= 0 {
            neighbors.append(gridOfCells[index.0 - 1][index.1])
        }
        
        // Top Right
        if index.0 + 1 < gridOfCells.count && index.1 - 1 >= 0 {
            neighbors.append(gridOfCells[index.0 + 1][index.1 - 1])
        }
        
        // Top left
        if index.0 - 1 >= 0 && index.1 - 1 >= 0 {
            neighbors.append(gridOfCells[index.0 - 1][index.1 - 1])
        }
        
        // Bottom Right
        if index.0 + 1 < gridOfCells.count && index.1 + 1 < gridOfCells.count {
            neighbors.append(gridOfCells[index.0 + 1][index.1 + 1])
        }
        
        // Bottom left
        if index.0 - 1 >= 0 && index.1 + 1 < gridOfCells.count {
            neighbors.append(gridOfCells[index.0 - 1][index.1 + 1])
        }
        
        return neighbors
    }
}
