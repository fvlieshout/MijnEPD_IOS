////
////  ContextMenu.swift
////  MijnEPDTest
////
////  Created by Denise van Diermen on 07-08-18.
////  Copyright © 2018 Floor van Lieshout. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class ContextMenu {
//    
//    init (viewController: UIViewController) {
//    
//    // make MenuController
//    let myMenuController = UIMenuController.shared
//    
//    // make menu visible on MenuController
//        myMenuController.isMenuVisible = true
//    
//    // set the arrow down.
//        myMenuController.arrowDirection = UIMenuControllerArrowDirection.down
//    
//    // set rect、view
//        myMenuController.setTargetRect(CGRect.zero, in: viewController.view)
//    
//    // make MenuItems
//        let myMenuItem_1: UIMenuItem = UIMenuItem(title: "Menu1", action: #selector(onMenu1(_:)))
//    let myMenuItem_2: UIMenuItem = UIMenuItem(title: "Menu2", action: #selector(onMenu2(_:)))
//    let myMenuItem_3: UIMenuItem = UIMenuItem(title: "Menu3", action: #selector(onMenu3(_:)))
//    
//    // make an array to store MenuItems
//    let myMenuItems: NSArray = [myMenuItem_1, myMenuItem_2, myMenuItem_3]
//    
//    // add MenuItems to MenuController
//    myMenuController.menuItems = myMenuItems as? [UIMenuItem]
//}
//}
//// called when textField begin editing.
//func textFieldDidBeginEditing(textField: UITextField) {
//    print("textFieldDidBeginEditing:" + textField.text!)
//}
//
//// called when textField end editing.
//func textFieldShouldEndEditing(textField: UITextField) -> Bool {
//    print("textFieldShouldEndEditing:" + textField.text!)
//    return true
//}
//
//// make the action on Menu active.
//override func canPerformAction(action: Selector, withSender sender: AnyObject!) -> Bool {
//    if action == #selector(ViewController.onMenu1(_:)) || action == #selector(ViewController.onMenu2(_:)) || action == #selector(ViewController.onMenu3(_:)) {
//        return true
//    }
//    return false
//}
//
//// called when the menus are clicked.
//private func onMenu1(sender: UIMenuItem) {
//    print("onMenu1")
//}
//private func onMenu2(sender: UIMenuItem) {
//    print("onMenu2")
//}
//private func onMenu3(sender: UIMenuItem) {
//    print("onMenu3")
//}
//}
