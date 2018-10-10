//
//  CollapsibleIndexPath.swift
//  BDTv6
//
//  Created by Masher on 30/07/2018.
//  Copyright © 2018 Masher.dev. All rights reserved.
//

import Foundation

public struct CollapsibleIndexPath {

    public let row: Int

    public let collapsibleSection: Int

    public let section: Int

    /// 일반 테이블 뷰에 대응되는 indexPath
    public let realIndexPath: IndexPath

    /// collapsible 테이블 뷰에 대응되는 indexPath
    public var indexPath: IndexPath {
        return IndexPath(row: row, section: collapsibleSection)
    }

    init(row: Int = 0, collapsibleSection: Int = 0, section: Int = 0, realIndexPath: IndexPath = IndexPath()) {
        self.row = row
        self.collapsibleSection = collapsibleSection
        self.section = section
        self.realIndexPath = realIndexPath
    }

}
