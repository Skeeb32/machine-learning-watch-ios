import XCTest
final class MomentUITests: XCTestCase {
    func testOnboardingNavigationAndSampleChat() {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        let explore = app.buttons["exploreMoment"]
        XCTAssertTrue(explore.waitForExistence(timeout: 10))
        if !explore.isHittable { app.swipeUp() }
        explore.tap()
        XCTAssertTrue(app.tabBars.buttons["Today"].waitForExistence(timeout: 10))
        for tab in ["Insights", "Patterns", "Profile", "Ask"] {
            app.tabBars.buttons[tab].tap()
            XCTAssertTrue(app.navigationBars.firstMatch.exists)
        }
        app.buttons["How was my sleep?"].tap()
        XCTAssertTrue(app.staticTexts["MOMENT · SAMPLE"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Today"].tap()
        XCTAssertTrue(app.staticTexts["You're finding your rhythm."].exists)
    }
}
