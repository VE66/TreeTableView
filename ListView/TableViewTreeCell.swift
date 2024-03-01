//
//  TableViewTreeCell.swift
//  ListView
//
//  Created by zcz on 2024/2/29.
//

import UIKit

protocol TableViewTreeCellProtocol: AnyObject {
    func pancell(_ cell: UITableViewCell, oringX: CGFloat)
    func unbindAction(_ cell: UITableViewCell)
}

class TableViewTreeCell: UITableViewCell {
    
    var exceedWidth: ((CGFloat) -> Void)?
    weak var delegate: TableViewTreeCellProtocol?
    
    private lazy var tipImageView = {
       let img = UIImageView()
        img.contentMode = .center
        img.image = UIImage(named: "vk_hidden_more")
        return img
    }()
    
    private var lastPanX: CGFloat = 0
    private var tipImageMaxX: CGFloat = 0
    private lazy var avaterView = {
        let img = UIImageView()
         img.contentMode = .scaleAspectFit
//         img.image = UIImage(named: "vk_hidden_more")
        img.backgroundColor = UIColor.red
         return img
    }()
    
    private lazy var titleLable = {
      let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 16)
        
        return lab
    }()
    
    private lazy var unbindView = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "vk_group_unbind"), for: .normal)
        btn.imageView?.contentMode = .center
        btn.addTarget(self, action: #selector(unbindAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var separatorLine = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 232/255.0, green: 234/255.0, blue: 239/255.0, alpha: 1.0)
        return view
    }()
    
    private lazy var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(_:)))
        
        return pan
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    private func setupUI() {
        self.contentView.addSubview(tipImageView)
        self.contentView.addSubview(avaterView)
        self.contentView.addSubview(titleLable)
        self.addSubview(unbindView)
        self.addSubview(separatorLine)

        tipImageView.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        
        avaterView.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.centerY.equalTo(tipImageView)
            make.size.equalTo(CGSize(width: 24, height: 24))
            make.left.equalTo(tipImageView.snp.right).offset(8)
        }
        
        titleLable.snp.makeConstraints { make in
            make.left.equalTo(avaterView.snp.right).offset(8)
            make.top.equalTo(12)
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalTo(-12)
        }
        
        unbindView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        separatorLine.snp.makeConstraints { make in
            make.left.equalTo(tipImageView)
            make.bottom.equalToSuperview()
            make.right.equalTo(-16)
            make.height.equalTo(0.5)
        }
    }
    
    func setData(title: String?, avater: String?, showMore: TreeTipStatus = .close, level: Int = 0, showUnbind: Bool = false, delegate: TableViewTreeCellProtocol? = nil) {
        self.delegate = delegate
        if showMore == .show {
            tipImageView.image = UIImage(named: "vk_show_more")
            tipImageView.isHidden = false
        } else if showMore == .close {
            tipImageView.isHidden = false
            tipImageView.image = UIImage(named: "vk_hidden_more")
        } else {
            tipImageView.isHidden = true
        }
        
        if showUnbind {
            unbindView.isHidden = false
        } else {
            unbindView.isHidden = true
        }
        let title = title ?? ""
        titleLable.text = title + title + title + title
        
        let leftMargin: CGFloat = CGFloat(30 * indentationLevel)
        tipImageMaxX = leftMargin + 12
        tipImageView.snp.updateConstraints { make in
            make.left.equalTo(leftMargin + 12)
        }
        
        titleLable.superview?.layoutIfNeeded()
        let frame = titleLable.frame
        let maxX = UIScreen.main.bounds.width - 36
        if level > 1 {
            self.addPanGesture()
        }
        
    }
    
    private func addPanGesture() {
        if self.contentView.gestureRecognizers?.contains(pan) == false {
            self.contentView.addGestureRecognizer(pan)
        }
    }
    
    @objc func panGestureRecognizer(_ pan: UIPanGestureRecognizer) {
        let panX = pan.location(in: self.contentView).x
        switch pan.state {
        case .began:
            self.lastPanX = panX
        case .changed:
            let x = panX - self.lastPanX
            tipImageView.superview?.layoutIfNeeded()
            self.horizontalMigration(x)
            delegate?.pancell(self, oringX: x)
            self.lastPanX = panX
        default:
            self.lastPanX = 0
        }
    }
    
    func horizontalMigration(_ orgx: CGFloat) {
        var x = tipImageView.frame.minX + orgx
        if x < 12 {
            x = 12
        }
        if x > tipImageMaxX {
            x = tipImageMaxX
        }
        tipImageView.snp.updateConstraints { make in
            make.left.equalTo(x)
        }
        tipImageView.superview?.layoutIfNeeded()
    }
    
    @objc func unbindAction(_ sender: UIButton) {
        delegate?.unbindAction(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
