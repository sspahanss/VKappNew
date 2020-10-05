//
//  NewsPhotoCellCollectionLayout.swift
//  VKappNew
//
//  Created by Павел on 05.10.2020.
//

import UIKit

class NewsPhotoCellCollectionViewLayout: UICollectionViewLayout {
    var cacheAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    
    let viewHeight: CGFloat = 400
    var cellHeight: CGFloat = 400
    private var totalCellsHeight: CGFloat = 400
    
    override func prepare() {
        super.prepare()
        
        cacheAttributes = [:]
        guard let collectionView = self.collectionView else { return }
        
        let itemsCount = collectionView.numberOfItems(inSection: 0)
        guard itemsCount > 0 else { return }
        let dataSourceCell = collectionView.dataSource as! NewsTableViewCell
      
        let horizontal = dataSourceCell.photos.filter({$0.size.height < $0.size.width}).count > dataSourceCell.photos.filter({$0.size.height >= $0.size.width}).count
       
        let countOfLinesInView = calculateCountOfLines(for: itemsCount)

        let countsOfCellsInOneSection = calculateCellCountInLines(for: countOfLinesInView, itemsCount)
        
        
        let cellWidth = collectionView.bounds.width
        var lastY: CGFloat = 0
        var lastX: CGFloat = 0
        var numberOfCurrenSection = 1
        var currentCellInSection = 1
        
        for index in 0..<itemsCount {
            let indexPath = IndexPath(item: index, section: 0)
            let attributtes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
          
            let countOfCellsInCurrentSection : CGFloat = CGFloat(countsOfCellsInOneSection[numberOfCurrenSection-1])
            
            let currentWidth = horizontal ? cellWidth / countOfCellsInCurrentSection : cellWidth / CGFloat(countOfLinesInView)
            let currentHeight = horizontal ? viewHeight / CGFloat(countOfLinesInView) : viewHeight / countOfCellsInCurrentSection
            
            attributtes.frame = CGRect(
                x: lastX,
                y: lastY,
                width: currentWidth,
                height: currentHeight)
            
            if horizontal {
                lastX += currentWidth + 1
            } else {
                lastY += currentHeight + 1
            }
       
            if currentCellInSection == countsOfCellsInOneSection[numberOfCurrenSection - 1] {
                numberOfCurrenSection += 1
                currentCellInSection = 1
                if horizontal {
                    lastY = CGFloat((numberOfCurrenSection-1) * (Int(viewHeight) / countOfLinesInView) + numberOfCurrenSection )
                    lastX = 0
                } else {
                    lastX = CGFloat((numberOfCurrenSection-1) * (Int(cellWidth) / countOfLinesInView) + numberOfCurrenSection)
                    lastY = 0
                }
            } else {
                currentCellInSection += 1
            }
            cacheAttributes[indexPath] = attributtes
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cacheAttributes.values.filter { attributes in
            rect.intersects(attributes.frame)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cacheAttributes[indexPath]
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView?.bounds.width ?? 0,
                      height: totalCellsHeight)
    }
    
    func calculateCountOfLines(for count: Int) -> Int{
        switch count {
        case 1:
            return 1
        case 2...6:
            return 2
        case 7...10:
            return 3
        default:
            return 0
        }
    }
    
    func calculateCellCountInLines(for line: Int, _ allCount : Int) -> [Int]{
        var array = [Int]()
        var currentAllCount = allCount
        switch allCount {
        case 1:
            return [1]
        case 2...4:
            return [1, allCount-1]
        case 5...10:
            for i in (1...line).reversed() {
                let cells = currentAllCount/i
                array.append(cells)
                currentAllCount -= cells
            }
            fallthrough
        default:
            return array
        }
    }
}
