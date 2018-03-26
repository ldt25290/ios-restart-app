//
//  ChatOtherMeetingCell.swift
//  LetGo
//
//  Created by Dídac on 20/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol OtherMeetingCellDelegate: class {
    func acceptMeeting()
    func rejectMeeting()
}


class ChatOtherMeetingCell: UITableViewCell, ReusableCell {

    @IBOutlet weak var meetingContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationView: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var meetingDateLabel: UILabel!
    @IBOutlet weak var meetingTimeLabel: UILabel!

    @IBOutlet weak var actionsContainer: UIView!
    @IBOutlet weak var actionAccept: UIButton!
    @IBOutlet weak var actionReject: UIButton!

    @IBOutlet weak var messageDateLabel: UILabel!

    @IBOutlet weak var actionsContainerHeight: NSLayoutConstraint!

    @IBOutlet weak var locationLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var locationLabelTop: NSLayoutConstraint!
    @IBOutlet weak var locationViewWidth: NSLayoutConstraint!

    weak var delegate: OtherMeetingCellDelegate?

    weak var locationDelegate: MeetingCellImageDelegate?

    var coordinates: LGLocationCoordinates2D?

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
}


// MARK: - Public

extension ChatOtherMeetingCell {

    func setupLocation(locationName: String?, coordinates: LGLocationCoordinates2D?, date: Date, status: MeetingStatus) {

        self.coordinates = coordinates
        if let locationName = locationName, locationName.isEmpty {
            locationLabel.isHidden = true
            locationLabelHeight.constant = 0
            locationLabelTop.constant = 0
        }

        if let coords = coordinates {
            let mapStringUrl = "https://maps.googleapis.com/maps/api/staticmap?zoom=15&size=200x200&maptype=roadmap&markers=\(coords.latitude),\(coords.longitude)"

            if let url = URL(string: mapStringUrl) {
                locationView.lg_setImageWithURL(url, placeholderImage: nil) { [weak self] (result, url) in
                    if let _ = result.error {
                        self?.hideMapView()
                    }
                }
            } else {
                hideMapView()
            }
        } else {
            hideMapView()
        }

        locationLabel.isHidden = false
        locationLabel.text = locationName

        meetingDateLabel.text = date.prettyDateForMeeting()
        meetingTimeLabel.text = date.prettyTimeForMeeting()

        updateStatus(status: status)
    }

    private func hideMapView() {
        locationView.isHidden = true
        locationViewWidth.constant = 0
    }

    fileprivate func updateStatus(status: MeetingStatus) {
        switch status {
        case .pending:
            statusLabel.text = "_ Pending"
            statusLabel.textColor = UIColor.grayText
            statusIcon.image = #imageLiteral(resourceName: "ic_time")
            actionsContainerHeight.constant = 44
            actionsContainer.isHidden = false
        case .accepted:
            statusLabel.text = "_ Accepted"
            statusLabel.textColor = UIColor.asparagus
            statusIcon.image = #imageLiteral(resourceName: "ic_time")
            actionsContainerHeight.constant = 0
            actionsContainer.isHidden = true
        case .rejected:
            statusLabel.text = "_ Declined"
            statusLabel.textColor = UIColor.primaryColor
            statusIcon.image = #imageLiteral(resourceName: "ic_time")
            actionsContainerHeight.constant = 0
            actionsContainer.isHidden = true
        }
        layoutIfNeeded()
    }
}


// MARK: - Private

private extension ChatOtherMeetingCell {
    func setupUI() {
        meetingContainer.layer.cornerRadius = LGUIKitConstants.mediumCornerRadius
        meetingContainer.layer.shouldRasterize = true
        meetingContainer.layer.rasterizationScale = UIScreen.main.scale
        backgroundColor = UIColor.clear
        titleLabel.text = "_ Let's meet up on:"
        titleLabel.textColor = UIColor.grayText

        actionAccept.setTitle("_ Accept", for: .normal)
        actionReject.setTitle("_ Decline", for: .normal)
        locationButton.addTarget(self, action: #selector(locationTapped), for: .touchUpInside)

        locationView.cornerRadius = LGUIKitConstants.mediumCornerRadius
    }

    @objc func locationTapped() {
        guard let coords = coordinates else { return }
        let rect = locationView.convert(locationView.frame, to: nil)
        locationDelegate?.imagePressed(coordinates: coords, originPoint: rect.center)
    }

    @IBAction func acceptMeeting(_ sender: AnyObject) {
        delegate?.acceptMeeting()
        updateStatus(status: .accepted)
    }

    @IBAction func rejectMeeting(_ sender: AnyObject) {
        delegate?.rejectMeeting()
        updateStatus(status: .rejected)
    }
}
