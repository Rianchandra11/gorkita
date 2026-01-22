import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:uts_backend/helper/fasilitas_icon.dart';
import 'package:uts_backend/helper/number_formatter.dart';
import 'package:uts_backend/model/venue_model.dart';
import 'package:uts_backend/pages/booking/choose_booking_schedule_screen.dart';
import 'package:uts_backend/repository/venue_repository.dart';

class VenueDetailScreen extends StatefulWidget {
  final int id;
  final Future<VenueModel> Function(int)? fetchDetails;
  const VenueDetailScreen({super.key, required this.id, this.fetchDetails});

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  VenueModel? data;

  getData() async {
    final fetch = widget.fetchDetails ?? VenueRepository.getDetails;
    data = await fetch(widget.id);
    setState(() {});
  }

  @override
  void initState() {
    getData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return data == null
        ? Scaffold(body: Center(child: CircularProgressIndicator()))
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(21, 116, 42, 1),
              foregroundColor: Colors.white,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data!.nama!,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('Kota ${data!.kota}', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 300.0,
                      viewportFraction: 1,
                      autoPlay: true,
                    ),
                    items: data!.linkGambar!.map((e) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            child: Image.network(
                              e,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Container(
                                      width: 110,
                                      height: 110,
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data!.nama!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          spacing: 4,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  data!.rating.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            Text("•"),
                            Text(
                              'Kota ${data!.kota}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(data!.deskripsi!, style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  _buildHoursSection(),
                  _buildFacilitiesSection(),
                  const Divider(thickness: 6, color: Color(0xFFF5F5F5)),
                  _buildLocationSection(),
                  const Divider(thickness: 6, color: Color(0xFFF5F5F5)),
                  _buildPolicySection(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            bottomNavigationBar: _buildBookingBar(context),
          );
  }

  Widget _buildHoursSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jam Operasional',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Senin - Minggu', style: TextStyle(fontSize: 16)),
              Text(data!.jamOperasional!, style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fasilitas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 12,
            children: [
              ...data!.fasilitas!.map(
                (e) => _FacilityItem(id: e.facilityId!, nama: e.nama!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lokasi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(data!.alamat!, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPolicySection() {
    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: const Text(
        'Kebijakan Pembatalan',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _buildBookingBar(BuildContext context) {
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Mulai dari',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    NumberFormatter.currency(data!.harga!),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '/ sesi',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChooseBookingScheduleScreen(
                    venueId: data!.venueId!,
                    jamOperasional: data!.jamOperasional!,
                    harga: "${data!.harga!}",
                    jumlahLapangan: data!.jumlahLapangan!,
                    namaVenue: data!.nama!,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(21, 116, 42, 1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Booking',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilityItem extends StatelessWidget {
  final int id;
  final String nama;
  const _FacilityItem({required this.id, required this.nama});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(FasilitasIcon.get(id), size: 22, color: Colors.black),
        const SizedBox(width: 12),
        Expanded(
          child: Text(nama, style: TextStyle(fontSize: 14), softWrap: true),
        ),
      ],
    );
  }
}
