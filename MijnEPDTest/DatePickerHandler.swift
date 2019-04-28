//
//  DatePickerHandler.swift
//  MijnEPDTest
//
//  Created by Thijs Frederik van Haaps on 28/04/2019.
//  Copyright © 2019 Floor van Lieshout. All rights reserved.
//

import Foundation
import UIKit

class DatePickerHandler {
    
    var txtDatePicker: UITextField
    var view: UIView
    let datePicker = UIDatePicker()
    
    
    init(textFieldDate: UITextField, deView: UIView) {
        self.txtDatePicker = textFieldDate
        self.view = deView
    }
    
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        datePicker.locale = nederlands
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        // add toolbar to textField
        txtDatePicker.inputAccessoryView = toolbar
        // add datepicker to textField
        txtDatePicker.inputView = datePicker
        
    }
    
    @objc func donedatePicker(){
        //For date formate
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        txtDatePicker.text = formatter.string(from: datePicker.date)
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        //cancel button dismiss datepicker dialog
        self.view.endEditing(true)
    }
}

