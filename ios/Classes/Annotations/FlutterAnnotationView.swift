//
//  FlutterAnnotationView.swift
//  apple_maps_flutter
//
//  Created by Luis Thein on 30.03.21.
//

import Foundation
import MapKit

protocol ZPositionableAnnotation {
    var stickyZPosition: CGFloat {
        get
        set
    }
}

class FlutterAnnotationView: MKAnnotationView {

    /// Override the layer factory for this class to return a custom CALayer class
    override class var layerClass: AnyClass {
        return ZPositionableLayer.self
    }

    /// convenience accessor for setting zPosition
    var stickyZPosition: CGFloat {
        get {
            return (self.layer as! ZPositionableLayer).stickyZPosition
        }
        set {
            (self.layer as! ZPositionableLayer).stickyZPosition = newValue
        }
    }
    
    /// https://stackoverflow.com/questions/48487846/custom-mkmarkerannotationview-like-photos-app
    private lazy var containerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .white
        view.layer.cornerRadius = view.frame.width / 2
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageview = UIImageView()
        imageview.translatesAutoresizingMaskIntoConstraints = false
        imageview.image = image
        imageview.layer.cornerRadius = containerView.frame.width / 2
        imageview.contentMode = .scaleAspectFit
        imageview.clipsToBounds = true
        return imageview
    }()
    
    private lazy var bottomCornerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 4.0
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = OutlineLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.outlineWidth = 3.0
        label.outlineColor = .white
        return label
    }()
    
    // MARK: Initialization
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        // setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(text: String? = nil) {
        containerView.addSubview(bottomCornerView)
        bottomCornerView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15.0).isActive = true
        bottomCornerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        bottomCornerView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        bottomCornerView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        let angle = (39.0 * CGFloat.pi) / 180
        let transform = CGAffineTransform(rotationAngle: angle)
        bottomCornerView.transform = transform
        
        addSubview(containerView)
        containerView.addSubview(imageView)
        
        imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8.0).isActive = true
        imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8.0).isActive = true
        imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8.0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8.0).isActive = true
        
        if let text = text {
            addSubview(titleLabel)
            titleLabel.text = text
            titleLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 8.0).isActive = true
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            titleLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            // 高さは固定にしない
//            titleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
    }
}

class OutlineLabel: UILabel {
    var outlineWidth: CGFloat = 2.0
    var outlineColor: UIColor = .white

    override func drawText(in rect: CGRect) {
        let shadowOffset = self.shadowOffset
        let textColor = self.textColor

        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(outlineWidth)
        context?.setLineJoin(.round)
        context?.setTextDrawingMode(.stroke)

        self.textColor = outlineColor
        super.drawText(in: rect)

        context?.setTextDrawingMode(.fill)
        self.textColor = textColor
        super.drawText(in: rect)

        self.shadowOffset = shadowOffset
    }
}

@available(iOS 11.0, *)
class FlutterMarkerAnnotationView: MKMarkerAnnotationView {
    /// Override the layer factory for this class to return a custom CALayer class
    override class var layerClass: AnyClass {
        return ZPositionableLayer.self
    }
}

@available(iOS 11.0, *)
extension FlutterMarkerAnnotationView: ZPositionableAnnotation {
    /// convenience accessor for setting zPosition
    var stickyZPosition: CGFloat {
        get {
            return (self.layer as! ZPositionableLayer).stickyZPosition
        }
        set {
            (self.layer as! ZPositionableLayer).stickyZPosition = newValue
        }
    }
}

/// iOS 11 automagically manages the CALayer zPosition, which breaks manual z-ordering.
/// This subclass just throws away any values which the OS sets for zPosition, and provides
/// a specialized accessor for setting the zPosition
private class ZPositionableLayer: CALayer {

    /// no-op accessor for setting the zPosition
    override var zPosition: CGFloat {
        get {
            return super.zPosition
        }
        set {
            // do nothing
        }
    }

    /// specialized accessor for setting the zPosition
    var stickyZPosition: CGFloat {
        get {
            return super.zPosition
        }
        set {
            super.zPosition = newValue
        }
    }
}
