//
//  PeopleListViewControllerTests.swift
//  Birthdays
//
//  Created by Geosat-RD01 on 2015/11/11.
//  Copyright © 2015年 Dominik Hauser. All rights reserved.
//

import UIKit
import XCTest
import Birthdays
import CoreData
import AddressBookUI

class PeopleListViewControllerTests: XCTestCase {
    
    var viewController: PeopleListViewController!
    
    override func setUp() {
        super.setUp()
        
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PeopleListViewController") as! PeopleListViewController
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /***
    Unit tests in three parts called given, when and then.
    ‘Given’: sets up the environment;
    ‘when’: executes the code you want to test;
    ‘then’: checks for the expected result.
    ***/
    func testDataProviderHasTableViewPropertySetAfterLoading() {
        
        // "given"
        // 1. Creates an instance of MockDataProvider and sets it to the dataProvider property of the view controller
        let mockDataProvider = MockDataProvider()
        
        viewController.dataProvider = mockDataProvider
        
        // "when"
        // 2. Asserts that the tableView property is nil before the test.
        XCTAssertNil(mockDataProvider.tableView, "Before loading the table view should be nil")
        
        // 3. Accesses the view to trigger viewDidLoad().
        let _ = viewController.view
        
        // "then"
        // 4. Asserts that the test class’ tableView property is not nil and that it is set to the tableView of the view controller.
        XCTAssertTrue(mockDataProvider.tableView != nil, "The table view should be set")
        XCTAssert(mockDataProvider.tableView === viewController.tableView,
            "The table view should be set to the table view of the data source")
    }
    
    func testCallsAddPersonOfThePeopleDataSourceAfterAddingAPersion() {
        // given
        let mockDataSource = MockDataProvider()
        
        // 1. First you set the data provider of the view controller to an instance of your mock data provider.
        viewController.dataProvider = mockDataSource
        
        // when
        // 2. Then you create a contact by using ABPersonCreate().
        let record: ABRecord = ABPersonCreate().takeRetainedValue()
        ABRecordSetValue(record, kABPersonFirstNameProperty, "TestFirstname", nil)
        ABRecordSetValue(record, kABPersonLastNameProperty, "TestLastname", nil)
        ABRecordSetValue(record, kABPersonBirthdayProperty, NSDate(), nil)
        
        // 3. Here you manually call the delegate method peoplePickerNavigationController(_:didSelectPerson:). Normally, calling delegate methods manually is a code smell, but it’s fine for testing purposes.
        viewController.peoplePickerNavigationController(ABPeoplePickerNavigationController(),
            didSelectPerson: record)
        
        // then
        // 4. Finally you assert that addPerson(_:) was called by checking that addPersonGotCalled of the data provider mock is true.
        XCTAssert(mockDataSource.addPersonGotCalled, "addPerson should have been called")
    }
    
    func testSortingCanBeChanged() {
        // given
        // 1. You first assign an instance of MockUserDefaults to userDefaults of the view controller
        let mockUserDefaults = MockUserDefaults(suiteName: "testing")!
        viewController.userDefaults = mockUserDefaults
        
        // when
        // 2. You then create an instance of UISegmentedControl, add the view controller as the target for the .ValueChanged control event and send the event.
        let segmentedControl = UISegmentedControl()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(viewController, action: "changeSorting:", forControlEvents: .ValueChanged)
        segmentedControl.sendActionsForControlEvents(.ValueChanged)
        
        // then
        // 3. Finally, you assert that setInteger(_:forKey:) of the mock user defaults was called. Note that you don’t check if the value was actually stored in NSUserDefaults, since that’s an implementation detail.
        XCTAssertTrue(mockUserDefaults.sortWasChanged, "Sort value in user defaults should be altered")
    }
}

class MockDataProvider: NSObject, PeopleListDataProviderProtocol {
    var addPersonGotCalled = false
    
    var managedObjectContext: NSManagedObjectContext?
    weak var tableView: UITableView!
    func addPerson(personInfo: PersonInfo) { addPersonGotCalled = true}
    func fetch() { }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

class MockUserDefaults: NSUserDefaults {
    var sortWasChanged = false
    override func setInteger(value: Int, forKey defaultName: String) {
        if defaultName == "sort" {
            sortWasChanged = true
        }
    }
}




