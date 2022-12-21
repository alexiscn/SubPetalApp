import Alamofire
import Foundation

/// Client for Subsonic service
public class SubsonicClient {
    
    public static var debug = true
    
    public let baseURL: URL
    /// A unique string identifying the client application.
    public var clientName: String = "awesomeappname"
    public var username: String
    public var password: String
    public var version = "1.15.0"
    private let salt: String
    
    /// Create an instance of SubsonicClient.
    /// - Parameters:
    ///   - baseURL: The server base url.
    ///   - username: The username.
    ///   - password: The password.
    public init(baseURL: URL, username: String, password: String) {
        self.baseURL = baseURL.appendingPathComponent("rest")
        self.username = username
        self.password = password
        self.salt = String.randomSalt(length: 6)
    }
    
    /// Used to test connectivity with the server. Takes no extra parameters.
    /// - Returns: Returns an `EmptyResponse` element on success.
    @discardableResult
    public func ping() async throws -> EmptyResponse {
        return try await request(path: "ping")
    }
    
    /// Returns all configured top-level music folders. Takes no extra parameters.
    /// - Returns: Returns a `MusicFoldersResponse` element with a nested `musicFolders` element on success.
    public func getMusicFolders() async throws -> MusicFoldersResponse {
        return try await request(path: "getMusicFolders")
    }
    
    /// Returns an indexed structure of all artists.
    /// - Parameters:
    ///   - musicFolderId: If specified, only return artists in the music folder with the given ID. See getMusicFolders.
    ///   - ifModifiedSince: If specified, only return a result if the artist collection has changed since the given time (in milliseconds since 1 Jan 1970).
    /// - Returns: Returns an `IndexesResponse` element with a nested `indexes` element on success.
    public func getIndexes(musicFolderId: String? = nil, ifModifiedSince: Bool = false) async throws -> IndexesResponse {
        var params = [String: Any]()
        if let musicFolderId = musicFolderId {
            params["musicFolderId"] = musicFolderId
        }
        params["ifModifiedSince"] = ifModifiedSince
        return try await request(path: "getIndexes")
    }
    
    /// Returns a listing of all files in a music directory. Typically used to get list of albums for an artist, or list of songs for an album.
    /// - Parameter id: A string which uniquely identifies the music folder. Obtained by calls to getIndexes or getMusicDirectory.
    /// - Returns: Returns a `MusicDirectoryResponse` element with a nested `directory` element on success.
    public func getMusicDirectory(id: String) async throws -> MusicDirectoryResponse {
        return try await request(path: "getMusicDirectory", params: ["id": id])
    }
    
    /// Returns all genres.
    /// - Returns: Returns a `GenresResponse` element with a nested `genres` element on success.
    public func getGenres() async throws -> GenresResponse {
        return try await request(path: "getGenres")
    }
    
    /// Similar to getIndexes, but organizes music according to ID3 tags.
    /// - Parameter musicFolderId: If specified, only return artists in the music folder with the given ID.
    /// - Returns: Returns an `ArtistsResponse` element with a nested `artists` element on success.
    public func getArtists(musicFolderId: String? = nil) async throws -> ArtistsResponse {
        var params = [String: String]()
        if let musicFolderId = musicFolderId {
            params["musicFolderId"] = musicFolderId
        }
        return try await request(path: "getArtists", params: params)
    }
    
    /// Returns details for an artist, including a list of albums. This method organizes music according to ID3 tags. (Since 1.8.0)
    /// - Parameter id: The artist ID.
    /// - Returns: Returns an `ArtistResponse` element with a nested `artist` element on success.
    public func getArtist(id: String) async throws -> ArtistResponse {
        return try await request(path: "getArtist", params: ["id": id])
    }
    
    /// Returns details for an album, including a list of songs. This method organizes music according to ID3 tags. (Since 1.8.0)
    /// - Parameter id: The album ID.
    /// - Returns: Returns an `AlbumResponse` object with a nested `album` element on success.
    public func getAlbum(id: String) async throws -> AlbumResponse {
        return try await request(path: "getAlbum", params: ["id": id])
    }
    
    
    /// Returns details for a song.
    /// - Parameter id: The song ID.
    /// - Returns: Returns a `SongResponse` element with a nested `song` element on success.
    public func getSong(id: String) async throws -> SongResponse {
        return try await request(path: "getSong", params: ["id": id])
    }
    
    public func getVideos() {
        
    }
    
    public func getVideoInfo() {
        
    }
    
    /// Returns artist info with biography, image URLs and similar artists, using data from last.fm.
    /// - Parameters:
    ///   - id: The artist, album or song ID.
    ///   - count: Max number of similar artists to return.
    ///   - includeNotPresent: Whether to return artists that are not present in the media library.
    /// - Returns: Returns an `ArtistInfoResponse` object with a nested `artistInfo` element on success.
    public func getArtistInfo(id: String, count: Int = 20, includeNotPresent: Bool = false) async throws -> ArtistInfoResponse {
        var params = [String: Any]()
        params["id"] = id
        params["count"] = count
        params["includeNotPresent"] = false
        return try await request(path: "getArtistInfo", params: params)
    }
    
    /// Similar to getArtistInfo, but organizes music according to ID3 tags.
    /// - Parameters:
    ///   - id: The artist ID.
    ///   - count: Max number of similar artists to return.
    ///   - includeNotPresent: Whether to return artists that are not present in the media library.
    /// - Returns: Returns an `ArtistInfo2Response` object with a nested `artistInfo2` element on success.
    public func getArtistInfo2(id: String, count: Int = 20, includeNotPresent: Bool = false) async throws -> ArtistInfo2Response {
        var params = [String: Any]()
        params["id"] = id
        params["count"] = count
        params["includeNotPresent"] = false
        return try await request(path: "getArtistInfo2", params: params)
    }
    
    /// Returns album notes, image URLs etc, using data from last.fm. Since 1.14.0
    /// - Parameter id: The album or song ID.
    /// - Returns: Returns an `AlbumInfoResponse` object with a nested `albumInfo` element on success.
    public func getAlbumInfo(id: String) async throws -> AlbumInfoResponse {
        return try await request(path: "getAlbumInfo", params: ["id": id])
    }
    
    /// Similar to getAlbumInfo, but organizes music according to ID3 tags. Since 1.14.0
    /// - Parameter id: The album ID.
    /// - Returns: Returns an `AlbumInfo2Response` object with a nested `albumInfo2` element on success.
    public func getAlbumInfo2(id: String) async throws -> AlbumInfo2Response {
        return try await request(path: "getAlbumInfo2", params: ["id": id])
    }
    
    /// Returns a random collection of songs from the given artist and similar artists, using data from last.fm. Typically used for artist radio features.
    /// - Parameters:
    ///   - id: The artist, album or song ID.
    ///   - count: Max number of songs to return.
    /// - Returns: Returns a `SimilarSongsResponse` object with a nested `similarSongs` element on success.
    public func getSimilarSongs(id: String, count: Int = 50) async throws -> SimilarSongsResponse {
        var params = [String: Any]()
        params["id"] = id
        params["count"] = count
        return try await request(path: "getSimilarSongs", params: params)
    }
    
    /// Similar to getSimilarSongs, but organizes music according to ID3 tags.
    /// - Parameters:
    ///   - id: The artist ID.
    ///   - count: Max number of songs to return.
    /// - Returns: Returns a `SimilarSongs2Response` object with a nested `similarSongs2` element on success.
    public func getSimilarSongs2(id: String, count: Int = 50) async throws -> SimilarSongs2Response {
        var params = [String: Any]()
        params["id"] = id
        params["count"] = count
        return try await request(path: "getSimilarSongs2", params: params)
    }
    
    /// Returns top songs for the given artist, using data from last.fm.
    /// - Parameters:
    ///   - artist: The artist name.
    ///   - count: Max number of songs to return.
    /// - Returns: Returns a `TopSongsResponse` object with a nested `topSongs` element on success.
    public func getTopSongs(artist: String, count: Int = 50) async throws -> TopSongsResponse {
        var params = [String: Any]()
        params["artist"] = artist
        params["count"] = count
        return try await request(path: "getTopSongs", params: params)
    }
    
    /// Returns a list of random, newest, highest rated etc. albums. Similar to the album lists on the home page of the Subsonic web interface.
    /// - Parameters:
    ///   - type: The list type. Must be one of the following: random, newest, highest, frequent, recent. Since 1.8.0 you can also use alphabeticalByName or alphabeticalByArtist to page through all albums alphabetically, and starred to retrieve starred albums. Since 1.10.1 you can use byYear and byGenre to list albums in a given year range or genre.
    ///   - size: The number of albums to return. Max 500.
    ///   - offset: The list offset. Useful if you for example want to page through the list of newest albums.
    /// - Returns: Returns an `AlbumListResponse` object with a nested `albumList` element on success.
    public func getAlbumList(type: AlbumListType, size: Int = 10, offset: Int = 0) async throws -> AlbumListResponse {
        var params = [String: Any]()
        params["type"] = type.rawValue
        params["size"] = size
        params["offset"] = offset
        return try await request(path: "getAlbumList", params: params)
    }
    
    /// Similar to `getAlbumList`, but organizes music according to ID3 tags.
    /// - Parameters:
    ///   - type: The list type. Must be one of the following: random, newest, frequent, recent, starred, alphabeticalByName or alphabeticalByArtist. Since 1.10.1 you can use byYear and byGenre to list albums in a given year range or genre.
    ///   - size: The number of albums to return. Max 500.
    ///   - offset: The list offset. Useful if you for example want to page through the list of newest albums.
    /// - Returns: Returns an `AlbumList2Response` object with a nested `albumList2` element on success.
    public func getAlbumList2(type: AlbumListType, size: Int = 10, offset: Int = 0) async throws -> AlbumList2Response {
        var params = [String: Any]()
        params["type"] = type.rawValue
        params["size"] = size
        params["offset"] = offset
        return try await request(path: "getAlbumList2", params: params)
    }
    
    /// Returns random songs matching the given criteria.
    /// - Parameters:
    ///   - size: The maximum number of songs to return. Max 500.
    ///   - genre: Only returns songs belonging to this genre.
    ///   - fromYear: Only return songs published after or in this year.
    ///   - toYear: Only return songs published before or in this year.
    ///   - musicFolderId: Only return songs in the music folder with the given ID.
    /// - Returns: Returns a `RandomSongsResponse` object with a nested `randomSongs` element on success.
    public func getRandomSongs(size: Int = 10,
                               genre: String? = nil,
                               fromYear: String? = nil,
                               toYear: String? = nil,
                               musicFolderId: String? = nil) async throws -> RandomSongsResponse {
        var params = [String: Any]()
        params["size"] = size
        if let genre = genre {
            params["genre"] = genre
        }
        if let fromYear = fromYear {
            params["fromYear"] = fromYear
        }
        if let toYear = toYear {
            params["toYear"] = toYear
        }
        if let musicFolderId = musicFolderId {
            params["musicFolderId"] = musicFolderId
        }
        return try await request(path: "getRandomSongs", params: params)
    }
    
    /// Returns songs in a given genre.
    /// - Parameters:
    ///   - genre: The genre, as returned by `getGenres`.
    ///   - count: The maximum number of songs to return. Max 500.
    ///   - offset: The offset. Useful if you want to page through the songs in a genre.
    ///   - musicFolderId: Only return albums in the music folder with the given ID.
    /// - Returns: Returns a `SongsByGenreResponse` element with a nested `songsByGenre` element on success.
    public func getSongsByGenre(genre: String, count: Int = 10, offset: Int = 10, musicFolderId: String? = nil) async throws -> SongsByGenreResponse {
        var params = [String: Any]()
        params["genre"] = genre
        params["count"] = count
        params["offset"] = offset
        if let musicFolderId = musicFolderId {
            params["musicFolderId"] = musicFolderId
        }
        return try await request(path: "getSongsByGenre", params: params)
    }
    
    /// Returns what is currently being played by all users. Takes no extra parameters.
    /// - Returns: Returns a `NowPlayingResponse` element with a nested `nowPlaying` element on success.
    public func getNowPlaying() async throws -> NowPlayingResponse {
        return try await request(path: "getNowPlaying")
    }
    
    /// Returns starred songs, albums and artists.
    /// - Parameter musicFolderId: Only return results from the music folder with the given ID.
    /// - Returns: Returns a `StarredResponse` element with a nested `starred` element on success.
    public func getStarred(musicFolderId: String? = nil) async throws -> StarredResponse {
        var params = [String: String]()
        if let musicFolderId = musicFolderId {
            params["musicFolderId"] = musicFolderId
        }
        return try await request(path: "getStarred", params: params)
    }
    
    /// Similar to getStarred, but organizes music according to ID3 tags.
    /// - Parameter musicFolderId: Only return results from the music folder with the given ID.
    /// - Returns: Returns a `StarredResponse2` element with a nested `starred2` element on success.
    public func getStarred2(musicFolderId: String? = nil) async throws -> Starred2Response {
        var params = [String: String]()
        if let musicFolderId = musicFolderId {
            params["musicFolderId"] = musicFolderId
        }
        return try await request(path: "getStarred2", params: params)
    }
    
    
    /// Returns albums, artists and songs matching the given search criteria. Supports paging through the result.
    /// - Parameters:
    ///   - query: Search query.
    ///   - artistCount: Maximum number of artists to return.
    ///   - artistOffset: Search result offset for artists. Used for paging.
    ///   - albumCount: Maximum number of albums to return.
    ///   - albumOffset: Search result offset for albums. Used for paging.
    ///   - songCount: Maximum number of songs to return.
    ///   - songOffset: Search result offset for songs. Used for paging.
    /// - Returns: Returns a `SearchResult2Response` element with a nested `searchResult2` element on success.
    public func search2(query: String, artistCount: Int? = nil, artistOffset: Int? = nil, albumCount: Int? = nil, albumOffset: Int? = nil, songCount: Int? = nil, songOffset: Int? = nil) async throws -> SearchResult2Response {
        var params = [String: Any]()
        params["query"] = query
        if let artistCount = artistCount {
            params["artistCount"] = artistCount
        }
        if let artistOffset = artistOffset {
            params["artistOffset"] = artistOffset
        }
        if let albumCount = albumCount {
            params["albumCount"] = albumCount
        }
        if let albumOffset = albumOffset {
            params["albumOffset"] = albumOffset
        }
        if let songCount = songCount {
            params["songCount"] = songCount
        }
        if let songOffset = songOffset {
            params["songOffset"] = songOffset
        }
        return try await request(path: "search2", params: params)
    }
    
    /// Similar to search2, but organizes music according to ID3 tags. Since 1.8.0
    /// - Parameters:
    ///   - query: Search query.
    ///   - artistCount: Maximum number of artists to return.
    ///   - artistOffset: Search result offset for artists. Used for paging.
    ///   - albumCount: Maximum number of albums to return.
    ///   - albumOffset: Search result offset for albums. Used for paging.
    ///   - songCount: Maximum number of songs to return.
    ///   - songOffset: Search result offset for songs. Used for paging.
    /// - Returns: Returns a `SearchResult3Response` element with a nested `searchResult3`.
    public func search3(query: String, artistCount: Int? = nil, artistOffset: Int? = nil, albumCount: Int? = nil, albumOffset: Int? = nil, songCount: Int? = nil, songOffset: Int? = nil) async throws -> SearchResult3Response {
        var params = [String: Any]()
        params["query"] = query
        if let artistCount = artistCount {
            params["artistCount"] = artistCount
        }
        if let artistOffset = artistOffset {
            params["artistOffset"] = artistOffset
        }
        if let albumCount = albumCount {
            params["albumCount"] = albumCount
        }
        if let albumOffset = albumOffset {
            params["albumOffset"] = albumOffset
        }
        if let songCount = songCount {
            params["songCount"] = songCount
        }
        if let songOffset = songOffset {
            params["songOffset"] = songOffset
        }
        return try await request(path: "search3", params: params)
    }
    
    /// Returns all playlists a user is allowed to play.
    /// - Parameter username: (Since 1.8.0) If specified, return playlists for this user rather than for the authenticated user. The authenticated user must have admin role if this parameter is used.
    /// - Returns: Returns a `PlaylistsResponse` element with a nested `playlists` element on success.
    public func getPlaylists(username: String? = nil) async throws -> PlaylistsResponse {
        var params = [String: String]()
        if let username = username {
            params["username"] = username
        }
        return try await request(path: "getPlaylists", params: params)
    }
    
    /// Returns a listing of files in a saved playlist.
    /// - Parameter id: ID of the playlist to return, as obtained by getPlaylists
    /// - Returns: Returns a `PlaylistResponse` element with a nested `playlist` element on success.
    public func getPlaylist(id: String) async throws -> PlaylistResponse {
        return try await request(path: "getPlaylist", params: ["id": id])
    }
    
    /// Creates a playlist.
    /// - Parameter name: The human-readable name of the playlist.
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    @discardableResult
    public func createPlaylist(name: String) async throws -> EmptyResponse {
        return try await request(path: "createPlaylist", params: ["name": name])
    }
    
    /// Updates a playlist.
    /// - Parameters:
    ///   - playlistId: The playlist ID.
    ///   - songId: ID of a song in the playlist. Use one songId parameter for each song in the playlist.
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    @discardableResult
    public func createPlaylist(playlistId: String, songId: [String]) async throws -> EmptyResponse {
        var params = [String: Any]()
        params["playlistId"] = playlistId
        params["songId"] = songId
        return try await request(path: "createPlaylist", params: params)
    }
    
    /// Updates a playlist. Only the owner of a playlist is allowed to update it.
    /// - Parameters:
    ///   - playlistId: The playlist ID.
    ///   - name: The human-readable name of the playlist.
    ///   - comment: The playlist comment.
    ///   - `public`: true if the playlist should be visible to all users, false otherwise.
    ///   - songIdToAdd: Add this song with this ID to the playlist. Multiple parameters allowed.
    ///   - songIndexToRemove: Remove the song at this position in the playlist. Multiple parameters allowed.
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    @discardableResult
    public func updatePlaylist(playlistId: String,
                               name: String? = nil,
                               comment: String? = nil,
                               `public`: Bool? = nil,
                               songIdToAdd: [String]? = nil,
                               songIndexToRemove: [Int]? = nil) async throws -> EmptyResponse {
        var params = [String: Any]()
        params["playlistId"] = playlistId
        if let name = name {
            params["name"] = name
        }
        if let comment = comment {
            params["comment"] = comment
        }
        if let `public` = `public` {
            params["public"] = `public`
        }
        if let songIdToAdd = songIdToAdd, !songIdToAdd.isEmpty {
            params["songIdToAdd"] = songIdToAdd
        }
        if let songIndexToRemove = songIndexToRemove, !songIndexToRemove.isEmpty {
            params["songIndexToRemove"] = songIndexToRemove
        }
        return try await request(path: "updatePlaylist", params: params)
    }
    
    /// Deletes a saved playlist.
    /// - Parameter id: ID of the playlist to delete, as obtained by getPlaylists
    /// - Returns: Returns an `EmptyResponse` element on success.
    public func deletePlaylist(id: String) async throws -> EmptyResponse {
        return try await request(path: "deletePlaylist", params: ["id": id])
    }
        
    /// Streams a given media file.
    /// - Parameters:
    ///   - id: A string which uniquely identifies the file to stream.
    ///   - maxBitRate: (Since 1.2.0) If specified, the server will attempt to limit the bitrate to this value, in kilobits per second. If set to zero, no limit is imposed.
    ///   - format: (Since 1.6.0) Specifies the preferred target format (e.g., "mp3" or "flv") in case there are multiple applicable transcodings. Starting with 1.9.0 you can use the special value "raw" to disable transcoding.
    /// - Returns: Returns binary data on success
    public func stream(id: String, maxBitRate: Int? = nil, format: String? = nil) -> URL? {
        var params = [String: String]()
        params["id"] = id
        if let maxBitRate = maxBitRate {
            params["maxBitRate"] = String(maxBitRate)
        }
        if let format = format {
            params["format"] = format
        }
        return resourceURL(path: "stream", params: ["id": id], salt: id.salt)
    }
    
    /// Downloads a given media file. Similar to stream, but this method returns the original media data without transcoding or downsampling.
    /// - Parameter id: A string which uniquely identifies the file to download.
    /// - Returns: Returns binary data on success
    public func download(id: String) -> URL? {
        return resourceURL(path: "download", params: ["id": id], salt: id.salt)
    }
    
    /// Returns a cover art image.
    /// - Parameter id: The ID of a song, album or artist.
    /// - Parameter size: If specified, scale image to this size.
    /// - Returns: Returns the cover art image in binary form.
    public func getCoverArt(id: String, size: Int? = 0) -> URL? {
        var params = [String: String]()
        params["id"] = id
        if let size = size, size > 0 {
            params["size"] = String(size)
        }
        return resourceURL(path: "getCoverArt", params: params, salt: id.salt)
    }
    
    /// Searches for and returns lyrics for a given song.
    /// - Parameters:
    ///   - artist: The artist name.
    ///   - title: The song title.
    /// - Returns: Returns a `LyricsResponse` element with a nested `lyrics` element on success. The `lyrics` element is empty if no matching lyrics was found.
    public func getLyrics(artist: String? = nil, title: String?) async throws -> LyricsResponse {
        var params = [String: String]()
        if let artist = artist {
            params["artist"] = artist
        }
        if let title = title {
            params["title"] = title
        }
        return try await request(path: "getLyrics", params: params)
    }
    
    /// Returns the avatar (personal image) for a user.
    /// - Parameter username: The user in question.
    /// - Returns: Returns the avatar image in binary form.
    public func getAvatar(username: String) -> URL? {
        return resourceURL(path: "getAvatar", params: ["username": username], salt: username.salt)
    }
    
    /// Attaches a star to a song, album or artist.
    /// - Parameters:
    ///   - id: The ID of the file (song) or folder (album/artist) to star. Multiple parameters allowed.
    ///   - albumId: The ID of an album to star. Use this rather than id if the client accesses the media collection according to ID3 tags rather than file structure. Multiple parameters allowed.
    ///   - artistId: The ID of an artist to star. Use this rather than id if the client accesses the media collection according to ID3 tags rather than file structure. Multiple parameters allowed.
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    @discardableResult
    public func star(id: String? = nil, albumId: String? = nil, artistId: String? = nil) async throws -> EmptyResponse {
        var params = [String: String]()
        if let id = id {
            params["id"] = id
        }
        if let albumId = albumId {
            params["albumId"] = albumId
        }
        if let artistId = artistId {
            params["artistId"] = artistId
        }
        return try await request(path: "star", params: params)
    }
    
    /// Attaches a star to a song, album or artist.
    /// - Parameters:
    ///   - id: The ID of the file (song) or folder (album/artist) to star. Multiple parameters allowed.
    ///   - albumId: The ID of an album to star. Use this rather than id if the client accesses the media collection according to ID3 tags rather than file structure. Multiple parameters allowed.
    ///   - artistId: The ID of an artist to star. Use this rather than id if the client accesses the media collection according to ID3 tags rather than file structure. Multiple parameters allowed.
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    @discardableResult
    public func unstar(id: String? = nil, albumId: String? = nil, artistId: String? = nil) async throws -> EmptyResponse {
        var params = [String: String]()
        if let id = id {
            params["id"] = id
        }
        if let albumId = albumId {
            params["albumId"] = albumId
        }
        if let artistId = artistId {
            params["artistId"] = artistId
        }
        return try await request(path: "unstar", params: params)
    }
    
    /// Sets the rating for a music file.
    /// - Parameters:
    ///   - id: A string which uniquely identifies the file (song) or folder (album/artist) to rate.
    ///   - rating: The rating between 1 and 5 (inclusive), or 0 to remove the rating.
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    @discardableResult
    public func setRating(id: String, rating: Int) async throws -> EmptyResponse {
        var params = [String: Any]()
        params["id"] = id
        params["rating"] = rating
        return try await request(path: "setRating", params: params)
    }
    
    /// Registers the local playback of one or more media files. Typically used when playing media that is cached on the client. This operation includes the following:
    /// "Scrobbles" the media files on last.fm if the user has configured his/her last.fm credentials on the Subsonic server (Settings > Personal).
    /// Updates the play count and last played timestamp for the media files. (Since 1.11.0)
    /// Makes the media files appear in the "Now playing" page in the web app, and appear in the list of songs returned by getNowPlaying (Since 1.11.0)
    /// - Parameters:
    ///   - id: A string which uniquely identifies the file to scrobble.
    ///   - time: (Since 1.8.0) The time (in milliseconds since 1 Jan 1970) at which the song was listened to.
    ///   - submission: Whether this is a "submission" or a "now playing" notification.
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    @discardableResult
    public func scrobble(id: String, time: Int64? = nil, submission: Bool? = nil) async throws -> EmptyResponse {
        var params = [String: Any]()
        params["id"] = id
        if let time = time {
            params["time"] = time
        }
        if let submission = submission {
            params["submission"] = submission
        }
        return try await request(path: "scrobble", params: params)
    }
    
    
    /// Returns all Podcast channels the server subscribes to, and (optionally) their episodes. This method can also be used to return details for only one channel - refer to the id parameter. A typical use case for this method would be to first retrieve all channels without episodes, and then retrieve all episodes for the single channel the user selects.
    /// - Parameters:
    ///   - includeEpisodes: (Since 1.9.0) Whether to include Podcast episodes in the returned result.
    ///   - id: (Since 1.9.0) If specified, only return the Podcast channel with this ID.
    /// - Returns: Returns a `PodcastsResponse` element with a nested `podcasts` element on success.
    public func getPodcasts(includeEpisodes: Bool? = nil, id: String? = nil) async throws -> PodcastsResponse {
        var params = [String: Any]()
        if let includeEpisodes = includeEpisodes {
            params["includeEpisodes"] = includeEpisodes
        }
        if let id = id {
            params["id"] = id
        }
        return try await request(path: "getPodcasts", params: params)
    }
    
    /// Returns the most recently published Podcast episodes.
    /// - Parameter count: The maximum number of episodes to return.
    /// - Returns: Returns a `NewestPodcastsResponse` element with a nested `newestPodcasts` element on success.
    public func getNewestPodcasts(count: Int = 20) async throws -> NewestPodcastsResponse {
        return try await request(path: "getNewestPodcasts", params: ["count": count])
    }
    
    /// Requests the server to check for new Podcast episodes. Note: The user must be authorized for Podcast administration (see Settings > Users > User is allowed to administrate Podcasts).
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    public func refreshPodcasts() async throws -> EmptyResponse {
        return try await request(path: "refreshPodcasts")
    }
    
    /// Adds a new Podcast channel. Note: The user must be authorized for Podcast administration (see Settings > Users > User is allowed to administrate Podcasts).
    /// - Parameter url: The URL of the Podcast to add.
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    public func createPodcastChannel(url: String) async throws -> EmptyResponse {
        return try await request(path: "createPodcastChannel", params: ["url": url])
    }
    
    /// Deletes a Podcast channel. Note: The user must be authorized for Podcast administration (see Settings > Users > User is allowed to administrate Podcasts).
    /// - Parameter id: The ID of the Podcast channel to delete.
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    public func deletePodcastChannel(id: String) async throws -> EmptyResponse {
        return try await request(path: "deletePodcastChannel", params: ["id": id])
    }
    
    /// Deletes a Podcast episode. Note: The user must be authorized for Podcast administration (see Settings > Users > User is allowed to administrate Podcasts).
    /// - Parameter id: The ID of the Podcast episode to delete.
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    public func deletePodcastEpisode(id: String) async throws -> EmptyResponse {
        return try await request(path: "deletePodcastEpisode", params: ["id": id])
    }
    
    /// Request the server to start downloading a given Podcast episode. Note: The user must be authorized for Podcast administration (see Settings > Users > User is allowed to administrate Podcasts).
    /// - Parameter id: The ID of the Podcast episode to download.
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    public func downloadPodcastEpisode(id: String) async throws -> EmptyResponse {
        return try await request(path: "downloadPodcastEpisode", params: ["id": id])
    }
    
    /// Returns all internet radio stations. Takes no extra parameters.
    /// - Returns: Returns a   `InternetRadioStationsResponse` element with a nested `internetRadioStations` element on success.
    public func getInternetRadioStations() async throws -> EmptyResponse {
        return try await request(path: "getInternetRadioStations")
    }
    
    /// Get details about a given user, including which authorization roles and folder access it has. Can be used to enable/disable certain features in the client, such as jukebox control.
    /// - Parameter username: The name of the user to retrieve. You can only retrieve your own user unless you have admin privileges.
    /// - Returns: Returns a `UserResponse` element with a nested `user` element on success.
    public func getUser(username: String) async throws -> UserResponse {
        return try await request(path: "getUser", params: ["username": username])
    }
    
    /// Get details about all users, including which authorization roles and folder access they have. Only users with admin privileges are allowed to call this method.
    /// - Returns: Returns a `UsersResponse` element with a nested `users` element on success.
    public func getUsers() async throws -> UsersResponse {
        return try await request(path: "getUsers")
    }
    
    /// Creates a new Subsonic user, using the following parameters:
    /// - Parameters:
    ///   - username: The name of the new user.
    ///   - password: The password of the new user, either in clear text of hex-encoded (see above).
    ///   - email: The email address of the new user.
    ///   - ldapAuthenticated: Whether the user is authenicated in LDAP.
    ///   - adminRole: Whether the user is administrator.
    ///   - settingsRole: Whether the user is allowed to change personal settings and password.
    ///   - streamRole: Whether the user is allowed to play files.
    ///   - jukeboxRole: Whether the user is allowed to play files in jukebox mode.
    ///   - downloadRole: Whether the user is allowed to download files.
    ///   - uploadRole: Whether the user is allowed to upload files.
    ///   - playlistRole: Whether the user is allowed to create and delete playlists. Since 1.8.0, changing this role has no effect.
    ///   - coverArtRole: Whether the user is allowed to change cover art and tags.
    ///   - commentRole: Whether the user is allowed to create and edit comments and ratings.
    ///   - podcastRole: Whether the user is allowed to administrate Podcasts.
    ///   - shareRole: (Since 1.8.0) Whether the user is allowed to share files with anyone.
    ///   - videoConversionRole: (Since 1.15.0) Whether the user is allowed to start video conversions.
    ///   - musicFolderId: (Since 1.12.0) IDs of the music folders the user is allowed access to. Include the parameter once for each folder.
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    @discardableResult
    public func createUser(username: String,
                           password: String,
                           email: String,
                           ldapAuthenticated: Bool? = nil,
                           adminRole: Bool? = nil,
                           settingsRole: Bool? = nil,
                           streamRole: Bool? = nil,
                           jukeboxRole: Bool? = nil,
                           downloadRole: Bool? = nil,
                           uploadRole: Bool? = nil,
                           playlistRole: Bool? = nil,
                           coverArtRole: Bool? = nil,
                           commentRole: Bool? = nil,
                           podcastRole: Bool? = nil,
                           shareRole: Bool? = nil,
                           videoConversionRole: Bool? = nil,
                           musicFolderId: String? = nil) async throws -> EmptyResponse {
        var params = [String: Any]()
        params["username"] = username
        params["password"] = password
        params["email"] = email
        if let ldapAuthenticated = ldapAuthenticated {
            params["ldapAuthenticated"] = ldapAuthenticated
        }
        if let adminRole = adminRole {
            params["adminRole"] = adminRole
        }
        if let settingsRole = settingsRole {
            params["settingsRole"] = settingsRole
        }
        if let streamRole = streamRole {
            params["streamRole"] = streamRole
        }
        if let jukeboxRole = jukeboxRole {
            params["jukeboxRole"] = jukeboxRole
        }
        if let downloadRole = downloadRole {
            params["downloadRole"] = downloadRole
        }
        if let uploadRole = uploadRole {
            params["uploadRole"] = uploadRole
        }
        if let playlistRole = playlistRole {
            params["playlistRole"] = playlistRole
        }
        if let coverArtRole = coverArtRole {
            params["coverArtRole"] = coverArtRole
        }
        if let commentRole = commentRole {
            params["commentRole"] = commentRole
        }
        if let podcastRole = podcastRole {
            params["podcastRole"] = podcastRole
        }
        if let shareRole = shareRole {
            params["shareRole"] = shareRole
        }
        if let videoConversionRole = videoConversionRole {
            params["videoConversionRole"] = videoConversionRole
        }
        if let musicFolderId = musicFolderId {
            params["musicFolderId"] = musicFolderId
        }
        return try await request(path: "createUser", params: params)
    }
    
    /// Modifies an existing Subsonic user, using the following parameters:
    /// - Parameters:
    ///   - username: The name of the user.
    ///   - password: The password of the user, either in clear text of hex-encoded (see above).
    ///   - email: The email address of the user.
    ///   - ldapAuthenticated: Whether the user is authenicated in LDAP.
    ///   - adminRole: Whether the user is administrator.
    ///   - settingsRole: Whether the user is allowed to change personal settings and password.
    ///   - streamRole: Whether the user is allowed to play files.
    ///   - jukeboxRole: Whether the user is allowed to play files in jukebox mode.
    ///   - downloadRole: Whether the user is allowed to download files.
    ///   - uploadRole: Whether the user is allowed to upload files.
    ///   - playlistRole: Whether the user is allowed to create and delete playlists. Since 1.8.0, changing this role has no effect.
    ///   - coverArtRole: Whether the user is allowed to change cover art and tags.
    ///   - commentRole: Whether the user is allowed to create and edit comments and ratings.
    ///   - podcastRole: Whether the user is allowed to administrate Podcasts.
    ///   - shareRole: (Since 1.8.0) Whether the user is allowed to share files with anyone.
    ///   - videoConversionRole: (Since 1.15.0) Whether the user is allowed to start video conversions.
    ///   - musicFolderId: (Since 1.12.0) IDs of the music folders the user is allowed access to. Include the parameter once for each folder.
    ///   - maxBitRate: (Since 1.13.0) The maximum bit rate (in Kbps) for the user. Audio streams of higher bit rates are automatically downsampled to this bit rate. Legal values: 0 (no limit), 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320.
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    @discardableResult
    public func updateUser(username: String,
                           password: String?,
                           email: String? = nil,
                           ldapAuthenticated: Bool? = nil,
                           adminRole: Bool? = nil,
                           settingsRole: Bool? = nil,
                           streamRole: Bool? = nil,
                           jukeboxRole: Bool? = nil,
                           downloadRole: Bool? = nil,
                           uploadRole: Bool? = nil,
                           coverArtRole: Bool? = nil,
                           commentRole: Bool? = nil,
                           podcastRole: Bool? = nil,
                           shareRole: Bool? = nil,
                           videoConversionRole: Bool? = nil,
                           musicFolderId: String? = nil,
                           maxBitRate: Int? = nil) async throws -> EmptyResponse {
        var params = [String: Any]()
        params["username"] = username
        if let password = password {
            params["password"] = password
        }
        if let email = email {
            params["email"] = email
        }
        if let ldapAuthenticated = ldapAuthenticated {
            params["ldapAuthenticated"] = ldapAuthenticated
        }
        if let adminRole = adminRole {
            params["adminRole"] = adminRole
        }
        if let settingsRole = settingsRole {
            params["settingsRole"] = settingsRole
        }
        if let streamRole = streamRole {
            params["streamRole"] = streamRole
        }
        if let jukeboxRole = jukeboxRole {
            params["jukeboxRole"] = jukeboxRole
        }
        if let downloadRole = downloadRole {
            params["downloadRole"] = downloadRole
        }
        if let uploadRole = uploadRole {
            params["uploadRole"] = uploadRole
        }
        if let coverArtRole = coverArtRole {
            params["coverArtRole"] = coverArtRole
        }
        if let commentRole = commentRole {
            params["commentRole"] = commentRole
        }
        if let podcastRole = podcastRole {
            params["podcastRole"] = podcastRole
        }
        if let shareRole = shareRole {
            params["shareRole"] = shareRole
        }
        if let videoConversionRole = videoConversionRole {
            params["videoConversionRole"] = videoConversionRole
        }
        if let musicFolderId = musicFolderId {
            params["musicFolderId"] = musicFolderId
        }
        if let maxBitRate = maxBitRate {
            params["maxBitRate"] = maxBitRate
        }
        return try await request(path: "updateUser", params: params)
    }
    
    
    /// Deletes an existing Subsonic user, using the following parameters:
    /// - Parameter username: The name of the user to delete.
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    @discardableResult
    public func deleteUser(username: String) async throws -> EmptyResponse {
        return try await request(path: "deleteUser", params: ["username": username])
    }
    
    /// Changes the password of an existing Subsonic user, using the following parameters. You can only change your own password unless you have admin privileges.
    /// - Parameters:
    ///   - username: The name of the user which should change its password.
    ///   - password: The new password of the new user, either in clear text of hex-encoded (see above).
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    @discardableResult
    public func changePassword(username: String, password: String) async throws -> EmptyResponse {
        let params = [
            "username": username,
            "password": password
        ]
        return try await request(path: "changePassword", params: params)
    }
    
    
    /// Returns all bookmarks for this user. A bookmark is a position within a certain media file.
    /// - Returns: Returns a `BookmarksResponse` element with a nested `bookmarks` element on success.
    public func getBookmarks() async throws -> BookmarksResponse {
        return try await request(path: "getBookmarks")
    }
    
    /// Returns the state of the play queue for this user (as set by savePlayQueue). This includes the tracks in the play queue, the currently playing track, and the position within this track. Typically used to allow a user to move between different clients/apps while retaining the same play queue (for instance when listening to an audio book).
    /// - Returns: Returns a <subsonic-response> element with a nested <playQueue> element on success, or an empty <subsonic-response> if no play queue has been saved
    public func getPlayQueue() async throws -> PlayQueueResponse {
        return try await request(path: "getPlayQueue")
    }
    
    /// Saves the state of the play queue for this user. This includes the tracks in the play queue, the currently playing track, and the position within this track. Typically used to allow a user to move between different clients/apps while retaining the same play queue (for instance when listening to an audio book).
    /// - Parameters:
    ///   - id: ID of a song in the play queue. Use one id parameter for each song in the play queue.
    ///   - current: The ID of the current playing song.
    ///   - position: The position in milliseconds within the currently playing song.
    /// - Returns: Returns an empty `EmptyResponse` element on success.
    @discardableResult
    public func savePlayQueue(id: [String], current: String? = nil, position: Int64? = nil) async throws -> EmptyResponse {
        var params = [String: Any]()
        params["id"] = id
        if let current = current {
            params["current"] = current
        }
        if let position = position {
            params["position"] = position
        }
        return try await request(path: "savePlayQueue", params: params)
    }
}

extension SubsonicClient {
    
    func request<Value: Response>(path: String,
                                   method: HTTPMethod = .get,
                                   params: [String: Any] = [:],
                                   headers: HTTPHeaders? = nil) async throws -> Value {
        var parameters = params
        parameters["u"] = username
        parameters["t"] = (password + salt).md5
        parameters["s"] = salt
        parameters["c"] = clientName
        parameters["v"] = version
        parameters["f"] = "json"
        
        let url = baseURL.appendingPathComponent(path)
        let response = AF.request(url, method: method, parameters: parameters, headers: headers).serializingData()
        
        let result = await response.result
        switch result {
        case .success(let data):
            if SubsonicClient.debug {
                print(String(data: data, encoding: .utf8) ?? "")
                if let url = await response.response.request?.url {
                    print(url)
                }
            }
            let value = try JSONDecoder().decode(SubsonicResponse<Value>.self, from: data)
            return value.response
        case .failure(let error):
            throw error
        }
    }
    
    func resourceURL(path: String, params: [String: String], salt: String) -> URL? {
        var parameters = params
        parameters["u"] = username
        parameters["t"] = (password + salt).md5
        parameters["s"] = salt
        parameters["c"] = clientName
        parameters["v"] = version
        parameters["f"] = "json"
        let url = baseURL.appendingPathComponent(path)
        do {
            let request = try URLRequest(url: url, method: .get)
            return try URLEncoding.default.encode(request, with: parameters).url
        } catch {
            return nil
        }
    }
}

