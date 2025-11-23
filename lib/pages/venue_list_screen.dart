import 'package:flutter/material.dart';
import 'package:uts_backend/helper/number_formatter.dart';
import 'package:uts_backend/model/venue_model.dart';
import 'package:uts_backend/pages/venue_detail_screen.dart';
import 'package:uts_backend/repository/venue_repository.dart';

class VenueListScreen extends StatefulWidget {
  const VenueListScreen({super.key});

  @override
  State<VenueListScreen> createState() => _VenueListScreenState();
}

class _VenueListScreenState extends State<VenueListScreen> {
  List<VenueModel> initList = [];
  List<VenueModel> listVenue = [];
  TextEditingController search = TextEditingController();

  getData() async {
    initList = await VenueRepository.getAll();
    setState(() {
      listVenue = initList;
    });
  }

  searchVenue(String keyword) {
    if (keyword == "") {
      listVenue = initList;
    } else {
      setState(() {
        listVenue =
            initList
                .where(
                  (x) =>
                      x.namaVenue.toLowerCase().contains(keyword.toLowerCase()),
                )
                .toList();
      });
    }
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(21, 116, 42, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          iconSize: 22,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Daftar Venue",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _buildSearchBar(),
          ),
        ),
      ),
      body:
          initList.isEmpty
              ? Center(child: CircularProgressIndicator())
              : listVenue.isEmpty
              ? Center(child: Text("Pencarian Anda tidak ditemukan"))
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 12, 0, 8.0),
                    child: Row(
                      children: [
                        Text(
                          "Menampilkan ",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "${listVenue.length} Venue",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8.0),
                      itemCount: listVenue.length,
                      itemBuilder: (context, index) {
                        final venue = listVenue[index];
                        return _buildVenueCard(venue);
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: search,
              decoration: InputDecoration(
                hintText: "Cari lapangan disini",
                hintStyle: TextStyle(color: Colors.grey[500]),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(width: 2, color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(width: 2, color: Colors.grey[300]!),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              searchVenue(search.text);
            },
            icon: Icon(Icons.search, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCard(VenueModel venue) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VenueDetailScreen(id: venue.venueId),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                venue.url,
                width: 115,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: SizedBox(
                height: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venue.namaVenue,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Kota ${venue.kota}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.amber[600],
                              size: 18,
                            ),
                            const SizedBox(width: 2.0),
                            Text(
                              venue.rating.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 2.0),
                            Text(
                              "(${venue.totalRating.toString()})",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mulai dari",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "${NumberFormatter.currency(int.parse(venue.hargaPerjam))}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 2),
                            Text(
                              "/ sesi",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildFilterChips() {
  //   return Container(
  //     color: Colors.white,
  //     padding: const EdgeInsets.only(bottom: 12.0),
  //     child: SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //       padding: const EdgeInsets.symmetric(horizontal: 12.0),
  //       child: Row(
  //         children: [_buildFilterChip("Filter", icon: Icons.filter_alt)],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildFilterChip(String label, {IconData? icon}) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 4.0),
  //     child: OutlinedButton(
  //       onPressed: () {
  //       },
  //       style: OutlinedButton.styleFrom(
  //         foregroundColor: Colors.grey[700],
  //         backgroundColor: Colors.white,
  //         side: BorderSide(color: Colors.grey[400]!),
  //         shape: const StadiumBorder(),
  //         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  //       ),
  //       child:
  //           (icon != null)
  //               ? Row(
  //                 children: [
  //                   Icon(icon, size: 18, color: Colors.grey[700]),
  //                   const SizedBox(width: 6),
  //                   Text(
  //                     label,
  //                     style: const TextStyle(fontWeight: FontWeight.normal),
  //                   ),
  //                 ],
  //               )
  //               : Text(
  //                 label,
  //                 style: const TextStyle(fontWeight: FontWeight.normal),
  //               ),
  //     ),
  //   );
  // }
}
