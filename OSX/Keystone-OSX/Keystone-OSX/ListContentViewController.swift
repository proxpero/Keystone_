//
//  ListContentViewController.swift
//  Keystone-OSX
//
//  Created by Todd Olsen on 12/2/15.
//  Copyright © 2015 Todd Olsen. All rights reserved.
//

import Cocoa
import Keystone_Model_OSX

public enum ListControllerItem: String {
    case Settings   = "Settings"
    case History    = "History"
    case Problems   = "Problems"
}

protocol ListSettable {
    var list: List! { get set }
}

public class ListContentViewController: ContentTabViewController {
    
    var list: List!
    
    public override func tabView(tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?) {
        super.tabView(tabView, didSelectTabViewItem: tabViewItem)
        guard var vc = tabViewItem?.viewController as? ListSettable else { return }
        vc.list = list
    }

}

public class ListSummaryViewController: NSViewController, ListSettable {
    
    public var list: List! {
        didSet {
            title = list.name
        }
    }
    @IBOutlet weak var label: NSTextField!
    
}

public class ListHistoryViewController: NSViewController, ListSettable {

    public var list: List! {
        didSet {
            title = list.name
        }
    }

}