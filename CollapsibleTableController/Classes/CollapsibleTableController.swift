//
//  CollapsibleTableController.swift
//  BDTv6
//
//  Created by Masher on 23/07/2018.
//  Copyright © 2018 Masher.dev. All rights reserved.
//

import UIKit

// MARK: - CollapsibleSectionInfo
private struct CollapsibleSectionInfo {

    let range: CountableClosedRange<Int>
    let section: Int
    let collapsibleSection: Int

    var indexPath: IndexPath {
        let row = range.lowerBound - 1
        return IndexPath(row: row < 0 ? 0 : range.lowerBound - 1, section: section)
    }

}

extension CollapsibleSectionInfo: Equatable {

    static func == (lhs: CollapsibleSectionInfo, rhs: CollapsibleSectionInfo) -> Bool {
        return lhs.section == rhs.section && lhs.collapsibleSection == rhs.collapsibleSection
    }

}

extension CollapsibleSectionInfo: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(section)
        hasher.combine(collapsibleSection)
    }

}

// MARK: -
// MARK: - CollapsibleTableController
public class CollapsibleTableController: NSObject {

    private var collapsedSectionInfos: Set<CollapsibleSectionInfo> = []

    private var collapsedSections: [Int] { return collapsedSectionInfos.map { $0.collapsibleSection } }

    /// key: collapsible Section
    ///
    /// value: radians
    private var rotatedRadiansSet: [Int: RotatedRadian] = [:]

    public weak var dataSource: CollapsibleTableDataSource? {
        didSet {
            dataSource?.collapsibleTableView?.dataSource = self
            dataSource?.collapsibleTableView?.delegate = self
        }
    }

    public weak var delegate: CollapsibleTableDelegate?

    public var animation = UITableView.RowAnimation.fade

    public var scrollTopWhenExpand = true

    public func expand(atSection section: Int, collapsibleSection: Int) {
        guard collapsedSections.contains(collapsibleSection) else { return }
        guard let dataSource = dataSource, let tableView = dataSource.collapsibleTableView else { return }
        guard let info = gainCollapsingSectionInfoAt(section: section, collapsibleSection: collapsibleSection)
            else { return }
        expandTableView(tableView, of: info, withAni: false)
    }

    public func expandAll() {
        collapsedSectionInfos.forEach {
            expand(atSection: $0.section, collapsibleSection: $0.collapsibleSection)
        }
    }

    public func collapse(atSection section: Int, collapsibleSection: Int) {
        guard let dataSource = dataSource, let tableView = dataSource.collapsibleTableView else { return }
        guard let info = gainCollapsingSectionInfoAt(section: section, collapsibleSection: collapsibleSection)
            else { return }
        collapseTableView(tableView, of: info, withAni: false)
    }

    public func collapseAll() {
        guard let dataSource = dataSource, let tableView = dataSource.collapsibleTableView else { return }
        let sectionCount = dataSource.numberOfSections(in: tableView)
        (0...sectionCount).forEach { section in
            let collapsibleSectionCount = dataSource.tableView(tableView, numberOfCollapsibleSectionsInSection: section)
            (0...collapsibleSectionCount).forEach { collSection in
                collapse(atSection: section, collapsibleSection: collSection)
            }
        }
    }

}

// MARK: - Private
private extension CollapsibleTableController {

    func gainCollapsingSectionInfoAt(section: Int, collapsibleSection: Int) -> CollapsibleSectionInfo? {
        guard let dataSource = dataSource, let tableView = dataSource.collapsibleTableView else { return nil }
        let sectionCount = dataSource.numberOfSections(in: tableView)
        guard section < sectionCount else { return nil }
        let collapsibleSectionCount = dataSource.tableView(tableView, numberOfCollapsibleSectionsInSection: section)
        guard collapsibleSection < collapsibleSectionCount else { return nil }
        let realRow = (0..<collapsibleSection).reduce(0) {
            let rowCount = dataSource.tableView(tableView, numberOfRowsInSection: section, collapsibleSection: $1)
            let count = collapsedSections.contains($1) ? 0 : rowCount
            return $0 + count + 1
        }
        let low = realRow + 1
        let targetRowCount = dataSource
            .tableView(tableView, numberOfRowsInSection: section, collapsibleSection: collapsibleSection)
        guard targetRowCount > 0 else { return nil }
        let upper = realRow + targetRowCount
        return CollapsibleSectionInfo(range: low...upper, section: section, collapsibleSection: collapsibleSection)
    }

    func toggleCollapsing(_ tableView: UITableView, at indexPath: IndexPath) {
        let collapsibleIndexPath = substituteIndexPath(indexPath, with: tableView)
        guard collapsibleIndexPath.row < 0 else { return }
        let collSection = collapsibleIndexPath.collapsibleSection
        let realSection = collapsibleIndexPath.realIndexPath.section
        guard let info = gainCollapsingSectionInfoAt(section: realSection, collapsibleSection: collSection)
            else { return }
        if collapsedSections.contains(collSection) {
            expandTableView(tableView, of: info)
            if scrollTopWhenExpand {
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        } else {
            collapseTableView(tableView, of: info)
        }
    }

    func substituteIndexPath(_ indexPath: IndexPath, with tableView: UITableView) -> CollapsibleIndexPath {
        guard let dataSource = dataSource else { return CollapsibleIndexPath() }
        let section = indexPath.section
        let cHeaderCount = dataSource.tableView(tableView, numberOfCollapsibleSectionsInSection: section)
        var collapsibleRows: [Int: Int] = [:]
        for cSection in 0..<cHeaderCount {
            let realRow = cSection + 1 + collapsibleRows.reduce(0) { $0 + $1.value }
            let rowCount = dataSource.tableView(tableView, numberOfRowsInSection: section, collapsibleSection: cSection)
            let count = collapsedSections.contains(cSection) ? 0 : rowCount
            let totalCount = realRow + count // 현재 collapsible section의 row 갯수
            if indexPath.row >= totalCount { // 그다음 collapsible section으로..
                collapsibleRows[cSection] = count
                continue
            }
            let cRow = indexPath.row - realRow
            return CollapsibleIndexPath(
                row: cRow,
                collapsibleSection: cSection,
                section: section,
                realIndexPath: indexPath
            )
        }
        return CollapsibleIndexPath()
    }

    func expandTableView(_ tableView: UITableView, of info: CollapsibleSectionInfo, withAni animate: Bool = true) {
        collapsedSectionInfos.remove(info)
        let doIt = {
            let indexPaths = info.range.map { IndexPath(row: $0, section: info.section) }
            tableView.insertRows(at: indexPaths, with: self.animation)
            if let rotatableCell = (tableView.cellForRow(at: info.indexPath) as? CollapsibleHeaderArrowRotatable) {
                rotatableCell.rotateWhenExpand()
            }
            let radians = CollapsibleHeaderArrowRadians.expanded
            self.rotatedRadiansSet[info.collapsibleSection] = RotatedRadian(isCollapsed: false, radians: radians)
        }
        animate ? doIt() : tableView.doWithoutAnimation(doIt)
    }

    func collapseTableView(_ tableView: UITableView, of info: CollapsibleSectionInfo, withAni animate: Bool = true) {
        collapsedSectionInfos.insert(info)
        let doIt = {
            let indexPaths = info.range.map { IndexPath(row: $0, section: info.section) }
            tableView.deleteRows(at: indexPaths, with: self.animation)
            if let rotatableCell = (tableView.cellForRow(at: info.indexPath) as? CollapsibleHeaderArrowRotatable) {
                rotatableCell.rotateWhenCollapse()
            }
            let radians = CollapsibleHeaderArrowRadians.collapsed
            self.rotatedRadiansSet[info.collapsibleSection] = RotatedRadian(isCollapsed: true, radians: radians)
        }
        animate ? doIt() : tableView.doWithoutAnimation(doIt)
    }

}

// MARK: - UITableViewDataSource
extension CollapsibleTableController: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfSections(in: tableView) ?? 0
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataSource = dataSource else { return 0 }
        let headerCount = dataSource.tableView(tableView, numberOfCollapsibleSectionsInSection: section)
        let rowCount = (0..<headerCount).reduce(0) {
            guard collapsedSections.contains($1) == false else { return $0 }
            return $0 + dataSource.tableView(tableView, numberOfRowsInSection: section, collapsibleSection: $1)
        }
        return headerCount + rowCount
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataSource = dataSource else { preconditionFailure() }
        let collapsibleIndexPath = substituteIndexPath(indexPath, with: tableView)
        guard collapsibleIndexPath.row >= 0 else {
            // collapsible header
            let cell = dataSource.tableView(
                tableView,
                headerForSection: collapsibleIndexPath.section,
                collapsibleSection: collapsibleIndexPath.collapsibleSection
            )
            if let radians = rotatedRadiansSet[collapsibleIndexPath.collapsibleSection] {
                (cell as? CollapsibleHeaderArrowRotatable)?.rotateArrow(toRadians: radians, withAnimate: false)
            }
            return cell
        }
        // collapsible cell
        return dataSource.tableView(tableView, cellForRowAt: collapsibleIndexPath)
    }

}

// MARK: - UITableViewDelegate
extension CollapsibleTableController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toggleCollapsing(tableView, at: indexPath)
    }

    // MARK: Scroll View Delegate

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging(scrollView)
    }

}

private extension UIView {

    func doWithoutAnimation(_ doing: () -> Void) {
        UIView.setAnimationsEnabled(false)
        doing()
        UIView.setAnimationsEnabled(true)
    }

}
