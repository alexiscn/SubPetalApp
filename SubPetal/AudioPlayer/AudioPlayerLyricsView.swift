//
//  AudioPlayerLyricsView.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/7.
//

import UIKit

class AudioPlayerLyricsView: UIView {
    
    private let tableView = UITableView(frame: .zero)
    
    private var dataSource: [Lyrics.Sentence] = []
    
    private var currentIndex = 0
    
    private let placeholder = AudioPlayerLyricsPlaceholder()
    
    var loadingState: LyricsLoadingState = .loading {
        didSet {
            switch loadingState {
            case .loading:
                placeholder.isHidden = false
                tableView.isHidden = true
            case .success:
                placeholder.isHidden = true
                tableView.isHidden = false
            case .failed:
                placeholder.isHidden = false
                tableView.isHidden = true
            }
            placeholder.state = loadingState
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView.register(LyricsTableViewCell.self, forCellReuseIdentifier: LyricsTableViewCell.reuseIdentifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false
        addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        placeholder.isHidden = true
        addSubview(placeholder)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            placeholder.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            placeholder.topAnchor.constraint(equalTo: self.topAnchor),
            placeholder.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            placeholder.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLyric(_ lyric: Lyrics?) {
        dataSource = lyric?.sentences ?? []
        tableView.reloadData()
    }
    
    func updatePlaying(currentTime: TimeInterval) {
        guard let index = dataSource.firstIndex(where: { $0.start > Int(currentTime * 100) }) else {
            return
        }
        let lines = Int(bounds.height / 36)
        let lineNumber = max(0, min(dataSource.count - 1, index - 1))
        if lineNumber != currentIndex {
            tableView.deselectRow(at: IndexPath(row: currentIndex, section: 0), animated: true)
            tableView.selectRow(at: IndexPath(row: lineNumber, section: 0), animated: true, scrollPosition: .none)
            
            let targetIndex = max(lineNumber - lines/2, 0)
            tableView.setContentOffset(CGPoint(x: 0, y: CGFloat(targetIndex * 36)), animated: true)
            currentIndex = lineNumber
        }
    }
    
    func resetOnRotation() {
        tableView.setContentOffset(.zero, animated: false)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension AudioPlayerLyricsView: UITableViewDataSource, UITableViewDelegate {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LyricsTableViewCell.reuseIdentifier, for: indexPath) as! LyricsTableViewCell
        cell.backgroundColor = .clear
        cell.update(sentence: dataSource[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
    }
}

class LyricsTableViewCell: UITableViewCell {
    
    class var reuseIdentifier: String { return "LyricsTableViewCell" }
    
    var sentence: Lyrics.Sentence?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel?.textAlignment = .center
        textLabel?.font = UIFont.systemFont(ofSize: 15)
        textLabel?.textColor = .tertiaryLabel
        selectedBackgroundView = UIView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let foregroundColor: UIColor = selected ? .label: .tertiaryLabel
        let font = selected ? UIFont.systemFont(ofSize: 15, weight: .medium): UIFont.systemFont(ofSize: 15)
        textLabel?.text = sentence?.content
        textLabel?.textColor = foregroundColor
        textLabel?.font = font
    }
    
    func update(sentence: Lyrics.Sentence) {
        self.sentence = sentence
        textLabel?.text = sentence.content
    }
}

enum LyricsLoadingState {
    case success
    case loading
    case failed
}

class AudioPlayerLyricsPlaceholder: UIView {
    
    var searchCommand: (() -> Void)?
    
    private let titleLabel = UILabel()
    
    private let searchButton = UIButton(type: .custom)
    
    private let stackView = UIStackView()
    
    var state: LyricsLoadingState = .loading {
        didSet {
            switch state {
            case .loading:
                let title = "Loading lyrics"
                titleLabel.attributedText = NSAttributedString(string: title, attributes: [
                    .foregroundColor: UIColor.secondaryLabel,
                    .font: UIFont.systemFont(ofSize: 14)
                ])
            case .success:
                break
            case .failed:
                let title = "Load lyrics failed, please try search manually"
                titleLabel.attributedText = NSAttributedString(string: title, attributes: [
                    .foregroundColor: UIColor.secondaryLabel,
                    .font: UIFont.systemFont(ofSize: 14)
                ])
            }
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(searchButton)
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        let searchButtonTitle = "Search lyrics"
        searchButton.setAttributedTitle(NSAttributedString(string: searchButtonTitle, attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 15, weight: .medium)
        ]), for: .normal)
        searchButton.addTarget(self, action: #selector(onSearchButtonClicked), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onSearchButtonClicked() {
        searchCommand?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch state {
        case .success:
            titleLabel.isHidden = true
            searchButton.isHidden = true
        case .loading:
            titleLabel.isHidden = false
            searchButton.isHidden = true
        case .failed:
            titleLabel.isHidden = false
            searchButton.isHidden = false
        }
    }
}
