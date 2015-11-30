//
//  ContentTabViewController.swift
//  Example
//
//  Created by Todd Olsen on 11/20/15.
//  Copyright © 2015 Todd Olsen. All rights reserved.
//

import Cocoa

public protocol TabItemIdentifying  {
    func selectTabItemWithIdentifier(identifier: String) -> NSTabViewItem?
}

public class ContentTabViewController: NSTabViewController {
    public var managedObjectContext: NSManagedObjectContext!
    
    func newContentViewController(viewController: NSViewController) {
        
        let tabViewItem = NSTabViewItem(viewController: viewController)
        insertTabViewItem(tabViewItem, atIndex: 0)
        selectedTabViewItemIndex = 0

    }
}