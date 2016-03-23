//
//  AdminViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 23/3/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import FLEX
import FlipTheSwitch

class AdminViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView = UITableView()
    
    static func canOpenAdminPanel() -> Bool {
        var compiledInGodMode = false
        #if GOD_MODE
            compiledInGodMode = true
        #endif
        return compiledInGodMode || UserDefaultsManager.sharedInstance.loadIsGod()
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        view.addSubview(tableView)
        title = "🙏 God Panel 🙏"
        
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: UIBarButtonItemStyle.Plain,
            target: self, action: Selector("closeButtonPressed"))
        self.navigationItem.leftBarButtonItem = closeButton;
    }
    
    func closeButtonPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }


    // MARK: - TableView
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleForCellAtIndexPath(indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            openFlex()
        case 1:
            openFeatureToggle()
        default:
            break
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    // MARK: - Private
    
    private func openFlex() {
        FLEXManager.sharedManager().showExplorer()
    }
    
    private func openFeatureToggle() {
        let bundle = NSBundle(path: NSBundle(forClass: FTSFeatureConfigurationViewController.classForCoder())
            .pathForResource("FlipTheSwitch", ofType: "bundle")!)
        let storyboard = UIStoryboard(name: "FlipTheSwitch", bundle: bundle)
        let view = storyboard.instantiateInitialViewController() as! UINavigationController
        let vc = view.viewControllers.first!
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func titleForCellAtIndexPath(indexPath: NSIndexPath) -> String {
        switch indexPath.row {
        case 0:
            return "👾 FLEX"
        case 1:
            return "🎪 Feature Toggle"
        default:
            return "Not implemented"
        }
    }
}
