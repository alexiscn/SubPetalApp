//
//  AudioPlayerPlaylistView.swift
//  SubPetal
//
//  Created by alexiscn on 2022/6/7.
//

import UIKit
import SubsonicKit
import Defaults

class AudioPlaylistView: UIView {
     
    private let tableView = UITableView()
    
    var dataSource: [Song] {
        return AudioPlayerManager.shared.queue.songs
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.backgroundColor = .clear
        tableView.register(AudioPlaylistCell.self, forCellReuseIdentifier: AudioPlaylistCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        addSubview(tableView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds
    }
    
    func select(song: Song) {
        if let index = dataSource.firstIndex(where: { $0.id == song.id }) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
            tableView.scrollToRow(at: indexPath, at: .none, animated: false)
        }
    }
    
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension AudioPlaylistView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AudioPlaylistCell.reuseIdentifier, for: indexPath) as! AudioPlaylistCell
        cell.update(dataSource[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource[indexPath.item]
        AudioPlayerManager.shared.play(item)
    }
}

class AudioPlaylistCell: UITableViewCell {
    
    class var reuseIdentifier: String { return "MusicPlayerPlaylistCell" }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectedBackgroundView = UIView()
        textLabel?.textColor = .label
        textLabel?.font = UIFont.systemFont(ofSize: 16)
        
        detailTextLabel?.textColor = .secondaryLabel
        detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
    }
    
    func update(_ song: Song) {
        textLabel?.text = song.title
        let artist = song.artist ?? "Artist"
        let album = song.album ?? "Single"
        detailTextLabel?.text = artist + " - " + album
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        textLabel?.textColor = selected ? UIColor.purple: UIColor.label
    }
}
