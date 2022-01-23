import 'package:cognite_cdf_sdk/cognite_cdf_sdk.dart';

class MockMap {
  CDFApiClient? mockCDF;

  CDFApiClient? getCDF() {
    return mockCDF;
  }

  void enableCDF(CDFApiClient obj) {
    mockCDF = obj;
  }

  void disableMock(String mock) {
    if (mock == 'CDF') {
      mockCDF = null;
    }
  }

  void clearMocks() {
    mockCDF = null;
  }
}
