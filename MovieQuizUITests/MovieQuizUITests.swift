import XCTest

final class UI_Testing_Bundle: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
    
    @MainActor
    
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    func testYesButton() {
        let firstPoster = app.images["Poster"]
        sleep(3)
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testNoButton() {
        let firstPoster = app.images["Poster"]
        sleep(3)
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testAlertGameFinish() {
        let yesButton = app.buttons["Yes"]
        XCTAssertTrue(yesButton.exists)
        XCTAssertTrue(yesButton.isHittable)
        
        for _ in 1...10 {
            yesButton.tap()
            sleep(2)
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        let alertExists = alert.waitForExistence(timeout: 5)
        XCTAssertTrue(alertExists)
        
        let alertTitle = alert.staticTexts["Этот раунд окончен!"]
        XCTAssertTrue(alertTitle.exists)
        
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }
    
    
    func testAlertDismissSimplified() {
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(3)
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        
        alert.buttons.firstMatch.tap()
        sleep(2)
        
        XCTAssertTrue(app.staticTexts["1/10"].exists)
        XCTAssertFalse(alert.exists)
    }
}
