import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CMMap extends StatefulWidget {
  const CMMap({super.key});

  @override
  State<CMMap> createState() => _CMMapState();
}

class _CMMapState extends State<CMMap> {
  final Set<Marker> _markers = {};
  late BitmapDescriptor customIcon;
  // LatLng? _selectedLocation;
  // ignore: unused_field
  String _locationName = '';
  // ignore: unused_field
  double _latitude = 0;
  // ignore: unused_field
  double _longitude = 0;
  // ignore: unused_field
  String _sido = '';
  // ignore: unused_field
  String _gugun = '';

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(30, 40)), 'assets/flower_marker.png')
        .then((icon) => customIcon = icon);
  }

  GoogleMapController? _mapController;

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;

    // 위치 권한 확인
    LocationPermission permission;
    bool serviceEnabled;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition();
    LatLng currentPosition = LatLng(position.latitude, position.longitude);

    // 카메라 이동
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: currentPosition, zoom: 15.0)),
    );
  }

  void _onTap(LatLng location) async {
    // Add marker
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(markerId: MarkerId('selected-location'), position: location, icon: customIcon),
      );
    });
    // Get address and show in bottom sheet
    String address = await _getAddress(location.latitude, location.longitude);
    final String apiKey = dotenv.get('GOOGLE_MAP_API_KEY');
    final String url =
        "https://maps.googleapis.com/maps/api/streetview?size=400x400&location=${location.latitude},${location.longitude}&fov=90&heading=235&pitch=10&key=$apiKey";
    // ignore: use_build_context_synchronously
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: Column(
            children: [
              SizedBox(height: 30),
              Expanded(child: SizedBox(height: 200, child: Image.network(url))),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(address),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // 저장 버튼 클릭 시, _selectedLocation 변수에 현재 선택한 위치 값을 사용할 수 있습니다.
                      _onSavePressed();
                    },
                    icon: Icon(Icons.save),
                    label: Text('해당 위치 저장'),
                  ),
                  FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.backspace),
                      label: Text('뒤로 가기'))
                ],
              ),
              SizedBox(height: 20)
            ],
          ),
        );
      },
    );
  }

  Future<String> _getAddress(double lat, double lon) async {
    final List<geocoding.Placemark> placemarks =
        await geocoding.placemarkFromCoordinates(lat, lon, localeIdentifier: 'ko');
    // if (placemarks != null && placemarks.isNotEmpty) {
    if (placemarks.isNotEmpty) {
      final geocoding.Placemark place = placemarks.first;
      final String thoroughfare = place.thoroughfare ?? '';
      final String subThoroughfare = place.subThoroughfare ?? '';
      final String locality = place.locality ?? '';
      final String subLocality = place.subLocality ?? '';
      final String administrativeArea = place.administrativeArea ?? '';
      return '$administrativeArea $locality $subLocality $thoroughfare $subThoroughfare';
    }
    return '';
  }

  // 시도, 구군 정보 따로 저장하는 과정
  // Future<String> _getSido(double lat, double lon) async {
  //   final List<geocoding.Placemark> placemarks = await geocoding
  //       .placemarkFromCoordinates(lat, lon, localeIdentifier: 'ko');
  //   if (placemarks != null && placemarks.isNotEmpty) {
  //     final geocoding.Placemark place = placemarks.first;
  //     final String administrativeArea = place.administrativeArea ?? '';
  //     return '$administrativeArea';
  //   }
  //   return '';
  // }
  Future<String> _getSido(double lat, double lon) async {
    final List<geocoding.Placemark> placemarks =
        await geocoding.placemarkFromCoordinates(lat, lon, localeIdentifier: 'ko');
    // if (placemarks != null && placemarks.isNotEmpty) {
    if (placemarks.isNotEmpty) {
      final geocoding.Placemark place = placemarks.first;
      final String administrativeArea = place.administrativeArea ?? '';
      if (administrativeArea.isNotEmpty) {
        return administrativeArea;
      }
      return '전체';
    }
    return '';
  }

  Future<String> _getGugun(double lat, double lon) async {
    final List<geocoding.Placemark> placemarks =
        await geocoding.placemarkFromCoordinates(lat, lon, localeIdentifier: 'ko');
    // if (placemarks != null && placemarks.isNotEmpty) {
    if (placemarks.isNotEmpty) {
      final geocoding.Placemark place = placemarks.first;
      final String locality = place.locality ?? '';
      final String subLocality = place.subLocality ?? '';
      if (locality.isNotEmpty) {
        return locality.trim();
      } else if (subLocality.isNotEmpty) {
        return subLocality.trim();
      } else {
        return '전체';
      }
    }
    return '';
  }

  void _onMyLocationButtonPressed() async {
    final position = await Geolocator.getCurrentPosition();
    final cameraUpdate = CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 17);
    _mapController?.animateCamera(cameraUpdate);
  }

  void _onSavePressed() async {
    final selectedMarker = _markers.first;
    final latitude = selectedMarker.position.latitude;
    final longitude = selectedMarker.position.longitude;

    String address = await _getAddress(latitude, longitude);
    String sido = await _getSido(latitude, longitude);
    String gugun = await _getGugun(latitude, longitude);
    setState(() {
      _locationName = address;
      _latitude = latitude;
      _longitude = longitude;
      _sido = sido;
      _gugun = gugun;
    });

    // Show alert dialog to get the name of the location
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String locationName = '';
        return AlertDialog(
          title: Text('이 장소의 이름을 입력하세요.'),
          content: TextField(
            maxLength: 30, // 최대 글자 수
            onChanged: (value) {
              locationName = value;
            },
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                if (locationName.trim().isEmpty) {
                  // If locationName is empty, show a dialog
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('에러'),
                        content: Text('장소 이름은 1글자 이상입니다'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('확인'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Save location with the entered name
                  String message = '위치 이름: $locationName\n위도: $latitude, 경도: $longitude';
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                  Navigator.pop(context);
                  Navigator.pop(context, {
                    'locationName': locationName,
                    'latitude': latitude,
                    'longitude': longitude,
                    'sido': sido,
                    'gugun': gugun,
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 80, 170, 208),
        leading: IconButton(
          icon: Icon(Icons.navigate_before, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: RichText(
              text: TextSpan(
            children: const [
              // WidgetSpan(child: Icon(Icons.edit_note, color: Colors.white)),
              WidgetSpan(child: SizedBox(width: 5)),
              TextSpan(
                text: '지도 마커로 추가하기',
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
            ],
          )),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close, color: Colors.white)),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('지도 화면을 누르면 마커가 생겨요', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Flexible(
              flex: 2,
              child: Container(
                // height: MediaQuery.of(context).size.height / 1.5,
                // height: 550,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(37.5665, 126.9780),
                    zoom: 10,
                  ),
                  markers: _markers,
                  onTap: _onTap,
                  onMapCreated: _onMapCreated,
                  myLocationButtonEnabled: false, // 현재 위치 버튼 숨기기
                  myLocationEnabled: true, // 현재 위치 파란색 마커로 표시
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.extended(
                  onPressed: () {
                    // 저장 버튼 클릭 시, _selectedLocation 변수에 현재 선택한 위치 값을 사용할 수 있습니다.
                    _onSavePressed();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('해당 위치 저장'),
                  elevation: 15,
                ),
                FloatingActionButton(
                  onPressed: _onMyLocationButtonPressed,
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
