//
//  AnimeListViewModel.swift
//  Trending AnimeTests
//
//  Created by Roy Rodriguez on 19/06/20.
//  Copyright © 2020 Roy Rodriguez. All rights reserved.
//

import XCTest
@testable import Trending_Anime

class AnimeListViewModelTests: XCTestCase {
    
    var animeListViewModel: AnimeListViewModel!

    override func setUpWithError() throws {
        animeListViewModel = AnimeListViewModel()
    }

    override func tearDownWithError() throws {
        animeListViewModel = nil
    }

    func testExample() throws {
        XCTAssertEqual(animeListViewModel.state.description, "idle")
    }

}
