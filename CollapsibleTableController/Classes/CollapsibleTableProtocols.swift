//
//  CollapsibleTableProtocols.swift
//  BDTv6
//
//  Created by Masher on 30/07/2018.
//  Copyright © 2018 Masher.dev. All rights reserved.
//

import UIKit

// MARK: - CollapsibleTableDataSource
public protocol CollapsibleTableDataSource: class {

    var collapsibleTableView: UITableView? { get }

    func numberOfSections(in tableView: UITableView) -> Int

    func tableView(_ tableView: UITableView, numberOfCollapsibleSectionsInSection section: Int) -> Int

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int, collapsibleSection: Int) -> Int

    func tableView(_ tableView: UITableView, headerForSection section: Int,
                   collapsibleSection: Int) -> UITableViewCell

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: CollapsibleIndexPath) -> UITableViewCell

}

// MARK: - Optional CollapsibleTableDataSource
public extension CollapsibleTableDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { return 1 }

}

// MARK: - CollapsibleTableDelegate
public protocol CollapsibleTableDelegate: class {

    func scrollViewDidScroll(_ scrollView: UIScrollView)

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)

}

// MARK: - Optional CollapsibleTableDelegate
public extension CollapsibleTableDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {}

}

// MARK: -
// MARK: - CollapsibleHeaderArrowRotatable
public protocol CollapsibleHeaderArrowRotatable: class {

    /// Arrow image view that default direction up when expanded.
    var collapsibleArrow: UIImageView { get }

    /// Default 0.3 second
    var rotateDuration: TimeInterval { get }

    func didRotated(afterCollapse collapse: Bool)

}

public enum CollapsibleHeaderArrowRadians {

    static let collapsed = CGFloat(180 * Double.pi / 180)

    static let expanded = CGFloat(0 * Double.pi / 180)

}

extension CollapsibleHeaderArrowRotatable {

    var rotateDuration: TimeInterval {
        return 0.3
    }

    func rotateWhenCollapse() {
        rotateArrow(toRadians: RotatedRadian(isCollapsed: true, radians: CollapsibleHeaderArrowRadians.collapsed))
        didRotated(afterCollapse: true)
    }

    func rotateWhenExpand() {
        rotateArrow(toRadians: RotatedRadian(isCollapsed: false, radians: CollapsibleHeaderArrowRadians.expanded))
        didRotated(afterCollapse: false)
    }

    func rotateArrow(toRadians radians: RotatedRadian, withAnimate animate: Bool = true) {
        let doIt = {
            self.collapsibleArrow.layer.transform = CATransform3DMakeRotation(radians.radians, 0.0, 0.0, 1.0)
        }
        animate ? UIView.animate(withDuration: rotateDuration, animations: doIt) : doIt()
        didRotated(afterCollapse: radians.isCollapsed)
    }

}

struct RotatedRadian {
    var isCollapsed: Bool
    var radians: CGFloat
}
