class MockMap {
  Map<String, Object> _mocks = Map();

  Object? getMock(String mock) {
    return _mocks[mock];
  }

  void enableMock(String mock, Object obj) {
    _mocks[mock] = obj;
  }

  void disableMock(String mock) {
    _mocks.remove(mock);
  }

  void clearMocks() {
    _mocks.clear();
  }
}
