import MJRefresh

class RefreshHeader: MJRefreshNormalHeader {
    
    override func prepare() {
        super.prepare()
        loadingView?.style = .medium
        stateLabel?.isHidden = true
        lastUpdatedTimeLabel?.isHidden = true
        autoChangeTransparency(true)
    }
}
