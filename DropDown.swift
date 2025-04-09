//
//  DropDown.swift
//  IntelRail
//
//  Created by Swapnil on 21/03/25.
//

import UIKit

class DropDown: UIView, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties
    var anchorView: UIView? // View to attach dropdown
    var dataSource: [String] = [] { didSet { tableView.reloadData() } }
    var selectionAction: ((Int, String) -> Void)?
    var cancelAction: (() -> Void)?
    var willShowAction: (() -> Void)?
    
    var direction: DropDownDirection = .any
    var bottomOffset: CGPoint = .zero
    var topOffset: CGPoint = .zero
    var dismissMode: DropDownDismissMode = .onTap
    var customWidth: CGFloat?
    var textColor: UIColor = .black
    var textFont: UIFont = .systemFont(ofSize: 16)
    
    private let tableView = UITableView()
    private var isVisible = false
    private var selectedRow: Int?
    private var backgroundTapGesture: UITapGestureRecognizer?
    
    enum DropDownDirection { case any, top, bottom }
    enum DropDownDismissMode { case onTap, automatic, manual }
    
    // MARK: - Init
    init() {
        super.init(frame: .zero)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 5
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        addSubview(tableView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds
    }
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        cell.textLabel?.textColor = textColor
        cell.textLabel?.font = textFont
        cell.backgroundColor = (indexPath.row == selectedRow) ? .gray.withAlphaComponent(0.1) : .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        selectionAction?(indexPath.row, dataSource[indexPath.row])
        tableView.reloadData()
        hide()
    }
    
    // MARK: - Show / Hide
    func show() {
        guard let anchorView = anchorView, let window = UIWindow.key else { return }

        willShowAction?()

        // Remove any previous dropdowns
        for subview in window.subviews {
            if let dropdown = subview as? DropDown {
                dropdown.hide()
            }
        }

        let anchorFrame = anchorView.convert(anchorView.bounds, to: window)
        let maxHeight: CGFloat = min(CGFloat(dataSource.count) * 44, 200)
        let width = customWidth ?? anchorFrame.width

        let spaceBelow = window.bounds.height - anchorFrame.maxY
        let spaceAbove = anchorFrame.minY

        var finalHeight = maxHeight
        var dropdownY = anchorFrame.maxY + bottomOffset.y

        var showAbove = false

        if spaceBelow < maxHeight && spaceAbove > spaceBelow {
            // Not enough room below, show above if more space
            showAbove = true
            finalHeight = min(spaceAbove - topOffset.y, maxHeight)
            dropdownY = anchorFrame.minY - finalHeight - topOffset.y
        } else {
            // Enough space below
            finalHeight = min(spaceBelow - bottomOffset.y, maxHeight)
            dropdownY = anchorFrame.maxY + bottomOffset.y
        }

        // Set frame
        self.frame = CGRect(x: anchorFrame.origin.x, y: dropdownY, width: width, height: finalHeight)

        // Add tap-capture background
        let backgroundView = UIView(frame: window.bounds)
        backgroundView.backgroundColor = UIColor.clear
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hide)))
        backgroundView.tag = 999
        window.addSubview(backgroundView)

        self.alpha = 0
        self.isHidden = false
        window.addSubview(self)

        UIView.animate(withDuration: 0.3) { self.alpha = 1 }
        isVisible = true
    }

    @objc func hide() {
        guard isVisible else { return }

        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { _ in
            self.isHidden = true
            self.removeFromSuperview()
            self.cancelAction?()
        }

        if let window = UIWindow.key {
            // Remove background view
            if let backgroundView = window.viewWithTag(999) {
                backgroundView.removeFromSuperview()
            }
        }

        isVisible = false
    }

    // MARK: - Select Row
    func selectRow(at index: Int) {
        guard index >= 0, index < dataSource.count else { return }
        selectedRow = index
        tableView.reloadData()
    }
}

extension UIWindow {
    static var window: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.currentUIWindow()
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
public extension UIApplication {
    func currentWindow() -> UIWindow? {
        let connectedScenes = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
        
        let window = connectedScenes.first?
            .windows
            .first { $0.isKeyWindow }

        return window
        
    }
}
