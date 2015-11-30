//
//  Student+SourceListKit.swift
//  Keystone-OSX
//
//  Created by Todd Olsen on 11/23/15.
//  Copyright © 2015 Todd Olsen. All rights reserved.
//

import Foundation
import SourceListKit
import Keystone_Model_OSX

extension Student: SourceListItemsProvider {
    
    public static func sourceListItemsInContext(context: NSManagedObjectContext) -> [SourceListItem] {
        
        var items: [SourceListItem] = []
        
        func configureHeaderCell(tableView: NSTableView) -> NSTableCellView {
            guard let headerCell = tableView.makeViewWithIdentifier(SourceListKitConstants.CellIdentifier.Header, owner: tableView) as? SourceListHeaderCellView else { fatalError() }
            headerCell.textField?.stringValue = "Students"
            headerCell.showHiddenViews = true
            headerCell.buttonActionCallback = buttonAction
            return headerCell
        }
        
        func buttonAction(button: NSButton) {
            print("Student Header button clicked")
        }
        
        let header = SourceListItem(
            itemType: .Header,
            cellViewConfigurator: configureHeaderCell)
        
        items.append(header)
        
        let students: [Student] = Student.fetchInContext(context)
        
        items.appendContentsOf(students.map { SourceListItem(
            itemType: .DynamicChild(
                sourceListConfigurator: Student.sourceListConfigurator($0),
                contentViewConfigurator: Student.contentViewControllerConfigurator($0),
                toolbarConfigurator: Student.toolbarConfigurator($0)),
            cellViewConfigurator: Student.cellViewConfigurator($0),
            cellSelectionCallback: Student.cellSelectionCallback($0)) })
        
        return items
    }
}

extension Student {
    
    static func cellViewConfigurator(student: Student)(tableView: NSTableView) -> NSTableCellView {
        guard let view = tableView.makeViewWithIdentifier(SourceListKitConstants.CellIdentifier.Detail, owner: tableView) as? SourceListDetailCellView else { fatalError() }
        view.textField?.stringValue = student.fullName
        return view
    }

    static func contentViewControllerConfigurator(student: Student)() -> NSViewController {
        guard let vc = NSStoryboard(name: "StudentContentView", bundle: NSBundle(forClass: StudentContentViewController.self)).instantiateInitialController() as? StudentContentViewController else { fatalError() }
        vc.student = student
        return vc
    }
    
    static func sourceListConfigurator(student: Student)() -> [SourceListItem] {
        
        var items: [SourceListItem] = []
        
        // Profile Header
        
        func configureProfileHeaderCell(tableView: NSTableView) -> NSTableCellView {
            guard let headerCell = tableView.makeViewWithIdentifier(SourceListKitConstants.CellIdentifier.Header, owner: tableView) as? SourceListHeaderCellView else { fatalError() }
            headerCell.textField?.stringValue = "Profile"
            headerCell.showHiddenViews = false
            return headerCell
        }
        
        items.append(SourceListItem(
            itemType: .Header,
            cellViewConfigurator: configureProfileHeaderCell)
        )
        
        // Personal Item
        
        func personalCellViewConfigurator(tableView: NSTableView) -> NSTableCellView {
            guard let staticCell = tableView.makeViewWithIdentifier(SourceListKitConstants.CellIdentifier.Detail, owner: tableView) as? SourceListDetailCellView else { fatalError() }
            staticCell.textField?.stringValue = "Personal"
            staticCell.showHiddenViews = false
            return staticCell
        }
        
        func personalCellSelectionCallback() {
            print("Personal callback")
        }
        
        items.append(SourceListItem(
            itemType: .StaticChild(identifier: StudentViewControllerItem.Personal.rawValue),
            cellViewConfigurator: personalCellViewConfigurator,
            cellSelectionCallback: personalCellSelectionCallback)
        )
        
        // History Item
        
        func historyCellViewConfigurator(tableView: NSTableView) -> NSTableCellView {
            guard let staticCell = tableView.makeViewWithIdentifier(SourceListKitConstants.CellIdentifier.Detail, owner: tableView) as? SourceListDetailCellView else { fatalError() }
            staticCell.textField?.stringValue = "History"
            staticCell.showHiddenViews = false
            return staticCell
        }
        
        func historyCellSelectionCallback() {
            print("History callback")
        }
        
        items.append(SourceListItem(
            itemType: .StaticChild(identifier: StudentViewControllerItem.History.rawValue),
            cellViewConfigurator: historyCellViewConfigurator,
            cellSelectionCallback: historyCellSelectionCallback)
        )
        
        // Overdue Assignments
        
        let overdueAssignments = student.assignments.filter { !$0.completed && $0.dueDate.compare(NSDate(timeIntervalSinceNow: 0)) == .OrderedAscending }.sort { $0.dueDate.compare($1.dueDate) == .OrderedAscending }
        if !overdueAssignments.isEmpty {
            
            func configureOverdueAssignmentsHeaderCell(tableView: NSTableView) -> NSTableCellView {
                guard let headerCell = tableView.makeViewWithIdentifier(SourceListKitConstants.CellIdentifier.Header, owner: tableView) as? SourceListHeaderCellView else { fatalError() }

                let stringValue = "\(overdueAssignments.count) OVERDUE Assignment" + (overdueAssignments.count == 1 ? "" : "s")
                
                let mutableAttributedString = NSMutableAttributedString(
                    string: stringValue,
                    attributes: headerCell.textField?.attributedStringValue.attributesAtIndex(0, effectiveRange: nil))
                mutableAttributedString.addAttribute(NSForegroundColorAttributeName,
                    value: SourceListKitConstants.Color.OverdueAssignment,
                    range: (stringValue as NSString).rangeOfString("OVERDUE"))

                headerCell.textField?.attributedStringValue = mutableAttributedString
                headerCell.showHiddenViews = true
                return headerCell
            }
            
            items.append(SourceListItem(
                itemType: .Header,
                cellViewConfigurator: configureOverdueAssignmentsHeaderCell))
            
            func assignmentViewControllerConfigurator(assignment: Assignment)() -> NSViewController {
                guard let vc = NSStoryboard(name: "StudentContentView", bundle: NSBundle(forClass: AssignmentViewController.self)).instantiateControllerWithIdentifier("AssignmentViewController") as? AssignmentViewController else { fatalError() }
                vc.assignment = assignment
                return vc
            }
            
            items.appendContentsOf(overdueAssignments.map { SourceListItem(
                itemType: .StaticChildViewController(identifier: StudentViewControllerItem.Assignments.rawValue, viewControllerConfigurator: assignmentViewControllerConfigurator($0)),
                cellViewConfigurator: Assignment.cellViewConfigurator($0),
                cellSelectionCallback: Assignment.cellSelectionCallback($0)) })

        }

        // Active Assignments
        
        let activeAssignments = student.assignments.filter { !overdueAssignments.contains($0) && !$0.completed }.sort { $0.dueDate.compare($1.dueDate) == .OrderedAscending }
        if !activeAssignments.isEmpty {
            
            func configureActiveAssignmentsHeaderCell(tableView: NSTableView) -> NSTableCellView {
                guard let headerCell = tableView.makeViewWithIdentifier(SourceListKitConstants.CellIdentifier.Header, owner: tableView) as? SourceListHeaderCellView else { fatalError() }
                
                let mutableAttributedString = NSMutableAttributedString(
                    string: "\(activeAssignments.count) ACTIVE Assignment" + (activeAssignments.count == 1 ? "" : "s"),
                    attributes: headerCell.textField?.attributedStringValue.attributesAtIndex(0, effectiveRange: nil))
                mutableAttributedString.addAttribute(
                    NSForegroundColorAttributeName,
                    value: SourceListKitConstants.Color.ActiveAssignment,
                    range: (mutableAttributedString.string as NSString).rangeOfString("ACTIVE"))
                
                headerCell.textField?.attributedStringValue = mutableAttributedString
                headerCell.showHiddenViews = true
                return headerCell
            }
            
            items.append(SourceListItem(
                itemType: .Header,
                cellViewConfigurator: configureActiveAssignmentsHeaderCell))
            
            func assignmentViewControllerConfigurator(assignment: Assignment)() -> NSViewController {
                guard let vc = NSStoryboard(name: "StudentContentView", bundle: NSBundle(forClass: AssignmentViewController.self)).instantiateControllerWithIdentifier("AssignmentViewController") as? AssignmentViewController else { fatalError() }
                vc.assignment = assignment
                return vc
            }
            
            items.appendContentsOf(activeAssignments.map { SourceListItem(
                itemType: .StaticChildViewController(identifier: StudentViewControllerItem.Assignments.rawValue, viewControllerConfigurator: assignmentViewControllerConfigurator($0)),
                cellViewConfigurator: Assignment.cellViewConfigurator($0),
                cellSelectionCallback: Assignment.cellSelectionCallback($0)) })

        }

        // Completed Assignments
        
        let completedAssignments = student.assignments.filter { !overdueAssignments.contains($0) && !activeAssignments.contains($0) }.sort { $0.dueDate.compare($1.dueDate) == .OrderedDescending }
        if !completedAssignments.isEmpty {
            
            func configureCompletedAssignmentsHeaderCell(tableView: NSTableView) -> NSTableCellView {
                guard let headerCell = tableView.makeViewWithIdentifier(SourceListKitConstants.CellIdentifier.Header, owner: tableView) as? SourceListHeaderCellView else { fatalError() }
                headerCell.textField?.stringValue = "\(completedAssignments.count) Completed Assignment" + (completedAssignments.count == 1 ? "" : "s")
                headerCell.showHiddenViews = true
                return headerCell
            }
            
            items.append(SourceListItem(
                itemType: .Header,
                cellViewConfigurator: configureCompletedAssignmentsHeaderCell))
            
            func assignmentViewControllerConfigurator(assignment: Assignment)() -> NSViewController {
                guard let vc = NSStoryboard(name: "StudentContentView", bundle: NSBundle(forClass: AssignmentViewController.self)).instantiateControllerWithIdentifier("AssignmentViewController") as? AssignmentViewController else { fatalError() }
                vc.assignment = assignment
                return vc
            }
            
            items.appendContentsOf(completedAssignments.map { SourceListItem(
                itemType: .StaticChildViewController(identifier: StudentViewControllerItem.Assignments.rawValue, viewControllerConfigurator: assignmentViewControllerConfigurator($0)),
                cellViewConfigurator: Assignment.cellViewConfigurator($0),
                cellSelectionCallback: Assignment.cellSelectionCallback($0)) })
            
        }
        
        return items
    }

    static func toolbarConfigurator(student: Student)(toolbar: NSToolbar) {
        if let label = (toolbar.items.filter { $0.itemIdentifier == "ToolbarLabelItem" }).first?.view as? NSTextField {
            label.stringValue = student.fullName
        }
    }

    static func cellSelectionCallback(student: Student)() {
        print("Hi, I'm \(student.firstName)")
    }
}
