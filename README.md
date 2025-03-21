# DropDown: A Customizable Dropdown for iOS

## Introduction
This repository provides a **custom dropdown menu** for iOS, inspired by `AssistoLab/DropDown`. It allows developers to integrate a dropdown selection UI with minimal effort while offering flexibility in customization.

## Features
✅ **Anchor-based positioning** – Attach the dropdown to any `UIView`.  
✅ **Customizable UI** – Modify text color, font, border, and size.  
✅ **Selection handling** – Capture user selections via a closure callback.  
✅ **Multiple dismissal modes** – Tap-to-dismiss, automatic, and manual control.  
✅ **Lightweight & efficient** – No third-party dependencies.  

## Usage
```swift
let dropDown = DropDown()
dropDown.anchorView = myButton // Attach to a view
dropDown.dataSource = ["Option 1", "Option 2", "Option 3"]

// Handling selection
dropDown.selectionAction = { index, item in
    print("Selected item: \(item) at index \(index)")
    dropDown.hide() // Hide dropdown after selection
}

// Show dropdown
dropDown.show()

// Customization
dropDown.textColor = .blue
dropDown.textFont = .boldSystemFont(ofSize: 18)
dropDown.customWidth = 150
dropDown.bottomOffset = CGPoint(x: 0, y: 10)
dropDown.dismissMode = .onTap

// Programmatically select an item
dropDown.selectRow(at: 1) // Select second item

// Manually hide dropdown if needed
dropDown.hide()
