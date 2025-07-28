import 'package:flutter/material.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng currentLocation = const LatLng(23.8103, 90.4125); // Dhaka as default
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    googlePlace = GooglePlace("YOUR_GOOGLE_MAPS_API_KEY");
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied || !serviceEnabled) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });

    mapController.animateCamera(CameraUpdate.newLatLngZoom(currentLocation, 15));
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  void setLocationFromPlaceId(String placeId) async {
    var details = await googlePlace.details.get(placeId);
    if (details != null &&
        details.result != null &&
        details.result!.geometry != null) {
      final loc = details.result!.geometry!.location!;
      final latLng = LatLng(loc.lat!, loc.lng!);

      mapController.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
      setState(() {
        predictions = [];
        searchController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Map + Location")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
            CameraPosition(target: currentLocation, zoom: 14),
            onMapCreated: (controller) => mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Material(
                  elevation: 4,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search location...",
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                    onChanged: autoCompleteSearch,
                  ),
                ),
                ...predictions.map(
                      (p) => ListTile(
                    tileColor: Colors.white,
                    title: Text(p.description ?? ""),
                    onTap: () {
                      setLocationFromPlaceId(p.placeId!);
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}