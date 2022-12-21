//
//  DownloadingCell.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/14.
//

import UIKit
import Tiercel

class DownloadingCell: UICollectionViewCell {
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let cancelButton = UIButton()
    let pauseResumeButton = UIButton()
    
    var task: DownloadTask?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.textColor = .label
        titleLabel.font = .preferredFont(forTextStyle: .footnote)
        
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.font = .preferredFont(forTextStyle: .caption1)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        contentView.addSubview(stackView)
        
        cancelButton.setImage(UIImage(systemName: "xmark.circle"), for: [])
        pauseResumeButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
        pauseResumeButton.setImage(UIImage(systemName: "play.circle"), for: .selected)
        
        contentView.addSubview(cancelButton)
        contentView.addSubview(pauseResumeButton)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        pauseResumeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: stackView.trailingAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 40),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: pauseResumeButton.leadingAnchor),
            pauseResumeButton.widthAnchor.constraint(equalToConstant: 40),
            pauseResumeButton.heightAnchor.constraint(equalToConstant: 40),
            pauseResumeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pauseResumeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pauseResumeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10)
        ])
        
        cancelButton.addTarget(self, action: #selector(onCancelButtonClicked), for: .touchUpInside)
        pauseResumeButton.addTarget(self, action: #selector(onPauseResumeButtonClicked), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        pauseResumeButton.isHidden = false
        pauseResumeButton.isSelected = false
        cancelButton.isHidden = false
    }
    
    func render(_ task: DownloadTask) {
        self.task = task
        updateUI(with: task)
        task.progress { [weak self] task in
            guard let self = self else { return }
            self.updateUI(with: task)
        }
    }
    
    func updateUI(with task: DownloadTask) {
        let id = URL(fileURLWithPath: task.filePath).deletingPathExtension().lastPathComponent
        let song = Context.current?.streamCache.loadSong(id: id)
        titleLabel.text = song?.title
        
        var subtitles = [String]()
        subtitles.append(task.status.title)
        
        switch task.status {
        case .running:
            let processed = Formatter.byteCountFormatter.string(fromByteCount: task.progress.completedUnitCount)
            let totalSize = Formatter.byteCountFormatter.string(fromByteCount: task.progress.totalUnitCount)
            subtitles.append(processed + "/" + totalSize)
            subtitles.append(task.speedString)
        case .succeeded:
            let totalSize = Formatter.byteCountFormatter.string(fromByteCount: task.progress.totalUnitCount)
            subtitles.append(totalSize)
            pauseResumeButton.isHidden = true
            cancelButton.isHidden = true
        case .suspended:
            let processed = Formatter.byteCountFormatter.string(fromByteCount: task.progress.completedUnitCount)
            let totalSize = Formatter.byteCountFormatter.string(fromByteCount: task.progress.totalUnitCount)
            subtitles.append(processed + "/" + totalSize)
            pauseResumeButton.isSelected = true
        default:
            print("TODO")
        }
    
        subtitleLabel.text = subtitles.joined(separator: " ")
    }

    @objc private func onCancelButtonClicked() {
        guard let task = task else {
            return
        }
        Context.current?.sessionManager.cancel(task)
    }
    
    @objc private func onPauseResumeButtonClicked() {
        guard let task = task else {
            return
        }
        if task.status == .suspended {
            Context.current?.sessionManager.start(task)
        } else {
            Context.current?.sessionManager.suspend(task)
        }
    }
}

extension Tiercel.Status {
    
    var title: String {
        switch self {
        case .running: return "Downloading"
        case .failed: return "Failed"
        case .canceled: return "Canceled"
        case .removed: return "Removed"
        case .succeeded: return "Succeed"
        case .suspended: return "Suspended"
        case .waiting: return "Waiting"
        default: return ""
        }
    }
    
}
