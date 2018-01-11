extension MockNotificationModel: MockFactory {
    public static func makeMock() -> MockNotificationModel {
        return MockNotificationModel(objectId: String.makeRandom(),
                                     createdAt: Date.makeRandom(),
                                     isRead: Bool.makeRandom(),
                                     campaignType: String.makeRandom(),
                                     modules: MockNotificationModular.makeMock())
    }
}