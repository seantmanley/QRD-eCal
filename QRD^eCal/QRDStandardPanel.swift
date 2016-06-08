//
//  QRDStandardPanel.swift
//  QRD^eCal
//
//  Created by Sean Manley on 6/7/16.
//  Copyright © 2016 Sean Manley. All rights reserved.
//

import Foundation

class QRDStandardPanel {
//    MARK: - Member Variables
    var maxDesignWidth:Int
    var maxDesignDepth:Int
    var designFinWidth:Int
    
    var designFrequency:Int {
        didSet {
            designWavelength = getDesignWavelength(designFrequency)
        }
    }
    var designWavelength:Double = 0.0 {
        didSet {
            designDepth = getDesignDepth(designWavelength)
        }
    }
    
    var periodWidth = 0
    var designDepth = 0
    var depthIncrement = 0
    var buildDepth = 0
    var designWellWidth = 0
    var designWellDepth = 0
    
    var numWells = 0 {
        didSet{
            periodWidth = numWells * designWellWidth + (numWells + 1) * designFinWidth
            depthIncrement = getDepthIncrements(designDepth, wellCount: numWells)
        }
    }
    
    var wellsTuple:[(structure: Int, size: Int)] = []
    
    var wellStructure:[Int] = []
    var wells:[Int] = []
    
    init(maxDesignWidth:Int, maxDesignDepth:Int, designFinWidth:Int, designFrequency:Int) {
        self.maxDesignWidth = maxDesignWidth
        self.maxDesignDepth = maxDesignDepth
        self.designFinWidth = designFinWidth
        self.designFrequency = designFrequency

        buildPanel()
    }
    
    func buildPanel() {
        self.designWavelength = getDesignWavelength(self.designFrequency)
        self.designWellWidth = (getViscousLowerLimit(designDepth) + getViscousUpperLimit(designWavelength)) / 2
        self.numWells = getNumberOfWells(sieveOfEratosthenes(150), viscousMid: designWellWidth, maxDesignWidth: maxDesignWidth, designFinWidth: designFinWidth)
        self.wellStructure = getPanelWellStructure(numWells)
        self.buildDepth = getBuildDepth(wellStructure, depthIncrement: depthIncrement)
        self.wells = getPanelWells(wellStructure, depthIncrement: depthIncrement, buildDepth: buildDepth)
    }
    
//    MARK: - Calculations
    
    func sieveOfEratosthenes(maxPrime:Int) -> [Int] {
        var primes:[Int] = []
        var isPrime:[Bool] = []
        
        for _ in 0...maxPrime-2 {
            isPrime.append(true)
        }
        
        let numChecks = Int(round(sqrt(Double(maxPrime))))
        var curNum = 2
        
        for i in 0..<numChecks {
            if isPrime[i] {
                let x = i+curNum
                for j in x.stride(to:isPrime.count-1, by:curNum) {
                    isPrime[j] = false
                }
            }
            curNum += 1
        }
        
        for i in 0..<isPrime.count-1 {
            if isPrime[i] {
                primes.append(i+2)
            }
        }
        
        return primes
    }
    
    func getNumberOfWells(wellOptions:[Int], viscousMid:Int, maxDesignWidth:Int, designFinWidth:Int) -> Int {
        let maxNumWells = maxDesignWidth / viscousMid
        var numWellsOver = 1
        
        while (maxNumWells + 1 - numWellsOver) * designFinWidth > numWellsOver * viscousMid {
            numWellsOver += 1
        }
        
        return wellOptions[(wellOptions.indexOf({$0 > maxNumWells - numWellsOver}) ?? 0) - 1]
        
    }
    
    func getDesignWavelength(designFrequency:Int) -> Double {
//        wavelength = speed of light / frequency
        return 343.0 / Double(designFrequency) * 1000  // m -> mm
    }
    
    func getDepthIncrements(designDepth:Int, wellCount:Int) -> Int {
//        depths are multiples of half the design wavelength divided by the number of wells.
        return designDepth / wellCount
    }
    
    func getPeriodWidth(wellCount:Int, designWellWidth:Int, designFinWidth:Int) -> Int {
//        the width occupied by the wells plus the same number of fins. needs to be at least double the design depth.
        return designWellWidth * wellCount + designFinWidth * wellCount // +1?
    }
    
    func getDesignDepth(designWavelength:Double) -> Int {
        return Int(round(designWavelength / 2.0))
    }
    
    func getBuildDepth(wellStructure:[Int], depthIncrement:Int) -> Int {
        var maxWell = wellStructure[0]
        for i in wellStructure {
            maxWell = maxWell < wellStructure[i] ? wellStructure[i] : maxWell
        }
        return maxWell * depthIncrement
    }
    
    func getPanelWellStructure(numWells:Int) -> [Int] {
        var panelStructure:[Int] = []
        for i in 0..<numWells {
            let sq = i*i
            let well = sq % numWells
            panelStructure.append(well)
        }
        return panelStructure
    }
    
    func getPanelWells(wellStructure:[Int], depthIncrement:Int, buildDepth:Int) -> [Int] {
        var panel:[Int] = []
        for i in wellStructure {
            let well = buildDepth - (depthIncrement * i)
            panel.append(well)
        }
        return panel
    }
    
//    MARK: - Limits
    
    func getViscousLowerLimit(buildDepth:Int) -> Int {
//        minimum well width should be equal to the build depth divided by 16. wells can be as narrow as 25mm for well depths up to 400mm
        return buildDepth <= 400 ? 25 : buildDepth / 16
    }
    
    func getViscousUpperLimit(designWavelength:Double) -> Int {
//        Maximum well width = design wavelength times 0.137
        return Int(round(designWavelength * 0.137))
    }
    
    func getPlateLimit(designFrequency:Int, wellCount:Int) -> Int {
//        design frequency times N
        return designFrequency * wellCount
    }
}