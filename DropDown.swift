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
        tableView.layer.cornerRadius = 8
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
        cell.backgroundColor = (indexPath.row == selectedRow) ? .appLightGray : .white
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
        guard let anchorView = anchorView, let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        willShowAction?()
        
        let anchorFrame = anchorView.convert(anchorView.bounds, to: window)
        let width = customWidth ?? anchorFrame.width
        
        self.frame = CGRect(x: anchorFrame.origin.x,
                            y: anchorFrame.maxY + bottomOffset.y,
                            width: width,
                            height: min(CGFloat(dataSource.count) * 44, 200))
        
        self.alpha = 0
        self.isHidden = false
        for subview in window.subviews {
            if let dropdown = subview as? DropDown {
                dropdown.hide()
            }
        }
        window.addSubview(self)

        
        backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        backgroundTapGesture?.cancelsTouchesInView = false
        window.addGestureRecognizer(backgroundTapGesture!)
        
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
        
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }), let gesture = backgroundTapGesture {
            window.removeGestureRecognizer(gesture)
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
