//
//  ZlTableViewTreeCell.swift
//  ListView
//
//  Created by zcz on 2024/2/29.
//

import UIKit

protocol ZLTableViewTreeCellProtocol: AnyObject {
    func pancell(_ cell: UITableViewCell, oringX: CGFloat)
    func endPanCell(_ cell: UITableViewCell)
    func unbindAction(_ cell: UITableViewCell)
}

class ZlTableViewTreeCell: UITableViewCell {
    
    static let indentSize: CGFloat = 30
    static let leftMargin: CGFloat = 12
    static let tipImageSize: CGSize = CGSize(width: 16, height: 16)
    static let avaterViewSize: CGSize = CGSize(width: 24, height: 24)
    static let viewSpaceMargin: CGFloat = 8
    static let titleRightMargin: CGFloat = -40

    weak var currentModel: ListModel?
    
    weak var delegate: ZLTableViewTreeCellProtocol?
    
    private lazy var tipImageView = {
       let img = UIImageView()
        img.contentMode = .center
        img.image = UIImage(named: "vk_hidden_more")
        return img
    }()
    
    private var lastPanX: CGFloat = 0
    private var tipImageMaxX: CGFloat = 0
    private var tipImageMinX: CGFloat = 0

    private var canShowScrollIndicator: Bool = false

    
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
        lab.lineBreakMode = .byClipping
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
        pan.delegate = self
        return pan
    }()
    
    private lazy var scrollIndicator: UIImageView = {
        let img = UIImageView()
         img.contentMode = .scaleAspectFit
        img.backgroundColor = UIColor(hex: "#D8D8D8")
        img.layer.cornerRadius = 7/2.0
        img.isHidden = true
        return img
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
        self.addSubview(scrollIndicator)

        tipImageView.snp.makeConstraints { make in
            make.left.equalTo(Self.leftMargin)
            make.size.equalTo(Self.tipImageSize)
        }
        
        avaterView.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.centerY.equalTo(tipImageView)
            make.size.equalTo(Self.avaterViewSize)
            make.left.equalTo(tipImageView.snp.right).offset(Self.viewSpaceMargin)
        }
        
        titleLable.snp.makeConstraints { make in
            make.left.equalTo(avaterView.snp.right).offset(Self.viewSpaceMargin)
            make.top.equalTo(12)
            make.right.equalToSuperview().offset(Self.titleRightMargin)
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
        
        scrollIndicator.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(0)
            make.right.lessThanOrEqualToSuperview()
            make.height.equalTo(7)
            make.width.equalTo(50)
        }
        print("scrollIndicator 1 = 50")
    }
    
    func setData(model: ListModel, showUnbind: Bool = false, delegate: ZLTableViewTreeCellProtocol? = nil) {
        currentModel = model
        self.delegate = delegate
        let showMore = model.showMore
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
        let title = model.text
        titleLable.text = title + title + title + title
        
        let level: Int = model.level
        var leftMargin: CGFloat = Self.indentSize * CGFloat(level) + 12
        tipImageMaxX = leftMargin
//        tipImageMinX = leftMargin
        
        if let upViewOffSetX = model.supperOffSetX {
            leftMargin = upViewOffSetX + Self.indentSize
        }
        tipImageView.snp.updateConstraints { make in
            make.left.equalTo(leftMargin)
        }
        
        titleLable.superview?.layoutIfNeeded()
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
        case .ended:
            self.endPan()
            delegate?.endPanCell(self)
        default:
            self.lastPanX = 0
        }
    }
    
    func endPan() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.scrollIndicator.isHidden = true
        }
    }
    
    func horizontalMigration(_ orgx: CGFloat) {
        let scrollIndicatorX = scrollIndicator.frame.minX
        let x = handlePanOriginX(orgx)
        tipImageView.snp.updateConstraints { make in
            make.left.equalTo(x)
        }
        let minOffX = currentModel?.srcollSpace ?? 0
        if minOffX != 0 {
            var value: CGFloat = (x - tipImageMaxX + minOffX) * (self.bounds.width - scrollIndicator.frame.width)/minOffX
            if value < 0 {
                value = 0
            }
            if scrollIndicator.superview != nil {
                var width = self.bounds.width - minOffX
                if width < 50 {
                    width = 50
                }
                
                if width > 200 {
                    width = 200
                }
                
                if scrollIndicatorX != value, self.canShowScrollIndicator {
                    self.scrollIndicator.isHidden = false
                }
                
                scrollIndicator.snp.remakeConstraints { make in
                    make.left.equalTo(value)
                    make.bottom.equalToSuperview()
                    make.right.lessThanOrEqualToSuperview()
                    make.height.equalTo(7)
                    make.width.equalTo(width)
                }
            }
        } else {
            scrollIndicator.isHidden = true
        }
        tipImageView.superview?.layoutIfNeeded()
    }
    
    private func handlePanOriginX(_ orgx: CGFloat) -> CGFloat {
        var x = tipImageView.frame.minX + orgx
        let minOffX = currentModel?.srcollSpace ?? 0
        
        if x < tipImageMaxX - minOffX, orgx < 0 {
            x = tipImageMaxX - minOffX
        }
        
        if x > tipImageMaxX {
            x = tipImageMaxX
        }
        return x
    }
    
    func showScrollIndicator(show: Bool, oringX: CGFloat = 0) {
        self.canShowScrollIndicator = show
    }
    
    func getCurrentOffSetX() -> CGFloat? {
        tipImageView.superview?.layoutIfNeeded()
        return tipImageView.frame.origin.x
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
    
    static func getMinX(title: String, level: Int) -> CGFloat {
        var maxX: CGFloat = self.leftMargin + self.tipImageSize.width + self.viewSpaceMargin + self.avaterViewSize.width + self.viewSpaceMargin + CGFloat(level) * self.indentSize
        
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 16)
        lab.text = title + title + title + title
        lab.sizeToFit()
        maxX = maxX + lab.frame.width
        let offSetX = abs(Self.titleRightMargin) + maxX - UIScreen.main.bounds.width
        if offSetX <= 0 {
            return 0
        } else {
            return offSetX
        }
    }

}

extension ZlTableViewTreeCell {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let view = gestureRecognizer.view
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let offSet = pan.translation(in: view)
            if offSet.y <= offSet.x {
                if pan == self.pan {
                    return true
                }
                return false
            }
        }
        return true
    }
}
